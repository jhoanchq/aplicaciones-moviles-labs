// ============================================================================
// LABORATORIOS SEMANA 14 Y 15 — API REST CON http
// ============================================================================
//
// Semana 14: GET para leer datos de una API.
// Semana 15: POST para enviar datos a una API.
//
// Usamos JSONPlaceholder porque es una API pública de prueba:
// - GET  /posts  -> lista de publicaciones.
// - POST /posts  -> crea una publicación y responde 201.
//
// En una app real, la URL y los datos serían de tu propio servidor.
// ============================================================================

import 'dart:convert';

import 'package:http/http.dart' as http;

/// Modelo que representa una publicación de la API.
class PostApi {
  final int id;
  final String title;
  final String body;

  const PostApi({
    required this.id,
    required this.title,
    required this.body,
  });

  /// Convierte el JSON del servidor en un objeto Dart.
  ///
  /// Las claves del JSON deben coincidir con las que usa el servidor.
  factory PostApi.fromJson(Map<String, dynamic> json) {
    return PostApi(
      id: json['id'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
    );
  }
}

class ApiService {
  static const _base = 'https://jsonplaceholder.typicode.com';
  static const _timeout = Duration(seconds: 12);

  /// GET: obtiene la lista de publicaciones.
  ///
  /// Revisa el statusCode antes de convertir el body.
  /// Si la API falla, lanza una excepción para que la pantalla la muestre.
  Future<List<PostApi>> obtenerPosts() async {
    final uri = Uri.parse('$_base/posts');

    final respuesta = await http.get(uri).timeout(_timeout);

    if (respuesta.statusCode != 200) {
      throw Exception('La API respondió ${respuesta.statusCode}');
    }

    final lista = jsonDecode(respuesta.body) as List<dynamic>;

    return lista
        .map((item) => PostApi.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// POST: envía una publicación nueva al servidor.
  ///
  /// - `headers` indica que el body es JSON.
  /// - `body` es el objeto convertido a texto con jsonEncode.
  /// - Un 201 significa "recurso creado".
  Future<PostApi> crearPost({
    required String title,
    required String body,
  }) async {
    final uri = Uri.parse('$_base/posts');

    final respuesta = await http
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'title': title,
            'body': body,
            'userId': 1,
          }),
        )
        .timeout(_timeout);

    if (respuesta.statusCode != 201) {
      throw Exception('No se pudo crear: ${respuesta.statusCode}');
    }

    return PostApi.fromJson(
      jsonDecode(respuesta.body) as Map<String, dynamic>,
    );
  }
}
