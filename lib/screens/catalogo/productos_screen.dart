import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../../../models/productos_model.dart';
import '../../../query/productos_query.dart';
import 'add_productos_screen.dart';
import 'package:shop/main.dart'; // Importar el archivo principal donde está la función
import '../../../mutation/delete_productos_mutation.dart';

class ProductosScreen extends StatefulWidget {
  const ProductosScreen({super.key});

  @override
  _ProductosScreenState createState() => _ProductosScreenState();
}

class _ProductosScreenState extends State<ProductosScreen> {
  TextEditingController _searchController = TextEditingController();
  String searchTerm = "*";

  Future<List<Producto>> getProductos(GraphQLClient client, String searchTerm) async {
    final QueryOptions options = QueryOptions(
      document: gql('''
        query {
          links(search: "$searchTerm") {
            id
            url
            description
            precio
            modelo 
            status
            marca {
              id
              description
            }
            linea {
              id
              description
              
            }
            claveunidad {
              id
            }
            
            codigosat {
              id
            }
            
            codigobarras
            descuento
            existencias
            noidentificacion
            retencionieps
            retencionisr
            retencioniva
            stockmax
            stockmin
            trasladoieps
            trasladoiva

          }
        }
      '''),
    );

    try {
      final result = await client.query(options);

      if (result.hasException) {
        print("Error de GraphQL: ${result.exception}");
        throw Exception(result.exception.toString());
      }

      if (result.data == null || result.data!['links'] == null) {
        print("Respuesta inválida: ${result.data}");
        throw Exception('No se encontraron productos');
      }

      
      // Filtrar productos con status = 1
      final List<Producto> productos = (result.data?['links'] as List)
          .map((productoJson) => Producto.fromJson(productoJson))
          .where((producto) => producto.status == 1) // Filtrar aquí
          .toList();

      print("Productos filtrados: $productos");
      return productos;
    } catch (e) {
      print("Error al procesar los productos: $e");
      throw Exception('Error al procesar los productos');
    }
  }

  Future<void> _eliminarProducto(int idprod) async {
    if (idprod <= 0) {
      print("ID de producto no válido.");
      return;
    }

    final GraphQLClient client = GraphQLProvider.of(context).value;
    final deleteMutation = DeleteProductoMutation(client: client);

    try {
      // Ejecutar la mutación para eliminar el producto
      await deleteMutation.deleteProducto(idprod, 0);
      print("Producto eliminado: $idprod");

      // Llamar a getProductos para obtener la lista filtrada
      final List<Producto> productosActualizados =
          await getProductos(client, '*'); // '*' para obtener todos los productos

      // Filtrar productos con status = 1
      final List<Producto> productosFiltrados = productosActualizados
          .where((producto) => producto.status == 1)
          .toList();

      print("Productos filtrados: $productosFiltrados");

      // Actualizar el estado para reflejar los cambios
      setState(() {
        searchTerm = '*';
        

        _searchController.clear(); // Limpia el campo de texto
      });

      // Llamar a la función para actualizar el cliente GraphQL
      updateGraphQLClient(context); 

      print("Lista de productos actualizada");
    } catch (error) {
      print("Error al eliminar el producto: $error");
    }
  }





