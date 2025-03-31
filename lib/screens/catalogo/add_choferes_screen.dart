import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

class AddChoferesScreen extends StatelessWidget {
  final TextEditingController idController = TextEditingController();
  final TextEditingController rfcController = TextEditingController();
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController direccionController = TextEditingController();
  final TextEditingController cpController = TextEditingController();
  final TextEditingController regimenFiscalController = TextEditingController();
  final TextEditingController certificadoController = TextEditingController();
  final TextEditingController fileKeyController = TextEditingController();
  final TextEditingController passCertificadoController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: Colors.white.withOpacity(0.5),
        middle: const Text(
          'Agregar Chofer',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            fontFamily: 'Grandis Extended',
          ),
        ),
        trailing: GestureDetector(
          onTap: () {
            if (nombreController.text.isNotEmpty) {
              Navigator.pop(context, {
                "id": idController.text,
                "rfc": rfcController.text,
                "nombre": nombreController.text,
                "direccion": direccionController.text,
                "cp": cpController.text,
                "regimenfiscal": regimenFiscalController.text,
                "certificado": certificadoController.text,
                "filekey": fileKeyController.text,
                "passcertificado": passCertificadoController.text,
              });
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _buildGlassTextField(
                      controller: idController,
                      placeholder: 'ID',
                    ),
                    const SizedBox(height: 10),
                    _buildGlassTextField(
                      controller: rfcController,
                      placeholder: 'RFC',
                    ),
                    const SizedBox(height: 10),
                    _buildGlassTextField(
                      controller: nombreController,
                      placeholder: 'Nombre',
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
                      controller: regimenFiscalController,
                      placeholder: 'Régimen Fiscal',
                    ),
                    const SizedBox(height: 10),
                    _buildGlassTextField(
                      controller: certificadoController,
                      placeholder: 'Certificado',
                    ),
                    const SizedBox(height: 10),
                    _buildGlassTextField(
                      controller: fileKeyController,
                      placeholder: 'File Key',
                    ),
                    const SizedBox(height: 10),
                    _buildGlassTextField(
                      controller: passCertificadoController,
                      placeholder: 'Contraseña del Certificado',
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
