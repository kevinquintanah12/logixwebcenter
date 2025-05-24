import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

/// Formateador custom para convertir texto a mayúsculas
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
  ) {
    return newValue.copyWith(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

class AddChoferesScreen extends StatefulWidget {
  const AddChoferesScreen({Key? key}) : super(key: key);

  @override
  _AddChoferesScreenState createState() => _AddChoferesScreenState();
}

class _AddChoferesScreenState extends State<AddChoferesScreen> {
  final nombreController          = TextEditingController();
  final apellidosController       = TextEditingController();
  final rfcController             = TextEditingController();
  final licenciaController        = TextEditingController();
  final certificacionesController = TextEditingController();
  final emailController           = TextEditingController();
  String? selectedHorarioId;

  // Máscara para RFC: 4 letras, 6 dígitos (fecha), 3 caracteres alfanuméricos
  final rfcFormatter = MaskTextInputFormatter(
    mask: 'AAAA######AAA',
    filter: { 'A': RegExp(r'[A-Za-z]'), '#': RegExp(r'[0-9]') },
    type: MaskAutoCompletionType.eager,
  );

  // Ejemplo de máscara para Licencia: 3 letras + 6 dígitos
  final licenciaFormatter = MaskTextInputFormatter(
    mask: 'AAA######',
    filter: { 'A': RegExp(r'[A-Za-z]'), '#': RegExp(r'[0-9]') },
    type: MaskAutoCompletionType.eager,
  );

  // RegEx sencillo para email
  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: Colors.white.withOpacity(0.5),
        middle: const Text(
          'Agregar Chofer',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            fontFamily: 'Grandis Extended',
          ),
        ),
        trailing: GestureDetector(
          onTap: _onSubmit,
          child: const Text(
            'Listo',
            style: TextStyle(
              color: CupertinoColors.activeBlue,
              fontFamily: 'Grandis Extended',
            ),
          ),
        ),
      ),
      backgroundColor: Colors.grey[200],
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGlassAvatar(),

              const SizedBox(height: 30),
              _buildFloatingTextField(
                controller: emailController,
                labelText: 'Correo electrónico',
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 10),
              _buildFloatingTextField(
                controller: nombreController,
                labelText: 'Nombre',
              ),

              const SizedBox(height: 10),
              _buildFloatingTextField(
                controller: apellidosController,
                labelText: 'Apellidos',
              ),

              const SizedBox(height: 10),
              _buildFloatingTextField(
                controller: rfcController,
                labelText: 'RFC',
                inputFormatters: [rfcFormatter, UpperCaseTextFormatter()],
              ),
              const Padding(
                padding: EdgeInsets.only(left: 12, top: 4),
                child: Text(
                  'Ejemplo: ABCD990101AAA',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ),

              const SizedBox(height: 10),
              _buildFloatingTextField(
                controller: licenciaController,
                labelText: 'Licencia',
                inputFormatters: [licenciaFormatter, UpperCaseTextFormatter()],
              ),
              const Padding(
                padding: EdgeInsets.only(left: 12, top: 4),
                child: Text(
                  'Ejemplo: ABC123456',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ),

              const SizedBox(height: 10),
              _buildFloatingTextField(
                controller: certificacionesController,
                labelText: 'Certificaciones (separadas por coma)',
                inputFormatters: [UpperCaseTextFormatter()],
              ),

              const SizedBox(height: 10),
              HorariosPicker(onSelectedHorario: (id) => setState(() => selectedHorarioId = id)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onSubmit() async {
    final email = emailController.text.trim();
    final rfcUnmasked = rfcFormatter.getUnmaskedText();
    final licUnmasked = licenciaFormatter.getUnmaskedText();

    // 1) Validar campos no vacíos
    if ([
      email,
      nombreController.text,
      apellidosController.text,
      rfcController.text,
      licenciaController.text,
      certificacionesController.text,
      selectedHorarioId
    ].any((e) => e == null || (e is String && e.isEmpty))) {
      await _showErrorDialog('Por favor, complete todos los campos');
      return;
    }

    // 2) Validar formato email
    if (!emailRegex.hasMatch(email)) {
      await _showErrorDialog('Correo inválido');
      return;
    }

    // 3) Validar RFC (13 caracteres sin máscara)
    if (rfcUnmasked.length != 13) {
      await _showErrorDialog('RFC inválido\nEjemplo: ABCD990101AAA');
      return;
    }

    // 4) Validar Licencia (9 caracteres sin máscara)
    if (licUnmasked.length != 9) {
      await _showErrorDialog('Licencia inválida\nEjemplo: ABC123456');
      return;
    }

    final client = GraphQLProvider.of(context).value;
    final randomUsername = 'logixch${Random().nextInt(9000) + 1000}';

    // ——— Crear usuario ———
    const String mCreateUser = r'''
      mutation CreateUserWithTempPwd($username: String!, $email: String!) {
        createUserWithTempPwd(username: $username, email: $email) {
          user { id username email }
          tempPassword
        }
      }
    ''';
    final userResult = await client.mutate(MutationOptions(
      document: gql(mCreateUser),
      variables: {'username': randomUsername, 'email': email},
    ));
    if (userResult.hasException || userResult.data == null) {
      await _showErrorDialog('Error al crear usuario');
      return;
    }
    final userId = int.parse(userResult.data!['createUserWithTempPwd']['user']['id'].toString());

    // ——— Crear chofer ———
    const String mCreateChofer = r'''
      mutation CreateChofer(
        $userId: Int!,
        $nombre: String!,
        $apellidos: String!,
        $rfc: String!,
        $licencia: String!,
        $certificaciones: String!,
        $horarioId: Int!
      ) {
        createChofer(
          userId: $userId,
          nombre: $nombre,
          apellidos: $apellidos,
          rfc: $rfc,
          licencia: $licencia,
          certificaciones: $certificaciones,
          horarioId: $horarioId
        ) {
          chofer { id nombre }
        }
      }
    ''';
    final horarioInt = int.parse(selectedHorarioId!);
    final choferResult = await client.mutate(MutationOptions(
      document: gql(mCreateChofer),
      variables: {
        'userId': userId,
        'nombre': nombreController.text.trim(),
        'apellidos': apellidosController.text.trim(),
        'rfc': rfcController.text.trim(),
        'licencia': licenciaController.text.trim(),
        'certificaciones': certificacionesController.text.trim(),
        'horarioId': horarioInt,
      },
    ));
    if (choferResult.hasException || choferResult.data == null) {
      await _showErrorDialog('Error al crear chofer');
      return;
    }
    final choferId = int.parse(choferResult.data!['createChofer']['chofer']['id'].toString());

    // ——— Asignar usuario al chofer ———
    const String mAssign = r'''
      mutation AssignUserToChofer($choferId: Int!, $userId: Int!) {
        assignUserToChofer(choferId: $choferId, userId: $userId) {
          ok
          chofer { id nombre usuario { id username email } }
        }
      }
    ''';
    final assignResult = await client.mutate(MutationOptions(
      document: gql(mAssign),
      variables: {'choferId': choferId, 'userId': userId},
    ));
    if (assignResult.hasException ||
        assignResult.data == null ||
        assignResult.data!['assignUserToChofer']['ok'] != true) {
      await _showErrorDialog('Error al asignar usuario al chofer');
      return;
    }

    // ——— Éxito ———
    await showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('¡Chofer dado de alta!'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop(); // cierra diálogo
              Navigator.of(context)
                  .pop(assignResult.data!['assignUserToChofer']['chofer']);
            },
          )
        ],
      ),
    );
  }

  Future<void> _showErrorDialog(String message) async {
    if (!mounted) return;
    await showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          )
        ],
      ),
    );
  }

  Widget _buildGlassAvatar() => Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Colors.grey.withOpacity(0.2), Colors.white.withOpacity(0.1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
            ),
            child: ClipOval(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(color: Colors.grey.withOpacity(0.2)),
              ),
            ),
          ),
          const Icon(CupertinoIcons.car_fill, size: 50, color: Colors.black54),
        ],
      );

  Widget _buildFloatingTextField({
    required TextEditingController controller,
    required String labelText,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) =>
      Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            labelText: labelText,
            floatingLabelBehavior: FloatingLabelBehavior.auto,
            border: InputBorder.none,
          ),
        ),
      );
}

