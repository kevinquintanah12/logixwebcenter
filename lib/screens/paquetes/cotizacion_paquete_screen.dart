import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shop/screens/paquetes/paymentview_screen.dart';

class CotizacionPaqueteScreen extends StatelessWidget {
  final String queryCalcularEnvio = r'''
    query {
      ultimoCalculo {
        id
        tarifaPorKm
        tarifaPeso
        tarifaBase
        tarifaExtraTemperatura
        tarifaExtraHumedad
        trasladoiva
        ieps
        totalTarifa
      }
    }
  ''';

  final String queryEnviarCotizacion = r'''
    query EnviarCotizacion($email: String!) {
      enviarUltimoCalculoEmail(email: $email) {
        id
        origenCd {
          ubicacion {
            ciudad
          }
        }
        destino {
          ciudad
        }
        tarifaPorKm
        tarifaPeso
        tarifaBase
        tarifaExtraTemperatura
        tarifaExtraHumedad
        trasladoiva
        ieps
        totalTarifa
      }
    }
  ''';

  CotizacionPaqueteScreen({Key? key}) : super(key: key);

  final TextEditingController correoController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final clientNotifier = GraphQLProvider.of(context);

    return GraphQLProvider(
      client: clientNotifier,
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          backgroundColor: Colors.transparent,
          middle: const Text('Detalle de Cotización'),
          leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(CupertinoIcons.back, color: Colors.black),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Query(
              options: QueryOptions(
                document: gql(queryCalcularEnvio),
              ),
              builder: (QueryResult result, {VoidCallback? refetch, FetchMore? fetchMore}) {
                if (result.isLoading) {
                  return const Center(child: CupertinoActivityIndicator());
                }
                if (result.hasException) {
                  return Center(child: Text("Error: ${result.exception.toString()}"));
                }

                final envio = result.data?['ultimoCalculo'];
                if (envio == null) {
                  return const Center(child: Text("No se encontraron datos."));
                }

                final String tarifaBase = "\$${envio['tarifaBase']}";
                final String tarifaPorKm = "\$${envio['tarifaPorKm']}/km";
                final String tarifaPorKg = "\$${envio['tarifaPeso']}/kg";
                final String tarifaExtraTemperatura = "\$${envio['tarifaExtraTemperatura']}";
                final String tarifaExtraHumedad = "\$${envio['tarifaExtraHumedad']}";
                final String trasladoiva = "\$${envio['trasladoiva']}";
                final String ieps = "\$${envio['ieps']}";
                final String totalTarifa = "\$${envio['totalTarifa']}";

                return SingleChildScrollView(
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetalleItem(context, "Tarifa Base", tarifaBase),
                          _buildDetalleItem(context, "Tarifa por Km", tarifaPorKm),
                          _buildDetalleItem(context, "Tarifa por Kg", tarifaPorKg),
                          _buildDetalleItem(context, "Tarifa Extra Temperatura", tarifaExtraTemperatura),
                          _buildDetalleItem(context, "Tarifa Extra Humedad", tarifaExtraHumedad),
                          _buildDetalleItem(context, "Traslado IVA", trasladoiva),
                          _buildDetalleItem(context, "IEPS", ieps),
                          const Divider(thickness: 1, color: Colors.black26),
                          _buildDetalleItem(context, "Total Estimado", totalTarifa, isTotal: true),
                          const SizedBox(height: 20),
                          // Sección para ingresar el correo
                          const Text(
                            'Ingresa tu correo:',
                            style: TextStyle(fontSize: 14, fontFamily: 'Grandis Extended'),
                          ),
                          const SizedBox(height: 8),
                          CupertinoTextField(
                            controller: correoController,
                            placeholder: 'Correo electrónico',
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(fontSize: 16, color: Colors.black),
                            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.shade300, width: 1),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              CupertinoButton.filled(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                child: const Text(
                                  'Enviar Cotización',
                                  style: TextStyle(fontSize: 16, fontFamily: 'Grandis Extended', color: Colors.white),
                                ),
                                onPressed: () {
                                  _enviarCotizacion(context);
                                },
                              ),
                              CupertinoButton.filled(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                child: const Text(
                                  'Aceptar Envío',
                                  style: TextStyle(fontSize: 16, fontFamily: 'Grandis Extended', color: Colors.white),
                                ),
                                onPressed: () {
                                  // Navegamos hacia PaymentViewScreen
                                  Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                      builder: (context) => PaymentPage(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetalleItem(BuildContext context, String title, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              title,
              style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                fontSize: 16,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _enviarCotizacion(BuildContext context) {
    // Obtener el correo ingresado
    final email = correoController.text.trim();

    if (email.isEmpty) {
      _mostrarDialogoError(context, 'Por favor ingrese un correo electrónico válido.');
      return;
    }

    // Ejecutar la query de GraphQL para enviar cotización
    final client = GraphQLProvider.of(context).value;

    client.query(
      QueryOptions(
        document: gql(queryEnviarCotizacion),
        variables: {
          'email': email,
        },
      ),
    ).then((result) {
      if (result.hasException) {
        _mostrarDialogoError(context, 'Error al enviar la cotización: ${result.exception.toString()}');
      } else {
        _mostrarDialogoExito(context);
      }
    }).catchError((e) {
      _mostrarDialogoError(context, 'Error al enviar la cotización: ${e.toString()}');
    });
  }

  void _mostrarDialogoContacto(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          content: Column(
            children: [
              CupertinoTextField(
                controller: correoController,
                placeholder: 'Correo electrónico',
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.black, fontSize: 16),
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300, width: 1),
                ),
              ),
            ],
          ),
          actions: [
            CupertinoDialogAction(
              child: const Text('Cancelar', style: TextStyle(color: Colors.black)),
              onPressed: () => Navigator.pop(context),
            ),
            CupertinoDialogAction(
              child: const Text('Enviar', style: TextStyle(color: Colors.black)),
              onPressed: () {
                Navigator.pop(context);
                _enviarCotizacion(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _mostrarDialogoExito(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: const Text('Cotización enviada'),
          content: const Text('La cotización ha sido enviada correctamente.'),
          actions: [
            CupertinoDialogAction(
              child: const Text('Aceptar', style: TextStyle(color: Colors.black)),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  void _mostrarDialogoError(BuildContext context, String mensaje) {
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: const Text('Error'),
          content: Text(mensaje),
          actions: [
            CupertinoDialogAction(
              child: const Text('Aceptar', style: TextStyle(color: Colors.black)),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }
}
