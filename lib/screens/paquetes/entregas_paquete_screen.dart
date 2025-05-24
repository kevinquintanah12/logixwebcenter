import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class EntregasPaqueteScreen extends StatefulWidget {
  const EntregasPaqueteScreen({Key? key}) : super(key: key);

  @override
  State<EntregasPaqueteScreen> createState() => _EntregasPaqueteScreenState();
}

class _EntregasPaqueteScreenState extends State<EntregasPaqueteScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final GlobalKey<_EntregaTabState> _pendienteKey = GlobalKey();
  final GlobalKey<_EntregaTabState> _enProcesoKey = GlobalKey();

  // Misma definición para pendientes y en proceso, con todos los campos.
  static const String queryPendiente = r'''
    query {
      entregasPorEstado(estado: "Pendiente") {
        id
        estado
        paquete {
          numeroGuia
          producto {
            description
            destinatario {
              nombre
              apellidos
              calle
              colonia
              ciudad
              codigoPostal
            }
            calculoenvio {
              origenCd { ubicacion { latitud longitud } }
              distanciaKm
            }
          }
        }
      }
    }
  ''';

  static const String queryEnProceso = r'''
    query {
      entregasPorEstado(estado: "En proceso") {
        id
        estado
        paquete {
          numeroGuia
          producto {
            description
            destinatario {
              nombre
              apellidos
              calle
              colonia
              ciudad
              codigoPostal
            }
            calculoenvio {
              origenCd { ubicacion { latitud longitud } }
              distanciaKm
            }
          }
        }
      }
    }
  ''';

  static const String queryAllChoferes = r'''
    query {
      allChoferes { id nombre apellidos }
    }
  ''';

  static const String queryGetCamiones = r'''
    query {
      camiones { id marca modelo }
    }
  ''';

  static const String mutationAsignarRuta = r'''
    mutation AsignarRuta(
      $entregaId: Int!, $distancia: Float!, $prioridad: Int!,
      $conductorId: Int!, $vehiculoId: Int!,
      $fechaInicio: DateTime!, $fechaFin: DateTime!
    ) {
      crearRuta(
        entregaId: $entregaId, distancia: $distancia, prioridad: $prioridad,
        conductorId: $conductorId, vehiculoId: $vehiculoId,
        fechaInicio: $fechaInicio, fechaFin: $fechaFin, estado: "por hacer"
      ) { ruta { id } }
    }
  ''';

  static const String mutationActualizarEstado = r'''
    mutation ActualizarEstadoEntrega($entregaId: Int!, $estado: String!) {
      actualizarEstadoEntrega(entregaId: $entregaId, estado: $estado) {
        entrega { id estado }
      }
    }
  ''';

  double _deg2rad(double deg) => deg * (pi / 180);

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371;
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(lat1)) * cos(_deg2rad(lat2)) *
            sin(dLon / 2) * sin(dLon / 2);
    return R * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  int computePriority(double km) {
    if (km < 50) return 1;
    if (km < 150) return 2;
    return 3;
  }

  double _parseCoord(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0.0;
    return 0.0;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this)
      ..addListener(() {
        if (!_tabController.indexIsChanging) {
          if (_tabController.index == 0) {
            _pendienteKey.currentState?.refetchData();
          } else {
            _enProcesoKey.currentState?.refetchData();
          }
        }
      });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void showAsignarRutaDialog(BuildContext context, Map<String, dynamic> entrega) {
    final prod = entrega['paquete']['producto'] as Map<String, dynamic>?;
    double distance = 0;
    if (prod != null) {
      final dest = prod['destinatario'] as Map<String, dynamic>?;
      final orig = prod['calculoenvio']?['origenCd']?['ubicacion'] as Map<String, dynamic>?;
      if (dest != null && orig != null) {
        distance = calculateDistance(
          _parseCoord(orig['latitud']),
          _parseCoord(orig['longitud']),
          _parseCoord(dest['latitud']),
          _parseCoord(dest['longitud']),
        );
      } else {
        final raw = prod['calculoenvio']?['distanciaKm'];
        distance = raw is num
            ? raw.toDouble()
            : (raw is String ? double.tryParse(raw) ?? 0 : 0);
      }
    }
    final prio = computePriority(distance);
    final fechaInicio = DateTime.now().toUtc().toIso8601String();
    final fechaFin = DateTime.now().add(const Duration(hours: 2)).toUtc().toIso8601String();

    showDialog(
      context: context,
      builder: (dialogCtx) {
        int? selectedChoferId;
        int? selectedCamionId;
        final screenWidth = MediaQuery.of(dialogCtx).size.width;
        final dialogWidth = min(screenWidth * 0.9, 600.0);

        return Center(
          child: SizedBox(
            width: dialogWidth,
            child: StatefulBuilder(
              builder: (ctx, setState) {
                return AlertDialog(
                  title: Text('Asignar Ruta #${entrega['id']}'),
                  content: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow('Distancia', '${distance.toStringAsFixed(2)} km'),
                        const SizedBox(height: 8),
                        _buildInfoRow('Prioridad', '$prio'),
                        const SizedBox(height: 16),
                        Query(
                          options: QueryOptions(document: gql(queryAllChoferes)),
                          builder: (qr, {fetchMore, refetch}) {
                            if (qr.isLoading) return const LinearProgressIndicator();
                            if (qr.hasException) return const Text('Error al cargar choferes');
                            final items = (qr.data!['allChoferes'] as List).cast<Map<String, dynamic>>();
                            return InputDecorator(
                              decoration: const InputDecoration(labelText: 'Chofer'),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<int>(
                                  isExpanded: true,
                                  value: selectedChoferId,
                                  hint: const Text('Seleccione chofer'),
                                  items: items.map((c) {
                                    return DropdownMenuItem(
                                      value: int.parse(c['id'].toString()),
                                      child: Text('${c['nombre']} ${c['apellidos']}'),
                                    );
                                  }).toList(),
                                  onChanged: (v) => setState(() => selectedChoferId = v),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        Query(
                          options: QueryOptions(document: gql(queryGetCamiones)),
                          builder: (qr, {fetchMore, refetch}) {
                            if (qr.isLoading) return const LinearProgressIndicator();
                            if (qr.hasException) return const Text('Error al cargar camiones');
                            final items = (qr.data!['camiones'] as List).cast<Map<String, dynamic>>();
                            return InputDecorator(
                              decoration: const InputDecoration(labelText: 'Camión'),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<int>(
                                  isExpanded: true,
                                  value: selectedCamionId,
                                  hint: const Text('Seleccione camión'),
                                  items: items.map((c) {
                                    return DropdownMenuItem(
                                      value: int.parse(c['id'].toString()),
                                      child: Text('${c['marca']} ${c['modelo']}'),
                                    );
                                  }).toList(),
                                  onChanged: (v) => setState(() => selectedCamionId = v),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.of(dialogCtx).pop(), child: const Text('Cancelar')),
                    Mutation(
                      options: MutationOptions(
                        document: gql(mutationAsignarRuta),
                        onCompleted: (_) {
                          final client = GraphQLProvider.of(context).value;
                          client.mutate(MutationOptions(
                            document: gql(mutationActualizarEstado),
                            variables: {
                              'entregaId': int.parse(entrega['id'].toString()),
                              'estado': 'En proceso',
                            },
                          )).then((_) {
                            Navigator.of(dialogCtx).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Ruta asignada al chofer en su app')),
                            );
                            _pendienteKey.currentState?.refetchData();
                            _enProcesoKey.currentState?.refetchData();
                          });
                        },
                      ),
                      builder: (runMutation, result) {
                        final disabled = selectedChoferId == null || selectedCamionId == null;
                        return ElevatedButton(
                          onPressed: disabled
                              ? null
                              : () => runMutation({
                                    'entregaId': int.parse(entrega['id'].toString()),
                                    'distancia': distance,
                                    'prioridad': prio,
                                    'conductorId': selectedChoferId!,
                                    'vehiculoId': selectedCamionId!,
                                    'fechaInicio': fechaInicio,
                                    'fechaFin': fechaFin,
                                  }),
                          child: const Text('Confirmar'),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text(label, style: const TextStyle(fontWeight: FontWeight.w500)), Text(value)],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Entregas de Paquetes'),
        elevation: 2,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [Tab(text: 'Pendientes'), Tab(text: 'En Proceso')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          EntregaTab(key: _pendienteKey, query: queryPendiente, onTap: showAsignarRutaDialog),
          EntregaTab(key: _enProcesoKey, query: queryEnProceso),
        ],
      ),
    );
  }
}

typedef OnEntregaTap = void Function(BuildContext context, Map<String, dynamic> entrega);

class EntregaTab extends StatefulWidget {
  final String query;
  final OnEntregaTap? onTap;
  const EntregaTab({Key? key, required this.query, this.onTap}) : super(key: key);

  @override
  State<EntregaTab> createState() => _EntregaTabState();
}

class _EntregaTabState extends State<EntregaTab> {
  VoidCallback? _refetchCallback;
  void refetchData() => _refetchCallback?.call();

  @override
  Widget build(BuildContext context) {
    return Query(
      options: QueryOptions(document: gql(widget.query), fetchPolicy: FetchPolicy.networkOnly),
      builder: (result, {fetchMore, refetch}) {
        _refetchCallback = refetch;
        if (result.hasException) return Center(child: Text('Error: ${result.exception}'));
        if (result.isLoading) return const Center(child: CircularProgressIndicator());
        final list = (result.data?['entregasPorEstado'] as List<dynamic>?) ?? [];
        if (list.isEmpty) return const Center(child: Text('No hay entregas'));
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: list.length + 1,
          itemBuilder: (_, i) {
            if (i == 0) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                child: Text(
                  'Selecciona una entrega para asignarla a un chofer y vehículo disponible.',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              );
            }
            final entrega = list[i - 1] as Map<String, dynamic>;
            final paquete = entrega['paquete'] as Map<String, dynamic>?;
            final producto = paquete?['producto'] as Map<String, dynamic>?;
            final dest = producto?['destinatario'] as Map<String, dynamic>?;
            final guia = paquete?['numeroGuia'] ?? '-';
            final direccion = dest != null
                ? '${dest['calle']}, ${dest['colonia']}, ${dest['ciudad']}'
                : 'Dirección no disponible';
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                title: Text(
                  '${entrega['estado']} a ${dest != null ? '${dest['nombre']} ${dest['apellidos']}' : 'Desconocido'}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Guía: $guia'),
                  if (producto?['description'] != null) ...[
                    const SizedBox(height: 4),
                    Text('Producto: ${producto!['description']}'),
                  ],
                  if (dest != null) ...[
                    const SizedBox(height: 4),
                    Text('Dirección: $direccion'),
                    Text('CP: ${dest['codigoPostal'] ?? '-'}'),
                  ],
                ]),
                trailing: widget.onTap != null
                    ? SizedBox(
                        width: 100,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
                          onPressed: () => widget.onTap!(context, entrega),
                          child: const Text('Asignar'),
                        ),
                      )
                    : null,
              ),
            );
          },
        );
      },
    );
  }
}
