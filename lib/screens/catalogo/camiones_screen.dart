import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'add_camiones_screen.dart'; // Pantalla para agregar camiones

class CamionesScreen extends StatefulWidget {
  const CamionesScreen({Key? key}) : super(key: key);

  @override
  State<CamionesScreen> createState() => _CamionesScreenState();
}

class _CamionesScreenState extends State<CamionesScreen> {
  String searchQuery = '';

  static const String queryGetCamiones = r'''
    query {
      camiones {
        id
        matricula
        marca
        modelo
        capacidadCarga
        tipoVehiculo
        cumplimientoNormas
      }
    }
  ''';

  static const String actualizarCamionMutation = r'''
    mutation ActualizarCamion(
      $id: Int!,
      $matricula: String!,
      $marca: String!,
      $modelo: String!,
      $capacidadCarga: Float!,
      $tipoVehiculo: String!,
      $cumplimientoNormas: Boolean!
    ) {
      actualizarCamion(
        id: $id,
        matricula: $matricula,
        marca: $marca,
        modelo: $modelo,
        capacidadCarga: $capacidadCarga,
        tipoVehiculo: $tipoVehiculo,
        cumplimientoNormas: $cumplimientoNormas
      ) {
        camion {
          id
          matricula
        }
      }
    }
  ''';

  static const String eliminarCamionMutation = r'''
    mutation EliminarCamion($id: Int!) {
      eliminarCamion(id: $id) {
        ok
      }
    }
  ''';

