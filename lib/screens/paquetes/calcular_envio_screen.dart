import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:ui'; // Para efecto de desenfoque
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shop/screens/administracion/viewtipoproducto_admin_screen.dart';
import 'package:shop/screens/administracion/viewcentrodistribucion_admin_screen.dart';
import 'package:shop/screens/administracion/viewubicaciones_admin_screen.dart';
// Asegúrate de que la ruta del import sea la correcta para tu proyecto.
import 'package:shop/screens/paquetes/cotizacion_paquete_screen.dart';

class CalcularEnvioScreen extends StatefulWidget {
  @override
  _CalcularEnvioScreenState createState() => _CalcularEnvioScreenState();
}

class _CalcularEnvioScreenState extends State<CalcularEnvioScreen> {
  // Controladores para los campos
  final TextEditingController _tipoProductoController = TextEditingController();
  String? _tipoProductoId; // ID del tipo de producto seleccionado

  final TextEditingController _origenCdIdController = TextEditingController();
  String? _origenCdId; // ID del centro de distribución seleccionado

  final TextEditingController _destinoIdController = TextEditingController();
  String? _destinoId; // ID de la ubicación seleccionada

  final TextEditingController _pesoUnitarioController = TextEditingController();
  final TextEditingController _numeroPiezasController = TextEditingController();
  final TextEditingController _dimensionesLargoController = TextEditingController();
  final TextEditingController _dimensionesAnchoController = TextEditingController();
  final TextEditingController _dimensionesAltoController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();

  // Variable booleana para el envío express
  bool _envioExpress = false; // false = No, true = Sí

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text(
          'Cotizar Envío',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        trailing: GestureDetector(
          onTap: () {
            _mostrarDialogoCotizacion(context);
          },
          child: const Text(
            'Cotizar',
            style: TextStyle(color: CupertinoColors.activeBlue),
          ),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildTipoProductoField(context),
                _buildOrigenField(context),
                _buildDestinoField(context),
                _buildFloatingTextField(
                  controller: _pesoUnitarioController,
                  label: 'Peso Unitario (kg)',
                  keyboardType: TextInputType.number,
                ),
                _buildFloatingTextField(
                  controller: _numeroPiezasController,
                  label: 'Número de Piezas',
                  keyboardType: TextInputType.number,
                ),
                _buildFloatingTextField(
                  controller: _dimensionesLargoController,
                  label: 'Largo (cm)',
                  keyboardType: TextInputType.number,
                ),
                _buildFloatingTextField(
                  controller: _dimensionesAnchoController,
                  label: 'Ancho (cm)',
                  keyboardType: TextInputType.number,
                ),
                _buildFloatingTextField(
                  controller: _dimensionesAltoController,
                  label: 'Alto (cm)',
                  keyboardType: TextInputType.number,
                ),
                _buildFloatingTextField(
                  controller: _descripcionController,
                  label: 'Descripción del paquete',
                ),
                const SizedBox(height: 20),
                _buildEnvioExpressField(),
                const SizedBox(height: 30),
                CupertinoButton.filled(
                  child: const Text("Cotizar Envío"),
                  onPressed: () {
                    _mostrarDialogoCotizacion(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: Colors.grey[200],
    );
  }

  /// Widget auxiliar para mostrar un campo de selección con efecto similar a un Floating Label.
  Widget _buildSelectionField({
    required String value,
    required String placeholder,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value.isEmpty ? placeholder : value,
                style: TextStyle(
                  color: value.isEmpty ? Colors.black54 : Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Icon(CupertinoIcons.chevron_down, color: Colors.black54),
            ],
          ),
        ),
      ),
    );
  }

