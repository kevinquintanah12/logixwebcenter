import 'package:flutter/material.dart';

class Trailero {
  final String claveOperador;
  final String nombre;
  final String numeroLicencia;
  final String tipoLicencia;
  final String fechaVigencia;
  final String economico;
  final String marca;
  final String modelo;
  final int anio;
  final String placas;
  final String remolque;
  final String foto;
  final String origen;
  final String destino;

  Trailero({
    required this.claveOperador,
    required this.nombre,
    required this.numeroLicencia,
    required this.tipoLicencia,
    required this.fechaVigencia,
    required this.economico,
    required this.marca,
    required this.modelo,
    required this.anio,
    required this.placas,
    required this.remolque,
    required this.foto,
    required this.origen,
    required this.destino,
  });
}

class TrailerosScreen extends StatelessWidget {
  const TrailerosScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Lista de traileros y sus rutas
    final List<Trailero> traileros = [
      Trailero(
        claveOperador: "OP-037",
        nombre: "Juan Pérez",
        numeroLicencia: "72795608040",
        tipoLicencia: "B",
        fechaVigencia: "2018/04/10",
        economico: "TR-890",
        marca: "Freightliner",
        modelo: "Cascadia",
        anio: 2018,
        placas: "DW-821",
        remolque: "R-01",
        foto: "https://via.placeholder.com/150",
        origen: "Base de Transportes, Coatzacoalcos, Veracruz",
        destino: "Empresa SA de CV, Villahermosa, Tabasco",
      ),
      Trailero(
        claveOperador: "OP-042",
        nombre: "María López",
        numeroLicencia: "82637495012",
        tipoLicencia: "C",
        fechaVigencia: "2022/09/15",
        economico: "TR-102",
        marca: "Kenworth",
        modelo: "T680",
        anio: 2020,
        placas: "DW-456",
        remolque: "R-05",
        foto: "https://via.placeholder.com/150",
        origen: "Almacén Logístico, Veracruz",
        destino: "Planta Industrial, Monterrey, Nuevo León",
      ),
      Trailero(
        claveOperador: "OP-045",
        nombre: "Carlos Díaz",
        numeroLicencia: "73628745019",
        tipoLicencia: "A",
        fechaVigencia: "2023/11/22",
        economico: "TR-304",
        marca: "Volvo",
        modelo: "FH16",
        anio: 2019,
        placas: "XT-789",
        remolque: "R-09",
        foto: "https://via.placeholder.com/150",
        origen: "Centro de Distribución, Puebla",
        destino: "Tienda Principal, Ciudad de México",
      ),
      Trailero(
        claveOperador: "OP-059",
        nombre: "Ana Martínez",
        numeroLicencia: "92837465023",
        tipoLicencia: "B",
        fechaVigencia: "2024/06/10",
        economico: "TR-501",
        marca: "Mercedes-Benz",
        modelo: "Actros",
        anio: 2021,
        placas: "HG-452",
        remolque: "R-12",
        foto: "https://via.placeholder.com/150",
        origen: "Planta Industrial, Guadalajara",
        destino: "Puerto Marítimo, Manzanillo",
      ),
      Trailero(
        claveOperador: "OP-063",
        nombre: "Luis Hernández",
        numeroLicencia: "10293847560",
        tipoLicencia: "C",
        fechaVigencia: "2025/01/01",
        economico: "TR-892",
        marca: "Scania",
        modelo: "R500",
        anio: 2022,
        placas: "ZL-321",
        remolque: "R-20",
        foto: "https://via.placeholder.com/150",
        origen: "Aeropuerto Internacional, Monterrey",
        destino: "Zona Fronteriza, Nuevo Laredo",
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Lista de Traileros en ruta"),
      ),
      body: ListView.builder(
        itemCount: traileros.length,
        itemBuilder: (context, index) {
          final trailero = traileros[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ExpansionTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(trailero.foto),
                radius: 25,
              ),
              title: Text(
                trailero.nombre,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Detalles del Operador",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text("Clave Operador: ${trailero.claveOperador}"),
                      Text("Número Licencia: ${trailero.numeroLicencia}"),
                      Text("Tipo Licencia: ${trailero.tipoLicencia}"),
                      Text("Fecha Vigencia: ${trailero.fechaVigencia}"),
                      const SizedBox(height: 10),
                      const Text(
                        "Detalles del Vehículo",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text("Económico: ${trailero.economico}"),
                      Text("Marca: ${trailero.marca}"),
                      Text("Modelo: ${trailero.modelo}"),
                      Text("Año: ${trailero.anio}"),
                      Text("Placas: ${trailero.placas}"),
                      Text("Remolque: ${trailero.remolque}"),
                      const SizedBox(height: 10),
                      const Text(
                        "Detalles de la Ruta",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text("Origen: ${trailero.origen}"),
                      Text("Destino: ${trailero.destino}"),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
