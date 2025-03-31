import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../../models/marca_model.dart';
import '../../models/linea_model.dart';

import '../../query/marca_query.dart';
import '../../query/linea_query.dart';
import './codigoSat_screen.dart';
import './claveUnidad_screen.dart';

class AddProductosScreen extends StatefulWidget {
  final String? productoId;
  final String? description;
  final double? precio;
  final int? marcaId;
  final int? lineaId;

  final String? linea;
  final String? marca;
  final int? claveunidad;
  final String? codigobarras;
  final int? codigosat;
  final double? descuento;
  final double? existencias;
  final String? modelo;
  final String? noidentificacion;
  final double? retencionieps;
  final double? retencionisr;
  final double? retencioniva;
  final double? stockmax;
  final double? stockmin;
  final double? trasladoieps;
  final double? trasladoiva;
  final String? url;
  final int? selectedMarca = 0 ; // O puedes poner un valor por defecto si es necesario
  final int? selectedLinea = 0; // Lo mismo para 'selectedLinea'
  

  



  const AddProductosScreen({
    Key? key,
    this.productoId,
    this.description,
    this.precio,
    this.marcaId,
    this.lineaId,
    this.marca,
    this.linea,
    this.claveunidad,
    this.codigobarras,
    this.codigosat,
    this.descuento,
    this.existencias,
    this.modelo,
    this.noidentificacion,
    this.retencionieps,
    this.retencionisr,
    this.retencioniva,
    this.stockmax,
    this.stockmin,
    this.trasladoieps,
    this.trasladoiva,
    this.url,
  }) : super(key: key);

  @override
  _AddProductosScreenState createState() => _AddProductosScreenState();
}


