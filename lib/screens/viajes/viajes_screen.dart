import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class ViajesScreen extends StatelessWidget {
  const ViajesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Query que trae rutas por estado "por hacer" con información anidada.
    // Se asume que la API retorna todas las rutas "por hacer".
    const String rutasQuery = r'''
      query {
        rutasCompletasPorEstado(estado: "por hacer") {
          id
          distancia
          prioridad
          estado
          fechaInicio
          fechaFin
          conductor {
            id
            nombre
            usuario {
              username
              email
            }
          }
          vehiculo {
            id
            modelo
          }
          entregas {
            id
            fechaEntrega
            paquete {
              id
              numeroGuia
            }
          }
        }
      }
    ''';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Viajes'),
        backgroundColor: Colors.blue,
        // Se quita el botón de Traileros
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Query(
          options: QueryOptions(
            document: gql(rutasQuery),
            // Refresca cada 10 segundos (opcional)
            pollInterval: const Duration(seconds: 10),
          ),
          builder: (QueryResult result, {FetchMore? fetchMore, VoidCallback? refetch}) {
            // Error y Loading
            if (result.hasException) {
              return Center(child: Text('Error: ${result.exception.toString()}'));
            }
            if (result.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            // Extraemos el dato del query
            final dynamic dataFromResult = result.data?['rutasCompletasPorEstado'];

            // Convertir a lista: si es List, lo usa; si es Map, lo envuelve en una lista.
            List<dynamic> rutas = [];
            if (dataFromResult is List) {
              rutas = dataFromResult;
            } else if (dataFromResult is Map<String, dynamic>) {
              rutas = [dataFromResult];
            }

            if (rutas.isEmpty) {
              return const Center(child: Text("No hay rutas disponibles"));
            }

            // Obtenemos la fecha de hoy y mañana
            final DateTime now = DateTime.now();
            final DateTime today = DateTime(now.year, now.month, now.day);
            final DateTime tomorrow = today.add(const Duration(days: 1));

            // Separamos las rutas según su fechaInicio
            List<dynamic> rutasHoy = [];
            List<dynamic> rutasManana = [];
            for (var ruta in rutas) {
              // Se asume que "fechaInicio" es un string en formato ISO compatible.
              final String fechaStr = ruta['fechaInicio'] ?? "";
              final DateTime? fechaInicio = DateTime.tryParse(fechaStr);
              if (fechaInicio != null) {
                final DateTime fecha = DateTime(fechaInicio.year, fechaInicio.month, fechaInicio.day);
                if (fecha.compareTo(today) == 0) {
                  rutasHoy.add(ruta);
                } else if (fecha.compareTo(tomorrow) == 0) {
                  rutasManana.add(ruta);
                }
              }
            }

            // Creamos dos secciones: una para Hoy y otra para Mañana.
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (rutasHoy.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text("Hoy", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                    _buildDataTable(rutasHoy),
                  ],
                  if (rutasManana.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text("Mañana", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                    _buildDataTable(rutasManana),
                  ],
                  if (rutasHoy.isEmpty && rutasManana.isEmpty)
                    const Center(child: Text("No hay viajes para hoy o mañana")),
                ],
              ),
            );
          },
        ),
      ),
      // Se elimina el floatingActionButton
    );
  }

  // Función para construir una DataTable a partir de una lista de rutas.
  Widget _buildDataTable(List<dynamic> rutas) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('ID')),
          DataColumn(label: Text('Distancia')),
          DataColumn(label: Text('Prioridad')),
          DataColumn(label: Text('Estado')),
          DataColumn(label: Text('Fecha Inicio')),
          DataColumn(label: Text('Fecha Fin')),
          DataColumn(label: Text('Conductor')),
          DataColumn(label: Text('Usuario')),
          DataColumn(label: Text('Vehículo')),
          DataColumn(label: Text('Guía')),
        ],
        rows: rutas.map((ruta) {
          // Extraemos datos anidados
          final conductor = ruta['conductor'];
          final usuario = conductor?['usuario'];
          final vehiculo = ruta['vehiculo'];

          // Se utiliza la primera entrega para obtener el número de guía, si existe.
          final List<dynamic> entregas = ruta['entregas'] is List ? ruta['entregas'] : [];
          final paquete = (entregas.isNotEmpty && entregas[0]['paquete'] != null)
              ? entregas[0]['paquete']
              : null;
          final String numeroGuia = paquete != null ? paquete['numeroGuia']?.toString() ?? '' : 'N/A';

          return DataRow(
            cells: [
              DataCell(Text(ruta['id'].toString())),
              DataCell(Text(ruta['distancia'].toString())),
              DataCell(Text(ruta['prioridad'].toString())),
              DataCell(Text(ruta['estado'] ?? "")),
              DataCell(Text(ruta['fechaInicio'] ?? "")),
              DataCell(Text(ruta['fechaFin'] ?? "")),
              DataCell(Text(conductor != null ? (conductor['nombre'] ?? "") : "")),
              DataCell(Text(usuario != null ? (usuario['username'] ?? "") : "")),
              DataCell(Text(vehiculo != null ? (vehiculo['modelo'] ?? "") : "")),
              DataCell(Text(numeroGuia)),
            ],
          );
        }).toList(),
      ),
    );
  }
}
