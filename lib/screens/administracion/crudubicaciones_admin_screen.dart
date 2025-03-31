import 'package:flutter/cupertino.dart'; 
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class CrudUbicaciones extends StatefulWidget {
  @override
  _CrudUbicacionesState createState() => _CrudUbicacionesState();
}

class _CrudUbicacionesState extends State<CrudUbicaciones> {
  TextEditingController _searchController = TextEditingController();
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
        ubicacion {
          id
          ciudad
          estado
          latitud
          longitud
        }
      }
    }
  """;

  void _showAddDialog(BuildContext context, RunMutation runMutation) {
    TextEditingController ciudadController = TextEditingController();
    TextEditingController estadoController = TextEditingController();

    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text('Agregar Ubicación'),
          content: Column(
            children: [
              CupertinoTextField(controller: ciudadController, placeholder: 'Ciudad'),
              SizedBox(height: 8),
              CupertinoTextField(controller: estadoController, placeholder: 'Estado'),
            ],
          ),
          actions: [
            CupertinoDialogAction(
              child: Text('Cancelar'),
              onPressed: () => Navigator.pop(context),
            ),
            CupertinoDialogAction(
              child: Icon(CupertinoIcons.check_mark_circled),
              onPressed: () {
                runMutation({
                  'ciudad': ciudadController.text,
                  'estado': estadoController.text,
                });
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final client = GraphQLProvider.of(context).value;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(middle: Text('Ubicaciones')),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Query(
            options: QueryOptions(
              document: gql(obtenerUbicacionesQuery),
            ),
            builder: (QueryResult result, {VoidCallback? refetch, FetchMore? fetchMore}) {
              if (result.isLoading) return Center(child: CupertinoActivityIndicator());
              if (result.hasException) return Center(child: Text("Error: ${result.exception.toString()}"));

              List ubicaciones = result.data?['ubicaciones'] ?? [];
              List filteredUbicaciones = searchQuery.isEmpty
                  ? ubicaciones
                  : ubicaciones.where((ubicacion) {
                      return ubicacion['ciudad']
                          .toLowerCase()
                          .contains(searchQuery.toLowerCase());
                    }).toList();

              return Column(
                children: [
                  CupertinoTextField(
                    controller: _searchController,
                    onChanged: (query) => setState(() => searchQuery = query),
                    placeholder: 'Buscar ubicaciones',
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: Mutation(
                      options: MutationOptions(
                        document: gql(crearUbicacionMutation),
                      ),
                      builder: (RunMutation runMutation, QueryResult? mutationResult) {
                        return Column(
                          children: [
                            CupertinoButton(
                              child: Text('Agregar Ubicación'),
                              onPressed: () {
                                _showAddDialog(context, runMutation);
                              },
                            ),
                            Expanded(
                              child: ListView.builder(
                                itemCount: filteredUbicaciones.length,
                                itemBuilder: (context, index) {
                                  var ubicacion = filteredUbicaciones[index];
                                  return Card(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    elevation: 4,
                                    margin: EdgeInsets.symmetric(vertical: 8),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            ubicacion['ciudad'],
                                            style: CupertinoTheme.of(context)
                                                .textTheme
                                                .textStyle
                                                .copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(height: 8),
                                          Text('Estado: ${ubicacion['estado']}'),
                                          SizedBox(height: 8),
                                          Text('Latitud: ${ubicacion['latitud']}'),
                                          SizedBox(height: 8),
                                          Text('Longitud: ${ubicacion['longitud']}'),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      },
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