class _AddProductosScreenState extends State<AddProductosScreen> {
  // Controladores de texto
  int? selectedLinea;
  int? selectedMarca;
  final ValueNotifier<bool> isSaveButtonEnabled = ValueNotifier(false);
  final TextEditingController claveUnidadController = TextEditingController();
  final TextEditingController codigoBarrasController = TextEditingController();
  final TextEditingController codigoSatController = TextEditingController();
  final TextEditingController descripcionController = TextEditingController();
  final TextEditingController descuentoController = TextEditingController();
  final TextEditingController existenciasController = TextEditingController();
  final TextEditingController idProdController = TextEditingController();
  final TextEditingController lineaController = TextEditingController();
  final TextEditingController marcaController = TextEditingController();
  final TextEditingController modeloController = TextEditingController();
  final TextEditingController noIdentificacionController = TextEditingController();
  final TextEditingController precioController = TextEditingController();
  final TextEditingController stockMaxController = TextEditingController();
  final TextEditingController stockMinController = TextEditingController();
  final TextEditingController trasladoIepsController = TextEditingController();
  final TextEditingController trasladoIvaController = TextEditingController();
  final TextEditingController retencionIepsController = TextEditingController();
  final TextEditingController retencionIsrController = TextEditingController();
  final TextEditingController retencionIvaController = TextEditingController();
  final TextEditingController urlController = TextEditingController();


@override
void initState() {
  super.initState();

  try {
    selectedLinea = widget.lineaId ?? 0; // Usamos lineaId si está disponible
    selectedMarca = widget.marcaId ?? 0; // Usamos marcaId si está disponible

    // Rellenar los controladores con los datos del producto recibido
    if (widget.productoId != null) {
      idProdController.text = widget.productoId!;
    }
    if (widget.description != null) {
      descripcionController.text = widget.description!;
    }
    if (widget.precio != null) {
      if (_esNumeroValido(widget.precio)) {
        precioController.text = widget.precio!.toString();
      } else {
        _mostrarError('Precio inválido: ${widget.precio}');
      }
    }
    if (widget.claveunidad != null) {
      claveUnidadController.text = widget.claveunidad!.toString();
    }
    if (widget.codigobarras != null) {
      codigoBarrasController.text = widget.codigobarras!;
    }
    if (widget.codigosat != null) {
      if (_esNumeroValido(widget.codigosat)) {
        codigoSatController.text = widget.codigosat!.toString();
      } else {
        _mostrarError('Código SAT inválido: ${widget.codigosat}');
      }
    }
    if (widget.descuento != null) {
      if (_esNumeroValido(widget.descuento)) {
        descuentoController.text = widget.descuento!.toString();
      } else {
        _mostrarError('Descuento inválido: ${widget.descuento}');
      }
    }
    if (widget.existencias != null) {
      if (_esNumeroValido(widget.existencias)) {
        existenciasController.text = widget.existencias!.toString();
      } else {
        _mostrarError('Existencias inválidas: ${widget.existencias}');
      }
    }
    if (widget.modelo != null) {
      modeloController.text = widget.modelo!;
    }
    if (widget.noidentificacion != null) {
      noIdentificacionController.text = widget.noidentificacion!;
    }
    if (widget.retencionieps != null) {
      if (_esNumeroValido(widget.retencionieps)) {
        retencionIepsController.text = widget.retencionieps!.toString();
      } else {
        _mostrarError('Retención IEPS inválida: ${widget.retencionieps}');
      }
    }
    if (widget.retencionisr != null) {
      if (_esNumeroValido(widget.retencionisr)) {
        retencionIsrController.text = widget.retencionisr!.toString();
      } else {
        _mostrarError('Retención ISR inválida: ${widget.retencionisr}');
      }
    }
    if (widget.retencioniva != null) {
      if (_esNumeroValido(widget.retencioniva)) {
        retencionIvaController.text = widget.retencioniva!.toString();
      } else {
        _mostrarError('Retención IVA inválida: ${widget.retencioniva}');
      }
    }
    if (widget.stockmax != null) {
      if (_esNumeroValido(widget.stockmax)) {
        stockMaxController.text = widget.stockmax!.toString();
      } else {
        _mostrarError('Stock máximo inválido: ${widget.stockmax}');
      }
    }
    if (widget.stockmin != null) {
      if (_esNumeroValido(widget.stockmin)) {
        stockMinController.text = widget.stockmin!.toString();
      } else {
        _mostrarError('Stock mínimo inválido: ${widget.stockmin}');
      }
    }
    if (widget.trasladoieps != null) {
      if (_esNumeroValido(widget.trasladoieps)) {
        trasladoIepsController.text = widget.trasladoieps!.toString();
      } else {
        _mostrarError('Traslado IEPS inválido: ${widget.trasladoieps}');
      }
    }
    if (widget.trasladoiva != null) {
      if (_esNumeroValido(widget.trasladoiva)) {
        trasladoIvaController.text = widget.trasladoiva!.toString();
      } else {
        _mostrarError('Traslado IVA inválido: ${widget.trasladoiva}');
      }
    }
    if (widget.url != null) {
      urlController.text = widget.url!;
    }
  } catch (e) {
    // Aquí puedes manejar los errores generales y mostrar un mensaje al usuario
    debugPrint('Ocurrió un error al inicializar: $e');

    // Mostrar un diálogo o snackbar con el error al usuario
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al inicializar los datos: $e'),
          backgroundColor: Colors.red,
        ),
      );
    });
  }
}

// Validar si un valor es un número válido
bool _esNumeroValido(dynamic value) {
  try {
    num.parse(value.toString());
    return true;
  } catch (e) {
    return false;
  }
}

