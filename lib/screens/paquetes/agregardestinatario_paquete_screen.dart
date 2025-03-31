import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:graphql_flutter/graphql_flutter.dart';

class AddDestinatarioScreen extends StatelessWidget {
  // Controladores para los campos del destinatario
  final TextEditingController rfcController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  final TextEditingController correoController = TextEditingController();
  final TextEditingController telefonoController = TextEditingController();
  final TextEditingController pinController = TextEditingController();
  final TextEditingController direccionDetalladaController = TextEditingController();
  final TextEditingController calleController = TextEditingController();
  final TextEditingController coloniaController = TextEditingController();
  final TextEditingController numeroController = TextEditingController();
  final TextEditingController ciudadController = TextEditingController();
  final TextEditingController estadoController = TextEditingController();
  final TextEditingController cpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: Colors.white.withOpacity(0.5),
        middle: const Text(
          'Agregar Destinatario',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            fontFamily: 'Grandis Extended',
          ),
        ),
        trailing: GestureDetector(
          onTap: () async {
            // Verifica que se haya llenado al menos el nombre
            if (nameController.text.isNotEmpty) {
              // Obtén el GraphQLClient
              final client = GraphQLProvider.of(context).value;

              // Define la mutación con los datos del formulario
              const String mutation = r'''
                mutation CrearDestinatario(
                  $rfc: String!,
                  $nombre: String!,
                  $apellidos: String!,
                  $correoElectronico: String!,
                  $telefono: String!,
                  $pin: String!,
                  $direccionDetallada: String!,
                  $calle: String!,
                  $colonia: String!,
                  $numero: String!,
                  $ciudad: String!,
                  $estado: String!,
                  $codigoPostal: String!
                ) {
                  crearDestinatario(
                    rfc: $rfc,
                    nombre: $nombre,
                    apellidos: $apellidos,
                    correoElectronico: $correoElectronico,
                    telefono: $telefono,
                    pin: $pin,
                    direccionDetallada: $direccionDetallada,
                    calle: $calle,
                    colonia: $colonia,
                    numero: $numero,
                    ciudad: $ciudad,
                    estado: $estado,
                    codigoPostal: $codigoPostal
                  ) {
                    destinatario {
                      id
                      nombre
                      apellidos
                      direccionDetallada
                      ciudad
                      estado
                    }
                  }
                }
              ''';

              // Ejecuta la mutación
              final MutationOptions options = MutationOptions(
                document: gql(mutation),
                variables: {
                  'rfc': rfcController.text,
                  'nombre': nameController.text,
                  'apellidos': surnameController.text,
                  'correoElectronico': correoController.text,
                  'telefono': telefonoController.text,
                  'pin': pinController.text,
                  'direccionDetallada': direccionDetalladaController.text,
                  'calle': calleController.text,
                  'colonia': coloniaController.text,
                  'numero': numeroController.text,
                  'ciudad': ciudadController.text,
                  'estado': estadoController.text,
                  'codigoPostal': cpController.text,
                },
                onCompleted: (dynamic resultData) {
                  // Procesa el resultado y navega hacia la pantalla anterior
                  print('Destinatario creado: ${resultData?['crearDestinatario']?['destinatario']}');
                  Navigator.pop(context, resultData?['crearDestinatario']?['destinatario']);
                },
                onError: (OperationException? error) {
                  // Manejo de errores
                  print('Error al crear el destinatario: $error');
                  // Aquí podrías mostrar un mensaje de error en la UI
                },
              );

              await client.mutate(options);
            }
          },
          child: const Text(
            'Listo',
            style: TextStyle(
              color: CupertinoColors.activeBlue,
              fontFamily: 'Grandis Extended',
            ),
          ),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 30),
              // Ícono del destinatario con efecto Glassmorphism
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Colors.grey.withOpacity(0.2),
                          Colors.white.withOpacity(0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.4),
                        width: 1.5,
                      ),
                    ),
                    child: ClipOval(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          color: Colors.grey.withOpacity(0.2),
                        ),
                      ),
                    ),
                  ),
                  const Icon(
                    CupertinoIcons.person_fill,
                    size: 50,
                    color: Colors.black54,
                  ),
                ],
              ),
              const SizedBox(height: 30),
              // Formulario con efecto Glassmorphism
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _buildGlassTextField(controller: rfcController, placeholder: 'RFC'),
                    const SizedBox(height: 10),
                    _buildGlassTextField(controller: nameController, placeholder: 'Nombre'),
                    const SizedBox(height: 10),
                    _buildGlassTextField(controller: surnameController, placeholder: 'Apellidos'),
                    const SizedBox(height: 10),
                    _buildGlassTextField(controller: correoController, placeholder: 'Correo Electrónico'),
                    const SizedBox(height: 10),
                    _buildGlassTextField(controller: telefonoController, placeholder: 'Teléfono'),
                    const SizedBox(height: 10),
                    _buildGlassTextField(controller: pinController, placeholder: 'PIN'),
                    const SizedBox(height: 10),
                    _buildGlassTextField(controller: direccionDetalladaController, placeholder: 'Dirección Detallada'),
                    const SizedBox(height: 10),
                    _buildGlassTextField(controller: calleController, placeholder: 'Calle'),
                    const SizedBox(height: 10),
                    _buildGlassTextField(controller: coloniaController, placeholder: 'Colonia'),
                    const SizedBox(height: 10),
                    _buildGlassTextField(controller: numeroController, placeholder: 'Número'),
                    const SizedBox(height: 10),
                    _buildGlassTextField(controller: ciudadController, placeholder: 'Ciudad'),
                    const SizedBox(height: 10),
                    _buildGlassTextField(controller: estadoController, placeholder: 'Estado'),
                    const SizedBox(height: 10),
                    _buildGlassTextField(controller: cpController, placeholder: 'Código Postal'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.grey[200],
    );
  }

  Widget _buildGlassTextField({
    required TextEditingController controller,
    required String placeholder,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.4),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: CupertinoTextField(
            controller: controller,
            placeholder: placeholder,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            placeholderStyle: const TextStyle(color: Colors.black54),
            style: const TextStyle(color: Colors.black87),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }
}