/// HorariosPicker (sin cambios)
class HorariosPicker extends StatefulWidget {
  final ValueChanged<String> onSelectedHorario;
  const HorariosPicker({Key? key, required this.onSelectedHorario}) : super(key: key);

  @override
  _HorariosPickerState createState() => _HorariosPickerState();
}

class _HorariosPickerState extends State<HorariosPicker> {
  int selectedIndex = 0;
  List<dynamic> horarios = [];

  @override
  Widget build(BuildContext context) {
    return Query(
      options: QueryOptions(document: gql(r'''
        query GetHorarios {
          allHorarios { id nombre horaInicio horaFin }
        }
      ''')),
      builder: (result, {fetchMore, refetch}) {
        if (result.isLoading) return const CupertinoActivityIndicator();
        if (result.hasException) return Text('Error: ${result.exception}');
        horarios = result.data!['allHorarios'];
        if (horarios.isEmpty) return const Text('No hay horarios disponibles');

        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.onSelectedHorario(horarios[selectedIndex]['id'].toString());
        });

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Selecciona un Horario',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 5),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => showCupertinoModalPopup(
                context: context,
                builder: (_) => Container(
                  color: Colors.white,
                  height: 250,
                  child: CupertinoPicker(
                    itemExtent: 32,
                    scrollController:
                        FixedExtentScrollController(initialItem: selectedIndex),
                    onSelectedItemChanged: (i) {
                      setState(() => selectedIndex = i);
                      widget.onSelectedHorario(horarios[i]['id'].toString());
                    },
                    children: horarios
                        .map<Widget>((h) => Center(
                            child: Text(
                                '${h['nombre']} (${h['horaInicio']} - ${h['horaFin']})')))
                        .toList(),
                  ),
                ),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${horarios[selectedIndex]['nombre']}',
                        style: const TextStyle(color: Colors.black87)),
                    const Icon(CupertinoIcons.down_arrow, color: Colors.black54),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
