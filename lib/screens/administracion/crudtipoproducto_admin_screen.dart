import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class CrudTipoProductosAdmin extends StatefulWidget {
  @override
  _CrudTipoProductosAdminState createState() => _CrudTipoProductosAdminState();
}

class _CrudTipoProductosAdminState extends State<CrudTipoProductosAdmin> {
  List<Map<String, dynamic>> tipoProductos = [];
  TextEditingController _searchController = TextEditingController();
  String searchQuery = '';

  // Consulta que obtiene los productos con su temperatura y humedad (si existen).
  final String obtenerTipoProductosQuery = """
    query ObtenerTipoProductos {
      tipoProductos {
        id
        nombre
        descripcion
        precioBase
        temperatura {
          id
          rangoMinimo
          rangoMaximo
          tarifaExtra
        }
        humedad {
          id
          rangoMinimo
          rangoMaximo
          tarifaExtra
        }
      }
    }
  """;

  // Mutación para crear un tipo de producto.
  final String crearTipoProductoMutation = """
    mutation CrearTipoProducto(\$nombre: String!, \$descripcion: String!, \$precioBase: Float!) {
      crearTipoProducto(nombre: \$nombre, descripcion: \$descripcion, precioBase: \$precioBase) {
        tipoProducto {
          id
          nombre
          descripcion
          precioBase
        }
      }
    }
  """;

  // Mutación para crear la Temperatura de un producto.
  final String crearTemperaturaMutation = """
    mutation CrearTemperatura(\$tipoProductoId: Int!, \$rangoMinimo: Int!, \$rangoMaximo: Int!, \$tarifaExtra: Float!) {
      crearTemperatura(tipoProductoId: \$tipoProductoId, rangoMinimo: \$rangoMinimo, rangoMaximo: \$rangoMaximo, tarifaExtra: \$tarifaExtra) {
        temperatura {
          id
          rangoMinimo
          rangoMaximo
          tarifaExtra
        }
      }
    }
  """;

  // Mutación para crear la Humedad de un producto.
  final String crearHumedadMutation = """
    mutation CrearHumedad(\$tipoProductoId: Int!, \$rangoMinimo: Int!, \$rangoMaximo: Int!, \$tarifaExtra: Float!) {
      crearHumedad(tipoProductoId: \$tipoProductoId, rangoMinimo: \$rangoMinimo, rangoMaximo: \$rangoMaximo, tarifaExtra: \$tarifaExtra) {
        humedad {
          id
          rangoMinimo
          rangoMaximo
          tarifaExtra
        }
      }
    }
  """;