  @override
  Widget build(BuildContext context) {
    final GraphQLClient client = GraphQLProvider.of(context).value;
    final screenWidth = MediaQuery.of(context).size.width;

    double searchFontSize = screenWidth > 600 ? 12 : 10;
    double productCardFontSize = screenWidth > 600 ? 14 : 12;

    return Scaffold(
      body: Container(
        color: const Color(0xFFF2F2F2),
        child: Column(
          children: [
            if (screenWidth <= 600)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  "Productos",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black.withOpacity(0.7),
                  ),
                ),
              ),
            // Barra de búsqueda con Refresh
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Icon(
                    Icons.shopping_cart,
                    size: 30,
                    color: const Color(0xFF031273),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: const Icon(Icons.search, color: Colors.grey),
                        hintText: 'Buscar producto',
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: searchFontSize,
                          fontFamily: 'Grandis Extended',
                        ),
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
                      onChanged: (value) {
                        setState(() {
                          searchTerm = value;
                        });
                      },
                    ),
                  ),
                  // Botón Refresh
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF031273),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.white),
                        onPressed: () {
                          // Establecer el término de búsqueda como '*' para buscar todos los productos
                          setState(() {
                            searchTerm = '*'; // Esto buscará todos los productos
                            

                            _searchController.clear(); // Limpia el campo de texto
                          });

                          // Llamar a la función para actualizar el cliente GraphQL
                          updateGraphQLClient(context); 
                        },
                      ),
                    ),
                  ),

                  

                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF031273),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.add, color: Colors.white),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return Dialog(
                                insetPadding: EdgeInsets.zero,
                                child: Container(
                                  width: screenWidth,
                                  height: MediaQuery.of(context).size.height,
                                  child: AddProductosScreen(),
                                ),
                              );
                            },
                          );
                          setState(() {
                            searchTerm = '*'; // Esto buscará todos los productos
                            

                            _searchController.clear(); // Limpia el campo de texto
                          });

                          // Llamar a la función para actualizar el cliente GraphQL
                          updateGraphQLClient(context); 
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Lista de productos
            Expanded(
              child: FutureBuilder<List<Producto>>(
                future: getProductos(client, searchTerm),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, color: Colors.red, size: 48),
                          const SizedBox(height: 8),
                          Text(
                            'Error al cargar productos',
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.black.withOpacity(0.7)),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${snapshot.error}',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                        child: Text('No se encontraron productos.'));
                  }

                  final List<Producto> productos = snapshot.data!;

                  return ListView.builder(
                    itemCount: productos.length,
                    itemBuilder: (context, index) {
                      final producto = productos[index];
                      return _buildProductCard(
                          producto, context, productCardFontSize);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(
      Producto producto, BuildContext context, double fontSize) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
              color: const Color(0xFF031273).withOpacity(0.3), width: 1),
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          title: Text(
            producto.description,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontFamily: 'Grandis Extended',
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '\$${producto.precio}',
                style: TextStyle(
                  fontSize: fontSize - 2,
                  fontWeight: FontWeight.w400,
                  color: Colors.black.withOpacity(0.6),
                  fontFamily: 'Grandis Extended',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Marca: ${producto.marca.description}',
                style: TextStyle(
                  fontSize: fontSize - 2,
                  color: Colors.black.withOpacity(0.6),
                ),
              ),
              Text(
                'Línea: ${producto.linea.description}',
                style: TextStyle(
                  fontSize: fontSize - 2,
                  color: Colors.black.withOpacity(0.6),
                ),
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildActionButton(
                icon: Icons.edit_rounded,
                color: Colors.blue,
                onPressed: () {
                  print("Editar producto con ID: ${producto.id}");
                  print("Descripción: ${producto.description}");
                  print("Precio: ${producto.precio}");
                  print("Marca: ${producto.marca}");
                  print("Línea: ${producto.linea}");
                  print("MarcaId: ${producto.marca.id}");
                  print("LíneaId: ${producto.linea.id}");
                  print("Clave Unidad: ${producto.claveunidad}");
                  print("Código de Barras: ${producto.codigobarras}");
                  print("Código SAT: ${producto.codigosat}");
                  print("Descuento: ${producto.descuento}");
                  print("Existencias: ${producto.existencias}");
                  print("Modelo: ${producto.modelo}");
                  print("No Identificación: ${producto.noidentificacion}");
                  print("Retención IEPS: ${producto.retencionieps}");
                  print("Retención ISR: ${producto.retencionisr}");
                  print("Retención IVA: ${producto.retencioniva}");
                  print("Stock Máximo: ${producto.stockmax}");
                  print("Stock Mínimo: ${producto.stockmin}");
                  print("Traslado IEPS: ${producto.trasladoieps}");
                  print("Traslado IVA: ${producto.trasladoiva}");
                  print("URL: ${producto.url}");
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddProductosScreen(
                        productoId: producto.id,
                        description: producto.description,
                        precio: producto.precio,
                        marca: producto.marca.description,
                        linea: producto.linea.description,
                        marcaId: producto.marca.id, // Pasar el ID de la marca
                        lineaId: producto.linea.id, // Pasar el ID de la línea
                        claveunidad: producto.claveunidad.id,
                        codigobarras: producto.codigobarras,
                        codigosat: producto.codigosat.id,
                        descuento: producto.descuento,
                        existencias: producto.existencias,
                        modelo: producto.modelo,
                        noidentificacion: producto.noidentificacion,
                        retencionieps: producto.retencionieps,
                        retencionisr: producto.retencionisr,
                        retencioniva: producto.retencioniva,
                        stockmax: producto.stockmax,
                        stockmin: producto.stockmin,
                        trasladoieps: producto.trasladoieps,
                        trasladoiva: producto.trasladoiva,
                        url: producto.url,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(width: 8),
              _buildActionButton(
                icon: Icons.delete_outline_rounded,
                color: Colors.red,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Confirmar eliminación'),
                        content: Text(
                            '¿Estás seguro de que deseas eliminar "${producto.description}"?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancelar'),
                          ),  
                          TextButton(
                            onPressed: () async {
                                try {
                                    // Convertir el ID de String a Int
                                    final int idInt = int.parse(producto.id);
                                    print("Eliminar producto con ID: $idInt");
                                    
                                    // Llamar a la mutación de eliminación con el ID convertido
                                    await _eliminarProducto(idInt);
                                    
                                    Navigator.pop(context); // Cerrar el diálogo después de la eliminación
                                  } catch (e) {
                                    print("Error al eliminar el producto: $e");
                                  }
                                },
                              
                            child: const Text('Eliminar',
                                style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}
