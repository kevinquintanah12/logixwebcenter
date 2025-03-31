import 'package:flutter/material.dart';
import 'package:shop/entry_point.dart';

class RutasScreen extends StatefulWidget {
  const RutasScreen({Key? key}) : super(key: key);

  @override
  _RutasScreenState createState() => _RutasScreenState();
}

class _RutasScreenState extends State<RutasScreen> {
  String? selectedRoute;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Selecciona la ruta',
                  border: OutlineInputBorder(),
                ),
                value: selectedRoute,
                items: [
                  'R91 - Coatzacoalcos - Villahermosa',
                  'R92 - Veracruz - Ciudad de México',
                  'R93 - Villahermosa - Monterrey',
                ]
                    .map((route) => DropdownMenuItem(
                          child: Text(route),
                          value: route,
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedRoute = value;
                  });
                },
              ),
              const SizedBox(height: 20),

              const Text(
                'Información de la ruta',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _buildInfoRow('Origen:', 'Base de Transportes, Coatzacoalcos, Veracruz'),
              _buildInfoRow('Destino:', 'Empresa SA de CV, Villahermosa, Tabasco'),
              _buildInfoRow('Dirección:', 'Av. Siempre Viva No. 2045, Villahermosa, Tabasco'),
              const SizedBox(height: 20),

              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/images/mapss.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 100,
                    child: ElevatedButton(
                      onPressed: () {
                        _mostrarConfirmacionCancelacion(context);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('Cancelar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  void _mostrarConfirmacionCancelacion(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('¿Estás seguro de Cancelar?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Rechazar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const EntryPoint()),
                );
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }
}
