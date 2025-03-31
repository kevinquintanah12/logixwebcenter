import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class CrudCentrosDistribucion extends StatefulWidget {
  @override
  _CrudCentrosDistribucionState createState() =>
      _CrudCentrosDistribucionState();
}

class _CrudCentrosDistribucionState extends State<CrudCentrosDistribucion> {
  TextEditingController _searchController = TextEditingController();
  String searchQuery = '';
  int? selectedUbicacionId;
  int selectedIndex = 0;

  final String obtenerCentrosDistribucionQuery = """
    query ObtenerCentrosDistribucion {
      centrosDistribucion {
        id
        ubicacion {
          ciudad
          estado
          latitud
          longitud
        }
      }
    }
  """;

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

  final String darAltaCentroDistribucionMutation = """
    mutation DarAltaCentroDistribucion(\$ubicacionId: Int!) {
      darAltaCentroDistribucion(ubicacionId: \$ubicacionId) {
        centroDistribucion {
          id
          ubicacion {
            ciudad
            estado
            latitud
            longitud
          }
        }
      }
    }
  """;

  // Diálogo para agregar un nuevo centro, que primero consulta las ubicaciones
  void _showAddDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return Query(
          options: QueryOptions(document: gql(obtenerUbicacionesQuery)),
          builder: (QueryResult result,
              {VoidCallback? refetch, FetchMore? fetchMore}) {
            if (result.isLoading) {
              return CupertinoAlertDialog(
                content: Center(child: CupertinoActivityIndicator()),
              );
            }
            if (result.hasException) {
              return CupertinoAlertDialog(
                title: Text('Error'),
                content: Text(result.exception.toString()),
                actions: [
                  CupertinoDialogAction(
                    child: Text('Cerrar'),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              );
            }

            List ubicaciones = result.data?['ubicaciones'] ?? [];
            // Si hay ubicaciones, inicializa la selección
            if (ubicaciones.isNotEmpty) {
              selectedIndex = 0;
              selectedUbicacionId =
                  int.tryParse(ubicaciones[0]['id'].toString()) ?? -1;
            }

            return CupertinoAlertDialog(
              title: Text('Agregar Centro'),
              content: Column(
                children: [
                  SizedBox(height: 8),
                  Container(
                    height: 150,
                    child: CupertinoPicker(
                      scrollController:
                          FixedExtentScrollController(initialItem: selectedIndex),
                      itemExtent: 32,
                      onSelectedItemChanged: (int index) {
                        setState(() {
                          selectedIndex = index;
                          selectedUbicacionId = int.tryParse(
                                  ubicaciones[index]['id'].toString()) ??
                              -1;
                        });
                      },
                      children: ubicaciones.map<Widget>((ubicacion) {
                        return Center(
                          child: Text(
                            '${ubicacion['ciudad']}, ${ubicacion['estado']}',
                            style: TextStyle(fontSize: 14),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
              actions: [
                CupertinoDialogAction(
                  child: Text('Cancelar', style: TextStyle(fontSize: 14)),
                  onPressed: () => Navigator.pop(context),
                ),
                Mutation(
                  options: MutationOptions(
                    document: gql(darAltaCentroDistribucionMutation),
                    onCompleted: (dynamic resultData) {
                      Navigator.pop(context);
                    },
                    onError: (error) {
                      Navigator.pop(context);
                    },
                  ),
                  builder:
                      (RunMutation runMutation, QueryResult? mutationResult) {
                    return CupertinoDialogAction(
                      child: Icon(CupertinoIcons.check_mark_circled),
                      onPressed: () {
                        if (selectedUbicacionId != null) {
                          runMutation({'ubicacionId': selectedUbicacionId});
                        }
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
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Centros Distribución'),
        trailing: GestureDetector(
          child: Icon(CupertinoIcons.add),
          onTap: () => _showAddDialog(context),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Query(
            options:
                QueryOptions(document: gql(obtenerCentrosDistribucionQuery)),
            builder:
                (QueryResult result, {VoidCallback? refetch, FetchMore? fetchMore}) {
              if (result.isLoading) {
                return Center(child: CupertinoActivityIndicator());
              }
              if (result.hasException) {
                return Center(
                    child: Text("Error: ${result.exception.toString()}"));
              }

              List centros = result.data?['centrosDistribucion'] ?? [];
              // Filtrar centros por ciudad si se ingresó texto en la búsqueda
              if (searchQuery.isNotEmpty) {
                centros = centros.where((centro) {
                  return centro['ubicacion']['ciudad']
                      .toLowerCase()
                      .contains(searchQuery.toLowerCase());
                }).toList();
              }

              return Column(
                children: [
                  CupertinoTextField(
                    controller: _searchController,
                    onChanged: (query) =>
                        setState(() => searchQuery = query),
                    placeholder: 'Buscar por ciudad',
                    padding: EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 10.0),
                    decoration: BoxDecoration(
                      border:
                          Border.all(color: CupertinoColors.inactiveGray),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: CupertinoScrollbar(
                      child: ListView.builder(
                        itemCount: centros.length,
                        itemBuilder: (context, index) {
                          var centro = centros[index];
                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 4,
                            margin: EdgeInsets.symmetric(vertical: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Centro #${centro['id']}',
                                    style: CupertinoTheme.of(context)
                                        .textTheme
                                        .textStyle
                                        .copyWith(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Ciudad: ${centro['ubicacion']['ciudad']}',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Estado: ${centro['ubicacion']['estado']}',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Latitud: ${centro['ubicacion']['latitud']}',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Longitud: ${centro['ubicacion']['longitud']}',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
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
