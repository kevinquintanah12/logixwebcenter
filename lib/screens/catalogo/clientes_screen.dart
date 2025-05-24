import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class ClientesScreen extends StatefulWidget {
  const ClientesScreen({Key? key}) : super(key: key);

  @override
  State<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  String searchQuery = '';
  final Map<String, bool> favoriteStatus = {};

  static const String obtenerClientesQuery = """
    query ObtenerClientes {
      clientes {
        id
        nombre
        apellido
        rfc
        codigoPostal
        direccion
        telefono
        email
      }
    }
  """;

  static const String actualizarClienteMutation = """
    mutation ActualizarCliente(
      \$id: Int!,
      \$nombre: String!,
      \$apellido: String!,
      \$telefono: String!,
      \$email: String!
    ) {
      actualizarCliente(
        id: \$id,
        nombre: \$nombre,
        apellido: \$apellido,
        telefono: \$telefono,
        email: \$email
      ) {
        cliente {
          id
          nombre
          apellido
          telefono
          email
        }
      }
    }
  """;

  static const String eliminarClienteMutation = """
    mutation EliminarCliente(\$id: Int!) {
      eliminarCliente(id: \$id) {
        ok
      }
    }
  """;

  void _showEditSheet(Map<String, String> client, VoidCallback? refetch) {
    // Separa nombre completo en nombre y apellido
    final parts = client['name']!.split(' ');
    final initialNombre = parts.first;
    final initialApellido = parts.length > 1 ? parts.sublist(1).join(' ') : '';

    final nombreCtrl = TextEditingController(text: initialNombre);
    final apellidoCtrl = TextEditingController(text: initialApellido);
    final telefonoCtrl = TextEditingController(text: client['telefono']);
    final emailCtrl = TextEditingController(text: client['email']);
    final id = int.parse(client['id']!);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16, right: 16, top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Editar Cliente',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nombreCtrl,
              decoration: InputDecoration(
                labelText: 'Nombre',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: apellidoCtrl,
              decoration: InputDecoration(
                labelText: 'Apellido',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: telefonoCtrl,
              decoration: InputDecoration(
                labelText: 'Teléfono',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailCtrl,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 24),
            Mutation(
              options: MutationOptions(
                document: gql(actualizarClienteMutation),
                onCompleted: (_) {
                  Navigator.pop(context);
                  refetch?.call();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✏️ Cliente actualizado'))
                  );
                },
                onError: (e) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${e.toString()}'))
                  );
                },
              ),
              builder: (RunMutation run, QueryResult? result) => SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: result?.isLoading ?? false
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.save),
                  label: const Text('Guardar cambios'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: result?.isLoading ?? false
                      ? null
                      : () {
                          run({
                            'id': id,
                            'nombre': nombreCtrl.text.trim(),
                            'apellido': apellidoCtrl.text.trim(),
                            'telefono': telefonoCtrl.text.trim(),
                            'email': emailCtrl.text.trim(),
                          });
                        },
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(String id, VoidCallback? refetch) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: const [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Eliminar Cliente'),
          ],
        ),
        content: const Text('¿Estás seguro de que quieres eliminar este cliente?'),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.delete),
            label: const Text('Eliminar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => const Center(child: CircularProgressIndicator()),
              );
              GraphQLProvider.of(context).value.mutate(
                MutationOptions(
                  document: gql(eliminarClienteMutation),
                  variables: { 'id': int.parse(id) },
                )
              ).then((_) {
                Navigator.pop(context);
                refetch?.call();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('🗑️ Cliente eliminado'))
                );
              });
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenSize = screenWidth / screenHeight;
    final fontSizeSubtitle = screenSize > 1 ? 14.0 : 10.0;
    final iconSize = screenSize > 1 ? 30.0 : 24.0;

    return Query(
      options: QueryOptions(
        document: gql(obtenerClientesQuery),
        fetchPolicy: FetchPolicy.networkOnly,
      ),
      builder: (QueryResult result, { VoidCallback? refetch, FetchMore? fetchMore }) {
        if (result.isLoading) {
          return const Center(child: CupertinoActivityIndicator());
        }
        if (result.hasException || result.data == null) {
          return Center(child: Text('Error al cargar clientes.\nRevisa la consola.'));
        }

        final datos = result.data!['clientes'] as List;
        final filtered = datos.where((c) {
          final full = '${c['nombre']} ${c['apellido']}'.toLowerCase();
          return full.contains(searchQuery.toLowerCase());
        }).toList();

        final Map<String, List<Map<String, String>>> grouped = {};
        for (var c in filtered) {
          final fullName = '${c['nombre']} ${c['apellido']}';
          final letter = fullName[0].toUpperCase();
          grouped.putIfAbsent(letter, () => []).add({
            'id': c['id'].toString(),
            'name': fullName,
            'telefono': c['telefono'] as String,
            'email': c['email'] as String,
          });
        }

        return Scaffold(
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Tooltip(
                      message: "Clientes",
                      child: Icon(Icons.person, color: Colors.grey, size: iconSize),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Buscar cliente',
                          hintStyle: TextStyle(
                            color: Colors.grey, fontSize: fontSizeSubtitle),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(
                              color: Colors.grey.withOpacity(0.5)),
                          ),
                        ),
                        onChanged: (v) => setState(() => searchQuery = v),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: grouped.keys.length,
                  itemBuilder: (context, index) {
                    final letter = grouped.keys.elementAt(index);
                    final clients = grouped[letter]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                          child: Text(
                            letter,
                            style: TextStyle(
                              fontSize: fontSizeSubtitle,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        ...clients.map((client) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 2),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 6,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                                border: Border.all(
                                  color: const Color(0xFF031273)
                                      .withOpacity(0.5),
                                  width: 1.5,
                                ),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                                title: Text(
                                  client["name"]!,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Tel: ${client["telefono"]!}',
                                      style: TextStyle(
                                        fontSize: fontSizeSubtitle,
                                        color: Colors.black54),
                                    ),
                                    Text(
                                      'Email: ${client["email"]!}',
                                      style: TextStyle(
                                        fontSize: fontSizeSubtitle,
                                        color: Colors.black54),
                                    ),
                                  ],
                                ),
                                trailing: PopupMenuButton<String>(
                                  icon: Icon(Icons.more_vert,
                                      color: Colors.grey[700]),
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      _showEditSheet(client, refetch);
                                    } else if (value == 'delete') {
                                      _showDeleteDialog(client['id']!, refetch);
                                    }
                                  },
                                  itemBuilder: (_) => const [
                                    PopupMenuItem(
                                      value: 'edit',
                                      child: ListTile(
                                        leading:
                                            Icon(Icons.edit, color: Colors.blue),
                                        title: Text('Editar'),
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: ListTile(
                                        leading: Icon(Icons.delete,
                                            color: Colors.red),
                                        title: Text('Eliminar'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
