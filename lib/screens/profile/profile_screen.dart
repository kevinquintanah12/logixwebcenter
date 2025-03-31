import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shop/screens/administracion/crudtipoproducto_admin_screen.dart'; // Asegúrate de importar la pantalla TipoProductoScreen
import 'package:shop/screens/administracion/crudubicaciones_admin_screen.dart'; // Asegúrate de importar la pantalla CrudUbicacionesAdminScreen
import 'package:shop/screens/administracion/crudcentrodistribucion_admin_screen.dart'; // Asegúrate de importar la pantalla CrudCentroDistribucionAdminScreen

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String role = 'Administrador';  // Puedes cambiar este valor para probar con otros roles.

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Perfil'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Icon(CupertinoIcons.settings, size: 24),
          onPressed: () {
            // Navegar a configuraciones
          },
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('assets/default_profile.png'), // Imagen de perfil predeterminada
              ),
              SizedBox(height: 20),
              Text(
                'Nombre de Usuario',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'correo@ejemplo.com',
                style: TextStyle(fontSize: 18, color: CupertinoColors.inactiveGray),
              ),
              SizedBox(height: 30),
              CupertinoListSection.insetGrouped(
                children: [
                  CupertinoListTile(
                    leading: Icon(CupertinoIcons.person),
                    title: Text('Mi Perfil'),
                    onTap: () {},
                  ),
                  CupertinoListTile(
                    leading: Icon(CupertinoIcons.gear),
                    title: Text('Configuraciones'),
                    onTap: () {},
                  ),
                  CupertinoListTile(
                    leading: Icon(CupertinoIcons.power),
                    title: Text('Cerrar sesión'),
                    onTap: () {},
                  ),
                ],
              ),
              // Solo mostrar secciones administrativas si el rol es 'Administrador' o 'Gerente'
              if (role == 'Administrador' || role == 'Gerente') ...[
                SizedBox(height: 20),
                Text(
                  'Administración',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                CupertinoListSection.insetGrouped(
                  children: [
                    CupertinoListTile(
                      leading: Icon(CupertinoIcons.money_dollar),
                      title: Text('Tarifas'),
                      onTap: () {},
                    ),
                    CupertinoListTile(
                      leading: Icon(CupertinoIcons.map),
                      title: Text('Ubicaciones'),
                      onTap: () {
                        // Mostrar la pantalla emergente de CrudUbicacionesAdmin
                        showCupertinoModalPopup(
                          context: context,
                          builder: (context) => CupertinoPopupSurface(
                            child: Container(
                              padding: EdgeInsets.all(16.0),
                              height: MediaQuery.of(context).size.height * 0.7, // Ajusta el tamaño del modal
                              decoration: BoxDecoration(
                                color: CupertinoColors.white,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(16.0),
                                  topRight: Radius.circular(16.0),
                                ),
                              ),
                              child: Column(
                                children: [
                                  CupertinoNavigationBar(
                                    previousPageTitle: 'Cerrar',
                                    trailing: CupertinoButton(
                                      padding: EdgeInsets.zero,
                                      child: Icon(CupertinoIcons.check_mark, size: 24),
                                      onPressed: () {
                                        // Lógica para guardar ubicaciones si es necesario
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ),
                                  Expanded(
                                    child: CrudUbicaciones(), // Mostrar la pantalla de Ubicaciones aquí
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    CupertinoListTile(
                      leading: Icon(CupertinoIcons.cube_box),
                      title: Text('Tipos de Productos'),
                      onTap: () {
                        // Mostrar la pantalla emergente de CrudTipoProductosAdmin
                        showCupertinoModalPopup(
                          context: context,
                          builder: (context) => CupertinoPopupSurface(
                            child: Container(
                              padding: EdgeInsets.all(16.0),
                              height: MediaQuery.of(context).size.height * 0.7, // Ajusta el tamaño del modal
                              decoration: BoxDecoration(
                                color: CupertinoColors.white,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(16.0),
                                  topRight: Radius.circular(16.0),
                                ),
                              ),
                              child: Column(
                                children: [
                                  CupertinoNavigationBar(
                                    previousPageTitle: 'Cerrar',
                                    trailing: CupertinoButton(
                                      padding: EdgeInsets.zero,
                                      child: Icon(CupertinoIcons.check_mark, size: 24),
                                      onPressed: () {
                                        // Lógica para guardar el producto
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ),
                                  Expanded(
                                    child: CrudTipoProductosAdmin(), // Mostrar la pantalla aquí
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    CupertinoListTile(
                      leading: Icon(CupertinoIcons.cube_box),
                      title: Text('Centros de Distribución'),
                      onTap: () {
                        // Mostrar la pantalla emergente de CrudCentroDistribucionAdmin
                        showCupertinoModalPopup(
                          context: context,
                          builder: (context) => CupertinoPopupSurface(
                            child: Container(
                              padding: EdgeInsets.all(16.0),
                              height: MediaQuery.of(context).size.height * 0.7, // Ajusta el tamaño del modal
                              decoration: BoxDecoration(
                                color: CupertinoColors.white,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(16.0),
                                  topRight: Radius.circular(16.0),
                                ),
                              ),
                              child: Column(
                                children: [
                                  CupertinoNavigationBar(
                                    previousPageTitle: 'Cerrar',
                                    trailing: CupertinoButton(
                                      padding: EdgeInsets.zero,
                                      child: Icon(CupertinoIcons.check_mark, size: 24),
                                      onPressed: () {
                                        // Lógica para guardar el centro de distribución si es necesario
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ),
                                  Expanded(
                                    child: CrudCentrosDistribucion(), // Mostrar la pantalla aquí
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    CupertinoListTile(
                      leading: Icon(CupertinoIcons.person_badge_minus),
                      title: Text('Baja de Empleados'),
                      onTap: () {} 
                    ),
                    CupertinoListTile(
                      leading: Icon(CupertinoIcons.lock),
                      title: Text('Administrar Contraseñas'),
                      onTap: () {}
                    ),
                  ],
                ),
              ],
              SizedBox(height: 20),
              // Botón para cambiar el rol
              CupertinoButton(
                child: Text('Cambiar rol'),
                onPressed: () {
                  setState(() {
                    // Cambiar entre diferentes roles para probar la interfaz
                    role = (role == 'Administrador') ? 'Gerente' : 'Administrador';
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