  // Diálogo para agregar un nuevo producto.
  void _showAddDialog(BuildContext context) {
    TextEditingController nombreController = TextEditingController();
    TextEditingController descripcionController = TextEditingController();
    TextEditingController precioController = TextEditingController();

    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text('Agregar Producto'),
          content: Column(
            children: [
              CupertinoTextField(
                controller: nombreController,
                placeholder: 'Nombre',
              ),
              SizedBox(height: 8),
              CupertinoTextField(
                controller: descripcionController,
                placeholder: 'Descripción',
              ),
              SizedBox(height: 8),
              CupertinoTextField(
                controller: precioController,
                placeholder: 'Precio Base',
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
            ],
          ),
          actions: [
            CupertinoDialogAction(
              child: Text('Cancelar'),
              onPressed: () => Navigator.pop(context),
            ),
            // Se utiliza Mutation para crear el producto.
            Mutation(
              options: MutationOptions(
                document: gql(crearTipoProductoMutation),
                onCompleted: (dynamic resultData) {
                  if (resultData != null) {
                    final tipoProducto = resultData['crearTipoProducto']['tipoProducto'];
                    setState(() {
                      tipoProductos.add({
                        'id': tipoProducto['id'],
                        'nombre': tipoProducto['nombre'],
                        'descripcion': tipoProducto['descripcion'],
                        'precioBase': tipoProducto['precioBase'],
                        // Inicialmente, no tiene temperatura ni humedad.
                        'temperatura': null,
                        'humedad': null,
                      });
                    });
                    print('Mutación crearTipoProducto completada: $tipoProducto');
                  }
                  Navigator.pop(context);
                },
                onError: (error) {
                  print('Error en mutación crearTipoProducto: ${error.toString()}');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error: ${error.toString()}")),
                  );
                },
              ),
              builder: (RunMutation runMutation, QueryResult? result) {
                return CupertinoDialogAction(
                  child: Icon(CupertinoIcons.check_mark_circled),
                  onPressed: () {
                    runMutation({
                      'nombre': nombreController.text,
                      'descripcion': descripcionController.text,
                      'precioBase': double.parse(precioController.text),
                    });
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }

  // Diálogo para ver, agregar o editar temperatura y humedad.
  void _showTempHumedadDialog(BuildContext context, Map<String, dynamic> producto) {
    // Controladores para los valores de temperatura y humedad.
    TextEditingController tempMinController = TextEditingController(
        text: producto['temperatura'] != null ? producto['temperatura']['rangoMinimo'].toString() : '');
    TextEditingController tempMaxController = TextEditingController(
        text: producto['temperatura'] != null ? producto['temperatura']['rangoMaximo'].toString() : '');
    TextEditingController tempTarifaController = TextEditingController(
        text: producto['temperatura'] != null ? producto['temperatura']['tarifaExtra'].toString() : '');
    TextEditingController humMinController = TextEditingController(
        text: producto['humedad'] != null ? producto['humedad']['rangoMinimo'].toString() : '');
    TextEditingController humMaxController = TextEditingController(
        text: producto['humedad'] != null ? producto['humedad']['rangoMaximo'].toString() : '');
    TextEditingController humTarifaController = TextEditingController(
        text: producto['humedad'] != null ? producto['humedad']['tarifaExtra'].toString() : '');

    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text('Temperatura y Humedad'),
          content: Column(
            children: [
              // Sección de Temperatura.
              Text('Temperatura', style: TextStyle(fontWeight: FontWeight.bold)),
              CupertinoTextField(
                controller: tempMinController,
                placeholder: 'Rango Mínimo',
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 8),
              CupertinoTextField(
                controller: tempMaxController,
                placeholder: 'Rango Máximo',
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 8),
              CupertinoTextField(
                controller: tempTarifaController,
                placeholder: 'Tarifa Extra',
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              SizedBox(height: 16),
              // Sección de Humedad.
              Text('Humedad', style: TextStyle(fontWeight: FontWeight.bold)),
              CupertinoTextField(
                controller: humMinController,
                placeholder: 'Rango Mínimo',
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 8),
              CupertinoTextField(
                controller: humMaxController,
                placeholder: 'Rango Máximo',
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 8),
              CupertinoTextField(
                controller: humTarifaController,
                placeholder: 'Tarifa Extra',
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
            ],
          ),
          actions: [
            CupertinoDialogAction(
              child: Text('Cancelar'),
              onPressed: () => Navigator.pop(context),
            ),
            // Botón de guardar que realiza las mutaciones o actualiza el estado.
            CupertinoDialogAction(
              child: Icon(CupertinoIcons.check_mark_circled),
              onPressed: () async {
                final client = GraphQLProvider.of(context).value;
                // Imprime en consola el id del producto y las variables que se pasarán.
                print("Producto ID: ${producto['id']}");
                print("Variables para Temperatura: rangoMinimo: ${tempMinController.text}, rangoMaximo: ${tempMaxController.text}, tarifaExtra: ${tempTarifaController.text}");
                print("Variables para Humedad: rangoMinimo: ${humMinController.text}, rangoMaximo: ${humMaxController.text}, tarifaExtra: ${humTarifaController.text}");

                // Para Temperatura: si no existe, se crea; de lo contrario se actualiza localmente.
                if (producto['temperatura'] == null) {
                  final resultTemp = await client.mutate(MutationOptions(
                    document: gql(crearTemperaturaMutation),
                    variables: {
                      'tipoProductoId': int.parse(producto['id'].toString()),
                      'rangoMinimo': int.parse(tempMinController.text),
                      'rangoMaximo': int.parse(tempMaxController.text),
                      'tarifaExtra': double.parse(tempTarifaController.text),
                    },
                  ));
                  if (resultTemp.hasException) {
                    print('Error en mutación Temperatura: ${resultTemp.exception.toString()}');
                  } else {
                    print('Resultado mutación Temperatura: ${resultTemp.data}');
                    if (resultTemp.data != null) {
                      producto['temperatura'] = resultTemp.data!['crearTemperatura']['temperatura'];
                    }
                  }
                } else {
                  // Simulación de edición: se actualiza el estado local.
                  producto['temperatura'] = {
                    'rangoMinimo': int.parse(tempMinController.text),
                    'rangoMaximo': int.parse(tempMaxController.text),
                    'tarifaExtra': double.parse(tempTarifaController.text),
                  };
                  print('Actualización local Temperatura: ${producto['temperatura']}');
                }
                // Para Humedad: si no existe, se crea; de lo contrario se actualiza localmente.
                if (producto['humedad'] == null) {
                  final resultHum = await client.mutate(MutationOptions(
                    document: gql(crearHumedadMutation),
                    variables: {
                      'tipoProductoId': int.parse(producto['id'].toString()),
                      'rangoMinimo': int.parse(humMinController.text),
                      'rangoMaximo': int.parse(humMaxController.text),
                      'tarifaExtra': double.parse(humTarifaController.text),
                    },
                  ));
                  if (resultHum.hasException) {
                    print('Error en mutación Humedad: ${resultHum.exception.toString()}');
                  } else {
                    print('Resultado mutación Humedad: ${resultHum.data}');
                    if (resultHum.data != null) {
                      producto['humedad'] = resultHum.data!['crearHumedad']['humedad'];
                    }
                  }
                } else {
                  // Simulación de edición: se actualiza el estado local.
                  producto['humedad'] = {
                    'rangoMinimo': int.parse(humMinController.text),
                    'rangoMaximo': int.parse(humMaxController.text),
                    'tarifaExtra': double.parse(humTarifaController.text),
                  };
                  print('Actualización local Humedad: ${producto['humedad']}');
                }
                setState(() {});
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  // Diálogo para editar el producto (nombre, descripción y precio base).
  void _showEditProductDialog(BuildContext context, Map<String, dynamic> producto) {
    TextEditingController nombreController = TextEditingController(text: producto['nombre']);
    TextEditingController descripcionController = TextEditingController(text: producto['descripcion']);
    TextEditingController precioController = TextEditingController(
        text: producto['precioBase'] is String
            ? producto['precioBase']
            : (producto['precioBase'] as num).toString());

    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text('Editar Producto'),
          content: Column(
            children: [
              CupertinoTextField(
                controller: nombreController,
                placeholder: 'Nombre',
              ),
              SizedBox(height: 8),
              CupertinoTextField(
                controller: descripcionController,
                placeholder: 'Descripción',
              ),
              SizedBox(height: 8),
              CupertinoTextField(
                controller: precioController,
                placeholder: 'Precio Base',
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
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
                setState(() {
                  producto['nombre'] = nombreController.text;
                  producto['descripcion'] = descripcionController.text;
                  producto['precioBase'] = double.tryParse(precioController.text) ?? producto['precioBase'];
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
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Tipos de Productos'),
        trailing: GestureDetector(
          child: Icon(CupertinoIcons.add),
          onTap: () => _showAddDialog(context),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Query(
            options: QueryOptions(document: gql(obtenerTipoProductosQuery)),
            builder: (QueryResult result, {VoidCallback? refetch, FetchMore? fetchMore}) {
              if (result.isLoading) {
                return Center(child: CupertinoActivityIndicator());
              }
              if (result.hasException) {
                print('Error en Query obtenerTipoProductos: ${result.exception.toString()}');
                return Center(child: Text("Error: ${result.exception.toString()}"));
              }

              List productos = result.data?['tipoProductos'] ?? [];
              List filteredProductos = searchQuery.isEmpty
                  ? productos
                  : productos.where((producto) {
                      final nombre = producto['nombre'] as String;
                      return nombre.toLowerCase().contains(searchQuery.toLowerCase());
                    }).toList();

              return Column(
                children: [
                  CupertinoTextField(
                    controller: _searchController,
                    onChanged: (query) {
                      setState(() {
                        searchQuery = query;
                      });
                    },
                    placeholder: 'Buscar productos',
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: CupertinoColors.inactiveGray),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: CupertinoScrollbar(
                      child: ListView.builder(
                        itemCount: filteredProductos.length,
                        itemBuilder: (context, index) {
                          var producto = filteredProductos[index];
                          double precio;
                          if (producto['precioBase'] is String) {
                            precio = double.tryParse(producto['precioBase']) ?? 0.0;
                          } else if (producto['precioBase'] is num) {
                            precio = (producto['precioBase'] as num).toDouble();
                          } else {
                            precio = 0.0;
                          }
                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 4,
                            margin: EdgeInsets.symmetric(vertical: 8),
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
                                  SizedBox(height: 8),
                                  Text('Precio base: \$${precio.toStringAsFixed(2)}'),
                                  SizedBox(height: 8),
                                  Text('Descripción: ${producto['descripcion'] ?? ""}'),
                                  if (producto['temperatura'] != null)
                                    Text(
                                      'Temperatura: ${producto['temperatura']['rangoMinimo']} - ${producto['temperatura']['rangoMaximo']} (tarifa: \$${producto['temperatura']['tarifaExtra']})',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  if (producto['humedad'] != null)
                                    Text(
                                      'Humedad: ${producto['humedad']['rangoMinimo']} - ${producto['humedad']['rangoMaximo']} (tarifa: \$${producto['humedad']['tarifaExtra']})',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      CupertinoButton(
                                        padding: EdgeInsets.zero,
                                        child: Icon(CupertinoIcons.thermometer),
                                        onPressed: () => _showTempHumedadDialog(context, producto),
                                      ),
                                      CupertinoButton(
                                        padding: EdgeInsets.zero,
                                        child: Icon(CupertinoIcons.pencil),
                                        onPressed: () => _showEditProductDialog(context, producto),
                                      ),
                                    ],
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
