import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

class AddCamionesScreen extends StatelessWidget {
  final TextEditingController idController = TextEditingController();
  final TextEditingController claveUnidadController = TextEditingController();
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController descripcionController = TextEditingController();
  final TextEditingController simboloController = TextEditingController();
  final TextEditingController linkSetController = TextEditingController();

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
          onTap: () {
            if (nombreController.text.isNotEmpty && claveUnidadController.text.isNotEmpty) {
              Navigator.pop(context, {
                "id": idController.text,
                "claveunidad": claveUnidadController.text,
                "nombre": nombreController.text,
                "descripcion": descripcionController.text,
                "simbolo": simboloController.text,
                "linkSet": linkSetController.text,
              });
            }
          },
          child: const Text(
            'Guardar',
            style: TextStyle(
              color: CupertinoColors.activeBlue,
              fontFamily: 'Grandis Extended',
            ),
          ),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const SizedBox(height: 30),
                _buildGlassTextField(
                  controller: idController,
                  placeholder: 'ID',
                ),
                const SizedBox(height: 10),
                _buildGlassTextField(
                  controller: claveUnidadController,
                  placeholder: 'Clave Unidad',
                ),
                const SizedBox(height: 10),
                _buildGlassTextField(
                  controller: nombreController,
                  placeholder: 'Nombre',
                ),
                const SizedBox(height: 10),
                _buildGlassTextField(
                  controller: descripcionController,
                  placeholder: 'Descripción',
                ),
                const SizedBox(height: 10),
                _buildGlassTextField(
                  controller: simboloController,
                  placeholder: 'Símbolo',
                ),
                const SizedBox(height: 10),
                _buildGlassTextField(
                  controller: linkSetController,
                  placeholder: 'Link Set',
                ),
              ],
            ),
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
