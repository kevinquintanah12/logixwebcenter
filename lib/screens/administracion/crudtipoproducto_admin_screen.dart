import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

int parseInt(dynamic v, {int fallback = 0}) {
  try {
    if (v is int) return v;
    if (v is String) return int.tryParse(v) ?? fallback;
  } catch (_) {}
  return fallback;
}

double parseDouble(dynamic v, {double fallback = 0.0}) {
  try {
    if (v is double) return v;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? fallback;
  } catch (_) {}
  return fallback;
}

class CrudTipoProductosAdmin extends StatefulWidget {
  @override
  _CrudTipoProductosAdminState createState() => _CrudTipoProductosAdminState();
}

class _CrudTipoProductosAdminState extends State<CrudTipoProductosAdmin> {
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';

  // — Queries y Mutaciones —
  static const String _queryList = r'''
    query ObtenerTipoProductos {
      tipoProductos {
        id
        nombre
        descripcion
        precioBase
        temperatura { id rangoMinimo rangoMaximo tarifaExtra }
        humedad     { id rangoMinimo rangoMaximo tarifaExtra }
      }
    }
  ''';

  static const String _mCreateProd = r'''
    mutation CrearTipoProducto($nombre:String!,$descripcion:String!,$precioBase:Float!){
      crearTipoProducto(nombre:$nombre,descripcion:$descripcion,precioBase:$precioBase){
        tipoProducto{ id }
      }
    }
  ''';

  static const String _mEditProd = r'''
    mutation EditarTipoProducto($id:Int!,$nombre:String!,$descripcion:String!,$precioBase:Float!){
      editarTipoProducto(id:$id,nombre:$nombre,descripcion:$descripcion,precioBase:$precioBase){
        tipoProducto{ id }
      }
    }
  ''';

  static const String _mDeleteProd = r'''
    mutation EliminarTipoProducto($id:Int!){
      eliminarTipoProducto(id:$id){ ok }
    }
  ''';

  static const String _mCreateTemp = r'''
    mutation CrearTemperatura($tipoProductoId:Int!,$rangoMinimo:Int!,$rangoMaximo:Int!,$tarifaExtra:Float){
      crearTemperatura(tipoProductoId:$tipoProductoId,rangoMinimo:$rangoMinimo,rangoMaximo:$rangoMaximo,tarifaExtra:$tarifaExtra){
        temperatura{id rangoMinimo rangoMaximo tarifaExtra}
      }
    }
  ''';

  static const String _mEditTemp = r'''
    mutation EditarTemperatura($id:Int!,$rangoMinimo:Int,$rangoMaximo:Int,$tarifaExtra:Float){
      editarTemperatura(id:$id,rangoMinimo:$rangoMinimo,rangoMaximo:$rangoMaximo,tarifaExtra:$tarifaExtra){
        temperatura{id rangoMinimo rangoMaximo tarifaExtra}
      }
    }
  ''';

  static const String _mCreateHum = r'''
    mutation CrearHumedad($tipoProductoId:Int!,$rangoMinimo:Int!,$rangoMaximo:Int!,$tarifaExtra:Float){
      crearHumedad(tipoProductoId:$tipoProductoId,rangoMinimo:$rangoMinimo,rangoMaximo:$rangoMaximo,tarifaExtra:$tarifaExtra){
        humedad{id rangoMinimo rangoMaximo tarifaExtra}
      }
    }
  ''';

  static const String _mEditHum = r'''
    mutation EditarHumedad($id:Int!,$rangoMinimo:Int,$rangoMaximo:Int,$tarifaExtra:Float){
      editarHumedad(id:$id,rangoMinimo:$rangoMinimo,rangoMaximo:$rangoMaximo,tarifaExtra:$tarifaExtra){
        humedad{id rangoMinimo rangoMaximo tarifaExtra}
      }
    }
  ''';

