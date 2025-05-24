import 'package:flutter/material.dart';

class CodigoSatScreen extends StatefulWidget {
  const CodigoSatScreen({super.key});

  @override
  _CodigoSatScreenState createState() => _CodigoSatScreenState();
}

class _CodigoSatScreenState extends State<CodigoSatScreen> {
  // Mapa de códigos agrupados por categoría.
  final Map<String, List<Map<String, String>>> groupedSatCodes = {
    "Carnes y Aves": [
      {
        "codigo": "50111500",
        "descripcion": "Carne y aves de corral - Clave a nivel clase para productos cárnicos sin especificar corte. (M.SAT.GOB.MX)"
      },
      {
        "codigo": "50111513",
        "descripcion": "Carne, mínimamente procesada sin aditivos - Para cortes frescos de res en cadena de frío. (M.SAT.GOB.MX)"
      },
      {
        "codigo": "50111514",
        "descripcion": "Cerdo, mínimamente procesado sin aditivos - Para productos de cerdo frescos o refrigerados. (M.SAT.GOB.MX)"
      },
      {
        "codigo": "50111515",
        "descripcion": "Pollo, mínimamente procesado sin aditivos - Clave para productos avícolas refrigerados. (M.SAT.GOB.MX)"
      },
      {
        "codigo": "50111521",
        "descripcion": "Pavo, mínimamente procesado sin aditivos - Clave para pavo fresco o refrigerado."
      },
      {
        "codigo": "50111523",
        "descripcion": "Cordero, mínimamente procesado sin aditivos - Para clasificar cortes de cordero."
      },
      {
        "codigo": "50111517",
        "descripcion": "Ternera, mínimamente procesada sin aditivos - Para productos de ternera en frío."
      },
      {
        "codigo": "50112000",
        "descripcion": "Carnes procesadas y preparadas - Para embutidos, carnes curadas o enlatadas. (VEINTE.IO)"
      },
    ],
    "Panadería": [
      {
        "codigo": "50181900",
        "descripcion": "Pan, galletas y pastelitos dulces - Clave para productos de panadería y repostería."
      },
      {
        "codigo": "50181901",
        "descripcion": "Pan fresco - Para pan elaborado no congelado."
      },
      {
        "codigo": "50181902",
        "descripcion": "Pan congelado - Para productos de panadería que requieren cadena de frío."
      },
    ],
    "Bebidas y Refrigeración": [
      {
        "codigo": "50202301",
        "descripcion": "Agua - Clave para bebidas básicas en presentación líquida."
      },
      {
        "codigo": "50201712",
        "descripcion": "Bebidas de té - Para té preparado o concentrado."
      },
      {
        "codigo": "50202302",
        "descripcion": "Hielo - Elementos esenciales para mantener la cadena de frío."
      },
      {
        "codigo": "50202200",
        "descripcion": "Bebidas alcohólicas - Clave general para productos alcohólicos."
      },
      {
        "codigo": "50201708",
        "descripcion": "Bebida de café - Para facturar café listo para consumir."
      },
      {
        "codigo": "50202307",
        "descripcion": "Bebida de chocolate o malta - Para productos líquidos a base de chocolate o malta."
      },
      {
        "codigo": "50202306",
        "descripcion": "Refrescos - Clave para productos de bebidas gaseosas o refrescantes."
      },
      {
        "codigo": "50201707",
        "descripcion": "Bebida de zumo o concentrado de frutas - Para productos de jugos y concentrados."
      },
    ],
    "Químicos y Farmacéuticos": [
      {
        "codigo": "31201601",
        "descripcion": "Adhesivos químicos - Ejemplo representativo de algunos productos químicos. (LOGSYS.MX)"
      },
      {
        "codigo": "51101500",
        "descripcion": "Medicamentos - Clave a nivel clase para productos farmacéuticos (incluye componentes activos). (LOGSYS.MX)"
      },
    ],
    "Electrónica y Accesorios": [
      {
        "codigo": "43191501",
        "descripcion": "Teléfonos móviles - Clave para dispositivos de comunicación personal."
      },
      {
        "codigo": "43201800",
        "descripcion": "Dispositivos de almacenamiento - Para memorias, discos duros y otros productos electrónicos."
      },
      {
        "codigo": "43191600",
        "descripcion": "Partes o accesorios de dispositivos de comunicación - Para facturar accesorios complementarios a dispositivos móviles."
      },
      {
        "codigo": "43191631",
        "descripcion": "Clavijas de adaptadores o kits para dispositivos - Clave para accesorios de teléfonos o módems."
      },
    ],
    "Papelería y Oficina": [
      {
        "codigo": "44121701",
        "descripcion": "Bolígrafos - Clave para artículos de papelería de uso frecuente."
      },
      {
        "codigo": "44121707",
        "descripcion": "Lápices de colores - Para productos artísticos y escolares."
      },
      {
        "codigo": "14111514",
        "descripcion": "Libretas o cuadernos de papel - Clave para blocs, cuadernos o libretas de uso general."
      },
      {
        "codigo": "44121706",
        "descripcion": "Lápices de madera - Otra opción en el rubro de papelería."
      },
      {
        "codigo": "60121535",
        "descripcion": "Borradores de goma - Clave para artículos de oficina como borradores."
      },
      {
        "codigo": "14111506",
        "descripcion": "Papel para impresión de computadores - Para facturar papel de oficina y uso informático."
      },
      {
        "codigo": "82121700",
        "descripcion": "Fotocopiado - Clave utilizada en servicios de impresión y reproducción documental."
      },
      {
        "codigo": "60121700",
        "descripcion": "Adhesivos educativos - Para productos de papelería y material escolar (alternativa universal)."
      },
    ],
    "Lácteos y Frutos Secos": [
      {
        "codigo": "50101717",
        "descripcion": "Nueces y semillas sin cáscara - Para productos alimenticios como frutos secos."
      },
      {
        "codigo": "50131800",
        "descripcion": "Queso - Para facturar productos lácteos en diversas presentaciones."
      },
    ],
    "Snacks y Postres": [
      {
        "codigo": "50192100",
        "descripcion": "Botanas - Clave para snacks y productos de consumo rápido."
      },
      {
        "codigo": "50192303",
        "descripcion": "Helado de sabor o postre congelado - Para productos congelados que requieren control de temperatura. (M.SAT.GOB.MX)"
      },
    ],
    "Salud Animal y Alimentación": [
      {
        "codigo": "70122000",
        "descripcion": "Salud animal - Para productos veterinarios y de cuidado animal."
      },
      {
        "codigo": "50121500",
        "descripcion": "Pienso para ganado - Clave para insumos en alimentación animal."
      },
    ],
    "Animales Vivos": [
      {
        "codigo": "10101601",
        "descripcion": "Pollos vivos - Para el transporte de aves vivas (en envíos especializados)."
      },
      {
        "codigo": "10101602",
        "descripcion": "Patos vivos - Clave para aves acuáticas en vivo."
      },
      {
        "codigo": "10101603",
        "descripcion": "Pavos vivos - Para el envío de pavos vivos."
      },
      {
        "codigo": "10101516",
        "descripcion": "Ganado vacuno - Clave para animales de cría en envíos especializados."
      },
      {
        "codigo": "10101700",
        "descripcion": "Peces vivos - Para el transporte de especies acuáticas vivas."
      },
      {
        "codigo": "10101702",
        "descripcion": "Trucha viva - Clave específica para truchas vivas."
      },
      {
        "codigo": "10101703",
        "descripcion": "Tilapia viva - Para el envío de tilapias en vivo."
      },
      {
        "codigo": "10101801",
        "descripcion": "Camarón vivo - Clave para el transporte de camarones vivos."
      },
    ],
    "Empaque y Embalaje": [
      {
        "codigo": "78121500",
        "descripcion": "Empaque - Clave para materiales de empaque o embalaje."
      },
      {
        "codigo": "78121501",
        "descripcion": "Contenedorización de mercancías - Para servicios o productos relacionados con contenedores."
      },
      {
        "codigo": "78121502",
        "descripcion": "Servicios de embalaje - Clave para la facturación de servicios de embalaje."
      },
    ],
    "Salsas y Condimentos": [
      {
        "codigo": "50171800",
        "descripcion": "Salsas y condimentos y productos para untar - Para productos alimenticios derivados."
      },
      {
        "codigo": "50171833",
        "descripcion": "Cremas de untar saladas o patés - Clave específica para ciertos productos para untar."
      },
      {
        "codigo": "50171832",
        "descripcion": "Salsas para ensaladas o dips - Clave para condimentos más específicos."
      },
    ],
    "Calzado y Ferretería": [
      {
        "codigo": "53111500",
        "descripcion": "Botas - Clave para el envío de calzado, aplicable a diversas categorías."
      },
      {
        "codigo": "27112000",
        "descripcion": "Herramientas manuales de jardinería - Para utensilios de ferretería y jardinería."
      },
      {
        "codigo": "31161500",
        "descripcion": "Tornillos - Para productos de ferretería o construcción."
      },
      {
        "codigo": "31162000",
        "descripcion": "Clavos - Clave para envíos de productos de ferretería."
      },
    ],
    "Juguetes": [
      {
        "codigo": "60141014",
        "descripcion": "Yoyós - Para clasificar juguetes u otros artículos lúdicos."
      },
    ],
    "Servicios": [
      {
        "codigo": "80151504",
        "descripcion": "Servicios de promoción comercial - Clave de servicios aplicable a actividades publicitarias y de marketing."
      },
      {
        "codigo": "80151600",
        "descripcion": "Servicios de comercio internacional - Clave para la facturación de servicios relacionados con operaciones de importación/exportación."
      },
    ],
  };

