import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop/entry_point.dart';

class CrearviajeScreen extends StatefulWidget {
  const CrearviajeScreen({super.key});

  @override
  _CrearviajeScreenState createState() => _CrearviajeScreenState();
}

class _CrearviajeScreenState extends State<CrearviajeScreen> {
  final TextEditingController _fechaInicioController = TextEditingController();
  final TextEditingController _fechaFinController = TextEditingController();

  Future<void> saveOperador(String operador) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('operador', operador);
  }

  Future<void> saveTransportista(String transportista) async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('transportista', transportista);
  }

  Future<void> saveRemolque(String remolque) async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('remolque', remolque);
  }

  Future<void> saveDolly(String dolly) async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('dolly', dolly);
  }

  //Future<void> saveVehiculo(String vehiculo) async{
  //  final prefs = await SharedPreferences.getInstance();
  //  await prefs.setString('vehiculo', vehiculo);
  //}


  String _folio = '';

  final List<String> _operadores = ["1", "2", "3"];
  final List<String> _transportistas = ["1", "2", "3", "4", "5"];
  final List<String> _remolques = ["1", "2", "3", "4", "5"];
  final List<String> _dollys = ["1", "2", "3", "4", "5"];
  final List<Map<String, String>> _vehiculos = [
    {'numeroEconomico': 'TR-890', 'marca': 'Freightliner', 'modelo': 'Cascadia', 'anio': '2018', 'placas': 'DW-821'},
    {'numeroEconomico': 'TR-891', 'marca': 'Kenworth', 'modelo': 'T680', 'anio': '2019', 'placas': 'DW-822'},
    {'numeroEconomico': 'TR-892', 'marca': 'Volvo', 'modelo': 'VNL', 'anio': '2020', 'placas': 'DW-823'},
    {'numeroEconomico': 'TR-893', 'marca': 'Mack', 'modelo': 'Anthem', 'anio': '2017', 'placas': 'DW-824'},
    {'numeroEconomico': 'TR-894', 'marca': 'Peterbilt', 'modelo': '579', 'anio': '2021', 'placas': 'DW-825'},
  ];

  String? _operadorSeleccionado;
  String? _transportistaSeleccionado;
  String? _remolqueSeleccionado;
  String? _dollySeleccionado;
  Map<String, String>? _vehiculoSeleccionado;

  @override
  void initState() {
    super.initState();
    _folio = _generarFolio();
  }

  String _generarFolio() {
    return '000120${DateTime.now().year}';
  }

  @override
  Widget build(BuildContext context) {
    //var appState = context.watch<MyAppState>();
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 248, 248, 248), // Fondo oscuro
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Información General'),
              _buildInputField('Folio despacho', _folio, readOnly: true),
              _buildDateInputField('Fecha de inicio', _fechaInicioController),
              _buildDateInputField('Fecha de fin', _fechaFinController),

              _buildSectionTitle('Detalles del Operador'),
              _buildDropdownField('Operador', _operadores, _operadorSeleccionado, (value) {
                setState(() {
                  saveOperador(value!);
                });
              }),
              _buildDropdownField('Transportista', _transportistas, _transportistaSeleccionado, (value) {
                setState(() {
                  saveTransportista(value!);
                });
              }),

              _buildSectionTitle('Detalles del Vehículo'),
              _buildDropdownField('Remolque', _remolques, _remolqueSeleccionado, (value) {
                setState(() {
                  saveRemolque(value!);
                });
              }),
              _buildDropdownField('Dolly', _dollys, _dollySeleccionado, (value) {
                setState(() {
                  saveDolly(value!);
                });
              }),

              _buildSectionTitle('Vehículo'),
              DropdownButtonFormField<Map<String, String>>(
                value: _vehiculoSeleccionado,
                items: _vehiculos.map((vehiculo) {
                  return DropdownMenuItem<Map<String, String>>(
                    value: vehiculo,
                    child: Text('${vehiculo['marca']} - ${vehiculo['modelo']}', style: const TextStyle(color: Colors.white)),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _vehiculoSeleccionado = newValue;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Selecciona Vehículo',
                  labelStyle: const TextStyle(color: Colors.white),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  filled: true,
                  fillColor: Colors.grey[800],
                ),
                dropdownColor: Colors.grey[900],
              ),
              if (_vehiculoSeleccionado != null) ...[
                const SizedBox(height: 20),
                Text('Número Económico: ${_vehiculoSeleccionado!['numeroEconomico']}', style: const TextStyle(color: Colors.white)),
                Text('Marca: ${_vehiculoSeleccionado!['marca']}', style: const TextStyle(color: Colors.white)),
                Text('Modelo: ${_vehiculoSeleccionado!['modelo']}', style: const TextStyle(color: Colors.white)),
                Text('Año: ${_vehiculoSeleccionado!['anio']}', style: const TextStyle(color: Colors.white)),
                Text('Placas: ${_vehiculoSeleccionado!['placas']}', style: const TextStyle(color: Colors.white)),
              ],
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 100,
                    child: ElevatedButton(
                      onPressed: () {
                        _mostrarConfirmacionCancelacion(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }

  Widget _buildInputField(String label, String initialValue, {bool readOnly = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          filled: true,
          fillColor: Colors.grey[800],
        ),
        readOnly: readOnly,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildDropdownField(String label, List<String> options, String? selectedValue, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        items: options.map((option) {
          return DropdownMenuItem<String>(
            value: option,
            child: Text(option, style: const TextStyle(color: Colors.white)),
          );
        }).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          filled: true,
          fillColor: Colors.grey[800],
        ),
        dropdownColor: Colors.grey[900],
      ),
    );
  }

  Widget _buildDateInputField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          suffixIcon: IconButton(
            icon: const Icon(Icons.calendar_today, color: Colors.white),
            onPressed: () => _seleccionarFecha(context, controller),
          ),
          filled: true,
          fillColor: Colors.grey[800],
        ),
        readOnly: true,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  Future<void> _seleccionarFecha(BuildContext context, TextEditingController controller) async {
    DateTime? fecha = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (fecha != null) {
      controller.text = DateFormat('yyyy/MM/dd').format(fecha);
    }
  }

  void _mostrarConfirmacionCancelacion(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('¿Estás seguro de Cancelar?', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.grey[900],
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Rechazar', style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const EntryPoint()),
                );
              },
              child: const Text('Aceptar', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
