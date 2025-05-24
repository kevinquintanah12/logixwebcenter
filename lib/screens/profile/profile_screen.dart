import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop/screens/administracion/crudtipoproducto_admin_screen.dart';
import 'package:shop/screens/administracion/crudubicaciones_admin_screen.dart';
import 'package:shop/screens/administracion/crudcentrodistribucion_admin_screen.dart';

/// Query para obtener datos del usuario autenticado
const String meQuery = r'''
  query {
    me {
      username
      email
    }
  }
''';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _username = '';
  String _email = '';
  bool _loading = true;
  bool _hasFetched = false;
  String role = 'Administrador';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasFetched) {
      _hasFetched = true;
      _fetchMe();
    }
  }

  Future<void> _fetchMe() async {
    final client = GraphQLProvider.of(context).value;
    final result = await client.query(
      QueryOptions(
        document: gql(meQuery),
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (!result.hasException && result.data != null) {
      final me = result.data!['me'];
      setState(() {
        _username = me['username'];
        _email = me['email'];
        _loading = false;
      });
    } else {
      print('Error fetching "me": \${result.exception}');
      setState(() => _loading = false);
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(middle: Text('Perfil')),
        child: Center(child: CupertinoActivityIndicator()),
      );
    }

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(middle: Text('Perfil')),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 30),
              // Avatar de perfil
              CircleAvatar(
                radius: 60,
                child: Icon(CupertinoIcons.person_fill, size: 60, color: CupertinoColors.white),
                backgroundColor: CupertinoColors.activeBlue,
              ),
              SizedBox(height: 20),
              Text(
                _username.isNotEmpty ? _username : 'Sin nombre',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text(
                _email.isNotEmpty ? _email : 'Sin correo',
                style: TextStyle(fontSize: 20, color: CupertinoColors.inactiveGray),
              ),
              SizedBox(height: 40),

              // Solo opción de cerrar sesión
              CupertinoListSection.insetGrouped(
                children: [
                  CupertinoListTile(
                    leading: Icon(CupertinoIcons.power, size: 28),
                    title: Text('Cerrar sesión', style: TextStyle(fontSize: 20)),
                    onTap: _logout,
                  ),
                ],
              ),

              if (role == 'Administrador' || role == 'Gerente') ...[
                SizedBox(height: 30),
                Text(
                  'Administración',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                CupertinoListSection.insetGrouped(
                  children: [
                    CupertinoListTile(
                      leading: Icon(CupertinoIcons.map, size: 32),
                      title: Text('Ubicaciones', style: TextStyle(fontSize: 22)),
                      onTap: () => _showModal(context, CrudUbicaciones()),
                    ),
                    CupertinoListTile(
                      leading: Icon(CupertinoIcons.cube_box, size: 32),
                      title: Text('Tipos de Productos', style: TextStyle(fontSize: 22)),
                      onTap: () => _showModal(context, CrudTipoProductosAdmin()),
                    ),
                    CupertinoListTile(
                      leading: Icon(CupertinoIcons.building_2_fill, size: 32),
                      title: Text('Centros de Distribución', style: TextStyle(fontSize: 22)),
                      onTap: () => _showModal(context, CrudCentrosDistribucion()),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showModal(BuildContext context, Widget childScreen) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => CupertinoPopupSurface(
        child: Container(
          padding: EdgeInsets.all(16),
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: CupertinoColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              CupertinoNavigationBar(
                previousPageTitle: 'Cerrar',
                trailing: CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: Icon(CupertinoIcons.check_mark),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              Expanded(child: childScreen),
            ],
          ),
        ),
      ),
    );
  }
}
