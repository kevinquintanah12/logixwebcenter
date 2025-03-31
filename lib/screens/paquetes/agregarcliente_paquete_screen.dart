import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shop/screens/paquetes/agregardestinatario_paquete_screen.dart';

class AddClienteScreen extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  final TextEditingController razonSocialController = TextEditingController();
  final TextEditingController rfcController = TextEditingController();
  final TextEditingController direccionController = TextEditingController();
  final TextEditingController cpController = TextEditingController();
  final TextEditingController telefonoController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: Colors.white.withOpacity(0.5),
        middle: const Text(
          'Agregar Cliente',
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
                mutation CrearCliente(
                  $nombre: String!, 
                  $apellido: String!, 
                  $razonSocial: String!, 
                  $rfc: String!, 
                  $direccion: String!, 
                  $codigoPostal: String!,
                  $telefono: String!,
                  $email: String!
                ) {
                  crearCliente(
                    nombre: $nombre,
                    apellido: $apellido,
                    razonSocial: $razonSocial,
                    rfc: $rfc,
                    direccion: $direccion,
                    codigoPostal: $codigoPostal,
                    telefono: $telefono,
                    email: $email
                  ) {
                    cliente {
                      id
                      nombre
                      apellido
                      razonSocial
                      rfc
                      direccion
                      codigoPostal
                      telefono
                      email
                    }
                  }
                }
              ''';

              // Ejecuta la mutación
              final MutationOptions options = MutationOptions(
                document: gql(mutation),
                variables: {
                  'nombre': nameController.text,
                  'apellido': surnameController.text,
                  'razonSocial': razonSocialController.text,
                  'rfc': rfcController.text,
                  'direccion': direccionController.text,
                  'codigoPostal': cpController.text,
                  'telefono': telefonoController.text,
                  'email': emailController.text,
                },
                onCompleted: (dynamic resultData) {
                  // Procesa el resultado y navega hacia la pantalla anterior
                  print('Cliente creado: ${resultData?['crearCliente']?['cliente']}');
                  Navigator.pop(context, resultData?['crearCliente']?['cliente']);
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => AddDestinatarioScreen(),
                    ),
                  );
                },
                onError: (OperationException? error) {
                  // Manejo de errores
                  print('Error al crear el cliente: $error');
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
              // Foto o ícono de cliente con Glassmorphism
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
              // Formulario con Glassmorphism
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _buildGlassTextField(
                      controller: nameController,
                      placeholder: 'Nombre',
                    ),
                    const SizedBox(height: 10),
                    _buildGlassTextField(
                      controller: surnameController,
                      placeholder: 'Apellidos',
                    ),
                    const SizedBox(height: 10),
                    _buildGlassTextField(
                      controller: razonSocialController,
                      placeholder: 'Razón Social',
                    ),
                    const SizedBox(height: 10),
                    _buildGlassTextField(
                      controller: rfcController,
                      placeholder: 'RFC',
                    ),
                    const SizedBox(height: 10),
                    _buildGlassTextField(
                      controller: direccionController,
                      placeholder: 'Dirección',
                    ),
                    const SizedBox(height: 10),
                    _buildGlassTextField(
                      controller: cpController,
                      placeholder: 'Código Postal',
                    ),
                    const SizedBox(height: 10),
                    _buildGlassTextField(
                      controller: telefonoController,
                      placeholder: 'Teléfono',
                    ),
                    const SizedBox(height: 10),
                    _buildGlassTextField(
                      controller: emailController,
                      placeholder: 'Email',
                    ),
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
