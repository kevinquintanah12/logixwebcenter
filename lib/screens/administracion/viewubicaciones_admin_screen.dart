import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class ViewUbicaciones extends StatelessWidget {
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

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Seleccionar Ubicación'),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Query(
            options: QueryOptions(
              document: gql(obtenerUbicacionesQuery),
            ),
            builder: (QueryResult result, {VoidCallback? refetch, FetchMore? fetchMore}) {
              if (result.isLoading) {
                return Center(child: CupertinoActivityIndicator());
              }
              if (result.hasException) {
                return Center(child: Text("Error: ${result.exception.toString()}"));
              }

              print("Respuesta del query: ${result.data}");

              List ubicaciones = result.data?['ubicaciones'] ?? [];

              return ListView.builder(
                itemCount: ubicaciones.length,
                itemBuilder: (context, index) {
                  var ubicacion = ubicaciones[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(context, {
                        'id': ubicacion['id'],
                        'ciudad': ubicacion['ciudad'],
                        'estado': ubicacion['estado'],
                        'latitud': ubicacion['latitud'],
                        'longitud': ubicacion['longitud'],
                      });
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8),
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
                            const SizedBox(height: 8),
                            Text(
                              'Estado: ${ubicacion['estado']}',
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Latitud: ${ubicacion['latitud']}, Longitud: ${ubicacion['longitud']}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
