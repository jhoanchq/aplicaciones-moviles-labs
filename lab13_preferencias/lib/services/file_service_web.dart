// ============================================================================
// LABORATORIO 13 — EXPORTACIÓN EN NAVEGADOR
// ============================================================================
//
// En web no existen dart:io ni path_provider. En lugar de escribir en una
// carpeta del dispositivo, se genera un Blob y se descarga con un enlace.
//
// La clase mantiene el mismo método que la versión IO para que la pantalla
// funcione igual en Android, iOS y navegador.
// ============================================================================

// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:convert';
import 'dart:html' as html;

import '../models/producto.dart';

class FileService {
  /// Genera `inventario_export.json` y lo descarga desde el navegador.
  Future<String> exportarInventario(List<Producto> productos) async {
    final datos = productos.map((producto) => producto.toMap()).toList();
    final contenido = const JsonEncoder.withIndent('  ').convert(datos);

    final bytes = utf8.encode(contenido);
    final blob = html.Blob([bytes], 'application/json');
    final url = html.Url.createObjectUrlFromBlob(blob);

    html.AnchorElement(href: url)
      ..download = 'inventario_export.json'
      ..click();

    html.Url.revokeObjectUrl(url);

    return 'inventario_export.json (descargado en el navegador)';
  }
}
