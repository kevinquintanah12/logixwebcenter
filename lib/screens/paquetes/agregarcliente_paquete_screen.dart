// lib/screens/paquetes/add_cliente_screen.dart

import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import 'agregardestinatario_paquete_screen.dart';
import 'crearproducto_paquete_screen.dart';

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

// Pantalla para agregar un cliente
class AddClienteScreen extends StatefulWidget {
  const AddClienteScreen({Key? key}) : super(key: key);

  @override
  _AddClienteScreenState createState() => _AddClienteScreenState();
}

class _AddClienteScreenState extends State<AddClienteScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final searchController       = TextEditingController(); // para TypeAhead
  final nameController         = TextEditingController();
  final surnameController      = TextEditingController();
  final razonSocialController  = TextEditingController();
  final rfcController          = TextEditingController();
  final direccionController    = TextEditingController();
  final cpController           = TextEditingController();
  final telefonoController     = TextEditingController();
  final emailController        = TextEditingController();

  Cliente? selectedCliente;

  Future<List<Cliente>> fetchClientes(String termino) async {
    final client = GraphQLProvider.of(context).value;
    const query = r'''
      query BuscarClientes($termino: String!) {
        buscarClientes(termino: $termino) {
          id nombre apellido razonSocial rfc direccion codigoPostal telefono email
        }
      }
    ''';
    final res = await client.query(QueryOptions(
      document: gql(query),
      variables: {'termino': termino},
    ));
    if (res.hasException || res.data == null) return [];
    return (res.data!['buscarClientes'] as List)
        .map((j) => Cliente.fromJson(j))
        .toList();
  }

  void _submitForm() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (selectedCliente != null) {
      _goToDestinatario(selectedCliente!.id);
      return;
    }

    final client = GraphQLProvider.of(context).value;
    const mutation = r'''
      mutation CrearCliente(
        $nombre: String!, $apellido: String!, $razonSocial: String!,
        $rfc: String!, $direccion: String!, $codigoPostal: String!,
        $telefono: String!, $email: String!
      ) {
        crearCliente(
          nombre: $nombre, apellido: $apellido, razonSocial: $razonSocial,
          rfc: $rfc, direccion: $direccion, codigoPostal: $codigoPostal,
          telefono: $telefono, email: $email
        ) {
          cliente { id }
        }
      }
    ''';
    final res = await client.mutate(MutationOptions(
      document: gql(mutation),
      variables: {
        'nombre': nameController.text.trim(),
        'apellido': surnameController.text.trim(),
        'razonSocial': razonSocialController.text.trim(),
        'rfc': rfcController.text.trim(),
        'direccion': direccionController.text.trim(),
        'codigoPostal': cpController.text.trim(),
        'telefono': telefonoController.text.trim(),
        'email': emailController.text.trim(),
      },
    ));

    if (res.hasException) {
      _showError();
    } else {
      final idNuevo = res.data!['crearCliente']['cliente']['id'] as String;
      _goToDestinatario(idNuevo);
    }
  }

  void _showError() {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Error'),
        content: const Text('No se pudo crear el cliente.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _goToDestinatario(String clienteId) {
    Navigator.push<Map<String, dynamic>>(
      context,
      CupertinoPageRoute(
        builder: (_) => AddDestinatarioScreen(clienteId: clienteId),
      ),
    ).then((dest) {
      if (dest != null) {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (_) => AddProductoScreen(
              clienteSeleccionado: {'id': clienteId},
              destinatarioSeleccionado: dest,
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: Colors.white.withOpacity(0.5),
        middle: const Text(
          'Agregar Cliente',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            fontFamily: 'Grandis Extended',
          ),
        ),
        trailing: GestureDetector(
          onTap: _submitForm,
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
          padding: const EdgeInsets.symmetric(vertical: 30),
          child: Column(
            children: [
              _buildAvatar(),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Autocompletado Cliente existente
                      Material(
                        color: Colors.transparent,
                        child: TypeAheadFormField<Cliente>(
                          textFieldConfiguration: TextFieldConfiguration(
                            controller: searchController,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9Ñ&]')),
                              UpperCaseTextFormatter(),
                            ],
                            decoration: InputDecoration(
                              labelText: 'Nombre o RFC',
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
                          suggestionsCallback: fetchClientes,
                          itemBuilder: (ctx, c) => ListTile(
                            title: Text('${c.nombre} ${c.apellido}'),
                            subtitle: Text(c.rfc),
                          ),
                          onSuggestionSelected: (c) {
                            selectedCliente = c;
                            nameController.text        = c.nombre;
                            surnameController.text     = c.apellido;
                            razonSocialController.text = c.razonSocial;
                            rfcController.text         = c.rfc;
                            direccionController.text   = c.direccion;
                            cpController.text          = c.codigoPostal;
                            telefonoController.text    = c.telefono;
                            emailController.text       = c.email;
                          },
                          noItemsFoundBuilder: (_) => const Padding(
                            padding: EdgeInsets.all(8),
                            child: Text('No se encontraron clientes.'),
                          ),
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Obligatorio' : null,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Apellidos
                      _buildGlassTextField(
                        controller: surnameController,
                        label: 'Apellidos',
                        validator: _notEmpty,
                      ),
                      const SizedBox(height: 10),

                      // Razón Social (opcional)
                      _buildGlassTextField(
                        controller: razonSocialController,
                        label: 'Razón Social',
                      ),
                      const SizedBox(height: 10),

                      // RFC
                      _buildGlassTextField(
                        controller: rfcController,
                        label: 'RFC',
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9Ñ&]')),
                          UpperCaseTextFormatter(),
                        ],
                        hintText: 'Ej. GODE561231GR8',
                        validator: _rfc,
                      ),
                      const SizedBox(height: 10),

                      // Dirección
                      _buildGlassTextField(
                        controller: direccionController,
                        label: 'Dirección',
                      ),
                      const SizedBox(height: 10),

                      // Código Postal
                      _buildGlassTextField(
                        controller: cpController,
                        label: 'Código Postal',
                        isNumeric: true,
                        validator: _postal,
                      ),
                      const SizedBox(height: 10),

                      // Teléfono
                      _buildGlassTextField(
                        controller: telefonoController,
                        label: 'Teléfono',
                        isNumeric: true,
                        validator: _phone,
                      ),
                      const SizedBox(height: 10),

                      // Email
                      _buildGlassTextField(
                        controller: emailController,
                        label: 'Email',
                        validator: _email,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() => Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Colors.grey.withOpacity(0.2),
                  Colors.white.withOpacity(0.1),
                ],
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
          const Icon(CupertinoIcons.person_fill, size: 50, color: Colors.black54),
        ],
      );

  Widget _buildGlassTextField({
    required TextEditingController controller,
    required String label,
    bool isNumeric = false,
    List<TextInputFormatter>? inputFormatters,
    String? hintText,
    String? Function(String?)? validator,
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
                keyboardType:
                    isNumeric ? TextInputType.number : TextInputType.text,
                inputFormatters: inputFormatters ??
                    (isNumeric ? [FilteringTextInputFormatter.digitsOnly] : null),
                decoration: InputDecoration(
                  labelText: label,
                  hintText: hintText,
                  hintStyle: hintText != null ? TextStyle(fontSize: 12) : null,
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                ),
                style: const TextStyle(color: Colors.black87),
                validator: validator,
              ),
            ),
          ),
        ),
      );

  // Validators
  String? _notEmpty(String? v) =>
      v == null || v.trim().isEmpty ? 'Obligatorio' : null;

  String? _email(String? v) {
    final value = v?.trim() ?? '';
    if (value.isEmpty) return 'Obligatorio';
    return RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value)
        ? null
        : 'Email inválido';
  }

  String? _phone(String? v) {
    final value = v?.trim() ?? '';
    if (value.isEmpty) return 'Obligatorio';
    return RegExp(r'^\d{10}$').hasMatch(value)
        ? null
        : 'Debe tener 10 dígitos';
  }

  String? _postal(String? v) {
    final value = v?.trim() ?? '';
    if (value.isEmpty) return 'Obligatorio';
    return RegExp(r'^\d{5}$').hasMatch(value)
        ? null
        : '5 dígitos';
  }

  String? _rfc(String? v) {
    final value = v?.trim().toUpperCase() ?? '';
    if (value.isEmpty) return 'Obligatorio';
    final pattern =
        r'^[A-ZÑ&]{3,4}\d{2}(0[1-9]|1[0-2])(0[1-9]|[12]\d|3[01])[A-Z0-9]{3}$';
    return RegExp(pattern).hasMatch(value)
        ? null
        : 'RFC inválido. Ejemplo: GODE561231GR8';
  }
}

/// Modelo Cliente para parsear la query
class Cliente {
  final String id;
  final String nombre;
  final String apellido;
  final String razonSocial;
  final String rfc;
  final String direccion;
  final String codigoPostal;
  final String telefono;
  final String email;

  Cliente({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.razonSocial,
    required this.rfc,
    required this.direccion,
    required this.codigoPostal,
    required this.telefono,
    required this.email,
  });

  factory Cliente.fromJson(Map<String, dynamic> j) => Cliente(
        id: j['id'],
        nombre: j['nombre'],
        apellido: j['apellido'],
        razonSocial: j['razonSocial'],
        rfc: j['rfc'],
        direccion: j['direccion'],
        codigoPostal: j['codigoPostal'],
        telefono: j['telefono'],
        email: j['email'],
      );
}
