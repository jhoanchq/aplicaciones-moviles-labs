// ============================================================================
// LABORATORIO SEMANA 14 — CONSUMO DE UNA API REST (GET)
// ============================================================================
//
// Flujo:
//   1. FutureBuilder inicia la carga.
//   2. ApiService.obtenerPosts() hace GET.
//   3. Mientras carga, se muestra un indicador.
//   4. Si falla, se muestra el error y un botón de reintento.
//   5. Si funciona, se construye la lista con los datos del servidor.
//
// La pantalla no escribe JSON ni conoce http: delega en ApiService.
// ============================================================================

import 'package:flutter/material.dart';

import '../services/api_service.dart';

class ApiScreen extends StatefulWidget {
  const ApiScreen({super.key});

  @override
  State<ApiScreen> createState() => _ApiScreenState();
}

class _ApiScreenState extends State<ApiScreen> {
  final _api = ApiService();
  late Future<List<PostApi>> _futuro;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  /// Reinicia la solicitud. Se usa al abrir y al reintentar.
  void _cargar() {
    setState(() {
      _futuro = _api.obtenerPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Semana 14 · API REST'),
        actions: [
          IconButton(
            onPressed: _cargar,
            tooltip: 'Recargar',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<List<PostApi>>(
        future: _futuro,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 14),
                  Text('Cargando publicaciones...'),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.cloud_off_outlined,
                      size: 56,
                      color: Color(0xFFDC2626),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No se pudo cargar la API.\n${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: _cargar,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }

          final posts = snapshot.data ?? [];

          return RefreshIndicator(
            onRefresh: () async => _cargar(),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: posts.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final post = posts[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: const Color(0xFFEFF6FF),
                              child: Text(
                                '${post.id}',
                                style: const TextStyle(
                                  color: Color(0xFF2563EB),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                post.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          post.body,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
