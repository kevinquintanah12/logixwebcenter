import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

/// Formateador custom para convertir texto a mayúsculas
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
  ) {
    return newValue.copyWith(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

class AddCamionesScreen extends StatefulWidget {
  const AddCamionesScreen({Key? key}) : super(key: key);

  @override
  _AddCamionesScreenState createState() => _AddCamionesScreenState();
}

class _AddCamionesScreenState extends State<AddCamionesScreen> {
  final matriculaController         = TextEditingController();
  final marcaController             = TextEditingController();
  final modeloController            = TextEditingController();
  final capacidadCargaController    = TextEditingController();
  final tipoVehiculoController      = TextEditingController();
  bool cumplimientoNormas           = false;

  // Máscara para matrícula: 3 letras + 4 dígitos
  final matriculaFormatter = MaskTextInputFormatter(
    mask: 'AAA####',
    filter: {
      'A': RegExp(r'[A-Za-z]'),
      '#': RegExp(r'[0-9]'),
    },
    type: MaskAutoCompletionType.eager,
  );

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: Colors.white.withOpacity(0.5),
        middle: const Text(
          'Agregar Camión',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            fontFamily: 'Grandis Extended',
          ),
        ),
        trailing: GestureDetector(
          onTap: _onSave,
          child: const Text(
            'Guardar',
            style: TextStyle(
              color: CupertinoColors.activeBlue,
              fontFamily: 'Grandis Extended',
            ),
          ),
        ),
      ),
      backgroundColor: Colors.grey[200],
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
          child: Column(
            children: [
              _buildFloatingTextField(
                controller: matriculaController,
                labelText: 'Matrícula',
                inputFormatters: [
                  matriculaFormatter,
                  UpperCaseTextFormatter(),
                ],
              ),
              const Padding(
                padding: EdgeInsets.only(left: 12, top: 4),
                child: Text(
                  'Ejemplo: ABC1234',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ),
              const SizedBox(height: 10),
              _buildFloatingTextField(
                controller: marcaController,
                labelText: 'Marca',
              ),
              const SizedBox(height: 10),
              _buildFloatingTextField(
                controller: modeloController,
                labelText: 'Modelo',
              ),
              const SizedBox(height: 10),
              _buildFloatingTextField(
                controller: capacidadCargaController,
                labelText: 'Capacidad de Carga',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 10),
              _buildFloatingTextField(
                controller: tipoVehiculoController,
                labelText: 'Tipo de Vehículo',
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Cumple Normas'),
                  CupertinoSwitch(
                    value: cumplimientoNormas,
                    onChanged: (value) =>
                        setState(() => cumplimientoNormas = value),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onSave() async {
    final matUnmasked = matriculaFormatter.getUnmaskedText();

    // 1) Validar campos no vacíos
    if ([
      matriculaController.text,
      marcaController.text,
      modeloController.text,
      capacidadCargaController.text,
      tipoVehiculoController.text
    ].any((e) => e.isEmpty)) {
      _showErrorDialog('Por favor, complete todos los campos.');
      return;
    }

    // 2) Validar formato matrícula (7 caracteres sin máscara)
    if (matUnmasked.length != 7) {
      _showErrorDialog('Matrícula inválida.\nEjemplo: ABC1234');
      return;
    }

    // 3) Validar capacidad de carga numérica
    final carga = double.tryParse(capacidadCargaController.text);
    if (carga == null) {
      _showErrorDialog('La capacidad de carga debe ser un número válido.');
      return;
    }

    final client = GraphQLProvider.of(context).value;
    const String mutationCrearCamion = r'''
      mutation CrearCamion(
        $matricula: String!,
        $marca: String!,
        $modelo: String!,
        $capacidadCarga: Float!,
        $tipoVehiculo: String!,
        $cumplimientoNormas: Boolean!
      ) {
        crearCamion(
          matricula: $matricula,
          marca: $marca,
          modelo: $modelo,
          capacidadCarga: $capacidadCarga,
          tipoVehiculo: $tipoVehiculo,
          cumplimientoNormas: $cumplimientoNormas
        ) {
          camion {
            id
            matricula
          }
        }
      }
    ''';

    final result = await client.mutate(
      MutationOptions(
        document: gql(mutationCrearCamion),
        variables: {
          'matricula': matriculaController.text.trim(),
          'marca': marcaController.text.trim(),
          'modelo': modeloController.text.trim(),
          'capacidadCarga': carga,
          'tipoVehiculo': tipoVehiculoController.text.trim(),
          'cumplimientoNormas': cumplimientoNormas,
        },
      ),
    );

    if (result.hasException) {
      // Mensaje amigable para clave única de matrícula
      String friendly = 'Ocurrió un error al crear el camión.';
      final ex = result.exception;
      if (ex != null &&
          ex.graphqlErrors.any((e) =>
              e.message.contains('duplicate key value') &&
              e.message.contains('matricula'))) {
        friendly = 'Ya existe un camión con esta matrícula.';
      }
      _showErrorDialog(friendly);
    } else {
      // Éxito: cerrar y devolver el camión creado
      await showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
          title: const Text('¡Camión dado de alta!'),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // cierra diálogo
                Navigator.of(context)
                    .pop(result.data?['crearCamion']?['camion']);
              },
            )
          ],
        ),
      );
    }
  }

  void _showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Error al crear camión'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
    );
  }

  Widget _buildFloatingTextField({
    required TextEditingController controller,
    required String labelText,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) =>
      Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            labelText: labelText,
            floatingLabelBehavior: FloatingLabelBehavior.auto,
            border: InputBorder.none,
          ),
        ),
      );
}