// Mostrar mensaje de error al usuario
void _mostrarError(String mensaje) {
  debugPrint(mensaje);
  WidgetsBinding.instance.addPostFrameCallback((_) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.orange,
      ),
    );
  });
}


    @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Ahora puedes acceder a GraphQLProvider de manera segura
    fetchMarcas();
    fetchLineas();
  }

  // Definir la mutación GraphQL
  final String createLinkMutation = """
    mutation CreateLink(\$claveunidad: Int!, \$codigobarras: String!, \$codigosat: Int!, \$description: String!,
                        \$descuento: Float!, \$existencias: Float!, \$idprod: Int!, \$linea: Int!, \$marca: Int!,
                        \$modelo: String!, \$noidentificacion: String!, \$precio: Float!, \$retencionieps: Float!,
                        \$retencionisr: Float!, \$retencioniva: Float!, \$stockmax: Float!, \$stockmin: Float!,
                        \$trasladoieps: Float!, \$trasladoiva: Float!, \$url: String!) {
      createLink(
        claveunidad: \$claveunidad,
        codigobarras: \$codigobarras,
        codigosat: \$codigosat,
        description: \$description,
        descuento: \$descuento,
        existencias: \$existencias,
        idprod: \$idprod,
        linea: \$linea,
        marca: \$marca,
        modelo: \$modelo,
        noidentificacion: \$noidentificacion,
        precio: \$precio,
        retencionieps: \$retencionieps,
        retencionisr: \$retencionisr,
        retencioniva: \$retencioniva,
        stockmax: \$stockmax,
        stockmin: \$stockmin,
        trasladoieps: \$trasladoieps,
        trasladoiva: \$trasladoiva,
        url: \$url
      ) {
        id
        description
        precio
        url
      }
    }
  """;


  List<MarcaModel> marcas = [];
  List<LineaModel> lineas = [];

  void fetchMarcas() async {
    final result = await GraphQLProvider.of(context).value.query(
      QueryOptions(
        document: gql("""
          query {
            marcas(search: "*") {
              id
              description
            }
          }
        """),
      ),
    );

    if (result.hasException) {
      print('Error fetching marcas: ${result.exception}');
    } else {
      setState(() {
        var marcasData = result.data?['marcas'];
        if (marcasData != null) {
          marcas = (marcasData as List)
              .map((e) => MarcaModel.fromJson(e))
              .toList();
          print('Marcas: $marcas');  // Verifica que los datos sean correctos
        } else {
          print('No marcas data found');
        }
      });
    }
  }


  void fetchLineas() async {
    final result = await GraphQLProvider.of(context).value.query(
      QueryOptions(
        document: gql("""
          query {
            lineas(search: "*") {
              id
              description
            }
          }
        """),
      ),
    );

    if (result.hasException) {
      print('Error fetching lineas: ${result.exception}');
    } else {
      setState(() {
        var lineasData = result.data?['lineas'];
        if (lineasData != null) {
          lineas = (lineasData as List)
              .map((e) => LineaModel.fromJson(e))
              .toList();
          print('Lineas: $lineas');
        } else {
          print('No lineas data found');
        }
      });
    }
  }


  




  @override
  Widget build(BuildContext context) {
    
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        
        backgroundColor: Colors.black,
          middle: Text(
            widget.productoId == null ? 'NUEVO PRODUCTO' : 'EDITAR PRODUCTO',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontFamily: 'Grandis Extended',
            ),
          ),
        trailing: GestureDetector(
          onTap: () {
            if (descripcionController.text.isNotEmpty && precioController.text.isNotEmpty) {
              _guardarProducto(context);
            }
          },
          child: const Text(
            'Guardar',
            style: TextStyle(color: CupertinoColors.activeGreen, fontFamily: 'Plus Jakarta'),
          ),
        ),
      ),
      child: SafeArea(
        child: Mutation(
          options: MutationOptions(
            document: gql(createLinkMutation),
            onCompleted: (dynamic resultData) {
              if (resultData != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Producto creado: ${resultData['createLink']['description']}")),
                );
                  Navigator.pop(context); // Regresa a la pantalla anterior
              }
            },
            onError: (error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Error al crear producto: ${error.toString()}")),
              );
            },
          ),
          builder: (RunMutation runMutation, QueryResult? result) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    
                    const SizedBox(height: 20),
                    _buildSectionTitle('Información General'),
                      Row(
                        children: [
                          Expanded(
                            child: _buildCupertinoTextField(claveUnidadController, 'Clave Unidad'),

                          ),
                          const SizedBox(width: 10),
                          IconButton(
                            icon: const Icon(Icons.search, color: Colors.white),  // Ícono de lupa con color blanco
                            onPressed: () async {
                              String? claveSeleccionada = await showClaveUnidadDialog(context);
                              if (claveSeleccionada != null) {
                                setState(() {
                                  claveUnidadController.text = claveSeleccionada; // Asigna el código al campo de texto
                                });
                              }
                            },
                            padding: EdgeInsets.zero, // Elimina el padding por defecto
                            constraints: BoxConstraints(), // Elimina las restricciones del botón
                          ),
                        ],
                      ),
                    _buildCupertinoTextField(codigoBarrasController, 'Código de Barras'),
                     Row(
                      children: [
                        Expanded(
                          child: _buildCupertinoTextField(codigoSatController, 'Código SAT'),
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          icon: const Icon(Icons.search, color: Colors.white), // Ícono de lupa con color blanco
                          onPressed: () async {
                            String? codigoSeleccionado = await showCodigoSatDialog(context);
                            if (codigoSeleccionado != null) {
                              setState(() {
                                codigoSatController.text = codigoSeleccionado; // Asigna el código al campo de texto
                              });
                            }
                          },
                          padding: EdgeInsets.zero, // Elimina el padding por defecto
                          constraints: const BoxConstraints(), // Elimina las restricciones del botón
                        ),
                      ],
                    ),



                  
                

                    _buildCupertinoTextField(descripcionController, 'Descripción'),
                    _buildCupertinoTextField(descuentoController, 'Descuento'),
                    _buildCupertinoTextField(existenciasController, 'Existencias'),
                    _buildCupertinoTextField(idProdController, 'ID Producto'),
                    _buildCupertinoDropdown(
                      selectedLinea,  // Valor seleccionado para 'Línea'
                      'Línea',        // Etiqueta
                      lineas,         // Lista de líneas
                      (int? newValue) {
                        setState(() {
                          selectedLinea = newValue;
                        });
                      },
                    ),

                    _buildCupertinoDropdown(
                      selectedMarca,  // Valor seleccionado para 'Marca'
                      'Marca',        // Etiqueta
                      marcas,         // Lista de marcas
                      (int? newValue) {
                        setState(() {
                          selectedMarca = newValue;
                        });
                      },
                    ),

                   
                    _buildCupertinoTextField(modeloController, 'Modelo'),
                    _buildCupertinoTextField(noIdentificacionController, 'No Identificación'),
                    _buildCupertinoTextField(precioController, 'Precio'),
                    _buildCupertinoTextField(urlController, 'URL'),

                    _buildSectionTitle('Stock'),
                    _buildCupertinoTextField(stockMaxController, 'Stock Máximo'),
                    _buildCupertinoTextField(stockMinController, 'Stock Mínimo'),
                    const SizedBox(height: 20),
                    _buildSectionTitle('Impuestos'),
                    _buildCupertinoTextField(retencionIepsController, 'Retención IEPS'),
                    _buildCupertinoTextField(retencionIsrController, 'Retención ISR'),
                    _buildCupertinoTextField(retencionIvaController, 'Retención IVA'),
                    _buildCupertinoTextField(trasladoIepsController, 'Traslado IEPS'),
                    _buildCupertinoTextField(trasladoIvaController, 'Traslado IVA'),

                    const SizedBox(height: 20),

                        // Botón de guardar
                    CupertinoButton.filled(
                      onPressed: () => _guardarProducto(context),
                      child: const Text('Guardar'),
                  )


                    
                  ],
                ),
              ),
              
            );
          },
        ),
      ),
      backgroundColor: Colors.black87,
      
    );
  }

  Widget _buildCupertinoTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Material(
        color: Colors.transparent, // Fondo transparente para integrarlo con otros estilos
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label, // Label flotante
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.white, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[800], // Fondo del campo
            labelStyle: const TextStyle(
              color: CupertinoColors.systemGrey,
              fontFamily: 'Plus Jakarta', // Fuente personalizada
              fontWeight: FontWeight.bold, // Negrita para el label
            ),
          ),
          style: const TextStyle(
            color: Colors.white, // Color del texto dentro del campo
            fontFamily: 'Plus Jakarta', // Fuente personalizada
            fontWeight: FontWeight.bold, // Negrita para el texto dentro del campo
          ),
        ),
      ),
    );
  }

  Widget _buildCupertinoDropdown(
    int? selectedValue, // Valor seleccionado para 'Línea'
    String label,
    List<dynamic> items,
    ValueChanged<int?> onChanged, // Maneja int? en lugar de String?
  ) {
    List<int> uniqueItems = items.map((item) => item.id as int).toSet().toList();
    int? validSelectedValue = uniqueItems.contains(selectedValue) ? selectedValue : null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Material(
        color: Colors.transparent, // Fondo transparente para integrarlo con otros estilos
        child: DropdownButtonFormField<int>(
          value: validSelectedValue, // Manejar el caso null correctamente
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.white, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[800],
            labelStyle: const TextStyle(
              color: CupertinoColors.systemGrey,
              fontFamily: 'Plus Jakarta',
              fontWeight: FontWeight.bold,
            ),
          ),
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'Plus Jakarta',
            fontWeight: FontWeight.bold,
          ),
          onChanged: (int? newValue) {
            print("ID seleccionado: $newValue");
            onChanged(newValue);
          },
          items: [
            DropdownMenuItem<int>(
              value: null,
              child: Text(
                'Elige una línea',
                style: const TextStyle(
                  color: CupertinoColors.systemGrey,
                  fontFamily: 'Plus Jakarta',
                ),
              ),
            ),
            ...uniqueItems.map((itemId) {
              final item = items.firstWhere((element) => element.id == itemId);
              return DropdownMenuItem<int>(
                value: item.id,
                child: Text(
                  item.description,
                  style: const TextStyle(
                    color: CupertinoColors.systemGrey,
                    fontFamily: 'Plus Jakarta',
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontFamily: 'Grandis Extended',

        ),
      ),
    );
  }




void _guardarProducto(BuildContext context) {
  // Lista de errores
  List<String> errores = [];

  // Validaciones
  if (descripcionController.text.isEmpty) {
    errores.add('La descripción es obligatoria.');
  }
  if (precioController.text.isEmpty || !_esNumeroValido(precioController.text)) {
    errores.add('El precio es obligatorio y debe ser un número válido.');
  }
  if (codigoBarrasController.text.isEmpty) {
    errores.add('El código de barras es obligatorio.');
  }
  if (codigoSatController.text.isEmpty || !_esNumeroValido(codigoSatController.text)) {
    errores.add('El código SAT es obligatorio y debe ser un número válido.');
  }

  if (claveUnidadController.text.isEmpty || !_esNumeroValido(claveUnidadController.text)) {
    errores.add('La clave Unidad es obligatoria y debe ser un número válido.');
  }
  if (descuentoController.text.isNotEmpty && !_esNumeroValido(descuentoController.text)) {
    errores.add('El descuento debe ser un número válido.');
  }
  if (existenciasController.text.isNotEmpty && !_esNumeroValido(existenciasController.text)) {
    errores.add('Las existencias deben ser un número válido.');
  }
  if (stockMaxController.text.isNotEmpty && !_esNumeroValido(stockMaxController.text)) {
    errores.add('El stock máximo debe ser un número válido.');
  }
  if (stockMinController.text.isNotEmpty && !_esNumeroValido(stockMinController.text)) {
    errores.add('El stock mínimo debe ser un número válido.');
  }
  if (retencionIepsController.text.isNotEmpty && !_esNumeroValido(retencionIepsController.text)) {
    errores.add('La retención IEPS debe ser un número válido.');
  }
  if (retencionIsrController.text.isNotEmpty && !_esNumeroValido(retencionIsrController.text)) {
    errores.add('La retención ISR debe ser un número válido.');
  }
  if (retencionIvaController.text.isNotEmpty && !_esNumeroValido(retencionIvaController.text)) {
    errores.add('La retención IVA debe ser un número válido.');
  }
  if (trasladoIepsController.text.isNotEmpty && !_esNumeroValido(trasladoIepsController.text)) {
    errores.add('El traslado IEPS debe ser un número válido.');
  }
  if (trasladoIvaController.text.isNotEmpty && !_esNumeroValido(trasladoIvaController.text)) {
    errores.add('El traslado IVA debe ser un número válido.');
  }

  // Mostrar errores si los hay
  if (errores.isNotEmpty) {
    _mostrarErrorMensaje(context, errores.join('\n'));
    return; // No continúa si hay errores
  }

  // Si no hay errores, procede con la lógica de guardar
  _mostrarExito(context, 'El producto ha sido guardado exitosamente.');





    // Ejecutar la mutación para guardar los datos
    MutationOptions options = MutationOptions(
      document: gql(createLinkMutation),
      variables: {
        'claveunidad': int.parse(claveUnidadController.text),
        'codigobarras': codigoBarrasController.text,
        'codigosat': int.parse(codigoSatController.text),
        'description': descripcionController.text,
        'descuento': double.parse(descuentoController.text),
        'existencias': double.tryParse(existenciasController.text) ?? 0.0,
        'idprod': int.parse(idProdController.text),
        'linea': selectedLinea ?? 0,  // Usar selectedLinea
        'marca': selectedMarca ?? 0,  // Usar selectedMarca
        
        'modelo': modeloController.text,
        'noidentificacion': noIdentificacionController.text,
        'precio': double.parse(precioController.text),
        'retencionieps': double.tryParse(retencionIepsController.text) ?? 0.0,
        'retencionisr': double.tryParse(retencionIsrController.text) ?? 0.0,
        'retencioniva': double.tryParse(retencionIvaController.text) ?? 0.0,
        'stockmax': double.tryParse(stockMaxController.text) ?? 0.0,
        'stockmin': double.tryParse(stockMinController.text) ?? 0.0,
        'trasladoieps': double.tryParse(trasladoIepsController.text) ?? 0.0,
        'trasladoiva': double.tryParse(trasladoIvaController.text) ?? 0.0,
        'url': urlController.text,
      },
      onCompleted: (resultData) {
        if (resultData != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Producto creado: ${resultData['createLink']['description']}")),
          );
        }
      },
      onError: (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al crear producto: ${error.toString()}")),
        );
        print("Error al crear producto: ${error.toString()}");
      },
    );

    GraphQLProvider.of(context).value.mutate(options);
  }
}