  // Mapa para los resultados filtrados.
  Map<String, List<Map<String, String>>> filteredGroupedSatCodes = {};

  @override
  void initState() {
    super.initState();
    filteredGroupedSatCodes = Map.from(groupedSatCodes);
  }

  // Función de filtrado que recorre cada grupo y conserva solo los ítems que coincidan con el query.
  void _filterSatCodes(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredGroupedSatCodes = Map.from(groupedSatCodes);
      } else {
        filteredGroupedSatCodes = {};
        groupedSatCodes.forEach((group, codes) {
          var filteredCodes = codes.where((code) =>
              code["codigo"]!.contains(query) ||
              code["descripcion"]!
                  .toLowerCase()
                  .contains(query.toLowerCase())).toList();
          if (filteredCodes.isNotEmpty) {
            filteredGroupedSatCodes[group] = filteredCodes;
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white.withOpacity(0.2), // Efecto Glassmorphism
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
            const Text(
              "Buscar Código SAT",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              onChanged: _filterSatCodes,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: "Buscar por código o descripción...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: filteredGroupedSatCodes.entries.map((entry) {
                  return ExpansionTile(
                    title: Text(
                      entry.key,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    children: entry.value.map((code) {
                      return ListTile(
                        title: Text(code["codigo"]!),
                        subtitle: Text(code["descripcion"]!),
                        onTap: () {
                          Navigator.pop(context, code["codigo"]);
                        },
                      );
                    }).toList(),
                  );
                }).toList(),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cerrar"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Método para mostrar la pantalla como diálogo y esperar el resultado seleccionado.
Future<String?> showCodigoSatDialog(BuildContext context) async {
  return await showDialog<String>(
    context: context,
    builder: (context) => const CodigoSatScreen(),
  );
}
