// ============================================================================
// LABORATORIO SEMANA 13 — PREFERENCIAS CON shared_preferences
// ============================================================================
//
// shared_preferences guarda datos simples (clave-valor) en el dispositivo:
// nombre de la tienda, moneda, última exportación, etc.
//
// Estos datos sobreviven al cierre de la app y se leen al iniciar.
// No se usan para listas grandes ni para datos sensibles.
// ============================================================================

import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  // Claves cortas y consistentes. Cambiarlas cambia el dato que se lee.
  static const _keyTienda = 'tienda_nombre';
  static const _keyMoneda = 'moneda';
  static const _keyUltimaExportacion = 'ultima_exportacion';

  /// Lee las preferencias. Si no existen, devuelve valores por defecto.
  Future<Map<String, String>> cargar() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      'tienda': prefs.getString(_keyTienda) ?? 'Mi Inventario',
      'moneda': prefs.getString(_keyMoneda) ?? 'S/',
      'ultimaExportacion': prefs.getString(_keyUltimaExportacion) ?? '',
    };
  }

  /// Guarda el nombre de la tienda y la moneda.
  ///
  /// setString es asíncrono: usa await para confirmar que se escribió.
  Future<void> guardar({
    required String tienda,
    required String moneda,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyTienda, tienda);
    await prefs.setString(_keyMoneda, moneda);
  }

  /// Guarda la ruta del último archivo exportado.
  ///
  /// Es útil para mostrar al usuario dónde quedó su respaldo.
  Future<void> guardarUltimaExportacion(String ruta) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUltimaExportacion, ruta);
  }
}
