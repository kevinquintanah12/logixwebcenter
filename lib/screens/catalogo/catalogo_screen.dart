import 'package:flutter/material.dart';
// Importa las nuevas pantallas de Choferes y Camiones
import 'choferes_screen.dart'; // Asegúrate de que la ruta sea correcta
import 'camiones_screen.dart'; // Asegúrate de que la ruta sea correcta
import 'clientes_screen.dart'; // Asegúrate de que la ruta sea correcta
import 'productos_screen.dart'; // Asegúrate de que la ruta sea correcta

class CatalogsScreen extends StatefulWidget {
  @override
  _CatalogsScreenState createState() => _CatalogsScreenState();
}

class _CatalogsScreenState extends State<CatalogsScreen> {
  int _selectedIndex = 0; // Índice para saber qué pantalla mostrar

  final List<Widget> catalogScreens = [
    ClientesScreen(),
    ProductosScreen(),
    ChoferesScreen(), // Nueva pantalla de Choferes
    CamionesScreen(), // Nueva pantalla de Camiones
  ];

  final List<String> catalogLabels = [
    "Clientes",
    "Productos",
    "Choferes",
    "Camiones",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Si el ancho de la pantalla es mayor a 600, usa el menú lateral
          if (constraints.maxWidth > 600) {
            return Row(
              children: [
                // Menú lateral con sombra
                Container(
                  width: 110, // Ancho del Drawer
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        offset: Offset(3, 3),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: ListView(
                    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                    children: [
                      _buildMenuItem(
                        icon: Icons.person_outline,
                        label: "Clientes",
                        index: 0,
                      ),
                      SizedBox(height: 16),
                      _buildMenuItem(
                        icon: Icons.shopping_bag_outlined,
                        label: "Productos",
                        index: 1,
                      ),
                      SizedBox(height: 16),
                      _buildMenuItem(
                        icon: Icons.directions_bus_outlined, // Icono para Choferes
                        label: "Choferes",
                        index: 2,
                      ),
                      SizedBox(height: 16),
                      _buildMenuItem(
                        icon: Icons.local_shipping_outlined, // Icono para Camiones
                        label: "Camiones",
                        index: 3,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: catalogScreens[_selectedIndex],
                ),
              ],
            );
          } else {
            // Si el ancho es menor a 600, usa BottomNavigationBar con solo nombres
            return Scaffold(
              bottomNavigationBar: BottomNavigationBar(
                currentIndex: _selectedIndex,
                onTap: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                items: catalogLabels
                    .map(
                      (label) => BottomNavigationBarItem(
                        icon: SizedBox.shrink(), // Sin ícono
                        label: label, // Solo texto
                      ),
                    )
                    .toList(),
                selectedItemColor: Colors.blueAccent,
                unselectedItemColor: Colors.grey,
                showUnselectedLabels: true,
                type: BottomNavigationBarType.fixed,
              ),
              body: catalogScreens[_selectedIndex], // Muestra la pantalla seleccionada
            );
          }
        },
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    bool isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? Colors.grey[300] : Colors.white, // Cambiar el color de fondo al seleccionar
            ),
            padding: EdgeInsets.all(10.0), // Ajustado el padding para íconos más pequeños
            child: Icon(
              icon,
              size: 27.0, // Íconos más pequeños
              color: isSelected ? Colors.grey : Colors.black, // Cambiar color del ícono cuando está seleccionado
            ),
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              color: isSelected ? Colors.grey : Colors.black, // Cambiar color del texto cuando está seleccionado
            ),
          ),
        ],
      ),
    );
  }
}
