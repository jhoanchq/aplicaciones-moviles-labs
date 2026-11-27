// ============================================================================
// LABORATORIO SEMANA 15 — ENVÍO DE DATOS A UNA API REST (POST)
// ============================================================================
//
// Flujo:
//   1. El usuario completa título y contenido.
//   2. Se valida el formulario.
//   3. ApiService.crearPost() envía un POST con body JSON.
//   4. Si el servidor responde 201, se muestra el recurso creado.
//   5. Si falla, se muestra el error sin perder los datos escritos.
//
// La pantalla no construye el JSON: eso ocurre en ApiService.
// ============================================================================

import 'package:flutter/material.dart';

import '../services/api_service.dart';

class EnvioScreen extends StatefulWidget {
  const EnvioScreen({super.key});

  @override
  State<EnvioScreen> createState() => _EnvioScreenState();
}

class _EnvioScreenState extends State<EnvioScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _contenidoController = TextEditingController();

  final _api = ApiService();

  bool _enviando = false;
  PostApi? _creado;
  String? _error;

  @override
  void dispose() {
    _tituloController.dispose();
    _contenidoController.dispose();
    super.dispose();
  }

  /// Envía el formulario por POST.
  Future<void> _enviar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _enviando = true;
      _creado = null;
      _error = null;
    });

    try {
      final post = await _api.crearPost(
        title: _tituloController.text.trim(),
        body: _contenidoController.text.trim(),
      );

      if (!mounted) return;
      setState(() {
        _creado = post;
        _enviando = false;
      });

      _mostrarMensaje('Servidor respondió 201: recurso creado.');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _enviando = false;
      });
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
      appBar: AppBar(title: const Text('Semana 15 · Enviar datos')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Card(
            child: Padding(
              padding: EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'POST a una API REST',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Completa el formulario. La app enviará un JSON y mostrará la respuesta del servidor.',
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
                  controller: _tituloController,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Título',
                    prefixIcon: Icon(Icons.title_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El título es obligatorio';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _contenidoController,
                  minLines: 3,
                  maxLines: 6,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Contenido',
                    alignLabelWithHint: true,
                    prefixIcon: Icon(Icons.notes_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El contenido es obligatorio';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _enviando ? null : _enviar,
                    icon: _enviando
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send_outlined),
                    label: Text(_enviando ? 'Enviando...' : 'Enviar POST'),
                  ),
                ),
              ],
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Card(
              color: const Color(0xFFFDECEC),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'No se pudo enviar:\n$_error',
                  style: const TextStyle(color: Color(0xFF991B1B)),
                ),
              ),
            ),
          ],
          if (_creado != null) ...[
            const SizedBox(height: 16),
            Card(
              color: const Color(0xFFE8F7EF),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '201 Created',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF15803D),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text('ID: ${_creado!.id}'),
                    const SizedBox(height: 4),
                    Text(
                      _creado!.title,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _creado!.body,
                      style: const TextStyle(color: Color(0xFF475569)),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 18),
          const Text(
            'La API de prueba es JSONPlaceholder: no guarda los datos de forma permanente, pero responde como un servidor real.',
            style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }
}
