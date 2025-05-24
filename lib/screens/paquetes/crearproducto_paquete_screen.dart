import 'dart:ui';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shop/screens/paquetes/codigoSat_screen.dart';
import 'package:shop/screens/paquetes/crearpaquete_paquete_screen.dart';

class AddProductoScreen extends StatefulWidget {
  final Map<String, dynamic>? clienteSeleccionado;
  final Map<String, dynamic>? destinatarioSeleccionado;

  const AddProductoScreen({
    Key? key,
    this.clienteSeleccionado,
    this.destinatarioSeleccionado,
  }) : super(key: key);

  @override
  _AddProductoScreenState createState() => _AddProductoScreenState();
}

class _AddProductoScreenState extends State<AddProductoScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController codigosatController = TextEditingController();
  final TextEditingController noidentificacionController = TextEditingController();
  final TextEditingController codigobarrasController = TextEditingController();
  final TextEditingController calculoenvioIdController = TextEditingController();

  Map<String, dynamic>? cliente;
  Map<String, dynamic>? destinatario;
  Map<String, dynamic>? ultimoCalculo;
  bool _loadingDatos = false;
  bool _hasFetched = false;

  @override
  void initState() {
    super.initState();
    // Valores por defecto
    noidentificacionController.text = Random().nextInt(1e6.toInt()).toString();
    codigobarrasController.text = Random().nextInt(1e6.toInt()).toString();
    calculoenvioIdController.text = '0';

    cliente = widget.clienteSeleccionado;
    destinatario = widget.destinatarioSeleccionado;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasFetched) {
      _hasFetched = true;
      _fetchDatosIniciales();
    }
  }

  int _toInt(dynamic val) {
    if (val is int) return val;
    if (val is String) return int.tryParse(val) ?? 0;
    return 0;
  }

  Future<void> _fetchDatosIniciales() async {
    setState(() => _loadingDatos = true);
    final client = GraphQLProvider.of(context).value;
    final futures = <Future<QueryResult>>[];

    final clienteId = _toInt(cliente?['id']);
    if (clienteId > 0) {
      futures.add(client.query(
        QueryOptions(
          document: gql(r'''
            query Cliente($id: Int!) {
              cliente(id: $id) {
                id nombre apellido razonSocial rfc direccion codigoPostal telefono email
              }
            }
          '''),
          variables: {'id': clienteId},
        ),
      ));
    }

    final destinatarioId = _toInt(destinatario?['id']);
    if (destinatarioId > 0) {
      futures.add(client.query(
        QueryOptions(
          document: gql(r'''
            query Destinatario($id: Int!) {
              destinatario(id: $id) {
                id nombre apellidos correoElectronico telefono ciudad estado
              }
            }
          '''),
          variables: {'id': destinatarioId},
        ),
      ));
    }

    // Siempre pedimos el último cálculo
    futures.add(client.query(
      QueryOptions(
        document: gql(r'''
          query {
            ultimoCalculo {
              id tarifaPorKm tarifaPeso tarifaBase tarifaExtraTemperatura
              tarifaExtraHumedad trasladoiva ieps totalTarifa
            }
          }
        '''),
      ),
    ));

    final results = await Future.wait(futures);
    var idx = 0;

    if (clienteId > 0) {
      final resC = results[idx++];
      if (!resC.hasException && resC.data?['cliente'] != null) {
        cliente = Map<String, dynamic>.from(resC.data!['cliente']);
      }
    }

    if (destinatarioId > 0) {
      final resD = results[idx++];
      if (!resD.hasException && resD.data?['destinatario'] != null) {
        destinatario = Map<String, dynamic>.from(resD.data!['destinatario']);
      }
    }

    final resCalc = results[idx++];
    if (!resCalc.hasException && resCalc.data?['ultimoCalculo'] != null) {
      ultimoCalculo = Map<String, dynamic>.from(resCalc.data!['ultimoCalculo']);
      calculoenvioIdController.text = ultimoCalculo!['totalTarifa'].toString();
    }

    setState(() => _loadingDatos = false);
  }

  void _onSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final clienteId = _toInt(cliente?['id']);
    final destinatarioId = _toInt(destinatario?['id']);
    final calculoId = _toInt(ultimoCalculo?['id']);

    if (clienteId == 0 || destinatarioId == 0 || calculoId == 0) {
      await showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
          title: const Text('Error'),
          content: const Text('Datos incompletos para enviar la petición.'),
          actions: [
            CupertinoDialogAction(child: const Text('OK'), onPressed: () => Navigator.pop(context)),
          ],
        ),
      );
      return;
    }

    final client = GraphQLProvider.of(context).value;
    const String mutation = r'''
      mutation CrearProducto(
        $description: String!,
        $codigosat: String!,
        $noidentificacion: String!,
        $codigobarras: String!,
        $destinatarioId: Int!,
        $clienteId: Int!,
        $calculoenvioId: Int!
      ) {
        crearProducto(
          description: $description,
          codigosat: $codigosat,
          noidentificacion: $noidentificacion,
          codigobarras: $codigobarras,
          destinatarioId: $destinatarioId,
          clienteId: $clienteId,
          calculoenvioId: $calculoenvioId
        ) {
          producto {
            id description codigosat noidentificacion codigobarras
          }
        }
      }
    ''';

    final res = await client.mutate(MutationOptions(
      document: gql(mutation),
      variables: {
        'description': descriptionController.text.trim(),
        'codigosat': codigosatController.text.trim(),
        'noidentificacion': noidentificacionController.text.trim(),
        'codigobarras': codigobarrasController.text.trim(),
        'destinatarioId': destinatarioId,
        'clienteId': clienteId,
        'calculoenvioId': calculoId,
      },
    ));

    if (res.hasException) {
      await showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
          title: const Text('Error'),
          content: const Text('Hubo un error al crear el producto.'),
          actions: [
            CupertinoDialogAction(child: const Text('OK'), onPressed: () => Navigator.pop(context)),
          ],
        ),
      );
    } else {
      await showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
          title: const Text('Éxito'),
          content: const Text('Producto creado correctamente.'),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context, res.data!['crearProducto']['producto']);
                Navigator.push(context, CupertinoPageRoute(builder: (_) => AddPaqueteScreen()));
              },
            ),
          ],
        ),
      );
    }
  }

  Future<void> _pickCodigoSat() async {
    final selected = await Navigator.push(
      context,
      CupertinoPageRoute(builder: (_) => CodigoSatScreen()),
    );
    if (selected != null) {
      setState(() => codigosatController.text = selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      resizeToAvoidBottomInset: true,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: Colors.white.withOpacity(0.5),
        middle: const Text(
          'Crear Producto',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            fontFamily: 'Grandis Extended',
          ),
        ),
        trailing: GestureDetector(onTap: _onSubmit, child: const Text('Listo', style: TextStyle(color: CupertinoColors.activeBlue, fontFamily: 'Grandis Extended'))),
      ),
      backgroundColor: Colors.grey[200],
      child: SafeArea(
        child: Material(
          color: Colors.transparent,
          child: _loadingDatos
              ? const Center(child: CupertinoActivityIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        if (cliente != null)
                          _buildInfoCard(title: 'Cliente', info: '${cliente!['nombre']} ${cliente!['apellido'] ?? ''}'),
                        const SizedBox(height: 10),
                        if (destinatario != null)
                          _buildInfoCard(title: 'Destinatario', info: '${destinatario!['nombre']} ${destinatario!['apellidos']}'),
                        if (ultimoCalculo != null) ...[
                          const SizedBox(height: 10),
                          _buildInfoCard(title: 'Cálculo Envío', info: 'Tarifa Total: ${ultimoCalculo!['totalTarifa']}'),
                        ],
                        const SizedBox(height: 30),
                        _buildGlassTextField(controller: descriptionController, label: 'Descripción', validator: _notEmpty('Ingrese la descripción')),
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: _pickCodigoSat,
                          child: AbsorbPointer(
                            child: _buildGlassTextField(controller: codigosatController, label: 'Código SAT', validator: _notEmpty('Seleccione el código SAT')),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildGlassTextField(
                          controller: noidentificacionController,
                          label: 'Número de Identificación',
                          readOnly: true,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          validator: _notEmpty('Número no generado'),
                        ),
                        const SizedBox(height: 10),
                        _buildGlassTextField(
                          controller: codigobarrasController,
                          label: 'Código de Barras',
                          readOnly: true,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          validator: _notEmpty('Código no generado'),
                        ),
                        const SizedBox(height: 10),
                        _buildGlassTextField(
                          controller: calculoenvioIdController,
                          label: 'Tarifa Total',
                          readOnly: true,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9\.]'))],
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Ingrese la tarifa total';
                            return double.tryParse(v) == null ? 'Ingrese un número válido' : null;
                          },
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  String? Function(String?) _notEmpty(String msg) => (v) => (v == null || v.trim().isEmpty) ? msg : null;

  Widget _buildGlassTextField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    bool readOnly = false,
    TextInputType? keyboardType,
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
            child: TextFormField(
              controller: controller,
              validator: validator,
              readOnly: readOnly,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              decoration: InputDecoration(
                labelText: label,
                floatingLabelBehavior: FloatingLabelBehavior.auto,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ),
      );

  Widget _buildInfoCard({required String title, required String info}) => ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
          ),
          child: Row(
            children: [
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text(info, style: const TextStyle(fontSize: 12, color: Colors.black87), maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}
