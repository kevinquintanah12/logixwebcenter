import 'dart:async';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class AtencionPaqueteScreen extends StatefulWidget {
  const AtencionPaqueteScreen({Key? key}) : super(key: key);

  @override
  State<AtencionPaqueteScreen> createState() => _AtencionPaqueteScreenState();
}

class _Message {
  final String text;
  final bool fromAgent;
  final String peer;
  final DateTime timestamp;
  _Message(this.text, this.fromAgent, this.peer, this.timestamp);
}

class _AtencionPaqueteScreenState extends State<AtencionPaqueteScreen>
    with SingleTickerProviderStateMixin {
  late GraphQLClient _client;
  bool _initialized = false;

  ObservableQuery? _queueWatcher;
  StreamSubscription<QueryResult>? _subQueue;
  ObservableQuery? _historyWatcher;
  StreamSubscription<QueryResult>? _subIncoming;

  final _chatController = TextEditingController();
  final List<_Message> messages = [];
  final Set<String> queue = {};

  bool connected = false;
  String? selectedClient;
  static const String AGENT_CHANNEL = 'agent';
  final royalBlue = const Color(0xFF4169E1);

  // Controllers para pestañas
  final _destController      = TextEditingController();
  final _guiaController      = TextEditingController();
  final _paqDestController   = TextEditingController();
  final _paqCliController    = TextEditingController();
  final _paquetesController  = TextEditingController();
  final _clientesController  = TextEditingController();
  final _formKey             = GlobalKey<FormState>();

  late TabController _tabController;
  int _currentTab = 0;

  // GraphQL queries/subscriptions
  static const _buscarDestQ = r'''
    query BuscarDestinatarios($termino: String!) {
      buscarDestinatarios(termino: $termino) {
        nombre
        apellidos
        correoElectronico
      }
    }
  ''';

  static const _entregaGuiaQ = r'''
    query EntregaPorGuia($numeroGuia: String!) {
      entregaPorGuia(numeroGuia: $numeroGuia) {
        estado
        paquete { numeroGuia }
      }
    }
  ''';

  static const _paquetesPorNombreDestQ = r'''
    query PaquetesPorNombreDestinatario($nombre: String!) {
      paquetesPorNombreDestinatario(nombre: $nombre) {
        id
        numeroGuia
        producto { destinatario { nombre } }
      }
    }
  ''';

  static const _paquetesPorNombreClienteQ = r'''
    query PaquetesPorNombreCliente($nombre: String!) {
      paquetes_por_nombre_cliente(nombre: $nombre) {
        id
        codigoBarras
        producto { cliente { nombre } }
      }
    }
  ''';

  static const _paquetesPorNombreQ = r'''
    query PaquetesPorNombre($nombre: String!) {
      paquetesPorNombre(nombre: $nombre) {
        numeroGuia
        producto { nombre }
      }
    }
  ''';

  static const _paquetesPorGuiaQ = r'''
    query PaquetesPorNumeroGuia($numeroGuia: String!) {
      paquetesPorNumeroGuia(numeroGuia: $numeroGuia) {
        codigoBarras
        fechaRegistro
      }
    }
  ''';

  static const _paquetesPorCodigoQ = r'''
    query PaquetesPorCodigoBarras($codigoBarras: String!) {
      paquetesPorCodigoBarras(codigoBarras: $codigoBarras) {
        numeroGuia
        producto { nombre }
      }
    }
  ''';

  static const _buscarClientesQ = r'''
    query BuscarClientes($termino: String!) {
      buscarClientes(termino: $termino) {
        nombre
        apellido
        razonSocial
        rfc
      }
    }
  ''';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _client = GraphQLProvider.of(context).value;
      _startQueueWatchAndSub();
      _startIncomingSubscription();
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _queueWatcher?.close();
    _subQueue?.cancel();
    _historyWatcher?.close();
    _subIncoming?.cancel();
    for (var c in [
      _chatController,
      _destController,
      _guiaController,
      _paqDestController,
      _paqCliController,
      _paquetesController,
      _clientesController
    ]) {
      c.dispose();
    }
    _tabController.dispose();
    super.dispose();
  }

  void _startQueueWatchAndSub() {
    _queueWatcher = _client.watchQuery(
      WatchQueryOptions(
        document: gql(r'''
          query ClientesActivos { clientesActivos }
        '''),
        fetchPolicy: FetchPolicy.networkOnly,
        pollInterval: const Duration(seconds: 5),
      ),
    );
    _queueWatcher!.stream.listen((res) {
      if (!res.hasException && res.data != null) {
        final list = (res.data!['clientesActivos'] as List<dynamic>)
            .cast<String>()
            .where((name) => name != AGENT_CHANNEL)
            .toList();
        setState(() {
          queue
            ..clear()
            ..addAll(list);
        });
      }
    });

    _subQueue = _client
        .subscribe(SubscriptionOptions(document: gql(r'''
          subscription ActiveClients {
            activeClients { nombre action }
          }
        ''')))
        .listen((res) {
      if (res.hasException || res.isLoading || res.data == null) return;
      final ev = res.data!['activeClients'] as Map<String, dynamic>;
      final name = ev['nombre'] as String;
      final action = ev['action'] as String;
      if (name == AGENT_CHANNEL) return;
      setState(() {
        if (action == 'join')
          queue.add(name);
        else
          queue.remove(name);
      });
    });
  }

  void _startIncomingSubscription() {
    _subIncoming = _client.subscribe(
      SubscriptionOptions(
        document: gql(r'''
          subscription PrivateChat($nombre: String!) {
            privateChat(nombre: $nombre) {
              mensaje { remitente destinatario contenido timestamp }
            }
          }
        '''),
        variables: {'nombre': AGENT_CHANNEL},
      ),
    ).listen((res) {
      if (res.hasException || res.isLoading || res.data == null) return;
      final payload = (res.data!['privateChat'] as Map?)?['mensaje'] as Map?;
      if (payload == null) return;
      final remitente    = payload['remitente']    as String? ?? '<desconocido>';
      final destinatario = payload['destinatario'] as String? ?? '<desconocido>';
      final contenido    = payload['contenido']    as String? ?? '';
      final timestamp    = payload['timestamp']    as String? ?? '';
      final dt           = DateTime.tryParse(timestamp) ?? DateTime.now();
      final peer         = remitente == AGENT_CHANNEL ? destinatario : remitente;
      setState(() {
        messages.add(_Message(contenido, remitente == AGENT_CHANNEL, peer, dt));
        messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      });
    });
  }

  void _connectToClient(String nombre) {
    _historyWatcher?.close();
    messages.clear();
    setState(() {
      selectedClient = nombre;
      connected = true;
    });
    _historyWatcher = _client.watchQuery(
      WatchQueryOptions(
        document: gql(r'''
          query Mensajes($nombre: String!) {
            mensajes(nombre: $nombre) {
              remitente destinatario contenido timestamp
            }
          }
        '''),
        variables: {'nombre': nombre},
        fetchPolicy: FetchPolicy.networkOnly,
        pollInterval: const Duration(seconds: 5),
      ),
    );
    _historyWatcher!.stream.listen((res) {
      if (res.hasException || res.data == null) return;
      final list = (res.data!['mensajes'] as List).map((m) {
        final map = m as Map<String, dynamic>;
        final r  = map['remitente']   as String? ?? '';
        final d  = map['destinatario']as String? ?? '';
        final c  = map['contenido']   as String? ?? '';
        final ts = map['timestamp']   as String? ?? '';
        final dt = DateTime.tryParse(ts) ?? DateTime.now();
        final peer = r == AGENT_CHANNEL ? d : r;
        return _Message(c, r == AGENT_CHANNEL, peer, dt);
      }).toList();
      setState(() {
        messages
          ..clear()
          ..addAll(list)
          ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
      });
    });
  }

  Future<void> _sendMessage() async {
    final text = _chatController.text.trim();
    if (!connected || text.isEmpty || selectedClient == null) return;
    _chatController.clear();
    setState(() {
      messages.add(_Message(text, true, selectedClient!, DateTime.now()));
    });
    await _client.mutate(
      MutationOptions(
        document: gql(r'''
          mutation EnviarMensajePublico($destinatario: String!, $contenido: String!) {
            enviarMensajePublico(destinatario: $destinatario, contenido: $contenido) {
              mensaje { remitente destinatario contenido timestamp }
            }
          }
        '''),
        variables: {'destinatario': selectedClient, 'contenido': text},
      ),
    );
  }

  void _finishChat() {
    _historyWatcher?.close();
    setState(() {
      connected = false;
      selectedClient = null;
      messages.clear();
    });
  }

  Future<void> _runQuery(String query, Map<String, dynamic> vars) async {
    final result = await _client.query(
      QueryOptions(document: gql(query), variables: vars),
    );
    if (result.hasException || result.data == null) {
      _showResultsDialog(['No se encontraron resultados']);
      return;
    }
    final lines = _formatData(result.data!);
    _showResultsDialog(lines.isEmpty ? ['No se encontraron resultados'] : lines);
  }

  List<String> _formatData(Map<String, dynamic> data, [String prefix = '']) {
    final lines = <String>[];
    data.forEach((key, value) {
      if (key == '__typename') return;
      if (value is Map<String, dynamic>) {
        lines.add('$prefix$key:');
        lines.addAll(_formatData(value, '$prefix  '));
      } else if (value is List) {
        for (var item in value) {
          if (item is Map<String, dynamic>) {
            lines.add('$prefix•');
            lines.addAll(_formatData(item, '$prefix  '));
          } else {
            lines.add('$prefix• $item');
          }
        }
      } else {
        lines.add('$prefix$key: $value');
      }
    });
    return lines;
  }

  void _showResultsDialog(List<String> lines) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(
          'Resultado:',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: lines
                .map((l) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: SelectableText(
                        l,
                        style: const TextStyle(fontSize: 18, color: Colors.black),
                      ),
                    ))
                .toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          connected
              ? 'Atendiendo a $selectedClient'
              : 'Clientes en cola (${queue.length})',
        ),
        backgroundColor: royalBlue,
      ),
      body: Row(
        children: [
          // Chat y cola
          Expanded(
            flex: 1,
            child: Column(
              children: [
                if (!connected)
                  SizedBox(
                    height: 100,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: queue.map((c) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            width: 120,
                            child: ElevatedButton(
                              onPressed: () => _connectToClient(c),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: royalBlue,
                              ),
                              child: Text('Atender a $c',
                                  textAlign: TextAlign.center),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      itemCount: messages.length,
                      itemBuilder: (_, i) {
                        final m = messages[i];
                        return Align(
                          alignment: m.fromAgent
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.all(8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: m.fromAgent
                                  ? royalBlue.withOpacity(0.2)
                                  : royalBlue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(m.text),
                          ),
                        );
                      },
                    ),
                  ),
                if (connected)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _chatController,
                            decoration:
                                const InputDecoration(hintText: 'Escribe mensaje'),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: _sendMessage,
                        ),
                      ],
                    ),
                  ),
                if (connected)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: _finishChat,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: royalBlue),
                      child: const Text('Finalizar Atención'),
                    ),
                  ),
              ],
            ),
          ),

          // Pestañas y formularios
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Container(
                  color: Colors.white,
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: royalBlue,
                    labelColor: royalBlue,
                    unselectedLabelColor: Colors.black,
                    tabs: const [
                      Tab(text: 'Destinatarios'),
                      Tab(text: 'Entregas'),
                      Tab(text: 'Guias.'),
                      Tab(text: 'Paquetes'),
                      Tab(text: 'Clientes'),
                    ],
                    onTap: (idx) => setState(() => _currentTab = idx),
                  ),
                ),               
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: IndexedStack(
                        index: _currentTab,
                        children: [
                          // 1. Destinatarios
                          _buildField(
                            _destController,
                            'Buscar destinatarios',
                            () => _runQuery(
                                _buscarDestQ, {'termino': _destController.text}),
                          ),

                          // 2. Entregas por guía
                          _buildField(
                            _guiaController,
                            'Número de guía',
                            () => _runQuery(_entregaGuiaQ,
                                {'numeroGuia': _guiaController.text}),
                          ),

                          // 3. Paquetes por destinatario / cliente
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Por destinatario',
                                  style:
                                      Theme.of(context).textTheme.titleLarge),
                              TextFormField(
                                controller: _paqDestController,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: 'Nombre destinatario',
                                ),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () => _runQuery(
                                    _paquetesPorNombreDestQ,
                                    {'nombre': _paqDestController.text}),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: royalBlue),
                                child:
                                    const Text('Consultar destinatario'),
                              ),
                              const Divider(height: 32),
                              Text('Por cliente',
                                  style:
                                      Theme.of(context).textTheme.titleLarge),
                              TextFormField(
                                controller: _paqCliController,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: 'Nombre cliente',
                                ),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () => _runQuery(
                                    _paquetesPorNombreClienteQ,
                                    {'nombre': _paqCliController.text}),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: royalBlue),
                                child: const Text('Consultar cliente'),
                              ),
                            ],
                          ),

                          // 4. Paquetes genéricos (guía/código/nombre)
                          _buildField(
                            _paquetesController,
                            'Nombre o GUIA o Cód. Barras',
                            () {
                              final t = _paquetesController.text;
                              if (RegExp(r'^[A-Z]{3}\d').hasMatch(t)) {
                                _runQuery(_paquetesPorGuiaQ,
                                    {'numeroGuia': t});
                              } else if (RegExp(r'^[A-Z]{3}').hasMatch(t)) {
                                _runQuery(_paquetesPorCodigoQ,
                                    {'codigoBarras': t});
                              } else {
                                _runQuery(_paquetesPorNombreQ,
                                    {'nombre': t});
                              }
                            },
                          ),

                          // 5. Buscar clientes
                          _buildField(
                            _clientesController,
                            'Buscar clientes',
                            () => _runQuery(_buscarClientesQ,
                                {'termino': _clientesController.text}),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(
      TextEditingController ctrl, String label, VoidCallback onPressed) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        TextFormField(
          controller: ctrl,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: label,
          ),
          validator: (v) => (v == null || v.isEmpty) ? 'Ingrese $label' : null,
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(backgroundColor: royalBlue),
          child: const Text('Consultar'),
        ),
      ],
    );
  }
}
