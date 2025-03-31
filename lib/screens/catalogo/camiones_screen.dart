import 'package:flutter/material.dart';
import 'add_camiones_screen.dart'; // Importa la pantalla de agregar camión

class CamionesScreen extends StatelessWidget {
  const CamionesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> camiones = [
      {'nombre': 'Camión 1234', 'placa': 'XYZ 1234'},
      {'nombre': 'Camión 5678', 'placa': 'ABC 5678'},
      {'nombre': 'Camión 9012', 'placa': 'DEF 9012'},
      {'nombre': 'Camión 3456', 'placa': 'GHI 3456'},
      {'nombre': 'Camión 7890', 'placa': 'JKL 7890'},
    ];

    final screenWidth = MediaQuery.of(context).size.width;
    double searchFontSize = screenWidth > 600 ? 12 : 10; // Tamaño de fuente de búsqueda
    double camionCardFontSize = screenWidth > 600 ? 14 : 12; // Ajuste para los camiones

    return Scaffold(
      body: Container(
        color: const Color(0xFFF2F2F2),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Tooltip(
                    message: 'Gestión de Camiones', // Tooltip con el nombre de la pantalla
                    child: Icon(
                      Icons.local_shipping,
                      size: 28,
                      color: const Color(0xFF031273),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: const Icon(Icons.search, color: Colors.grey),
                        hintText: 'Buscar camión',
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: searchFontSize,
                          fontFamily: 'Grandis Extended',
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide(color: Colors.grey.withOpacity(0.5)),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF031273),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.add, color: Colors.white),
                      onPressed: () async {
                        // Al presionar el botón, navega a la pantalla de agregar camión
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AddCamionesScreen()),
                        );

                        // Aquí puedes manejar el resultado (si se regresa un valor de la pantalla de agregar camión)
                        if (result != null) {
                          print('Nuevo camión agregado: $result');
                          // Puedes actualizar la lista de camiones aquí si es necesario
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: camiones.length,
                itemBuilder: (context, index) {
                  final camion = camiones[index];
                  return _buildCamionCard(camion, context, camionCardFontSize);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCamionCard(Map<String, String> camion, BuildContext context, double fontSize) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: const Color(0xFF031273).withOpacity(0.3), width: 1),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          leading: const CircleAvatar(
            backgroundColor: Color(0xFF031273),
            child: Icon(Icons.local_shipping, color: Colors.white, size: 20),
          ),
          title: Text(
            camion['nombre']!,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontFamily: 'Grandis Extended',
            ),
          ),
          subtitle: Text(
            'Placa: ${camion['placa']}',
            style: TextStyle(
              fontSize: fontSize - 2,
              color: Colors.black.withOpacity(0.6),
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Color(0xFF031273), size: 20),
                onPressed: () {
                  print("Editar camión: ${camion['nombre']}");
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Confirmar eliminación'),
                        content: Text('¿Estás seguro de que deseas eliminar "${camion['nombre']}"?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancelar', style: TextStyle(fontSize: 12)),
                          ),
                          TextButton(
                            onPressed: () {
                              print("Camión eliminado: ${camion['nombre']}");
                              Navigator.pop(context);
                            },
                            child: const Text('Eliminar', style: TextStyle(color: Colors.red, fontSize: 12)),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
