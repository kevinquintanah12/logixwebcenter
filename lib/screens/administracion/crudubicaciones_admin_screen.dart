// lib/screens/crud_ubicaciones.dart

import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:http/http.dart' as http;

/// Helpers para parsear dinámicamente a int/double sin lanzar excepciones.
int parseInt(dynamic value, {int fallback = 0}) {
  try {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? fallback;
  } catch (_) {}
  return fallback;
}

double parseDouble(dynamic value, {double fallback = 0.0}) {
  try {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? fallback;
  } catch (_) {}
  return fallback;
}

class CrudUbicaciones extends StatefulWidget {
  @override
  _CrudUbicacionesState createState() => _CrudUbicacionesState();
}

class _CrudUbicacionesState extends State<CrudUbicaciones> {
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';

  final String obtenerUbicacionesQuery = """
    query ObtenerUbicaciones {
      ubicaciones {
        id
        ciudad
        estado
        latitud
        longitud
      }
    }
  """;

  final String crearUbicacionMutation = """
    mutation CrearUbicacion(\$ciudad: String!, \$estado: String!) {
      crearUbicacion(ciudad: \$ciudad, estado: \$estado) {
        ubicacion { id ciudad estado latitud longitud }
      }
    }
  """;

  // Helper para mostrar alertas iOS centradas
  void _showAlert(String title, String content) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          CupertinoDialogAction(
            child: Text('OK'),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context, VoidCallback? refetch, List<dynamic> existentes) {
    final ciudadCtrl = TextEditingController();
    final estadoCtrl = TextEditingController();
    final textFmt    = FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z ]"));

