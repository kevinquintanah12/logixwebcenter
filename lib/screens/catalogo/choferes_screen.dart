import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'add_choferes_screen.dart'; // Importa la pantalla de agregar chofer

class ChoferesScreen extends StatefulWidget {
  const ChoferesScreen({Key? key}) : super(key: key);

  @override
  State<ChoferesScreen> createState() => _ChoferesScreenState();
}

class _ChoferesScreenState extends State<ChoferesScreen> {
  String searchQuery = '';

  static const String queryAllChoferes = r'''
    query {
      allChoferes {
        id
        nombre
        apellidos
        rfc
        licencia
        certificaciones
        horario {
          id
          horaInicio
          horaFin
        }
      }
    }
  ''';

  static const String actualizarChoferMutation = r'''
    mutation ActualizarChofer(
      $id: Int!,
      $nombre: String!,
      $apellidos: String!,
      $rfc: String!,
      $licencia: String!,
      $certificaciones: String!
    ) {
      actualizarChofer(
        id: $id,
        nombre: $nombre,
        apellidos: $apellidos,
        rfc: $rfc,
        licencia: $licencia,
        certificaciones: $certificaciones
      ) {
        chofer {
          id
          nombre
          apellidos
          rfc
          licencia
          certificaciones
        }
      }
    }
  ''';

  static const String eliminarChoferMutation = r'''
    mutation EliminarChofer($id: Int!) {
      eliminarChofer(id: $id) {
        ok
      }
    }
  ''';

