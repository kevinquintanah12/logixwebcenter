import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

int parseInt(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}

class CrudCentrosDistribucion extends StatefulWidget {
  @override
  _CrudCentrosDistribucionState createState() =>
      _CrudCentrosDistribucionState();
}

class _CrudCentrosDistribucionState extends State<CrudCentrosDistribucion> {
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';

  static const String obtenerCentrosQuery = """
    query ObtenerCentrosDistribucion {
      centrosDistribucion {
        id
        ubicacion { ciudad estado latitud longitud }
      }
    }
  """;

  static const String obtenerUbicacionesQuery = """
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

  static const String crearCentroMutation = """
    mutation CrearCentroDistribucion(\$ubicacionId: Int!) {
      crearCentroDistribucion(ubicacionId: \$ubicacionId) {
        centroDistribucion { id }
      }
    }
  """;

  static const String eliminarCentroMutation = """
    mutation EliminarCentroDistribucion(\$id: Int!) {
      eliminarCentroDistribucion(id: \$id) { ok }
    }
  """;

  void _showAddDialog(BuildContext context, VoidCallback? refetchCentros) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext dialogCtx) {
        int selectedIndex = 0;
        List<Map<String, dynamic>> ubicList = [];

        return StatefulBuilder(
          builder: (BuildContext ctx, StateSetter setState) {
            return Query(
              options: QueryOptions(
                document: gql(obtenerUbicacionesQuery),
                fetchPolicy: FetchPolicy.networkOnly,
              ),
              builder: (QueryResult result,
                  { VoidCallback? refetch, FetchMore? fetchMore }) {
                if (result.isLoading) {
                  return const Center(child: CupertinoActivityIndicator());
                }
                if (result.hasException || result.data == null) {
                  return CupertinoAlertDialog(
                    title: const Text('Oops'),
                    content: const Text(
                      'No fue posible cargar las ubicaciones.\nVerifica tu conexión e inténtalo de nuevo.',
                    ),
                    actions: [
                      CupertinoDialogAction(
                        child: const Text('Reintentar'),
                        onPressed: () => refetch?.call(),
                      ),
                      CupertinoDialogAction(
                        child: const Text('Cancelar'),
                        onPressed: () => Navigator.of(dialogCtx).pop(),
                      ),
                    ],
                  );
                }

                ubicList = (result.data!['ubicaciones'] as List)
                    .cast<Map<String, dynamic>>();

                return CupertinoAlertDialog(
                  title: const Text('Agregar Centro'),
                  content: SizedBox(
                    height: 200,
                    child: CupertinoPicker(
                      itemExtent: 32,
                      scrollController:
                          FixedExtentScrollController(initialItem: 0),
                      onSelectedItemChanged: (int i) {
                        setState(() => selectedIndex = i);
                      },
                      children: ubicList.map((u) {
                        final ciudad = u['ciudad'];
                        final estado = u['estado'];
                        return Center(child: Text('$ciudad, $estado'));
                      }).toList(),
                    ),
                  ),
                  actions: [
                    CupertinoDialogAction(
                      child: const Text('Cancelar'),
                      onPressed: () => Navigator.of(dialogCtx).pop(),
                    ),
                    Mutation(
                      options: MutationOptions(
                        document: gql(crearCentroMutation),
                        onCompleted: (_) {
                          refetchCentros?.call();
                          Navigator.of(dialogCtx).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('✅ Centro creado')),
                          );
                        },
                        onError: (OperationException? error) {
                          final msg = error
                                  ?.graphqlErrors
                                  .map((e) => e.message.toLowerCase())
                                  .join('; ') ??
                              '';
                          final duplicate = msg.contains('duplicate') ||
                              msg.contains('ya existe');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(duplicate
                                  ? '❗ Este centro ya existe.'
                                  : 'Error al crear el centro.'),
                            ),
                          );
                        },
                      ),
                      builder: (RunMutation runMutation, QueryResult? mutRes) {
                        final loading = mutRes?.isLoading ?? false;
                        return CupertinoDialogAction(
                          child: loading
                              ? const CupertinoActivityIndicator()
                              : const Icon(CupertinoIcons.check_mark_circled),
                          onPressed: () {
                            if (loading) return;
                            final ubicId =
                                parseInt(ubicList[selectedIndex]['id']);
                            runMutation({'ubicacionId': ubicId});
                          },
                        );
                      },
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  void _showDeleteDialog(
      BuildContext context, int centroId, VoidCallback? refetchCentros) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext dialogCtx) {
        return CupertinoAlertDialog(
          title: const Text('Eliminar Centro'),
          content: const Text('¿Seguro que deseas eliminar este centro?'),
          actions: [
            CupertinoDialogAction(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(dialogCtx).pop(),
            ),
            Mutation(
              options: MutationOptions(
                document: gql(eliminarCentroMutation),
                onCompleted: (_) {
                  refetchCentros?.call();
                  Navigator.of(dialogCtx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('🗑️ Centro eliminado')),
                  );
                },
                onError: (OperationException? error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Error al eliminar el centro.')),
                  );
                },
              ),
              builder: (RunMutation runMutation, QueryResult? mutRes) {
                final loading = mutRes?.isLoading ?? false;
                return CupertinoDialogAction(
                  child: loading
                      ? const CupertinoActivityIndicator()
                      : const Icon(CupertinoIcons.delete),
                  onPressed: () {
                    if (loading) return;
                    runMutation({'id': centroId});
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Query(
      options: QueryOptions(
        document: gql(obtenerCentrosQuery),
        fetchPolicy: FetchPolicy.networkOnly,
      ),
      builder: (QueryResult result,
          { VoidCallback? refetch, FetchMore? fetchMore }) {
        if (result.isLoading) {
          return const Center(child: CupertinoActivityIndicator());
        }
        if (result.hasException || result.data == null) {
          final linkEx = result.exception?.linkException;
          final isNetErr = linkEx is NetworkException ||
              linkEx?.originalException is SocketException;
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isNetErr
                      ? CupertinoIcons.wifi_exclamationmark
                      : CupertinoIcons.exclamationmark_circle,
                  size: 50,
                  color: CupertinoColors.systemGrey,
                ),
                const SizedBox(height: 16),
                Text(
                  isNetErr
                      ? 'Sin conexión a Internet.'
                      : 'Error al cargar centros.',
                  style: const TextStyle(
                      fontSize: 14, color: CupertinoColors.systemGrey),
                ),
                const SizedBox(height: 12),
                CupertinoButton.filled(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  onPressed: refetch,
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        final centros = (result.data!['centrosDistribucion'] as List)
            .cast<Map<String, dynamic>>();
        final filtered = searchQuery.isEmpty
            ? centros
            : centros.where((c) {
                final ciudad = c['ubicacion']['ciudad'] as String;
                return ciudad
                    .toLowerCase()
                    .contains(searchQuery.toLowerCase());
              }).toList();

        return CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            middle: const Text('Centros de Distribución'),
            trailing: GestureDetector(
              onTap: () => _showAddDialog(context, refetch),
              child: const Icon(CupertinoIcons.add),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  CupertinoTextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => searchQuery = v),
                    placeholder: 'Buscar por ciudad',
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: CupertinoColors.inactiveGray),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount:
                            MediaQuery.of(context).size.width > 800 ? 4 : 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.4,
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final centro = filtered[index];
                        final id = parseInt(centro['id']);
                        final ubic =
                            centro['ubicacion'] as Map<String, dynamic>;

                        return GestureDetector(
                          onTap: () => Navigator.of(context).pop({
                            'id': id,
                            'ciudad': ubic['ciudad'],
                            'estado': ubic['estado'],
                            'latitud': ubic['latitud'],
                            'longitud': ubic['longitud'],
                          }),
                          child: Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            elevation: 4,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    ubic['ciudad'],
                                    style:
                                        CupertinoTheme.of(context)
                                            .textTheme
                                            .textStyle
                                            .copyWith(
                                                fontSize: 16,
                                                fontWeight:
                                                    FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  Text('Estado: ${ubic['estado']}'),
                                  const SizedBox(height: 4),
                                  Text(
                                      'Lat: ${ubic['latitud']}, Lng: ${ubic['longitud']}'),
                                  Spacer(),
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: CupertinoButton(
                                      padding: EdgeInsets.zero,
                                      child: const Icon(
                                          CupertinoIcons.delete,
                                          size: 20),
                                      onPressed: () =>
                                          _showDeleteDialog(
                                              context, id, refetch),
                                    ),
                                  ),
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
            ),
          ),
        );
      },
    );
  }
}
