import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

class AddClienteScreen extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  final TextEditingController rfcController = TextEditingController();
  final TextEditingController direccionController = TextEditingController();
  final TextEditingController cpController = TextEditingController();
  final TextEditingController usocfdiController = TextEditingController();
  final TextEditingController metododepagoController = TextEditingController();
  final TextEditingController formadepagoController = TextEditingController();
  final TextEditingController tipocomprobanteController = TextEditingController();
  final TextEditingController listaprecioController = TextEditingController();

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
            fontFamily: 'Grandis Extended', // Se aplica la misma fuente
          ),
        ),
        trailing: GestureDetector(
          onTap: () {
            if (nameController.text.isNotEmpty) {
              Navigator.pop(context, {
                "name": nameController.text,
                "rfc": rfcController.text,
                "nombre": "${nameController.text} ${surnameController.text}",
                "direccion": direccionController.text,
                "cp": cpController.text,
                "usocfdi": usocfdiController.text,
                "metododepago": metododepagoController.text,
                "formadepago": formadepagoController.text,
                "tipocomprobante": tipocomprobanteController.text,
                "listaprecio": listaprecioController.text,
              });
            }
          },
          child: const Text(
            'Listo',
            style: TextStyle(
              color: CupertinoColors.activeBlue,
              fontFamily: 'Grandis Extended', // Fuente en el botón "Listo"
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
                      controller: usocfdiController,
                      placeholder: 'Uso CFDI',
                    ),
                    const SizedBox(height: 10),
                    _buildGlassTextField(
                      controller: metododepagoController,
                      placeholder: 'Método de Pago',
                    ),
                    const SizedBox(height: 10),
                    _buildGlassTextField(
                      controller: formadepagoController,
                      placeholder: 'Forma de Pago',
                    ),
                    const SizedBox(height: 10),
                    _buildGlassTextField(
                      controller: tipocomprobanteController,
                      placeholder: 'Tipo de Comprobante',
                    ),
                    const SizedBox(height: 10),
                    _buildGlassTextField(
                      controller: listaprecioController,
                      placeholder: 'Lista de Precio',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.grey[200], // Fondo gris claro
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

