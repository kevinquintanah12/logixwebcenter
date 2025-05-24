import 'dart:ui';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shop/constants.dart';
import 'package:shop/route/route_constants.dart';

class AddPaqueteScreen extends StatefulWidget {
  @override
  _AddPaqueteScreenState createState() => _AddPaqueteScreenState();
}

class _AddPaqueteScreenState extends State<AddPaqueteScreen> {
  Map<String, dynamic>? paquete;
  bool _envioRealizado = false;

  // GlobalKey para el formulario
  final _emailFormKey = GlobalKey<FormState>();

  // Controladores para los campos de correo
  final TextEditingController emailClienteController = TextEditingController();
  final TextEditingController emailDestinatarioController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    // Crear paquete automáticamente al iniciar
    Future.microtask(() => _crearPaqueteAutomatico());
  }

  Future<void> _crearPaqueteAutomatico() async {
    final client = GraphQLProvider.of(context).value;

    // Query para obtener el último producto
    const String queryUltimoProducto = r'''
      query {
        ultimoProducto {
          id
          description
          codigosat
          noidentificacion
          codigobarras
          destinatario {
            id
            correoElectronico
            nombre
          }
          cliente {
            id
            email
            nombre
          }
          calculoenvio {
            id
            totalTarifa
            envioExpress
            distanciaKm
          }
        }
      }
    ''';

    final QueryResult ultimoProductoResult = await client.query(
      QueryOptions(document: gql(queryUltimoProducto)),
    );
    if (ultimoProductoResult.hasException) {
      print(
          "Error al obtener el producto: ${ultimoProductoResult.exception.toString()}");
      _mostrarDialogoError('Error al obtener el producto.');
      return;
    }

    final ultimoProducto = ultimoProductoResult.data?['ultimoProducto'];
    if (ultimoProducto == null) {
      print("No se encontró un último producto.");
      return;
    }

    final productId = int.parse(ultimoProducto['id'].toString());

    // Mutación para crear el paquete
    const String mutationCrearPaquete = r'''
      mutation CrearPaquete($productoId: Int!) {
        crearPaquete(productoId: $productoId) {
          paquete {
            id
            numeroGuia
            codigoBarras
            fechaRegistro
            producto {
              id
              description
              cliente {
                id
                email
                nombre
              }
              destinatario {
                id
                correoElectronico
                nombre
              }
              calculoenvio {
                id
                envioExpress
                distanciaKm
                totalTarifa
              }
            }
          }
        }
      }
    ''';

    final MutationOptions optionsCrear = MutationOptions(
      document: gql(mutationCrearPaquete),
      variables: {'productoId': productId},
      onCompleted: (dynamic resultData) async {
        final paqueteResult = resultData?['crearPaquete']?['paquete'];
        if (paqueteResult == null) {
          print("No se obtuvo paquete en la respuesta.");
          return;
        }

        // Si 'fechaRegistro' es nulo, se asigna la fecha actual
        if (paqueteResult['fechaRegistro'] == null) {
          paqueteResult['fechaRegistro'] =
              DateTime.now().toIso8601String();
        }

        setState(() {
          paquete = paqueteResult;
        });

        // Inicializamos los controladores con los correos del producto
        emailClienteController.text =
            paqueteResult?['producto']?['cliente']?['email'] ?? "";
        emailDestinatarioController.text =
            paqueteResult?['producto']?['destinatario']?['correoElectronico'] ??
                "";

        // Enviar email con la guía
        await _enviarGuiaEmail(
          client,
          paqueteResult['id'],
          emailClienteController.text,
          emailDestinatarioController.text,
        );
      },
      onError: (OperationException? error) {
        print("Error en crearPaquete: ${error.toString()}");
        _mostrarDialogoError('Hubo un error al crear el paquete.');
      },
    );

    await client.mutate(optionsCrear);
  }

  Future<void> _enviarGuiaEmail(
    GraphQLClient client,
    dynamic paqueteId,
    String emailCliente,
    String emailDestinatario,
  ) async {
    // Mutación para enviar la guía vía email
    const String mutationEnviarEmail = r'''
      mutation EnviarGuiaEmail($paqueteId: Int!, $email1: String!, $email2: String!) {
        enviarGuiaEmail(paqueteId: $paqueteId, email1: $email1, email2: $email2) {
          success
          paquete {
            id
            numeroGuia
          }
        }
      }
    ''';

    final MutationOptions optionsEnviar = MutationOptions(
      document: gql(mutationEnviarEmail),
      variables: {
        'paqueteId': int.parse(paqueteId.toString()),
        'email1': emailCliente,
        'email2': emailDestinatario,
      },
      onCompleted: (dynamic resultData) {
        setState(() {
          _envioRealizado = true;
        });
      },
      onError: (OperationException? error) {
        print("Error en enviarGuiaEmail: ${error.toString()}");
        _mostrarDialogoError('Hubo un error al enviar el email de la guía.');
      },
    );

    await client.mutate(optionsEnviar);
  }

  Future<void> _crearEntrega(GraphQLClient client) async {
    if (paquete == null) return;

    final int paqueteId = int.parse(paquete!['id'].toString());
    // Se elimina destinatarioId, ya que el servidor no lo reconoce
    final String fechaRegistro =
        paquete!['fechaRegistro'] ?? DateTime.now().toIso8601String();
    final bool envioExpress =
        paquete!['producto']['calculoenvio']['envioExpress'];
    final num distanciaKm = num.parse(
        paquete!['producto']['calculoenvio']['distanciaKm'].toString());

    DateTime fechaEntrega =
        _calcularFechaEntrega(fechaRegistro, envioExpress, distanciaKm);

    // Mutación para crear la entrega (sin destinatarioId y sin consultar el campo destinatario)
    const String mutationCrearEntrega = r'''
      mutation CrearEntrega($paqueteId: Int!, $fechaEntrega: DateTime!, $estado: String!, $pin: String!) {
        crearEntrega(
          paqueteId: $paqueteId,
          fechaEntrega: $fechaEntrega,
          estado: $estado,
          pin: $pin
        ) {
          entrega {
            id
            fechaEntrega
            estado
            pin
            paquete {
              id
              numeroGuia
              fechaRegistro
            }
          }
        }
      }
    ''';

    final MutationOptions optionsCrearEntrega = MutationOptions(
      document: gql(mutationCrearEntrega),
      variables: {
        'paqueteId': paqueteId,
        'fechaEntrega': fechaEntrega.toIso8601String(),
        'estado': 'Pendiente',
        'pin': _generarPin(),
      },
    );

    // Se espera el resultado de la mutación y se muestra el diálogo correspondiente.
    final QueryResult result =
        await client.mutate(optionsCrearEntrega);
    if (result.hasException) {
      print("Error en crearEntrega: ${result.exception.toString()}");
      _mostrarDialogoError('Hubo un error al crear la entrega.');
    } else {
      print("Entrega creada satisfactoriamente.");
      _mostrarDialogoConfirmacion('Entrega creada satisfactoriamente.');
    }
  }

  DateTime _calcularFechaEntrega(
      String fechaRegistro, bool envioExpress, num distanciaKm) {
    DateTime registro = DateTime.parse(fechaRegistro);
    DateTime entrega =
        envioExpress ? registro : registro.add(const Duration(days: 1));
    int extraHours = (distanciaKm / 10).ceil();
    entrega = entrega.add(Duration(hours: extraHours));
    return entrega;
  }

  String _generarPin() {
    final random = Random();
    return (random.nextInt(9000) + 1000).toString();
  }

  // Diálogo de error
  void _mostrarDialogoError(String mensaje) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Error'),
        content: Text(mensaje),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
    );
  }

  // Diálogo de confirmación. Al presionar "OK" se navega a la siguiente pantalla.
  void _mostrarDialogoConfirmacion(String mensaje) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Éxito'),
        content: Text(mensaje),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, entryPointScreenRoute);
            },
          )
        ],
      ),
    );
  }

  // Validador básico de correo
  String? _validarEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo requerido';
    }
    final RegExp emailRegExp =
        RegExp(r'^[\w\.\-]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
    if (!emailRegExp.hasMatch(value.trim())) {
      return 'Ingrese un correo válido';
    }
    return null;
  }

  // Widget para un campo de texto con efecto glass
  Widget _buildGlassTextField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    bool readOnly = false,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.4),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Material(
            color: Colors.transparent,
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
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ),
      ),
    );
  }

  // Widget que construye la tarjeta (card) del paquete
  Widget _buildPaqueteCard() {
    final guia = paquete?['numeroGuia'] ?? 'N/A';
    final codigoBarras = paquete?['codigoBarras'] ?? 'N/A';
    final fecha = paquete?['fechaRegistro']
            ?.toString()
            .split('T')
            .first ??
        'N/A';
    final descripcion =
        paquete?['producto']?['description'] ?? 'Sin descripción';
    final cliente =
        paquete?['producto']?['cliente']?['nombre'] ?? 'Cliente';
    final destinatario =
        paquete?['producto']?['destinatario']?['nombre'] ?? 'Destinatario';

    // Se extrae el totalTarifa desde calculoenvio y se formatea el precio
    final totalTarifa =
        paquete?['producto']?['calculoenvio']?['totalTarifa'];
    final precio =
        totalTarifa != null ? '\$${totalTarifa.toString()}' : 'N/A';

    return Container(
      width: 300, // Ajusta el ancho según requieras
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Ícono representativo
          Icon(
            CupertinoIcons.archivebox_fill,
            size: 40,
            color: Colors.blueAccent.withOpacity(0.7),
          ),
          const SizedBox(height: 10),
          Text(
            'Paquete #$guia',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(),
          // Información del paquete
          Text('Código de Barras: $codigoBarras'),
          Text('Fecha de Registro: $fecha'),
          Text('Descripción: $descripcion'),
          Text('Cliente: $cliente'),
          Text('Destinatario: $destinatario'),
          const SizedBox(height: 10),
          // Muestra el precio obtenido desde totalTarifa
          Text(
            precio,
            style: const TextStyle(
              fontSize: 20,
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          // Campos editables para correos
          _buildGlassTextField(
            controller: emailClienteController,
            label: 'Correo Cliente',
            validator: _validarEmail,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 8),
          _buildGlassTextField(
            controller: emailDestinatarioController,
            label: 'Correo Destinatario',
            validator: _validarEmail,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          // Estado del envío de la guía
          (_envioRealizado)
              ? const Text(
                  '¡Guía enviada!',
                  style: TextStyle(color: CupertinoColors.activeGreen),
                )
              : const Text(
                  'Enviando guía...',
                  style: TextStyle(color: CupertinoColors.systemGrey),
                ),
          const SizedBox(height: 12),
          // Botón para confirmar el paquete y crear la entrega
          CupertinoButton.filled(
            child: const Text('Confirmar Paquete'),
            onPressed: () async {
              if (_emailFormKey.currentState?.validate() ?? false) {
                final client = GraphQLProvider.of(context).value;
                // Reenviar email si se cambiaron los correos
                await _enviarGuiaEmail(
                  client,
                  paquete!['id'],
                  emailClienteController.text.trim(),
                  emailDestinatarioController.text.trim(),
                );
                // Crear la entrega, que mostrará un diálogo con el resultado
                await _crearEntrega(client);
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: Colors.white.withOpacity(0.5),
        middle: const Text(
          'Agregar Paquete',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            fontFamily: 'Grandis Extended',
          ),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _emailFormKey,
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Si existe el paquete se muestra la tarjeta
                if (paquete != null)
                  Wrap(
                    alignment: WrapAlignment.center,
                    children: [
                      _buildPaqueteCard(),
                    ],
                  )
                else
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('Cargando paquete...'),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: Colors.grey[200],
    );
  }
}