void _mostrarErrorMensaje(BuildContext context, String mensaje) {
  debugPrint(mensaje); // Omitir si no quieres que aparezca en la consola

  // Obtener el tamaño de la pantalla
  final screenSize = MediaQuery.of(context).size;
  final isDesktop = screenSize.width > 600; // Detectar si es escritorio

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          width: isDesktop ? 500 : null, // Ancho más grande en escritorio
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Ícono de error
              Icon(
                Icons.error_outline,
                color: Colors.red,
                size: isDesktop ? 100 : 60,
              ),
              const SizedBox(height: 20),
              // Título del diálogo
              const Text(
                '¡Error!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              // Mensaje de error
              Text(
                mensaje,
                style: TextStyle(
                  fontSize: isDesktop ? 18 : 16,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              // Botón de aceptar
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, // Fondo rojo para indicar error
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop(); // Cierra el diálogo
                },
                child: const Text(
                  'Aceptar',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
void _mostrarExito(BuildContext context, String mensaje) {
  debugPrint(mensaje); // Omitir si no quieres que aparezca en la consola

  // Obtener el tamaño de la pantalla
  final screenSize = MediaQuery.of(context).size;
  final isDesktop = screenSize.width > 600; // Detectar si es escritorio

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          width: isDesktop ? 500 : null, // Ancho más grande en escritorio
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Ícono de éxito
              Icon(
                Icons.check_circle_outline,
                color: Colors.green,
                size: isDesktop ? 100 : 60,
              ),
              const SizedBox(height: 20),
              // Título del diálogo
              const Text(
                '¡Éxito!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              // Mensaje de éxito
              Text(
                mensaje,
                style: TextStyle(
                  fontSize: isDesktop ? 18 : 16,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              // Botón de aceptar
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, // Fondo verde para éxito
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop(); // Cierra el diálogo
                  Navigator.of(context).pop(); // Regresa a la pantalla anterior
                },
                child: const Text(
                  'Aceptar',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
