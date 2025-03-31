import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shop/screens/paquetes/agregarcliente_paquete_screen.dart';
import 'package:lottie/lottie.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({Key? key}) : super(key: key);

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage>
    with TickerProviderStateMixin {
  bool _isProcessing = false;
  bool _isSuccess = false;
  late AnimationController _controller;
  late Animation<double> _animation;

  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  final FocusNode _cardNumberFocus = FocusNode();
  final FocusNode _cvvFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    // El controlador se usará para animar la escala del spotlight.
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _cardNumberFocus.dispose();
    _cvvFocus.dispose();
    super.dispose();
  }

  // Simula el proceso de pago, mostrando la animación de spotlight para
  // "Procesando pago" y luego "Pago Exitoso" en el centro de la pantalla.
  Future<void> _simulatePayment() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
      _isSuccess = false;
    });
    // Inicia la animación para el estado de procesando
    _controller.forward(from: 0);
    await Future.delayed(const Duration(seconds: 3));

    setState(() {
      _isProcessing = false;
      _isSuccess = true;
    });
    // Reanuda la animación para mostrar el estado de éxito
    _controller.forward(from: 0);
    await Future.delayed(const Duration(seconds: 2));

    // Oculta el overlay de éxito
    setState(() {
      _isSuccess = false;
    });
    _controller.reset();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double horizontalPadding = screenWidth * 0.06;

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Pago Automático'),
      ),
      child: SafeArea(
        // Usamos un Stack para colocar el contenido normal y sobre él
        // el overlay animado en el centro.
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 24.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  _buildCreditCardPreview(context),
                  const SizedBox(height: 30),
                  _buildCardInputField(
                    controller: _cardNumberController,
                    focusNode: _cardNumberFocus,
                    placeholder: 'Número de Tarjeta',
                    keyboardType: TextInputType.number,
                    maxLength: 16,
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: _showExpiryDatePicker,
                    child: AbsorbPointer(
                      child: _buildCardInputField(
                        controller: _expiryController,
                        focusNode: FocusNode(),
                        placeholder: 'MM/YY',
                        keyboardType: TextInputType.datetime,
                        maxLength: 5, // "MM/YY"
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildCardInputField(
                    controller: _cvvController,
                    focusNode: _cvvFocus,
                    placeholder: 'CVV',
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    maxLength: 3,
                  ),
                  const SizedBox(height: 30),
                  CupertinoButton.filled(
                    child: const Text("Pagar"),
                    onPressed: () async {
    // Llamamos a simulatePayment y esperamos que se complete
                    await _simulatePayment();

                    // Luego navegamos a PaymentPage
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => AddClienteScreen(),
                      ),
                    );
                  },
                )
                    
                                  // Navegamos hacia PaymentViewScreen
                                  
                  
                  // Se removió la visualización previa del estado de pago
                  // ya que ahora se muestra como overlay.
                ],
              ),
            ),
            // Si se está procesando o se tuvo éxito, se muestra el overlay de spotlight.
            if (_isProcessing || _isSuccess)
              Center(
                child: _buildMinimalSuccessOverlay(),
              ),
          ],
        ),
      ),
    );
  }

  /// Crea el overlay de animación con efecto spotlight usando ScaleTransition.

/// Widget minimalista que muestra la animación de éxito
Widget _buildMinimalSuccessOverlay() {
  if (_isSuccess) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Lottie.asset(
          'assets\success.json', // Asegúrate de tener este asset en tu proyecto
          width: 100,
          repeat: false,
        ),
      ),
    );
  } else {
    return const SizedBox.shrink();
  }
}


  Widget _buildCreditCardPreview(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    double cardWidth;
    double cardHeight;

    if (screenWidth >= 600) {
      cardWidth = 400;
      cardHeight = 250;
    } else {
      cardWidth = screenWidth * 0.9;
      cardHeight = cardWidth * 0.6;
    }

    return Center(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 6,
        child: Container(
          width: cardWidth,
          height: cardHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [Color(0xFF4A90E2), Color(0xFF50E3C2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Tarjeta',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  _cardNumberController.text.isEmpty
                      ? '#### #### #### ####'
                      : _formatCardNumber(_cardNumberController.text),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _expiryController.text.isEmpty
                          ? 'MM/YY'
                          : _expiryController.text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _cvvController.text.isEmpty ? 'CVV' : _cvvController.text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardInputField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String placeholder,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    int? maxLength,
  }) {
    return CupertinoTextField(
      controller: controller,
      focusNode: focusNode,
      placeholder: placeholder,
      keyboardType: keyboardType,
      obscureText: obscureText,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(12),
      ),
      style: const TextStyle(fontSize: 16, color: CupertinoColors.black),
      maxLength: maxLength,
    );
  }

  String _formatCardNumber(String cardNumber) {
    return cardNumber.replaceAllMapped(
      RegExp(r".{4}"),
      (match) => "${match.group(0)} ",
    );
  }

  void _showExpiryDatePicker() async {
    final DateTime currentDate = DateTime.now();
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(currentDate.year),
      lastDate: DateTime(currentDate.year + 10),
    );

    if (pickedDate != null) {
      final String formattedDate = DateFormat('MM/yy').format(pickedDate);
      setState(() {
        _expiryController.text = formattedDate;
      });
    }
  }
}