    showCupertinoDialog(
      context: context,
      builder: (_) => Mutation(
        options: MutationOptions(
          document: gql(crearUbicacionMutation),
          onCompleted: (_) {
            refetch?.call();
            Navigator.pop(context);
            _showAlert('✅ Éxito', 'Ubicación creada exitosamente.');
          },
          onError: (err) {
            _showAlert('❗ Error', 'Error al crear: ${err.toString()}');
          },
        ),
        builder: (RunMutation runMutation, QueryResult? result) {
          return CupertinoAlertDialog(
            title: Text('Agregar Ubicación'),
            content: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                CupertinoTextField(
                  controller: ciudadCtrl,
                  placeholder: 'Ciudad',
                  inputFormatters: [textFmt],
                ),
                SizedBox(height: 8),
                CupertinoTextField(
                  controller: estadoCtrl,
                  placeholder: 'Estado',
                  inputFormatters: [textFmt],
                ),
              ]),
            ),
            actions: [
              CupertinoDialogAction(
                child: Text('Cancelar'),
                onPressed: () => Navigator.pop(context),
              ),
              CupertinoDialogAction(
                child: Icon(CupertinoIcons.check_mark_circled),
                onPressed: () async {
                  final ciudad = ciudadCtrl.text.trim();
                  final estado = estadoCtrl.text.trim();

                  if (ciudad.isEmpty || estado.isEmpty) {
                    Navigator.pop(context);
                    _showAlert('❗ Atención', 'Ciudad y Estado son obligatorios.');
                    return;
                  }

                  final existe = existentes.any((u) =>
                    (u['ciudad'] as String).toLowerCase() == ciudad.toLowerCase() &&
                    (u['estado'] as String).toLowerCase() == estado.toLowerCase()
                  );
                  if (existe) {
                    Navigator.pop(context);
                    _showAlert('⚠️ Atención', 'Ya existe esa ubicación.');
                    return;
                  }

                  final uri = Uri.https(
                    'nominatim.openstreetmap.org',
                    '/search',
                    {
                      'city': ciudad,
                      'state': estado,
                      'format': 'json',
                      'limit': '1',
                    },
                  );

                  List<dynamic> data = [];
                  try {
                    final resp = await http.get(uri, headers: {
                      'User-Agent': 'MiApp/1.0 (usuario@ejemplo.com)'
                    });
                    data = json.decode(resp.body) as List<dynamic>;
                  } catch (_) {
                    data = [];
                  }

                  if (data.isEmpty) {
                    Navigator.pop(context);
                    _showAlert('❗ No encontrado', "No se encontraron coordenadas para '$ciudad, $estado'.");
                    return;
                  }

                  final lat = data[0]['lat'];
                  final lon = data[0]['lon'];
                  Navigator.pop(context);
                  showCupertinoModalPopup(
                    context: context,
                    builder: (_) => CupertinoAlertDialog(
                      title: Text('📍 Ubicación encontrada'),
                      content: Text('lat: $lat\nlon: $lon'),
                      actions: [
                        CupertinoDialogAction(
                          child: Text('Crear'),
                          onPressed: () {
                            Navigator.pop(context);
                            runMutation({'ciudad': ciudad, 'estado': estado});
                          },
                        ),
                        CupertinoDialogAction(
                          child: Text('Cancelar'),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Ubicaciones'),
        trailing: Query(
          options: QueryOptions(document: gql(obtenerUbicacionesQuery)),
          builder: (result, { refetch, fetchMore }) {
            if (result.isLoading) return SizedBox();
            if (result.hasException) return Icon(CupertinoIcons.exclamationmark_triangle);
            final existentes = result.data!['ubicaciones'] as List<dynamic>;
            return GestureDetector(
              child: Icon(CupertinoIcons.add),
              onTap: () => _showAddDialog(context, refetch, existentes),
            );
          },
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Query(
            options: QueryOptions(document: gql(obtenerUbicacionesQuery)),
            builder: (result, { refetch, fetchMore }) {
              if (result.isLoading) return Center(child: CupertinoActivityIndicator());
              if (result.hasException) return Center(child: Text("Error: ${result.exception}"));

              final ubicaciones = result.data!['ubicaciones'] as List<dynamic>;
              final filtered = searchQuery.isEmpty
                  ? ubicaciones
                  : ubicaciones.where((u) =>
                      (u['ciudad'] as String).toLowerCase().contains(searchQuery.toLowerCase())
                    ).toList();

              return Column(
                children: [
                  CupertinoTextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => searchQuery = v),
                    placeholder: 'Buscar ubicaciones',
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: CupertinoColors.inactiveGray),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: Scrollbar(
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: MediaQuery.of(context).size.width > 1200
                              ? 4
                              : MediaQuery.of(context).size.width > 800 ? 3 : 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.4,
                        ),
                        itemCount: filtered.length,
                        itemBuilder: (context, i) {
                          final u = filtered[i] as Map<String, dynamic>;
                          final id = parseInt(u['id']);
                          final ciudad = u['ciudad'] as String;
                          final estado = u['estado'] as String;
                          final latitud = parseDouble(u['latitud']);
                          final longitud = parseDouble(u['longitud']);

                          return Card(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 6,
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(ciudad,
                                    style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                                        fontSize: 20, fontWeight: FontWeight.bold)),
                                SizedBox(height: 6),
                                Text('Estado: $estado'),
                                SizedBox(height: 6),
                                Text('Lat: ${latitud.toStringAsFixed(6)}'),
                                SizedBox(height: 6),
                                Text('Lng: ${longitud.toStringAsFixed(6)}'),
                                Spacer(),
                                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                                  CupertinoButton(
                                    padding: EdgeInsets.zero,
                                    child: Icon(CupertinoIcons.pencil, size: 20),
                                    onPressed: () => _showAddDialog(context, refetch, ubicaciones),
                                  ),
                                  SizedBox(width: 8),
                                  CupertinoButton(
                                    padding: EdgeInsets.zero,
                                    child: Icon(CupertinoIcons.delete, size: 20),
                                    onPressed: () => _showAddDialog(context, refetch, ubicaciones),
                                  ),
                                ]),
                              ]),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
