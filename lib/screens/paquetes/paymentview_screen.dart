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
    // Controlador para animación de spotlight
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

  // Simula el proceso de pago, mostrando animación de "Procesando" y "Exito"
  Future<void> _simulatePayment() async {
    if (_isProcessing) return;
    setState(() {
      _isProcessing = true;
      _isSuccess = false;
    });
    _controller.forward(from: 0);
    await Future.delayed(const Duration(seconds: 3));
    setState(() {
      _isProcessing = false;
      _isSuccess = true;
    });
    _controller.forward(from: 0);
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _isSuccess = false;
    });
    _controller.reset();
  }

  /// Función que valida el formulario de pago.
  /// Retorna null si la validación es exitosa, o un mensaje de error en caso contrario.
  String? _validarFormulario() {
    final cardNumber = _cardNumberController.text.trim();
    final expiry = _expiryController.text.trim();
    final cvv = _cvvController.text.trim();

    if (cardNumber.isEmpty || expiry.isEmpty || cvv.isEmpty) {
      return 'Por favor, complete todos los campos.';
    }
    // Validar que el número de tarjeta tenga 16 dígitos y sean solo números.
    if (!RegExp(r'^[0-9]{16}$').hasMatch(cardNumber)) {
      return 'Ingrese un número de tarjeta válido (16 dígitos).';
    }
    // Validar que el CVV tenga 3 dígitos.
    if (!RegExp(r'^[0-9]{3}$').hasMatch(cvv)) {
      return 'Ingrese un CVV válido (3 dígitos).';
    }
    // Validar formato del expiry (MM/YY). Se usa una expresión regular simple.
    if (!RegExp(r'^(0[1-9]|1[0-2])\/\d{2}$').hasMatch(expiry)) {
      return 'Ingrese una fecha de expiración válida (MM/YY).';
    }
    return null;
  }

  /// Se invoca al presionar "Pagar". Si la validación falla, muestra un diálogo de error.
  Future<void> _procesarPago() async {
    final errorMensaje = _validarFormulario();
    if (errorMensaje != null) {
      _mostrarDialogoError(context, errorMensaje);
      return;
    }
    // Si todo es correcto, se simula el proceso de pago.
    await _simulatePayment();
    // Luego se navega a la pantalla de "Agregar Cliente" u otra.
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) =>  AddClienteScreen(),
      ),
    );
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
                  // Para el campo de expiración, se usa un GestureDetector y AbsorbPointer para evitar entrada manual.
                  GestureDetector(
                    onTap: _showExpiryDatePicker,
                    child: AbsorbPointer(
                      child: _buildCardInputField(
                        controller: _expiryController,
                        focusNode: FocusNode(), // No necesitamos focus aquí.
                        placeholder: 'MM/YY',
                        keyboardType: TextInputType.datetime,
                        maxLength: 5,
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
                    onPressed: _procesarPago,
                  ),
                ],
              ),
            ),
            if (_isProcessing || _isSuccess)
              Center(
                child: _buildMinimalSuccessOverlay(),
              ),
          ],
        ),
      ),
    );
  }

  /// Widget que muestra la animación de éxito (spotlight) al completar el pago.
  Widget _buildMinimalSuccessOverlay() {
    if (_isSuccess) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 60,
              ),
              const SizedBox(height: 10),
              const Text(
                "¡Éxito!",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                "La operación se completó correctamente.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            ],
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
      maxLength: maxLength,
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(12),
      ),
      style: const TextStyle(fontSize: 16, color: CupertinoColors.black),
    );
  }

  String _formatCardNumber(String cardNumber) {
    return cardNumber.replaceAllMapped(
      RegExp(r".{4}"),
      (match) => "${match.group(0)} ",
    );
  }

  /// Para el campo de expiración, se usa un date picker y se evita la edición manual.
  void _showExpiryDatePicker() async {
    final DateTime currentDate = DateTime.now();
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(currentDate.year),
      lastDate: DateTime(currentDate.year + 10),
      // Se puede personalizar para que solo muestre mes y año.
    );

    if (pickedDate != null) {
      final String formattedDate = DateFormat('MM/yy').format(pickedDate);
      setState(() {
        _expiryController.text = formattedDate;
      });
    }
  }

  /// Muestra un diálogo de error con un mensaje personalizado.
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
