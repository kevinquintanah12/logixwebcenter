import 'package:flutter/material.dart'; 
import 'package:flutter_svg/svg.dart';
import 'package:shop/constants.dart';
import 'package:shop/route/route_constants.dart';

class OnBordingScreen extends StatelessWidget {
  const OnBordingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1) Imagen de fondo a pantalla completa
          Positioned.fill(
            child: Image.asset(
              'assets/images/inicio.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // 2) Capa oscura semitransparente para contraste
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.5),
            ),
          ),
          // 3) Contenido encima
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, logInScreenRoute);
                      },
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          color: Colors.white, // blanco directo
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'LogiX',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: defaultPadding / 2),
                  Text(
                    'Puntualidad, Seguridad, Confianza, Innovación, Responsabilidad Ambiental.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white70, // un tono algo más suave
                        ),
                  ),
                  const Spacer(),
                  SizedBox(
                    height: 60,
                    width: 60,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, logInScreenRoute);
                      },
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                      child: SvgPicture.asset(
                        'assets/icons/Arrow - Right.svg',
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: defaultPadding),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
