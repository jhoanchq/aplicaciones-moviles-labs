// ============================================================================
// LABORATORIO SEMANA 13 — PANTALLA DE PREFERENCIAS Y ARCHIVOS
// ============================================================================
//
// Esta pantalla demuestra dos almacenamientos locales:
//   1. shared_preferences: nombre de la tienda, moneda y última exportación.
//   2. path_provider + File: exportar el inventario a un archivo JSON.
//
// La lista de productos se recibe desde HomeScreen para poder exportarla.
// ============================================================================

import 'package:flutter/material.dart';

import '../models/producto.dart';
import '../services/file_service.dart';
import '../services/preferences_service.dart';

class PreferencesScreen extends StatefulWidget {
  final ValueNotifier<List<Producto>> productos;

  const PreferencesScreen({
    super.key,
    required this.productos,
  });

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tiendaController = TextEditingController();
  final _monedaController = TextEditingController();

  final _preferences = PreferencesService();
  final _fileService = FileService();

  bool _cargando = true;
  bool _exportando = false;
  String _ultimaExportacion = '';

  @override
  void initState() {
    super.initState();
    _cargarPreferencias();
  }

  @override
  void dispose() {
    _tiendaController.dispose();
    _monedaController.dispose();
    super.dispose();
  }

  /// Lee las preferencias guardadas y llena los campos.
  Future<void> _cargarPreferencias() async {
    final datos = await _preferences.cargar();

    if (!mounted) return;

    _tiendaController.text = datos['tienda'] ?? 'Mi Inventario';
    _monedaController.text = datos['moneda'] ?? 'S/';

    setState(() {
      _ultimaExportacion = datos['ultimaExportacion'] ?? '';
      _cargando = false;
    });
  }

  /// Guarda las preferencias con shared_preferences.
  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    await _preferences.guardar(
      tienda: _tiendaController.text.trim(),
      moneda: _monedaController.text.trim(),
    );

    if (!mounted) return;
    _mostrarMensaje('Preferencias guardadas en el dispositivo.');
  }

  /// Exporta el inventario a un archivo JSON con path_provider.
  Future<void> _exportar() async {
    final productos = widget.productos.value;

    if (productos.isEmpty) {
      _mostrarMensaje('No hay productos para exportar.');
      return;
    }

    setState(() => _exportando = true);

    try {
      final ruta = await _fileService.exportarInventario(productos);
      await _preferences.guardarUltimaExportacion(ruta);

      if (!mounted) return;

      setState(() {
        _ultimaExportacion = ruta;
        _exportando = false;
      });

      _mostrarMensaje('Inventario exportado.');
    } catch (e) {
      if (!mounted) return;
      setState(() => _exportando = false);
      _mostrarMensaje('No se pudo exportar: $e');
    }
  }

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Semana 13 · Preferencias')),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Preferencias y archivos',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Guarda datos simples con shared_preferences y exporta el inventario a un archivo JSON con path_provider.',
                          style: TextStyle(color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _tiendaController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre de la tienda',
                          prefixIcon: Icon(Icons.storefront_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Escribe el nombre de la tienda';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _monedaController,
                        decoration: const InputDecoration(
                          labelText: 'Moneda',
                          prefixIcon: Icon(Icons.payments_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Escribe la moneda';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _guardar,
                          icon: const Icon(Icons.save_outlined),
                          label: const Text('Guardar preferencias'),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _exportando ? null : _exportar,
                          icon: _exportando
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.file_download_outlined),
                          label: Text(
                            _exportando
                                ? 'Exportando...'
                                : 'Exportar inventario a JSON',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_ultimaExportacion.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  Card(
                    color: const Color(0xFFEFF6FF),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Última exportación',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 6),
                          SelectableText(
                            _ultimaExportacion,
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: Color(0xFF1E40AF),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                const Text(
                  'Los datos se guardan en el almacenamiento privado de la app. No se necesitan permisos.',
                  style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
                ),
              ],
            ),
    );
  }
}
