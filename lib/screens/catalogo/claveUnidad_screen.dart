import 'package:flutter/material.dart';

class ClaveUnidadScreen extends StatefulWidget {
  const ClaveUnidadScreen({super.key});

  @override
  _ClaveUnidadScreenState createState() => _ClaveUnidadScreenState();
}

class _ClaveUnidadScreenState extends State<ClaveUnidadScreen> {
  final List<Map<String, String>> unidadCodes = [
    {"codigo": "1", "descripcion": "Pieza"},
    {"codigo": "2", "descripcion": "Kilogramo"},
    {"codigo": "3", "descripcion": "Litro"},
    {"codigo": "4", "descripcion": "Metro"},
    {"codigo": "5", "descripcion": "Unidad"},
  ];

  List<Map<String, String>> filteredUnidadCodes = [];

  @override
  void initState() {
    super.initState();
    filteredUnidadCodes = List.from(unidadCodes);
  }

  void _filterUnidadCodes(String query) {
    setState(() {
      filteredUnidadCodes = unidadCodes
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
              "Buscar Clave de Unidad",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 10),
            TextField(
              onChanged: _filterUnidadCodes,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: "Buscar por clave o descripción...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 200,
              child: ListView.builder(
                itemCount: filteredUnidadCodes.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(filteredUnidadCodes[index]["codigo"]!),
                    subtitle: Text(filteredUnidadCodes[index]["descripcion"]!),
                    onTap: () {
                      Navigator.pop(context, filteredUnidadCodes[index]["codigo"]); // Devuelve solo el código
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
Future<String?> showClaveUnidadDialog(BuildContext context) async {
  return await showDialog<String>(
    context: context,
    builder: (context) => const ClaveUnidadScreen(),
  );
}
