import 'dart:async';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class InteroperabilidadPaqueteScreen extends StatelessWidget {
  // Ahora incluimos conductor.usuario.username
  static const String _todasRutasQuery = r'''
    query TodasRutas {
      todasRutas {
        id
        distancia
        prioridad
        estado
        conductor {
          usuario {
            username
          }
        }
      }
    }
  ''';

  @override
  Widget build(BuildContext context) {
    final client = GraphQLProvider.of(context).value as GraphQLClient;

    return Scaffold(
      appBar: AppBar(title: const Text('Interoperabilidad de Paquetes')),
      body: Query(
        options: QueryOptions(
          document: gql(_todasRutasQuery),
          fetchPolicy: FetchPolicy.networkOnly,
        ),
        builder: (routeRes, {fetchMore, refetch}) {
          if (routeRes.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (routeRes.hasException) {
            return Center(
              child: Text('Error cargando rutas: ${routeRes.exception}'),
            );
          }

          final rutas = (routeRes.data!['todasRutas'] as List)
              .cast<Map<String, dynamic>>();
          if (rutas.isEmpty) {
            return const Center(child: Text('No hay rutas disponibles'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: rutas.length,
            itemBuilder: (ctx, idx) {
              final ruta = rutas[idx];
              final rutaId = ruta['id'].toString();
              final usuario = ruta['conductor']?['usuario']?['username'] as String? ?? '—';

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 4,
                child: ExpansionTile(
                  key: ValueKey('ruta_$rutaId'),
                  title: Text(
                    'Ruta $rutaId',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Estado: ${ruta['estado']}'),
                  childrenPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        Chip(label: Text('Dist: ${ruta['distancia']} km')),
                        Chip(label: Text('Prio: ${ruta['prioridad']}')),
                        Chip(label: Text('Chofer: $usuario')),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SensorChartCard(rutaId: rutaId, client: client),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class SensorChartCard extends StatefulWidget {
  final String rutaId;
  final GraphQLClient client;
  const SensorChartCard({
    Key? key,
    required this.rutaId,
    required this.client,
  }) : super(key: key);

  @override
  _SensorChartCardState createState() => _SensorChartCardState();
}

class _SensorChartCardState extends State<SensorChartCard> {
  static const String _sensoresQuery = r'''
    query SensoresPorRuta($rutaId: ID!) {
      sensoresPorRuta(rutaId: $rutaId) {
        id
        temperatura
        humedad
        timestamp
      }
    }
  ''';

  static const String _sensoresSubscription = r'''
    subscription NuevosSensores($rutaId: ID!) {
      sensorPorRuta(rutaId: $rutaId) {
        sensor {
          id
          temperatura
          humedad
          timestamp
        }
      }
    }
  ''';

  final List<Map<String, dynamic>> _sensores = [];
  StreamSubscription<QueryResult>? _sub;
  final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
  int _selectedView = 0; // 0 = gráfica, 1 = datos

  @override
  void initState() {
    super.initState();
    _fetchInitial();
    _listenForNew();
  }

  Future<void> _fetchInitial() async {
    final result = await widget.client.query(
      QueryOptions(
        document: gql(_sensoresQuery),
        variables: {'rutaId': widget.rutaId},
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );
    if (!result.hasException) {
      final list = (result.data!['sensoresPorRuta'] as List)
          .cast<Map<String, dynamic>>();
      setState(() {
        _sensores
          ..clear()
          ..addAll(list);
      });
    }
  }

  void _listenForNew() {
    _sub = widget.client
        .subscribe(
          SubscriptionOptions(
            document: gql(_sensoresSubscription),
            variables: {'rutaId': widget.rutaId},
          ),
        )
        .listen((snap) {
      if (!snap.isLoading &&
          snap.data != null &&
          snap.exception == null) {
        final sensor = (snap.data!['sensorPorRuta'] as Map<String, dynamic>)[
            'sensor'] as Map<String, dynamic>;
        setState(() {
          _sensores.insert(0, sensor);
        });
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_sensores.isEmpty) {
      return const SizedBox(
        height: 150,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    // Preparamos datos para la gráfica
    final tempSpots = <FlSpot>[];
    final humSpots = <FlSpot>[];
    for (var i = 0; i < _sensores.length; i++) {
      final s = _sensores[i];
      tempSpots.add(FlSpot(i.toDouble(), (s['temperatura'] as num).toDouble()));
      humSpots.add(FlSpot(i.toDouble(), (s['humedad'] as num).toDouble()));
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Toggle entre gráfica y datos
            ToggleButtons(
              isSelected: [ _selectedView == 0, _selectedView == 1 ],
              onPressed: (i) => setState(() => _selectedView = i),
              borderRadius: BorderRadius.circular(8),
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Text('Gráfica'),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Text('Datos'),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (_selectedView == 0) ...[
              const Text(
                'Sensores (Gráfica)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: true),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: true),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(show: true),
                    lineBarsData: [
                      LineChartBarData(
                        spots: tempSpots,
                        isCurved: true,
                        barWidth: 2,
                        dotData: FlDotData(show: false),
                        color: Theme.of(context).primaryColor,
                      ),
                      LineChartBarData(
                        spots: humSpots,
                        isCurved: true,
                        barWidth: 2,
                        dotData: FlDotData(show: false),
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  LegendDot(
                      color: Theme.of(context).primaryColor, text: 'Temp (°C)'),
                  const SizedBox(width: 16),
                  LegendDot(
                      color: Theme.of(context).colorScheme.secondary,
                      text: 'Hum (%)'),
                ],
              ),
            ] else ...[
              const Text(
                'Sensores (Datos)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _sensores.length,
                itemBuilder: (_, idx) {
                  final s = _sensores[idx];
                  final t = (s['temperatura'] as num).toDouble();
                  final h = (s['humedad'] as num).toDouble();
                  final ts = dateFormat
                      .format(DateTime.parse(s['timestamp'] as String));
                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.sensors),
                    title: Text('Sensor ${s['id']}'),
                    subtitle: Text(
                        'Temp: ${t.toStringAsFixed(1)}°C, Hum: ${h.toStringAsFixed(1)}%'),
                    trailing: Text(ts, style: const TextStyle(fontSize: 12)),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class LegendDot extends StatelessWidget {
  final Color color;
  final String text;
  const LegendDot({Key? key, required this.color, required this.text})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(text),
      ],
    );
  }
}