  void _showEditSheet(Map<String, String> cam, VoidCallback? refetch) {
    final matriculaCtrl    = TextEditingController(text: cam['matricula']);
    final marcaCtrl        = TextEditingController(text: cam['marca']);
    final modeloCtrl       = TextEditingController(text: cam['modelo']);
    final capacidadCtrl    = TextEditingController(text: cam['capacidadCarga']);
    final tipoCtrl         = TextEditingController(text: cam['tipoVehiculo']);
    bool cumple            = cam['cumplimientoNormas'] == 'true';
    final id               = int.parse(cam['id']!);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16, right: 16, top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            const Text('Editar Camión', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            TextField(
              controller: matriculaCtrl,
              decoration: InputDecoration(labelText: 'Matrícula', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: marcaCtrl,
              decoration: InputDecoration(labelText: 'Marca', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: modeloCtrl,
              decoration: InputDecoration(labelText: 'Modelo', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: capacidadCtrl,
              decoration: InputDecoration(labelText: 'Capacidad (kg)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),

            TextField(
              controller: tipoCtrl,
              decoration: InputDecoration(labelText: 'Tipo de Vehículo', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Checkbox(value: cumple, onChanged: (v) => setState(() => cumple = v!)),
                const SizedBox(width: 8),
                const Text('Cumple normas')
              ],
            ),
            const SizedBox(height: 24),

            Mutation(
              options: MutationOptions(
                document: gql(actualizarCamionMutation),
                onCompleted: (_) {
                  Navigator.pop(context);
                  refetch?.call();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✏️ Camión actualizado')));
                },
                onError: (e) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
                },
              ),
              builder: (RunMutation run, QueryResult? result) => SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: result?.isLoading ?? false
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.save),
                  label: const Text('Guardar cambios'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: result?.isLoading ?? false
                      ? null
                      : () {
                          run({
                            'id': id,
                            'matricula': matriculaCtrl.text.trim(),
                            'marca': marcaCtrl.text.trim(),
                            'modelo': modeloCtrl.text.trim(),
                            'capacidadCarga': double.parse(capacidadCtrl.text),
                            'tipoVehiculo': tipoCtrl.text.trim(),
                            'cumplimientoNormas': cumple,
                          });
                        },
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(String id, VoidCallback? refetch) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(children: const [Icon(Icons.warning, color: Colors.red), SizedBox(width: 8), Text('Eliminar Camión')]),
        content: const Text('¿Estás seguro de que deseas eliminar este camión?'),
        actions: [
          TextButton(child: const Text('Cancelar'), onPressed: () => Navigator.pop(context)),
          ElevatedButton.icon(
            icon: const Icon(Icons.delete),
            label: const Text('Eliminar'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            onPressed: () {
              Navigator.pop(context);
              showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CupertinoActivityIndicator()));
              GraphQLProvider.of(context)
                  .value
                  .mutate(MutationOptions(document: gql(eliminarCamionMutation), variables: {'id': int.parse(id)}))
                  .then((_) {
                Navigator.pop(context);
                refetch?.call();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🗑️ Camión eliminado')));
              });
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth    = MediaQuery.of(context).size.width;
    final screenHeight   = MediaQuery.of(context).size.height;
    final screenRatio    = screenWidth / screenHeight;
    final fontSizeSearch = screenWidth > 600 ? 12.0 : 10.0;
    final iconSize       = screenRatio > 1 ? 28.0 : 24.0;

    return Query(
      options: QueryOptions(document: gql(queryGetCamiones), fetchPolicy: FetchPolicy.networkOnly),
      builder: (QueryResult result, { VoidCallback? refetch, FetchMore? fetchMore }) {
        if (result.isLoading) return const Center(child: CupertinoActivityIndicator());
        if (result.hasException || result.data == null) {
          return Center(child: Text('Error al cargar camiones.\nRevisa la consola.'));
        }

        final List camiones = result.data!['camiones'] as List;
        final filtered = camiones.where((c) {
          final mat = (c['matricula'] as String).toLowerCase();
          return mat.contains(searchQuery.toLowerCase());
        }).toList();

        return Scaffold(
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Tooltip(
                      message: 'Gestión de Camiones',
                      child: Icon(Icons.local_shipping, color: const Color(0xFF031273), size: iconSize),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: const Icon(Icons.search, color: Colors.grey),
                          hintText: 'Buscar camión',
                          hintStyle: TextStyle(color: Colors.grey, fontSize: fontSizeSearch),
                          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide(color: Colors.grey.withOpacity(0.5))),
                        ),
                        onChanged: (v) => setState(() => searchQuery = v),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      decoration: BoxDecoration(color: const Color(0xFF031273), borderRadius: BorderRadius.circular(25)),
                      child: IconButton(
                        icon: const Icon(Icons.add, color: Colors.white),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => Dialog(
                              insetPadding: EdgeInsets.zero,
                              child: SizedBox(width: screenWidth, height: screenHeight, child: const AddCamionesScreen()),
                            ),
                          ).then((_) {
                            if (refetch != null) refetch();
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final c = filtered[index] as Map<String, dynamic>;
                    final idStr = c['id'].toString();
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6, offset: const Offset(0, 4))],
                          border: Border.all(color: const Color(0xFF031273).withOpacity(0.3), width: 1),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          leading: const CircleAvatar(backgroundColor: Color(0xFF031273), child: Icon(Icons.local_shipping, color: Colors.white)),
                          title: Text(
                            c['matricula'] ?? '—',
                            style: TextStyle(fontSize: fontSizeSearch + 2, fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                          subtitle: Text(
                            '${c['marca']} ${c['modelo']} · Cap: ${c['capacidadCarga']}kg · ${c['tipoVehiculo']} · Normas: ${c['cumplimientoNormas'] ? "✓" : "✗"}',
                            style: TextStyle(fontSize: fontSizeSearch, color: Colors.black54),
                          ),
                          trailing: PopupMenuButton<String>(
                            icon: Icon(Icons.more_vert, color: Colors.grey[700]),
                            onSelected: (v) {
                              if (v == 'edit') {
                                _showEditSheet({
                                  'id': idStr,
                                  'matricula': c['matricula'],
                                  'marca': c['marca'],
                                  'modelo': c['modelo'],
                                  'capacidadCarga': c['capacidadCarga'].toString(),
                                  'tipoVehiculo': c['tipoVehiculo'],
                                  'cumplimientoNormas': c['cumplimientoNormas'].toString(),
                                }, refetch);
                              } else if (v == 'delete') {
                                _showDeleteDialog(idStr, refetch);
                              }
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(value: 'edit', child: ListTile(leading: Icon(Icons.edit, color: Colors.blue), title: Text('Editar'))),
                              PopupMenuItem(value: 'delete', child: ListTile(leading: Icon(Icons.delete, color: Colors.red), title: Text('Eliminar'))),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
