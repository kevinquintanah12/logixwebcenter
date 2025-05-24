import 'dart:math';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shop/route/route_constants.dart'; // para entryPointScreenRoute

class AddPaqueteScreen extends StatefulWidget {
  @override
  _AddPaqueteScreenState createState() => _AddPaqueteScreenState();
}

class _AddPaqueteScreenState extends State<AddPaqueteScreen> {
  Map<String, dynamic>? paquete;
  bool _envioRealizado = false;
  bool _initialized = false;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _clienteEmailController = TextEditingController();
  final TextEditingController _destEmailController    = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _crearPaqueteAutomatico();
    }
  }

  Future<void> _crearPaqueteAutomatico() async {
    final client = GraphQLProvider.of(context).value;
    const String query = r'''
      query {
        ultimoProducto {
          id
          description
          codigobarras
          destinatario { id nombre correoElectronico }
          cliente     { id nombre email }
          calculoenvio { totalTarifa envioExpress distanciaKm }
        }
      }
    ''';
    final result = await client.query(QueryOptions(document: gql(query)));
    if (result.hasException) {
      return _mostrarError('Error al obtener producto');
    }
    final prod = result.data?['ultimoProducto'];
    if (prod == null) {
      return _mostrarError('Producto no encontrado');
    }
    setState(() => paquete = prod);
    _clienteEmailController.text = prod['cliente']['email'] ?? '';
    _destEmailController.text    = prod['destinatario']['correoElectronico'] ?? '';
    await _crearPaquete(int.parse(prod['id'].toString()));
  }

  Future<void> _crearPaquete(int productoId) async {
    final client = GraphQLProvider.of(context).value;
    const String mutation = r'''
      mutation CrearPaquete($productoId: Int!) {
        crearPaquete(productoId: $productoId) {
          paquete { id numeroGuia codigoBarras fechaRegistro }
        }
      }
    ''';
    final result = await client.mutate(MutationOptions(
      document: gql(mutation),
      variables: {'productoId': productoId},
      errorPolicy: ErrorPolicy.all,
    ));
    if (result.hasException) {
      return _mostrarError('Error al crear paquete');
    }
    final pk = result.data?['crearPaquete']?['paquete'];
    if (pk != null) {
      setState(() => paquete = {...paquete!, ...pk});
      await _enviarGuiaEmail(int.parse(pk['id'].toString()));
    }
  }

  Future<void> _enviarGuiaEmail(int paqueteId) async {
    final client = GraphQLProvider.of(context).value;
    const String mutation = r'''
      mutation EnviarGuiaEmail($paqueteId: Int!, $email1: String!, $email2: String!) {
        enviarGuiaEmail(paqueteId: $paqueteId, email1: $email1, email2: $email2) { success }
      }
    ''';
    final email1 = _clienteEmailController.text.trim();
    final email2 = _destEmailController.text.trim();
    final result = await client.mutate(MutationOptions(
      document: gql(mutation),
      variables: {
        'paqueteId': paqueteId,
        'email1'   : email1,
        'email2'   : email2,
      },
      errorPolicy: ErrorPolicy.all,
    ));
    final success = result.data?['enviarGuiaEmail']?['success'] == true;
    if (result.hasException || !success) {
      return _mostrarError('Error al enviar email');
    }
    setState(() => _envioRealizado = true);
  }

  Future<Map<String, dynamic>?> _crearEntrega(int paqueteId) async {
    final client = GraphQLProvider.of(context).value;
    final fechaReg = paquete?['fechaRegistro'] as String? ?? DateTime.now().toIso8601String();
    final express = paquete?['calculoenvio']?['envioExpress'] as bool? ?? false;
    final kmRaw   = paquete?['calculoenvio']?['distanciaKm'];
    final num km = (kmRaw is String)
        ? num.tryParse(kmRaw) ?? 0
        : (kmRaw is num ? kmRaw : 0);
    final fechaEntrega = _calcularEntrega(fechaReg, express, km);

    // Generar PIN de 4 dígitos aleatorio
    final pin = (Random().nextInt(9000) + 1000).toString();

    const String mutation = r'''
      mutation CrearEntrega($paqueteId: Int!, $fechaEntrega: DateTime!, $pin: String!) {
        crearEntrega(
          paqueteId: $paqueteId,
          fechaEntrega: $fechaEntrega,
          estado: "Pendiente",
          pin: $pin
        ) {
          entrega { id pin }
        }
      }
    ''';
    final result = await client.mutate(MutationOptions(
      document: gql(mutation),
      variables: {
        'paqueteId'   : paqueteId,
        'fechaEntrega': fechaEntrega.toIso8601String(),
        'pin'         : pin,
      },
      errorPolicy: ErrorPolicy.all,
    ));
    if (result.hasException) {
      _mostrarError('Error al crear entrega');
      return null;
    }
    return result.data?['crearEntrega']?['entrega'];
  }

  DateTime _calcularEntrega(String reg, bool express, num km) {
    DateTime fecha = DateTime.tryParse(reg) ?? DateTime.now();
    if (!express) fecha = fecha.add(const Duration(days: 1));
    return fecha.add(Duration(hours: (km / 10).ceil()));
  }

  String? _validarEmail(String? v) {
    if (v == null || v.isEmpty) return 'Campo requerido';
    final reg = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$');
    return reg.hasMatch(v.trim()) ? null : 'Email inválido';
  }

  void _mostrarError(String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Error'),
        content: Text(msg),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agregar Paquete'), centerTitle: true),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: paquete == null
              ? const Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildCard(),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState?.validate() ?? false) {
                              final entrega = await _crearEntrega(int.parse(paquete!['id'].toString()));
                              if (entrega != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Entrega creada con ID ${entrega['id']} y PIN ${entrega['pin']}')),
                                );
                                Navigator.pushNamed(context, entryPointScreenRoute);
                              }
                            }
                          },
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Text('Confirmar Paquete', style: TextStyle(fontSize: 16)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildCard() {
    final datos = paquete!;
    final raw = datos['calculoenvio']?['totalTarifa'];
    double tarifa = 0;
    if (raw != null) {
      tarifa = raw is String ? double.tryParse(raw) ?? 0 : (raw as num).toDouble();
    }
    final fechaStr = (datos['fechaRegistro'] as String?)?.split('T').first
        ?? DateTime.now().toIso8601String().split('T').first;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.archive, size: 48, color: Theme.of(context).primaryColor),
                const SizedBox(width: 16),
                Text('Paquete #${datos['numeroGuia'] ?? 'N/A'}',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(height: 32),
            Wrap(
              spacing: 48,
              runSpacing: 16,
              children: [
                _info('Código Barras', datos['codigobarras']),
                _info('Fecha', fechaStr),
                _info('Descripción', datos['description']),
                _info('Cliente', datos['cliente']?['nombre']),
                _info('Destinatario', datos['destinatario']?['nombre']),
                _info('Tarifa', '\$${tarifa.toStringAsFixed(2)}'),
              ],
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _clienteEmailController,
              decoration: InputDecoration(
                labelText: 'Correo Cliente',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              validator: _validarEmail,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _destEmailController,
              decoration: InputDecoration(
                labelText: 'Correo Destinatario',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              validator: _validarEmail,
            ),
            const SizedBox(height: 16),
            Text(
              _envioRealizado ? '¡Guía enviada!' : 'Enviando guía...',
              style: TextStyle(
                color: _envioRealizado ? Colors.green : Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _info(String label, String? value) {
    return SizedBox(
      width: 200,
      child: RichText(
        text: TextSpan(
          text: '$label:\n',
          style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
          children: [
            TextSpan(
              text: value ?? 'N/A',
              style: const TextStyle(fontWeight: FontWeight.normal),
            )
          ],
        ),
      ),
    );
  }
}