  // Campo de selección de Tipo de Producto
  Widget _buildTipoProductoField(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final selectedProducto = await showCupertinoModalPopup(
          context: context,
          builder: (context) => CupertinoPopupSurface(
            isSurfacePainted: true,
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.8,
              child: ViewTipoProductos(),
            ),
          ),
        );
        if (selectedProducto != null) {
          setState(() {
            _tipoProductoController.text = selectedProducto['nombre'];
            _tipoProductoId = selectedProducto['id'].toString();
          });
        }
      },
      child: AbsorbPointer(
        child: _buildSelectionField(
          value: _tipoProductoController.text,
          placeholder: 'Seleccionar Tipo de Producto',
        ),
      ),
    );
  }

  // Campo de selección de Origen (Centro de Distribución)
  Widget _buildOrigenField(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final selectedCentro = await showCupertinoModalPopup(
          context: context,
          builder: (context) => CupertinoPopupSurface(
            isSurfacePainted: true,
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.8,
              child: ViewCentrosDistribucion(),
            ),
          ),
        );
        if (selectedCentro != null) {
          setState(() {
            _origenCdIdController.text = selectedCentro['ciudad'];
            _origenCdId = selectedCentro['id'].toString();
          });
        }
      },
      child: AbsorbPointer(
        child: _buildSelectionField(
          value: _origenCdIdController.text,
          placeholder: 'Seleccionar Origen (CD)',
        ),
      ),
    );
  }

  // Campo de selección de Destino (Ubicación)
  Widget _buildDestinoField(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final selectedUbicacion = await showCupertinoModalPopup(
          context: context,
          builder: (context) => CupertinoPopupSurface(
            isSurfacePainted: true,
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.8,
              child: ViewUbicaciones(),
            ),
          ),
        );
        if (selectedUbicacion != null) {
          setState(() {
            _destinoIdController.text = selectedUbicacion['ciudad'];
            _destinoId = selectedUbicacion['id'].toString();
          });
        }
      },
      child: AbsorbPointer(
        child: _buildSelectionField(
          value: _destinoIdController.text,
          placeholder: 'Seleccionar Destino',
        ),
      ),
    );
  }

  /// Widget que implementa un campo de texto con efecto "glass" y Floating Label.
  Widget _buildFloatingTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
            ),
            child: Material(
              color: Colors.transparent,
              child: TextFormField(
                controller: controller,
                keyboardType: keyboardType,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  labelText: label,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Selector para Envío Express (Sí/No) usando CupertinoSegmentedControl
  Widget _buildEnvioExpressField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 12.0),
          child: Text(
            '¿Envío Express?',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        CupertinoSegmentedControl<bool>(
          groupValue: _envioExpress,
          padding: const EdgeInsets.all(12),
          children: const {
            false: Padding(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              child: Text('No', style: TextStyle(fontSize: 16)),
            ),
            true: Padding(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              child: Text('Sí', style: TextStyle(fontSize: 16)),
            ),
          },
          onValueChanged: (bool value) {
            setState(() {
              _envioExpress = value;
            });
          },
        ),
      ],
    );
  }

  // Muestra el diálogo de cotización con un resumen de la información y confirma el envío
  void _mostrarDialogoCotizacion(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: const Text(
            'Cotización de Envío',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            children: [
              const SizedBox(height: 10),
              Text('Tipo de Producto: ${_tipoProductoController.text}'),
              Text('ID Producto: $_tipoProductoId'),
              Text('Origen: ${_origenCdIdController.text}'),
              Text('ID Origen: $_origenCdId'),
              Text('Destino: ${_destinoIdController.text}'),
              Text('ID Destino: $_destinoId'),
              Text('Peso: ${_pesoUnitarioController.text} kg'),
              Text('Piezas: ${_numeroPiezasController.text}'),
              Text('Envío Express: ${_envioExpress ? "Sí" : "No"}'),
            ],
          ),
          actions: [
            CupertinoDialogAction(
              child: const Text('Cancelar', style: TextStyle(color: Colors.red)),
              onPressed: () => Navigator.pop(context),
            ),
            CupertinoDialogAction(
              child: const Text('Confirmar', style: TextStyle(color: CupertinoColors.activeBlue)),
              onPressed: () async {
                Navigator.pop(context);
                await _enviarCotizacion();
              },
            ),
          ],
        );
      },
    );
  }

  /// Función que construye y ejecuta la mutation para crear la cotización de envío.
  Future<void> _enviarCotizacion() async {
    // Se obtiene el cliente GraphQL
    final client = GraphQLProvider.of(context).value;

    // Definición de la mutation con variables
    final String mutation = r'''
      mutation CrearCalcularEnvio(
        $tipoProductoId: Int!,
        $origenCdId: Int!,
        $destinoId: Int!,
        $pesoUnitario: Float!,
        $numeroPiezas: Int!,
        $dimensionesLargo: Float!,
        $dimensionesAncho: Float!,
        $dimensionesAlto: Float!,
        $descripcion: String!,
        $envioExpress: Boolean!
      ) {
        crearCalcularEnvio(
          tipoProductoId: $tipoProductoId,
          origenCdId: $origenCdId,
          destinoId: $destinoId,
          pesoUnitario: $pesoUnitario,
          numeroPiezas: $numeroPiezas,
          dimensionesLargo: $dimensionesLargo,
          dimensionesAncho: $dimensionesAncho,
          dimensionesAlto: $dimensionesAlto,
          descripcion: $descripcion,
          envioExpress: $envioExpress
        ) {
          calcularEnvio {
            id
            descripcion
            totalTarifa
            tarifaPeso
            distanciaKm
          }
        }
      }
    ''';

    // Construir el mapa de variables usando los valores de los controladores
    final variables = {
      "tipoProductoId": int.tryParse(_tipoProductoId ?? "") ?? 0,
      "origenCdId": int.tryParse(_origenCdId ?? "") ?? 0,
      "destinoId": int.tryParse(_destinoId ?? "") ?? 0,
      "pesoUnitario": double.tryParse(_pesoUnitarioController.text) ?? 0.0,
      "numeroPiezas": int.tryParse(_numeroPiezasController.text) ?? 0,
      "dimensionesLargo": double.tryParse(_dimensionesLargoController.text) ?? 0.0,
      "dimensionesAncho": double.tryParse(_dimensionesAnchoController.text) ?? 0.0,
      "dimensionesAlto": double.tryParse(_dimensionesAltoController.text) ?? 0.0,
      "descripcion": _descripcionController.text,
      "envioExpress": _envioExpress,
    };

    // Ejecutar la mutation
    try {
      final result = await client.mutate(
        MutationOptions(
          document: gql(mutation),
          variables: variables,
        ),
      );

      if (result.hasException) {
        // Manejo del error: se podría mostrar un mensaje de error en la UI.
        print("Error en la mutation: ${result.exception.toString()}");
      } else {
        // Procesar la respuesta exitosa.
        print("Resultado de la mutation: ${result.data}");
        // Mostrar la pantalla de Cotización como un modal en iOS.
        showCupertinoModalPopup(
          context: context,
          builder: (context) => CupertinoPopupSurface(
            isSurfacePainted: true,
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.8,
              child: CotizacionPaqueteScreen(),
            ),
          ),
        );
      }
    } catch (e) {
      print("Excepción al enviar la cotización: $e");
    }
  }
}