  void _showEditSheet(Map<String, String> driver, VoidCallback? refetch) {
    // Ya tenemos nombre y apellidos por separado en el map
    final nombreCtrl    = TextEditingController(text: driver['nombre']);
    final apellidosCtrl = TextEditingController(text: driver['apellidos']);
    final rfcCtrl       = TextEditingController(text: driver['rfc']);
    final licenciaCtrl  = TextEditingController(text: driver['licencia']);
    final certCtrl      = TextEditingController(text: driver['certificaciones']);
    final id             = int.parse(driver['id']!);

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
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Editar Chofer',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Nombre
            TextField(
              controller: nombreCtrl,
              decoration: InputDecoration(
                labelText: 'Nombre',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 12),

            // Apellidos
            TextField(
              controller: apellidosCtrl,
              decoration: InputDecoration(
                labelText: 'Apellidos',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 12),

            // RFC
            TextField(
              controller: rfcCtrl,
              decoration: InputDecoration(
                labelText: 'RFC',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 12),

            // Licencia
            TextField(
              controller: licenciaCtrl,
              decoration: InputDecoration(
                labelText: 'Licencia',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 12),

            // Certificaciones
            TextField(
              controller: certCtrl,
              decoration: InputDecoration(
                labelText: 'Certificaciones',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 24),

            Mutation(
              options: MutationOptions(
                document: gql(actualizarChoferMutation),
                onCompleted: (_) {
                  Navigator.pop(context);
                  refetch?.call();
                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text('✏️ Chofer actualizado')));
                },
                onError: (e) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
                },
              ),
              builder: (RunMutation run, QueryResult? result) => SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: result?.isLoading ?? false
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
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
                            'id'             : id,
                            'nombre'         : nombreCtrl.text.trim(),
                            'apellidos'      : apellidosCtrl.text.trim(),
                            'rfc'            : rfcCtrl.text.trim(),
                            'licencia'       : licenciaCtrl.text.trim(),
                            'certificaciones': certCtrl.text.trim(),
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
        title: Row(
          children: const [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Eliminar Chofer'),
          ],
        ),
        content: const Text('¿Estás seguro de que quieres eliminar este chofer?'),
        actions: [
          TextButton(child: const Text('Cancelar'), onPressed: () => Navigator.pop(context)),
          ElevatedButton.icon(
            icon: const Icon(Icons.delete),
            label: const Text('Eliminar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => const Center(child: CircularProgressIndicator()),
              );
              GraphQLProvider.of(context).value.mutate(
                MutationOptions(
                  document: gql(eliminarChoferMutation),
                  variables: {'id': int.parse(id)},
                ),
              ).then((_) {
                Navigator.pop(context);
                refetch?.call();
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text('🗑️ Chofer eliminado')));
              });
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth      = MediaQuery.of(context).size.width;
    final screenHeight     = MediaQuery.of(context).size.height;
    final screenSize       = screenWidth / screenHeight;
    final fontSizeSubtitle = screenSize > 1 ? 14.0 : 10.0;
    final iconSize         = screenSize > 1 ? 30.0 : 24.0;

    return Query(
      options: QueryOptions(
        document: gql(queryAllChoferes),
        fetchPolicy: FetchPolicy.networkOnly,
      ),
      builder: (QueryResult result, { VoidCallback? refetch, FetchMore? fetchMore }) {
        if (result.isLoading) return const Center(child: CupertinoActivityIndicator());
        if (result.hasException || result.data == null) {
          return Center(child: Text('Error al cargar choferes.\nRevisa la consola.'));
        }

        final datos    = result.data!['allChoferes'] as List;
        final filtered = datos.where((c) {
          final full = '${c['nombre']} ${c['apellidos']}'.toLowerCase();
          return full.contains(searchQuery.toLowerCase());
        }).toList();

        final Map<String, List<Map<String, String>>> grouped = {};
        for (var c in filtered) {
          final letter = c['nombre'][0].toUpperCase();
          grouped.putIfAbsent(letter, () => []).add({
            'id'             : c['id'].toString(),
            'nombre'         : c['nombre'] as String,
            'apellidos'      : c['apellidos'] as String,
            'rfc'            : c['rfc'] as String,
            'licencia'       : c['licencia'] as String,
            'certificaciones': c['certificaciones'] as String,
          });
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Choferes')),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Icon(Icons.drive_eta, color: Colors.grey, size: iconSize),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Buscar chofer',
                          hintStyle: TextStyle(color: Colors.grey, fontSize: fontSizeSubtitle),
                          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(color: Colors.grey.withOpacity(0.5)),
                          ),
                        ),
                        onChanged: (v) => setState(() => searchQuery = v),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FloatingActionButton(
                      mini: true,
                      tooltip: 'Agregar Chofer',
                      backgroundColor: const Color(0xFF031273),
                      child: Icon(Icons.add, size: iconSize, color: Colors.white),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => Dialog(
                            insetPadding: EdgeInsets.zero,
                            child: SizedBox(
                              width: screenWidth,
                              height: screenHeight,
                              child: AddChoferesScreen(),
                            ),
                          ),
                        ).then((_) {
                          if (refetch != null) refetch();
                        });
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: grouped.keys.length,
                  itemBuilder: (context, index) {
                    final letter  = grouped.keys.elementAt(index);
                    final drivers = grouped[letter]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          child: Text(
                            letter,
                            style: TextStyle(fontSize: fontSizeSubtitle, fontWeight: FontWeight.bold),
                          ),
                        ),
                        ...drivers.map((driver) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 6,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                                border: Border.all(
                                  color: const Color(0xFF031273).withOpacity(0.5),
                                  width: 1.5,
                                ),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                title: Text(
                                  '${driver["nombre"]} ${driver["apellidos"]}',
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('RFC: ${driver["rfc"]!}', style: TextStyle(fontSize: fontSizeSubtitle)),
                                    Text('Licencia: ${driver["licencia"]!}', style: TextStyle(fontSize: fontSizeSubtitle)),
                                    Text('Cert.: ${driver["certificaciones"]!}', style: TextStyle(fontSize: fontSizeSubtitle)),
                                  ],
                                ),
                                trailing: PopupMenuButton<String>(
                                  icon: Icon(Icons.more_vert, color: Colors.grey[700]),
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      _showEditSheet(driver, refetch);
                                    } else if (value == 'delete') {
                                      _showDeleteDialog(driver['id']!, refetch);
                                    }
                                  },
                                  itemBuilder: (_) => const [
                                    PopupMenuItem(
                                      value: 'edit',
                                      child: ListTile(
                                        leading: Icon(Icons.edit, color: Colors.blue),
                                        title: Text('Editar'),
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: ListTile(
                                        leading: Icon(Icons.delete, color: Colors.red),
                                        title: Text('Eliminar'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ],
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