  void _alert(BuildContext c, String title, String msg) {
    showCupertinoDialog(
      context: c,
      builder: (_) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(msg),
        actions: [
          CupertinoDialogAction(child: const Text('OK'), onPressed: () => Navigator.pop(c)),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext ctx, VoidCallback? refetch, List existentes) {
    final nombreCtrl = TextEditingController();
    final descCtrl   = TextEditingController();
    final precioCtrl = TextEditingController();
    final txtFmt     = FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z0-9 ]"));
    final decFmt     = FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'));

    showCupertinoDialog(
      context: ctx,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Agregar Tipo de Producto'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          CupertinoTextField(controller: nombreCtrl, placeholder: 'Nombre', inputFormatters: [txtFmt]),
          const SizedBox(height: 8),
          CupertinoTextField(controller: descCtrl, placeholder: 'Descripción', inputFormatters: [txtFmt]),
          const SizedBox(height: 8),
          CupertinoTextField(
            controller: precioCtrl,
            placeholder: 'Precio Base',
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [decFmt],
          ),
        ]),
        actions: [
          CupertinoDialogAction(child: const Text('Cancelar'), onPressed: () => Navigator.pop(ctx)),
          Mutation(
            options: MutationOptions(
              document: gql(_mCreateProd),
              onCompleted: (_) {
                refetch?.call();
                Navigator.pop(ctx);
                ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text("✅ Producto creado")));
              },
            ),
            builder: (runAdd, _) => CupertinoDialogAction(
              child: const Icon(CupertinoIcons.check_mark_circled),
              onPressed: () {
                final n = nombreCtrl.text.trim();
                final d = descCtrl.text.trim();
                final p = parseDouble(precioCtrl.text, fallback: -1);
                if (n.isEmpty || d.isEmpty || p < 0) {
                  ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text("❗ Completa todos los campos correctamente")));
                  return;
                }
                if (existentes.any((x) => (x['nombre'] as String).toLowerCase() == n.toLowerCase())) {
                  ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text("⚠️ Ya existe este producto")));
                  return;
                }
                runAdd({'nombre': n, 'descripcion': d, 'precioBase': p});
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext ctx, Map prod, VoidCallback? refetch) {
    final id         = parseInt(prod['id']);
    final nombreCtrl = TextEditingController(text: prod['nombre']);
    final descCtrl   = TextEditingController(text: prod['descripcion']);
    final precioCtrl = TextEditingController(text: prod['precioBase']?.toString() ?? '');
    final txtFmt     = FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z0-9 ]"));
    final decFmt     = FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'));

    showCupertinoDialog(
      context: ctx,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Editar Producto'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          CupertinoTextField(controller: nombreCtrl, placeholder: 'Nombre', inputFormatters: [txtFmt]),
          const SizedBox(height: 8),
          CupertinoTextField(controller: descCtrl, placeholder: 'Descripción', inputFormatters: [txtFmt]),
          const SizedBox(height: 8),
          CupertinoTextField(
            controller: precioCtrl,
            placeholder: 'Precio Base',
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [decFmt],
          ),
        ]),
        actions: [
          CupertinoDialogAction(child: const Text('Cancelar'), onPressed: () => Navigator.pop(ctx)),
          Mutation(
            options: MutationOptions(
              document: gql(_mEditProd),
              onCompleted: (_) {
                refetch?.call();
                Navigator.pop(ctx);
                ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text("✏️ Producto actualizado")));
              },
            ),
            builder: (runEdit, _) => CupertinoDialogAction(
              child: const Icon(CupertinoIcons.check_mark_circled),
              onPressed: () {
                final n = nombreCtrl.text.trim();
                final d = descCtrl.text.trim();
                final p = parseDouble(precioCtrl.text, fallback: -1);
                if (n.isEmpty || d.isEmpty || p < 0) {
                  ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text("❗ Completa todos los campos correctamente")));
                  return;
                }
                runEdit({'id': id, 'nombre': n, 'descripcion': d, 'precioBase': p});
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext ctx, int id, VoidCallback? refetch) {
    showCupertinoDialog(
      context: ctx,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Eliminar Producto'),
        content: const Text('¿Seguro que deseas eliminar este producto?'),
        actions: [
          CupertinoDialogAction(child: const Text('Cancelar'), onPressed: () => Navigator.pop(ctx)),
          Mutation(
            options: MutationOptions(
              document: gql(_mDeleteProd),
              onCompleted: (_) {
                refetch?.call();
                Navigator.pop(ctx);
                ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text("🗑️ Producto eliminado")));
              },
            ),
            builder: (runDel, _) => CupertinoDialogAction(
              child: const Icon(CupertinoIcons.delete),
              onPressed: () => runDel({'id': id}),
            ),
          ),
        ],
      ),
    );
  }

  void _showTempHumDialog(BuildContext ctx, Map prod, VoidCallback? refetch) {
    final id       = parseInt(prod['id']);
    final hasTemp  = prod['temperatura'] != null;
    final hasHum   = prod['humedad'] != null;
    final tMinCtrl = TextEditingController(text: prod['temperatura']?['rangoMinimo']?.toString());
    final tMaxCtrl = TextEditingController(text: prod['temperatura']?['rangoMaximo']?.toString());
    final tTarCtrl = TextEditingController(text: prod['temperatura']?['tarifaExtra']?.toString());
    final hMinCtrl = TextEditingController(text: prod['humedad']?['rangoMinimo']?.toString());
    final hMaxCtrl = TextEditingController(text: prod['humedad']?['rangoMaximo']?.toString());
    final hTarCtrl = TextEditingController(text: prod['humedad']?['tarifaExtra']?.toString());
    final intFmt   = FilteringTextInputFormatter.digitsOnly;
    final decFmt   = FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'));

    showCupertinoDialog(
      context: ctx,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Temperatura & Humedad'),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('Temperatura', style: TextStyle(fontWeight: FontWeight.bold)),
            CupertinoTextField(controller: tMinCtrl, placeholder: 'Mínimo', keyboardType: TextInputType.number, inputFormatters: [intFmt]),
            const SizedBox(height: 8),
            CupertinoTextField(controller: tMaxCtrl, placeholder: 'Máximo', keyboardType: TextInputType.number, inputFormatters: [intFmt]),
            const SizedBox(height: 8),
            CupertinoTextField(controller: tTarCtrl, placeholder: 'Tarifa Extra', keyboardType: TextInputType.numberWithOptions(decimal: true), inputFormatters: [decFmt]),
            const SizedBox(height: 16),
            const Text('Humedad', style: TextStyle(fontWeight: FontWeight.bold)),
            CupertinoTextField(controller: hMinCtrl, placeholder: 'Mínimo', keyboardType: TextInputType.number, inputFormatters: [intFmt]),
            const SizedBox(height: 8),
            CupertinoTextField(controller: hMaxCtrl, placeholder: 'Máximo', keyboardType: TextInputType.number, inputFormatters: [intFmt]),
            const SizedBox(height: 8),
            CupertinoTextField(controller: hTarCtrl, placeholder: 'Tarifa Extra', keyboardType: TextInputType.numberWithOptions(decimal: true), inputFormatters: [decFmt]),
          ]),
        ),
        actions: [
          CupertinoDialogAction(child: const Text('Cancelar'), onPressed: () => Navigator.pop(ctx)),
          Mutation(
            options: MutationOptions(
              document: gql(hasTemp ? _mEditTemp : _mCreateTemp),
              onCompleted: (_) => refetch?.call(),
            ),
            builder: (runTemp, _) => Mutation(
              options: MutationOptions(
                document: gql(hasHum ? _mEditHum : _mCreateHum),
                onCompleted: (_) {
                  Navigator.pop(ctx);
                  refetch?.call();
                  _alert(ctx, 'Listo', 'Temperatura y humedad configuradas.');
                },
              ),
              builder: (runHum, _) => CupertinoDialogAction(
                child: const Text('Guardar'),
                onPressed: () {
                  final minT = parseInt(tMinCtrl.text);
                  final maxT = parseInt(tMaxCtrl.text);
                  final valT = parseDouble(tTarCtrl.text);
                  final minH = parseInt(hMinCtrl.text);
                  final maxH = parseInt(hMaxCtrl.text);
                  final valH = parseDouble(hTarCtrl.text);

                  if (minT > maxT) { _alert(ctx, 'Error', 'Temperatura mínima no puede ser mayor que la máxima.'); return; }
                  if (minH > maxH) { _alert(ctx, 'Error', 'Humedad mínima no puede ser mayor que la máxima.'); return; }
                  if (valT < 0 || valH < 0) { _alert(ctx, 'Error', 'La tarifa extra no puede ser negativa.'); return; }

                  runTemp({
                    if (hasTemp) 'id': prod['temperatura']['id'],
                    if (!hasTemp) 'tipoProductoId': id,
                    'rangoMinimo': minT,
                    'rangoMaximo': maxT,
                    'tarifaExtra': valT,
                  });
                  runHum({
                    if (hasHum) 'id': prod['humedad']['id'],
                    if (!hasHum) 'tipoProductoId': id,
                    'rangoMinimo': minH,
                    'rangoMaximo': maxH,
                    'tarifaExtra': valH,
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Tipos de Productos'),
        trailing: Query(
          options: QueryOptions(document: gql(_queryList)),
          builder: (resAdd, { refetch, fetchMore }) {
            if (resAdd.isLoading) return const SizedBox();
            final lista = resAdd.data!['tipoProductos'] as List;
            return GestureDetector(
              child: const Icon(CupertinoIcons.add),
              onTap: () => _showAddDialog(context, refetch, lista),
            );
          },
        ),
      ),
      child: SafeArea(
        child: Query(
          options: QueryOptions(document: gql(_queryList)),
          builder: (res, {refetch, fetchMore}) {
            if (res.isLoading) return const Center(child: CupertinoActivityIndicator());
            final productos = res.data!['tipoProductos'] as List;
            final filtered = searchQuery.isEmpty
                ? productos
                : productos.where((p) => (p['nombre'] as String).toLowerCase().contains(searchQuery.toLowerCase())).toList();

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: CupertinoTextField(
                    controller: _searchController,
                    placeholder: 'Buscar...',
                    onChanged: (v) => setState(() => searchQuery = v),
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: MediaQuery.of(context).size.width > 800 ? 3 : 2,
                      crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 1.4,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (ctx, i) {
                      final p      = filtered[i] as Map<String, dynamic>;
                      final hasTemp = p['temperatura'] != null;
                      final hasHum  = p['humedad'] != null;

                      return Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p['nombre'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text('Precio: \$${parseDouble(p['precioBase']).toStringAsFixed(2)}'),
                              const SizedBox(height: 4),
                              if (!hasTemp || !hasHum)
                                Text('⚠️ T&H pendiente', style: TextStyle(color: Colors.red, fontSize: 12)),
                              const Spacer(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.settings, color: Colors.blue),
                                    onPressed: () => _showTempHumDialog(context, p, refetch),
                                    tooltip: 'Configurar T&H',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.orange),
                                    onPressed: () => _showEditDialog(context, p, refetch),
                                    tooltip: 'Editar',
                                  ),
                                  Mutation(
                                    options: MutationOptions(
                                      document: gql(_mDeleteProd),
                                      onCompleted: (_) => refetch?.call(),
                                    ),
                                    builder: (runDel, _) => IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _showDeleteDialog(context, parseInt(p['id']), refetch),
                                      tooltip: 'Eliminar',
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
