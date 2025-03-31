import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop/models/viaje_model.dart';

import 'crearviaje_screen.dart';
import 'estimacion_screen.dart';
import 'rutas_screen.dart';

class TabScreen extends StatefulWidget {
  const TabScreen({Key? key}) : super(key: key);

  @override
  _TabScreenState createState() => _TabScreenState();
}

class _TabScreenState extends State<TabScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  var myviaje = new Viaje();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Método para cambiar de tab
  void changeTab(int index) {
    _tabController.animateTo(index);
  }

  void guardarDatos() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final operador =  prefs.getString('operador');
    final transportista = prefs.getString('transportista');
    final remolque = prefs.getString('remolque');
    final dolly = prefs.getString('dolly');
    //final vehiculo = prefs.getString('vehiculo');

    myviaje.Idoperador = int.parse(operador!);
    myviaje.Idtransportista = int.parse(transportista!);
    myviaje.Idremolque = int.parse(remolque!);
    myviaje.Iddolly = int.parse(dolly!);
    //myviaje.idvehiculo = int.parse(vehiculo!);
    //meter todos los viajes crear viaje
    print(myviaje.Idoperador);
    print(myviaje.Idtransportista);
    print(myviaje.Idremolque);
    print(myviaje.Iddolly);
    //print(myviaje.Idvehiculo);
  }

  // Método para manejar el botón de guardar
  void guardarCambios(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Guardar Cambios'),
          content: const Text('¿Deseas guardar los cambios realizados?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cambios guardados exitosamente.')),
                );
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Fondo oscuro
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 200, 200, 200), // Fondo oscuro del AppBar
        actions: [
          IconButton(
            onPressed: () => guardarDatos(),
            icon: const Icon(Icons.save),
            tooltip: 'Guardar',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.blue, // Indicador azul en la pestaña activa
          labelColor: Colors.blue, // Color del texto de la pestaña activa
          unselectedLabelColor: Colors.white, // Color del texto de pestañas inactivas
          tabs: const [
            Tab(text: 'Crear Viaje'),
            Tab(text: 'Rutas'),
            Tab(text: 'Estimación'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          CrearviajeScreen(),
          RutasScreen(),
          EstimacionScreen(),
        ],
      ),
    );
  }
}
