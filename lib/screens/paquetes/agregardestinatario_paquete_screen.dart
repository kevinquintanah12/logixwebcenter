import 'dart:ui';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;

/// Formatter que convierte a mayúsculas
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

class AddDestinatarioScreen extends StatefulWidget {
  final String clienteId;
  const AddDestinatarioScreen({Key? key, required this.clienteId})
      : super(key: key);

  @override
  _AddDestinatarioScreenState createState() => _AddDestinatarioScreenState();
}

class _AddDestinatarioScreenState extends State<AddDestinatarioScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final searchController            = TextEditingController();  // para el TypeAhead
  final rfcController               = TextEditingController();  // para el RFC nuevo
  final nameController              = TextEditingController();
  final surnameController           = TextEditingController();
  final correoController            = TextEditingController();
  final telefonoController          = TextEditingController();
  final ciudadController            = TextEditingController();
  final estadoController            = TextEditingController();
  final cpController                = TextEditingController();
  final calleController             = TextEditingController();
  final coloniaController           = TextEditingController();
  final direccionDetalladaController= TextEditingController();
  final numeroController            = TextEditingController();

  // Listas para TypeAhead de CP
  List<String> estados = [];
  List<String> colonias = [];

  Destinatario? selectedDestinatario;

  @override
  void initState() {
    super.initState();
    cpController.addListener(() {
      final cp = cpController.text.trim();
      if (cp.length == 5) {
        _fetchAsentamientosPorCP(cp).catchError((_) {
          if (!mounted) return;
          setState(() {
            estados = [];
            colonias = [];
            estadoController.clear();
            coloniaController.clear();
          });
          _showError(message: 'Código postal no encontrado');
        });
      }
    });
  }

  /// Busca destinatarios existentes en tu API
  Future<List<Destinatario>> fetchDestinatarios(String termino) async {
    final client = GraphQLProvider.of(context).value;
    const query = r'''
      query BuscarDestinatarios($termino: String!) {
        buscarDestinatarios(termino: $termino) {
          id nombre apellidos rfc correoElectronico telefono ciudad estado codigoPostal calle colonia direccionDetallada numero
        }
      }
    ''';
    final result = await client.query(
      QueryOptions(document: gql(query), variables: {'termino': termino}),
    );
    if (result.hasException) return [];
    final data = result.data?['buscarDestinatarios'] as List?;
    if (data == null) return [];
    return data.map((j) => Destinatario.fromJson(j)).toList();
  }

  /// Consulta Zippopotam.us para CP mexicano
  Future<void> _fetchAsentamientosPorCP(String cp) async {
    final url = Uri.parse('https://api.zippopotam.us/MX/$cp');
    final response = await http.get(url);
    if (response.statusCode != 200) throw Exception('CP no existe');
    final data = json.decode(response.body);
    final places = data['places'] as List;
    if (!mounted) return;
    setState(() {
      estados = [places.first['state'] as String];
      colonias = places.map<String>((p) => p['place name'] as String).toList();
      estadoController.text = estados.first;
      coloniaController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: Colors.white.withOpacity(0.5),
        middle: const Text('Agregar Destinatario',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              fontFamily: 'Grandis Extended',
            )),
        trailing: GestureDetector(
          onTap: _submitForm,
          child: const Text('Listo',
              style: TextStyle(
                color: CupertinoColors.activeBlue,
                fontFamily: 'Grandis Extended',
              )),
        ),
      ),
      backgroundColor: Colors.grey[200],
      child: Material(
        color: Colors.transparent,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: Column(children: [
              _buildAvatar(),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Form(
                  key: _formKey,
                  child: Column(children: [
                    // Búsqueda por Nombre/Apellidos/RFC existente
                    Material(
                      color: Colors.transparent,
                      child: TypeAheadFormField<Destinatario>(
                        textFieldConfiguration: TextFieldConfiguration(
                          controller: searchController,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9Ñ&]')),
                            UpperCaseTextFormatter()
                          ],
                          decoration: InputDecoration(
                            labelText: 'Busca por Nombre o RFC',
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.4),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 16),
                          ),
                        ),
                        suggestionsCallback: fetchDestinatarios,
                        itemBuilder: (ctx, s) => ListTile(
                          title: Text('${s.nombre} ${s.apellidos}'),
                          subtitle: Text(s.rfc),
                        ),
                        onSuggestionSelected: (s) {
                          selectedDestinatario = s;
                          // Al seleccionar, llenamos todos los campos:
                          rfcController.text                = s.rfc;
                          nameController.text               = s.nombre;
                          surnameController.text            = s.apellidos;
                          correoController.text             = s.correoElectronico;
                          telefonoController.text           = s.telefono;
                          ciudadController.text             = s.ciudad;
                          estadoController.text             = s.estado;
                          cpController.text                 = s.codigoPostal;
                          calleController.text              = s.calle;
                          coloniaController.text            = s.colonia;
                          direccionDetalladaController.text = s.direccionDetallada;
                          numeroController.text             = s.numero;
                        },
                        noItemsFoundBuilder: (_) => const Padding(
                          padding: EdgeInsets.all(8),
                          child: Text('No se encontraron destinatarios.'),
                        ),
                        validator: (_) => null,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Campo RFC para nuevo registro con pista de formato
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: TextFormField(
                              controller: rfcController,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9Ñ&]')),
                                UpperCaseTextFormatter()
                              ],
                              decoration: InputDecoration(
                                labelText: 'RFC',
                                hintText: 'Ej. GODE561231GR8',
                                hintStyle: TextStyle(fontSize: 12),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                              ),
                              validator: _rfc,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Nombre y Apellidos
                    _buildGlassTextField(controller: nameController, label: 'Nombre', validator: _notEmpty),
                    const SizedBox(height: 10),
                    _buildGlassTextField(controller: surnameController, label: 'Apellidos', validator: _notEmpty),
                    const SizedBox(height: 10),

                    // Correo y Teléfono
                    _buildGlassTextField(controller: correoController, label: 'Correo Electrónico', validator: _email),
                    const SizedBox(height: 10),
                    _buildGlassTextField(controller: telefonoController, label: 'Teléfono', isNumeric: true, validator: _phone),
                    const SizedBox(height: 10),

                    // Código Postal
                    _buildGlassTextField(controller: cpController, label: 'Código Postal', isNumeric: true, validator: _postal),
                    const SizedBox(height: 10),

                    // Estado (autocomplete)
                    TypeAheadFormField<String>(
                      textFieldConfiguration: TextFieldConfiguration(
                        controller: estadoController,
                        decoration: InputDecoration(
                          labelText: 'Estado',
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.4),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        ),
                      ),
                      suggestionsCallback: (_) async => estados,
                      itemBuilder: (_, s) => ListTile(title: Text(s)),
                      onSuggestionSelected: (s) => estadoController.text = s,
                      validator: _notEmpty,
                    ),
                    const SizedBox(height: 10),

                    // Ciudad
                    _buildGlassTextField(controller: ciudadController, label: 'Ciudad', validator: _notEmpty),
                    const SizedBox(height: 10),

                    // Colonia
                    TypeAheadFormField<String>(
                      textFieldConfiguration: TextFieldConfiguration(
                        controller: coloniaController,
                        decoration: InputDecoration(
                          labelText: 'Colonia',
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.4),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        ),
                      ),
                      suggestionsCallback: (_) async => colonias,
                      itemBuilder: (_, s) => ListTile(title: Text(s)),
                      onSuggestionSelected: (s) => coloniaController.text = s,
                      validator: _notEmpty,
                    ),
                    const SizedBox(height: 10),

                    // Calle, Dirección Detallada, Número
                    _buildGlassTextField(controller: calleController, label: 'Calle', validator: _notEmpty),
                    const SizedBox(height: 10),
                    _buildGlassTextField(controller: direccionDetalladaController, label: 'Dirección Detallada', validator: _notEmpty),
                    const SizedBox(height: 10),
                    _buildGlassTextField(controller: numeroController, label: 'Número', validator: _notEmpty),
                  ]),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  // Validators
  String? _notEmpty(String? v) => v == null || v.trim().isEmpty ? 'Obligatorio' : null;

  String? _email(String? v) {
    final value = v?.trim() ?? '';
    if (value.isEmpty) return 'Obligatorio';
    return RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value) ? null : 'Email inválido';
  }

  String? _phone(String? v) {
    final value = v?.trim() ?? '';
    if (value.isEmpty) return 'Obligatorio';
    return RegExp(r'^\d{10}$').hasMatch(value) ? null : 'Debe tener 10 dígitos';
  }

  String? _postal(String? v) {
    final value = v?.trim() ?? '';
    if (value.isEmpty) return 'Obligatorio';
    return RegExp(r'^\d{5}$').hasMatch(value) ? null : '5 dígitos';
  }

  String? _rfc(String? v) {
    final value = v?.trim().toUpperCase() ?? '';
    if (value.isEmpty) return 'Obligatorio';
    final pattern = r'^[A-ZÑ&]{3,4}\d{2}(0[1-9]|1[0-2])(0[1-9]|[12]\d|3[01])[A-Z0-9]{3}$';
    return RegExp(pattern).hasMatch(value)
        ? null
        : 'RFC inválido. Ejemplo: GODE561231GR8';
  }

  Widget _buildAvatar() => Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 120, height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [Colors.grey.withOpacity(0.2), Colors.white.withOpacity(0.1)]),
              border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
            ),
            child: ClipOval(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(color: Colors.grey.withOpacity(0.2)),
              ),
            ),
          ),
          const Icon(CupertinoIcons.person_fill, size: 50, color: Colors.black54),
        ],
      );

  Widget _buildGlassTextField({
    required TextEditingController controller,
    required String label,
    bool isNumeric = false,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
  }) =>
      ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
            ),
            child: Material(
              color: Colors.transparent,
              child: TextFormField(
                controller: controller,
                keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
                inputFormatters: inputFormatters ?? (isNumeric ? [FilteringTextInputFormatter.digitsOnly] : null),
                decoration: InputDecoration(
                  labelText: label,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                ),
                style: const TextStyle(color: Colors.black87),
                validator: validator,
              ),
            ),
          ),
        ),
      );

  void _submitForm() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (selectedDestinatario != null) {
      Navigator.pop(context, selectedDestinatario!.toMap());
      return;
    }

    if ([calleController, coloniaController, direccionDetalladaController, numeroController]
        .any((c) => c.text.trim().isEmpty)) {
      _showError(message: 'Complete calle, colonia, dirección detallada y número.');
      return;
    }

    try {
      final client = GraphQLProvider.of(context).value;
      const mutation = r'''
        mutation CrearDestinatario(
          $rfc: String!, $nombre: String!, $apellidos: String!,
          $correoElectronico: String!, $telefono: String!,
          $ciudad: String!, $estado: String!, $codigoPostal: String!,
          $calle: String!, $colonia: String!, $direccionDetallada: String!, $numero: String!
        ) {
          crearDestinatario(
            rfc: $rfc, nombre: $nombre, apellidos: $apellidos,
            correoElectronico: $correoElectronico, telefono: $telefono,
            ciudad: $ciudad, estado: $estado, codigoPostal: $codigoPostal,
            calle: $calle, colonia: $colonia, direccionDetallada: $direccionDetallada, numero: $numero
          ) {
            destinatario { id }
          }
        }
      ''';

      final vars = {
        'rfc': rfcController.text.trim(),
        'nombre': nameController.text.trim(),
        'apellidos': surnameController.text.trim(),
        'correoElectronico': correoController.text.trim(),
        'telefono': telefonoController.text.trim(),
        'ciudad': ciudadController.text.trim(),
        'estado': estadoController.text.trim(),
        'codigoPostal': cpController.text.trim(),
        'calle': calleController.text.trim(),
        'colonia': coloniaController.text.trim(),
        'direccionDetallada': direccionDetalladaController.text.trim(),
        'numero': numeroController.text.trim(),
      };

      final result = await client.mutate(MutationOptions(document: gql(mutation), variables: vars));
      if (result.hasException) {
        _showError();
      } else {
        final newId = result.data!['crearDestinatario']['destinatario']['id'] as String;
        Navigator.pop(context, {
          ...vars,
          'id': newId,
        });
      }
    } catch (_) {
      _showError();
    }
  }

  void _showError({String message = 'No se pudo procesar el destinatario.'}) {
    if (!mounted) return;
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(child: const Text('OK'), onPressed: () => Navigator.pop(context))
        ],
      ),
    );
  }
}

