import 'package:flutter/material.dart';
import 'package:shop/screens/viajes/tab_screen.dart';
import 'package:shop/screens/viajes/traileros_screen.dart';

class ViajesScreen extends StatelessWidget {
  const ViajesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Viajes'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TrailerosScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Folio despacho')),
                      DataColumn(label: Text('Operador')),
                      DataColumn(label: Text('# Económico')),
                      DataColumn(label: Text('Territorio')),
                      DataColumn(label: Text('Fecha asignación')),
                      DataColumn(label: Text('Estado operativo')),
                      DataColumn(label: Text('Estado administrativo')),
                      DataColumn(label: Text('Fecha TEA')),
                      DataColumn(label: Text('Estado TEA')),
                      DataColumn(label: Text('Fin de viaje')),
                    ],
                    rows: const [
                      DataRow(cells: [
                        DataCell(Text('000038...')),
                        DataCell(Text('Alejandro Ávila')),
                        DataCell(Text('A8963')),
                        DataCell(Text('Centro')),
                        DataCell(Text('2018/03/24 - 10:00:20')),
                        DataCell(Text('En curso cargando')),
                        DataCell(Text('En tránsito')),
                        DataCell(Text('2018/03/30 - 10:00:20')),
                        DataCell(Text('A tiempo')),
                        DataCell(Text('2018/04/02 - 10:00:20')),
                      ]),
                      DataRow(cells: [
                        DataCell(Text('000985...')),
                        DataCell(Text('Carlos Díaz')),
                        DataCell(Text('C5012')),
                        DataCell(Text('Sur')),
                        DataCell(Text('2019/05/16 - 14:45:10')),
                        DataCell(Text('En curso')),
                        DataCell(Text('Activo')),
                        DataCell(Text('2019/06/01 - 08:30:10')),
                        DataCell(Text('A tiempo')),
                        DataCell(Text('2019/06/04 - 12:00:00')),
                      ]),
                      DataRow(cells: [
                        DataCell(Text('000583...')),
                        DataCell(Text('Marta Fernández')),
                        DataCell(Text('D2021')),
                        DataCell(Text('Norte')),
                        DataCell(Text('2020/02/14 - 09:20:05')),
                        DataCell(Text('Completado')),
                        DataCell(Text('Finalizado')),
                        DataCell(Text('2020/02/18 - 16:00:00')),
                        DataCell(Text('Completado')),
                        DataCell(Text('2020/02/19 - 11:00:00')),
                      ]),
                      DataRow(cells: [
                        DataCell(Text('000623...')),
                        DataCell(Text('Luis Hernández')),
                        DataCell(Text('E1042')),
                        DataCell(Text('Este')),
                        DataCell(Text('2021/09/08 - 18:30:10')),
                        DataCell(Text('Retrasado')),
                        DataCell(Text('Pendiente')),
                        DataCell(Text('2021/09/10 - 08:00:00')),
                        DataCell(Text('Retrasado')),
                        DataCell(Text('2021/09/12 - 13:00:00')),
                      ]),
                      DataRow(cells: [
                        DataCell(Text('001234...')),
                        DataCell(Text('Antonio Pérez')),
                        DataCell(Text('A1234')),
                        DataCell(Text('Sur')),
                        DataCell(Text('2022/01/01 - 12:15:30')),
                        DataCell(Text('En espera')),
                        DataCell(Text('En preparación')),
                        DataCell(Text('2022/01/03 - 10:45:15')),
                        DataCell(Text('Atrasado')),
                        DataCell(Text('2022/01/05 - 17:20:10')),
                      ]),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TabScreen()),
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }
}



