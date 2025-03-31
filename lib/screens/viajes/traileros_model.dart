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
  });
}

class TraileroCard extends StatelessWidget {
  final Trailero trailero;

  const TraileroCard({Key? key, required this.trailero}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(trailero.foto),
          radius: 30,
        ),
        title: Text(trailero.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("Clave: ${trailero.claveOperador}"),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Operador", style: TextStyle(fontWeight: FontWeight.bold)),
                const Divider(),
                _buildInfoRow("Clave operador:", trailero.claveOperador),
                _buildInfoRow("Nombre:", trailero.nombre),
                _buildInfoRow("Número de licencia:", trailero.numeroLicencia),
                _buildInfoRow("Tipo licencia:", trailero.tipoLicencia),
                _buildInfoRow("Fecha de vigencia:", trailero.fechaVigencia),
                const SizedBox(height: 10),
                const Text("Vehículo", style: TextStyle(fontWeight: FontWeight.bold)),
                const Divider(),
                _buildInfoRow("# Económico:", trailero.economico),
                _buildInfoRow("Marca:", trailero.marca),
                _buildInfoRow("Modelo:", trailero.modelo),
                _buildInfoRow("Año:", trailero.anio.toString()),
                _buildInfoRow("Placas:", trailero.placas),
                _buildInfoRow("Remolque:", trailero.remolque),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 10),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}
