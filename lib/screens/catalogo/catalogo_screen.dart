import 'package:flutter/material.dart';
// Importa las nuevas pantallas de Choferes y Camiones
import 'choferes_screen.dart';
import 'camiones_screen.dart';
import 'clientes_screen.dart';

class CatalogsScreen extends StatefulWidget {
  @override
  _CatalogsScreenState createState() => _CatalogsScreenState();
}

class _CatalogsScreenState extends State<CatalogsScreen> {
  int _selectedIndex = 0;

  final List<Widget> catalogScreens = [
    ClientesScreen(),
    ChoferesScreen(),
    CamionesScreen(),
  ];

  final List<String> catalogLabels = [
    "Clientes",
    "Choferes",
    "Camiones",
  ];

  final List<IconData> catalogIcons = [
    Icons.person_outline,
    Icons.directions_bus_outlined,
    Icons.local_shipping_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Lateral para pantallas anchas
          if (constraints.maxWidth > 600) {
            return Row(
              children: [
                Container(
                  width: 110,
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(catalogLabels.length, (index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: _buildMenuItem(
                          icon: catalogIcons[index],
                          label: catalogLabels[index],
                          index: index,
                        ),
                      );
                    }),
                  ),
                ),
                Expanded(child: catalogScreens[_selectedIndex]),
              ],
            );
          } else {
            // BottomNavigationBar para pantallas estrechas
            return Scaffold(
              bottomNavigationBar: BottomNavigationBar(
                currentIndex: _selectedIndex,
                onTap: (index) => setState(() => _selectedIndex = index),
                items: List.generate(catalogLabels.length, (index) {
                  return BottomNavigationBarItem(
                    icon: SizedBox.shrink(),
                    label: catalogLabels[index],
                  );
                }),
                selectedItemColor: Colors.blueAccent,
                unselectedItemColor: Colors.grey,
                showUnselectedLabels: true,
                type: BottomNavigationBarType.fixed,
              ),
              body: catalogScreens[_selectedIndex],
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
      onTap: () => setState(() => _selectedIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? Colors.grey[300] : Colors.white,
            ),
            padding: EdgeInsets.all(10),
            child: Icon(
              icon,
              size: 27,
              color: isSelected ? Colors.grey : Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              color: isSelected ? Colors.grey : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
