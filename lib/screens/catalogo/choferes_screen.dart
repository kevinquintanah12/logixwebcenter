import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'add_choferes_screen.dart';

class ChoferesScreen extends StatelessWidget {
  const ChoferesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> choferes = [
      {'nombre': 'Juan Pérez', 'licencia': 'A123456', 'horario': '08:00 - 16:00'},
      {'nombre': 'Ana Martínez', 'licencia': 'B654321', 'horario': '09:00 - 17:00'},
      {'nombre': 'Carlos Gómez', 'licencia': 'C789012', 'horario': '07:00 - 15:00'},
      {'nombre': 'Laura Ruiz', 'licencia': 'D987654', 'horario': '10:00 - 18:00'},
      {'nombre': 'Mario López', 'licencia': 'E321098', 'horario': '11:00 - 19:00'},
    ];

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Gestión de Choferes'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.add, color: CupertinoColors.activeBlue),
          onPressed: () {
            Navigator.push(
              context,
              CupertinoPageRoute(builder: (context) => AddChoferesScreen()),
            );
          },
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CupertinoSearchTextField(
                placeholder: 'Buscar chofer',
                onChanged: (value) {},
              ),
            ),
            Expanded(
              child: CupertinoScrollbar(
                child: ListView.builder(
                  itemCount: choferes.length,
                  itemBuilder: (context, index) {
                    final chofer = choferes[index];
                    return _buildChoferCard(chofer, context);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChoferCard(Map<String, String> chofer, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () {},
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: CupertinoColors.systemGrey6,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chofer['nombre']!,
                    style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text('Licencia: ${chofer['licencia']}'),
                  Text('Horario: ${chofer['horario']}'),
                ],
              ),
              Row(
                children: [
                  CupertinoButton(
                    child: const Icon(CupertinoIcons.time), // Ícono de horario
                    onPressed: () {
                      _asignarNuevoHorario(context, chofer);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarHorario(BuildContext context, Map<String, String> chofer) {
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text('Horario de ${chofer['nombre']}'),
          content: Text('Horario: ${chofer['horario']}'),
          actions: [
            CupertinoDialogAction(
              child: const Text('Cerrar'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  void _asignarNuevoHorario(BuildContext context, Map<String, String> chofer) {
    TextEditingController horarioController = TextEditingController();

    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return CupertinoActionSheet(
          title: Text('Asignar nuevo horario a ${chofer['nombre']}'),
          message: CupertinoTextField(
            controller: horarioController,
            placeholder: 'Ingrese nuevo horario',
          ),
          actions: [
            CupertinoActionSheetAction(
              onPressed: () {
                print('Nuevo horario asignado: ${horarioController.text}');
                Navigator.pop(context);
              },
              child: const Text('Guardar'),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        );
      },
    );
  }
}
