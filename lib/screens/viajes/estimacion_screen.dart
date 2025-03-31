import 'package:flutter/material.dart';
import 'package:shop/entry_point.dart';

class EstimacionScreen extends StatefulWidget {
  const EstimacionScreen({super.key});

  @override
  _EstimacionScreenState createState() => _EstimacionScreenState();
}

class _EstimacionScreenState extends State<EstimacionScreen> {
  // Datos iniciales para las rutas
  final List<Map<String, dynamic>> rutas = [
    {
      "numero": 1,
      "nombreRuta": "Base de transportes",
      "categoria": "Base",
      "clasificacion": "Planta",
      "audio": "-",
      "actividades": [
        {"llegada": "2018/01/01 - 13:00", "actividad": "Descarga", "producto": "Aceite", "cantidad": 2500.00, "unidad": "Litros"},
        {"llegada": "2018/01/01 - 14:20", "actividad": "Carga", "producto": "Alambrón", "cantidad": 285, "unidad": "Kg/m"}
      ]
    },
    {
      "numero": 2,
      "nombreRuta": "Almacén de material",
      "categoria": "Logístico",
      "clasificacion": "Agencia",
      "audio": "-",
      "actividades": [
        {"llegada": "2018/01/02 - 10:00", "actividad": "Carga", "producto": "Cemento", "cantidad": 1500.00, "unidad": "Kg"}
      ]
    }
  ];

  // Opciones para listas desplegables
  final List<String> actividades = ["Carga", "Descarga"];
  final List<String> productos = ["Aceite", "Alambrón", "Cemento", "Gasolina"];
  final List<String> unidades = ["Litros", "Kg/m", "Kg"];

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
              _buildInfoRow('Origen:', 'Base de Transportes, Coatzacoalcos, Veracruz'),
              _buildInfoRow('Destino:', 'Empresa SA de CV, Villahermosa, Tabasco'),
              const SizedBox(height: 20),
              const Text(
                'Información de la ruta',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: rutas.length,
                itemBuilder: (context, index) {
                  final ruta = rutas[index];
                  return Card(
                    color: const Color(0xFF2A2A2A),
                    child: ExpansionTile(
                      collapsedTextColor: Colors.white,
                      textColor: Colors.white,
                      iconColor: Colors.white,
                      title: Row(
                        children: [
                          Checkbox(
                            value: false,
                            onChanged: (value) {},
                            activeColor: Colors.white,
                            checkColor: Colors.black,
                          ),
                          Expanded(
                            child: Text(
                              ruta["nombreRuta"],
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      children: [
                        _buildActividadTable(ruta["actividades"]),
                      ],
                    ),
                  );
                },
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
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 16, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildActividadTable(List<dynamic> actividadesList) {
    if (actividadesList.isEmpty){
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          "No hay actividades disponibles",
          style: TextStyle(color: Colors.white),
        ),
      );
    }


    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: MaterialStateProperty.all(const Color(0xFF1E1E1E)),
        dataRowColor: MaterialStateProperty.all(const Color(0xFF2A2A2A)),
        columnSpacing: 12.0,
        headingTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        dataTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 13,
        ),
        columns: const [
          DataColumn(label: Text("Fecha")),
          DataColumn(label: Text("Hora")),
          DataColumn(label: Text("Minutos")),
          DataColumn(label: Text("Actividad")),
          DataColumn(label: Text("Producto")),
          DataColumn(label: Text("Cantidad")),
          DataColumn(label: Text("Unidad de medida")),
        ],
        rows: actividadesList.map((actividad) {
          return DataRow(
            cells: [
              DataCell(
                IconButton(
                  icon: const Icon(Icons.calendar_today, color: Colors.white),
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (date != null) {
                      setState(() {
                        actividad["llegada"] =
                            "${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}";
                      });
                    }
                  },
                ),
              ),
              DataCell(
                DropdownButton<int>(
                  dropdownColor: const Color(0xFF2A2A2A),
                  value: int.tryParse(actividad["llegada"].split(" - ")[1].split(":")[0]) ?? 0,
                  items: List.generate(24, (index) => index).map((hour) {
                    return DropdownMenuItem<int>(
                      value: hour,
                      child: Text(
                        hour.toString().padLeft(2, '0'),
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      final minutos = actividad["llegada"].split(" - ")[1].split(":")[1];
                      actividad["llegada"] =
                          "${actividad["llegada"].split(" - ")[0]} - ${value.toString().padLeft(2, '0')}:$minutos";
                    });
                  },
                ),
              ),
              DataCell(
                DropdownButton<int>(
                  dropdownColor: const Color(0xFF2A2A2A),
                  value: int.tryParse(actividad["llegada"].split(" - ")[1].split(":")[1]) ?? 0,
                  items: List.generate(60, (index) => index).map((minute) {
                    return DropdownMenuItem<int>(
                      value: minute,
                      child: Text(
                        minute.toString().padLeft(2, '0'),
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      final horas = actividad["llegada"].split(" - ")[1].split(":")[0];
                      actividad["llegada"] =
                          "${actividad["llegada"].split(" - ")[0]} - $horas:${value.toString().padLeft(2, '0')}";
                    });
                  },
                ),
              ),
              DataCell(
                DropdownButton<String>(
                  dropdownColor: const Color(0xFF2A2A2A),
                  value: actividad["actividad"],
                  items: actividades.map((act) {
                    return DropdownMenuItem<String>(
                      value: act,
                      child: Text(act, style: const TextStyle(color: Colors.white)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      actividad["actividad"] = value!;
                    });
                  },
                ),
              ),
              DataCell(
                DropdownButton<String>(
                  dropdownColor: const Color(0xFF2A2A2A),
                  value: actividad["producto"],
                  items: productos.map((producto) {
                    return DropdownMenuItem<String>(
                      value: producto,
                      child: Text(producto, style: const TextStyle(color: Colors.white)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      actividad["producto"] = value!;
                    });
                  },
                ),
              ),
              DataCell(
                TextFormField(
                  initialValue: actividad["cantidad"].toString(),
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    isDense: true,
                    filled: true,
                    fillColor: const Color(0xFF1E1E1E),
                  ),
                  onChanged: (value) {
                    setState(() {
                      actividad["cantidad"] = double.tryParse(value) ?? actividad["cantidad"];
                    });
                  },
                ),
              ),
              DataCell(
                DropdownButton<String>(
                  dropdownColor: const Color(0xFF2A2A2A),
                  value: actividad["unidad"],
                  items: unidades.map((unidad) {
                    return DropdownMenuItem<String>(
                      value: unidad,
                      child: Text(unidad, style: const TextStyle(color: Colors.white)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      actividad["unidad"] = value!;
                    });
                  },
                ),
              ),
            ],
          );
        }).toList(),
      ),
      
    );
    Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 100,
                    child: ElevatedButton(
                      onPressed: () {
                        _Aceptar(context);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('Aceptar'),
                    ),
                  ),
                ],
              );
  }

    void _Aceptar(BuildContext context) {
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
