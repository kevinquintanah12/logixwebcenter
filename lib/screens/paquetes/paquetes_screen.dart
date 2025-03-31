import 'package:flutter/material.dart';
import 'calcular_envio_screen.dart';
import 'control_paquete_screen.dart';
import 'atencion_paquete_screen.dart';
import 'interoperabilidad_paquete_screen.dart';
import 'inventario_paquete_screen.dart';
import 'alertas_paquete_screen.dart';
import 'entregas_paquete_screen.dart';

class PaquetesScreen extends StatefulWidget {
  @override
  _PaquetesScreenState createState() => _PaquetesScreenState();
}

class _PaquetesScreenState extends State<PaquetesScreen> {
  int _selectedIndex = 0;

  final List<Widget> paquetesScreens = [
    CalcularEnvioScreen(),
    ControlPaqueteScreen(),
    AtencionPaqueteScreen(),
    InteroperabilidadPaqueteScreen(),
    InventarioPaqueteScreen(),


































































































































































































































































































































    
    AlertasPaqueteScreen(),
    EntregasPaqueteScreen(),
  ];

  final List<String> paquetesLabels = [
    "Nuevo",
    "Control",
    "Atención",
    "InterOp",
    "Inventario",
    "Alertas",
    "Entregas",
  ];

  final List<IconData> paquetesIcons = [
    Icons.add_box_outlined,
    Icons.history_outlined,
    Icons.help_outline,
    Icons.link_outlined,
    Icons.storefront_outlined,
    Icons.warning_amber_outlined,
    Icons.done_all_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 600) {
            // Pantallas grandes (tablets o escritorio)
            return Row(
              children: [
                NavigationRail(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  labelType: NavigationRailLabelType.all,
                  destinations: List.generate(paquetesLabels.length, (index) {
                    return NavigationRailDestination(
                      icon: Icon(paquetesIcons[index]),
                      selectedIcon: Icon(paquetesIcons[index], color: Colors.blueAccent),
                      label: Text(paquetesLabels[index]),
                    );
                  }),
                ),
                Expanded(
                  child: paquetesScreens[_selectedIndex],
                ),
              ],
            );
          } else {
            // Pantallas pequeñas (móviles)
            return Scaffold(
              bottomNavigationBar: BottomNavigationBar(
                currentIndex: _selectedIndex,
                onTap: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                items: List.generate(paquetesLabels.length, (index) {
                  return BottomNavigationBarItem(
                    icon: Icon(paquetesIcons[index]),
                    label: paquetesLabels[index],
                  );
                }),
                selectedItemColor: Colors.blueAccent,
                unselectedItemColor: Colors.grey,
                showUnselectedLabels: true,
                type: BottomNavigationBarType.fixed,
              ),
              body: paquetesScreens[_selectedIndex],
            );
          }
        },
      ),
    );
  }
}