class Destinatario {
  final String id, nombre, apellidos, rfc, correoElectronico,
      telefono, ciudad, estado, codigoPostal,
      calle, colonia, direccionDetallada, numero;

  Destinatario({
    required this.id,
    required this.nombre,
    required this.apellidos,
    required this.rfc,
    required this.correoElectronico,
    required this.telefono,
    required this.ciudad,
    required this.estado,
    required this.codigoPostal,
    required this.calle,
    required this.colonia,
    required this.direccionDetallada,
    required this.numero,
  });

  factory Destinatario.fromJson(Map<String, dynamic> j) => Destinatario(
        id: j['id'],
        nombre: j['nombre'],
        apellidos: j['apellidos'],
        rfc: j['rfc'],
        correoElectronico: j['correoElectronico'],
        telefono: j['telefono'],
        ciudad: j['ciudad'],
        estado: j['estado'],
        codigoPostal: j['codigoPostal'],
        calle: j['calle'],
        colonia: j['colonia'],
        direccionDetallada: j['direccionDetallada'],
        numero: j['numero'],
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'nombre': nombre,
        'apellidos': apellidos,
        'rfc': rfc,
        'correoElectronico': correoElectronico,
        'telefono': telefono,
        'ciudad': ciudad,
        'estado': estado,
        'codigoPostal': codigoPostal,
        'calle': calle,
        'colonia': colonia,
        'direccionDetallada': direccionDetallada,
        'numero': numero,
      };
}
