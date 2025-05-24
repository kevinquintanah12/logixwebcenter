import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shop/constants.dart';
import 'package:shop/route/screen_export.dart';

class EntryPoint extends StatefulWidget {
  const EntryPoint({super.key});

  @override
  State<EntryPoint> createState() => _EntryPointState();
}

class _EntryPointState extends State<EntryPoint> {
  // Pantallas disponibles (sin "Viajes")
  final List<Widget> _pages = [
    CatalogsScreen(),
    ProfileScreen(),
    PaquetesScreen(),
  ];

  // Inicializar en la primera pantalla (Catálogos)
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    SvgPicture svgIcon(String src, {Color? color}) {
      return SvgPicture.asset(
        src,
        height: 20,
        colorFilter: ColorFilter.mode(
          color ?? Colors.grey,
          BlendMode.srcIn,
        ),
      );
    }

    Widget selectedIcon(String src) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
        ),
        child: svgIcon(src, color: Colors.white),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        bool isDesktop = constraints.maxWidth >= 1024;

        return Scaffold(
          appBar: null,
          body: Row(
            children: [
              if (isDesktop)
                NavigationRail(
                  backgroundColor: const Color(0xFF031273),
                  selectedIndex: _currentIndex,
                  onDestinationSelected: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  labelType: NavigationRailLabelType.all,
                  useIndicator: false,
                  minWidth: 50,
                  groupAlignment: 0.0,
                  destinations: [
                    NavigationRailDestination(
                      icon: svgIcon("assets/icons/Category.svg"),
                      selectedIcon: selectedIcon("assets/icons/Category.svg"),
                      label: const Text(
                        "Catálogos",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    NavigationRailDestination(
                      icon: svgIcon("assets/icons/Profile.svg"),
                      selectedIcon: selectedIcon("assets/icons/Profile.svg"),
                      label: const Text(
                        "Perfil",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    NavigationRailDestination(
                      icon: svgIcon("assets/icons/package.svg"),
                      selectedIcon: selectedIcon("assets/icons/package.svg"),
                      label: const Text(
                        "Paquetes",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              Expanded(
                child: PageTransitionSwitcher(
                  duration: defaultDuration,
                  transitionBuilder: (child, animation, secondAnimation) {
                    return FadeThroughTransition(
                      animation: animation,
                      secondaryAnimation: secondAnimation,
                      child: child,
                    );
                  },
                  child: _pages[_currentIndex],
                ),
              ),
            ],
          ),
          bottomNavigationBar: isDesktop
              ? null
              : BottomNavigationBar(
                  currentIndex: _currentIndex,
                  onTap: (index) {
                    if (index != _currentIndex) {
                      setState(() {
                        _currentIndex = index;
                      });
                    }
                  },
                  backgroundColor: Theme.of(context).brightness == Brightness.light
                      ? Colors.white
                      : const Color(0xFF101015),
                  type: BottomNavigationBarType.fixed,
                  selectedFontSize: 10,
                  unselectedFontSize: 10,
                  iconSize: 20,
                  selectedItemColor: primaryColor,
                  unselectedItemColor: Colors.grey,
                  elevation: 8,
                  items: [
                    BottomNavigationBarItem(
                      icon: svgIcon("assets/icons/Category.svg"),
                      activeIcon: svgIcon("assets/icons/Category.svg", color: primaryColor),
                      label: "Catálogos",
                    ),
                    BottomNavigationBarItem(
                      icon: svgIcon("assets/icons/Profile.svg"),
                      activeIcon: svgIcon("assets/icons/Profile.svg", color: primaryColor),
                      label: "Perfil",
                    ),
                    BottomNavigationBarItem(
                      icon: svgIcon("assets/icons/package.svg"),
                      activeIcon: svgIcon("assets/icons/package.svg", color: primaryColor),
                      label: "Paquetes",
                    ),
                  ],
                ),
        );
      },
    );
  }
}
