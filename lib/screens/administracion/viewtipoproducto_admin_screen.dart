import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class ViewTipoProductos extends StatelessWidget {
  final String viewTipoProductosQuery = """
    query ViewTipoProductos {
      tipoProductos {
        id
        nombre
        descripcion
      }
    }
  """;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Seleccionar Tipo de Producto'),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Query(
            options: QueryOptions(
              document: gql(viewTipoProductosQuery),
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
                  child: Text(
                    isInternetError
                        ? 'Parece que no tienes conexión a internet.'
                        : 'No pudimos cargar los productos en este momento.',
                    style: const TextStyle(fontSize: 14, color: CupertinoColors.systemGrey),
                    textAlign: TextAlign.center,
                  ),
                );
              }

              final List productos = result.data?['tipoProductos'] ?? [];

              if (productos.isEmpty) {
                return const Center(
                  child: Text(
                    'No hay productos disponibles.',
                    style: TextStyle(fontSize: 14, color: CupertinoColors.systemGrey),
                    textAlign: TextAlign.center,
                  ),
                );
              }

              return ListView.builder(
                itemCount: productos.length,
                itemBuilder: (context, index) {
                  final producto = productos[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(context, {
                        'id': producto['id'],
                        'nombre': producto['nombre'],
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
                              producto['nombre'],
                              style: CupertinoTheme.of(context)
                                  .textTheme
                                  .textStyle
                                  .copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Descripción: ${producto['descripcion']}',
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
