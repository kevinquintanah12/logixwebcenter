import 'package:flutter/material.dart';

class CodigoSatScreen extends StatefulWidget {
  const CodigoSatScreen({super.key});

  @override
  _CodigoSatScreenState createState() => _CodigoSatScreenState();
}

class _CodigoSatScreenState extends State<CodigoSatScreen> {
  final List<Map<String, String>> satCodes = [
    {"codigo": "1", "descripcion": "Alimentos y bebidas"},
    {"codigo": "2", "descripcion": "Equipos electrónicos"},
    {"codigo": "3", "descripcion": "Vehículos y autopartes"},
    {"codigo": "4", "descripcion": "Material de oficina"},
    {"codigo": "5", "descripcion": "Servicios profesionales"},
  ];

  List<Map<String, String>> filteredSatCodes = [];

  @override
  void initState() {
    super.initState();
    filteredSatCodes = List.from(satCodes);
  }

  void _filterSatCodes(String query) {
    setState(() {
      filteredSatCodes = satCodes
          .where((code) =>
              code["codigo"]!.contains(query) ||
              code["descripcion"]!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white.withOpacity(0.2), // Efecto Glassmorphism
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Buscar Código SAT",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 10),
            TextField(
              onChanged: _filterSatCodes,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: "Buscar por código o descripción...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 200,
              child: ListView.builder(
                itemCount: filteredSatCodes.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(filteredSatCodes[index]["codigo"]!),
                    subtitle: Text(filteredSatCodes[index]["descripcion"]!),
                    onTap: () {
                      Navigator.pop(context, filteredSatCodes[index]["codigo"]); // Devuelve el código
                    },
                  );
                },
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cerrar"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Método para mostrar la pantalla como diálogo emergente y esperar el resultado
Future<String?> showCodigoSatDialog(BuildContext context) async {
  return await showDialog<String>(
    context: context,
    builder: (context) => const CodigoSatScreen(),
  );
}
