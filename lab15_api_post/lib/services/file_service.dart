// ============================================================================
// LABORATORIO SEMANA 13 — ARCHIVOS CON path_provider
// ============================================================================
//
// path_provider obtiene la carpeta de documentos de la app.
// File permite escribir y leer el archivo.
//
// En este laboratorio exportamos el inventario a un archivo JSON.
// No se necesitan permisos: el archivo vive en el sandbox de la app.
// ============================================================================

import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/producto.dart';

class FileService {
  /// Exporta la lista de productos a `inventario_export.json`.
  ///
  /// Devuelve la ruta completa del archivo para mostrarla en pantalla.
  Future<String> exportarInventario(List<Producto> productos) async {
    // getApplicationDocumentsDirectory() devuelve una carpeta privada
    // de la app en Android/iOS.
    final carpeta = await getApplicationDocumentsDirectory();

    // File representa el archivo físico dentro de esa carpeta.
    final archivo = File('${carpeta.path}/inventario_export.json');

    // Convertimos cada Producto a Map y luego a JSON con sangría.
    final datos = productos.map((producto) => producto.toMap()).toList();
    final contenido = const JsonEncoder.withIndent('  ').convert(datos);

    // writeAsString reemplaza el contenido anterior del archivo.
    await archivo.writeAsString(contenido);

    return archivo.path;
  }
}
