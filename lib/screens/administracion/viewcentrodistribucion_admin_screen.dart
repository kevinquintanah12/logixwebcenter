import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class ViewCentrosDistribucion extends StatelessWidget {
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

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Seleccionar Centro de Distribución'),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Query(
            options: QueryOptions(
              document: gql(obtenerCentrosDistribucionQuery),
              fetchPolicy: FetchPolicy.networkOnly,
              errorPolicy: ErrorPolicy.ignore,
            ),
            builder: (QueryResult result, {VoidCallback? refetch, FetchMore? fetchMore}) {
              if (result.isLoading) {
                return const Center(child: CupertinoActivityIndicator());
              }

              if (result.hasException || result.data == null) {
                final linkException = result.exception?.linkException;
                final bool isInternetError = linkException is NetworkException ||
                    linkException?.originalException is SocketException;

                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isInternetError
                            ? CupertinoIcons.wifi_exclamationmark
                            : CupertinoIcons.exclamationmark_circle,
                        size: 50,
                        color: CupertinoColors.systemGrey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        isInternetError
                            ? 'Parece que no tienes conexión a internet.'
                            : 'No pudimos cargar los centros de distribución.',
                        style: const TextStyle(fontSize: 14, color: CupertinoColors.systemGrey),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      CupertinoButton.filled(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        onPressed: refetch,
                        child: const Text("Reintentar"),
                      ),
                    ],
                  ),
                );
              }

              final List centros = result.data?['centrosDistribucion'] ?? [];

              if (centros.isEmpty) {
                return const Center(
                  child: Text(
                    'No hay centros de distribución disponibles.',
                    style: TextStyle(fontSize: 14, color: CupertinoColors.systemGrey),
                    textAlign: TextAlign.center,
                  ),
                );
              }

              return ListView.builder(
                itemCount: centros.length,
                itemBuilder: (context, index) {
                  final centro = centros[index];
                  final ubicacion = centro['ubicacion'];
                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(context, {
                        'id': centro['id'],
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
