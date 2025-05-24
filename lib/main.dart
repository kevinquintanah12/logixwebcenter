import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart'; // Importación de GraphQL
import 'package:shared_preferences/shared_preferences.dart'; // Importar SharedPreferences
import 'package:shop/route/route_constants.dart';
import 'package:shop/route/router.dart' as router;
import 'package:shop/theme/app_theme.dart';

Future<ValueNotifier<GraphQLClient>> getClient() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token');

  print("🛠️ Token en getClient(): $token");

  // 1) HTTP link para queries y mutations
  final HttpLink httpLink = HttpLink(
    "https://logix-ioz0.onrender.com/graphql/",
    defaultHeaders: {
      'Authorization': token != null ? 'JWT $token' : '',
    },
  );

  // 2) WebSocket link para subscriptions
  final WebSocketLink wsLink = WebSocketLink(
    "wss://logix-ioz0.onrender.com/graphql/",
    config: SocketClientConfig(
      initialPayload: () => {
        'Authorization': token != null ? 'JWT $token' : '',
      },
      autoReconnect: true,
      inactivityTimeout: Duration(minutes: 5),
    ),
  );

  // 3) Combinar ambos: si es subscription va por wsLink, si no por httpLink
  final Link link = Link.split(
    (request) => request.isSubscription,
    wsLink,
    httpLink,
  );

  final client = ValueNotifier<GraphQLClient>(
    GraphQLClient(
      cache: GraphQLCache(),
      link: link,
    ),
  );

  return client;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Necesario si usas SharedPreferences antes de runApp
  runApp(const MyApp());
}

// Widget principal
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const GraphQLWrapper(); // Usas tu widget personalizado aquí
  }
}

class GraphQLWrapper extends StatefulWidget {
  const GraphQLWrapper({super.key});

  @override
  State<GraphQLWrapper> createState() => _GraphQLProviderState();
}

class _GraphQLProviderState extends State<GraphQLWrapper> {
  ValueNotifier<GraphQLClient>? _client;

  @override
  void initState() {
    super.initState();
    getClient().then((client) {
      setState(() {
        _client = client;
      });
    });
  }

  void refreshClient() async {
    final newClient = await getClient();
    setState(() {
      _client = newClient;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_client == null) {
      return const MaterialApp(home: Center(child: CircularProgressIndicator()));
    }

    return GraphQLProvider(
      client: _client!,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Truck GPS',
        theme: AppTheme.lightTheme(context),
        themeMode: ThemeMode.dark,
        onGenerateRoute: router.generateRoute,
      ),
    );
  }
}

// Llamar a esto desde cualquier parte para actualizar el token
void updateGraphQLClient(BuildContext context) {
  final _GraphQLProviderState? state =
      context.findAncestorStateOfType<_GraphQLProviderState>();
  state?.refreshClient();
}
