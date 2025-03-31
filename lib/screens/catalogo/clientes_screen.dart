import 'package:flutter/material.dart';
import 'add_clientes_screen.dart'; // Importa la pantalla de agregar cliente

class ClientesScreen extends StatefulWidget {
  const ClientesScreen({super.key});

  @override
  State<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  Map<String, List<Map<String, dynamic>>> groupedClients = {
    'A': [
      {"name": "Ana López", "rfc": "ANL123456789", "isFavorite": false},
      {"name": "Alberto Sánchez", "rfc": "ALS987654321", "isFavorite": false},
    ],
    'B': [
      {"name": "Bárbara Ramírez", "rfc": "BRM456789123", "isFavorite": false},
    ],
  };

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double screenSize = screenWidth / screenHeight;

    double fontSizeSubtitle = screenSize > 1 ? 14 : 10;
    double iconSize = screenSize > 1 ? 30 : 24;

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Tooltip(
                  message: "Clientes", // Tooltip con el mensaje de "Clientes"
                  child: Icon(
                    Icons.person, // Icono de persona para representar clientes
                    color: Colors.grey,
                    size: iconSize,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Buscar cliente',
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: fontSizeSubtitle,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: Colors.grey.withOpacity(0.5)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: groupedClients.keys.length,
              itemBuilder: (context, index) {
                final letter = groupedClients.keys.elementAt(index);
                final clients = groupedClients[letter]!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: Text(
                        letter,
                        style: TextStyle(
                          fontSize: fontSizeSubtitle,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    ...clients.map((client) {
                      return _buildClientCard(client, fontSizeSubtitle, iconSize);
                    }).toList(),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Tooltip(
        message: "Agregar Cliente",
        child: FloatingActionButton(
          onPressed: () {
            // Mostrar la pantalla de agregar cliente como un cuadro de diálogo con el mismo tamaño
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return Dialog(
                  insetPadding: EdgeInsets.zero, // Elimina el espacio alrededor del cuadro de diálogo
                  child: Container(
                    width: screenWidth, // Establecer el ancho del cuadro de diálogo
                    height: screenHeight, // Establecer la altura del cuadro de diálogo
                    child: AddClienteScreen(), // Aquí se carga la pantalla de agregar cliente
                  ),
                );
              },
            );
          },
          backgroundColor: const Color(0xFF031273),
          child: Icon(
            Icons.add,
            size: iconSize,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildClientCard(Map<String, dynamic> client, double fontSizeSubtitle, double iconSize) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: const Color(0xFF031273).withOpacity(0.5),
            width: 1.5,
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          title: Text(
            client["name"],
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          subtitle: Text(
            client["rfc"],
            style: TextStyle(
              fontSize: fontSizeSubtitle,
              fontWeight: FontWeight.w400,
              color: Colors.black54,
            ),
          ),
          trailing: IconButton(
            tooltip: "Agregar a favoritos",
            icon: Icon(
              client["isFavorite"] ? Icons.star : Icons.star_border,
              size: iconSize,
              color: client["isFavorite"] ? Colors.amber : const Color(0xFF031273),
            ),
            onPressed: () {
              setState(() {
                client["isFavorite"] = !client["isFavorite"];
              });
            },
          ),
        ),
      ),
    );
  }
}
