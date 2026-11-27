
# Lab 14 — Consumo de API REST (GET)

**Curso:** Aplicaciones Móviles · 2026-II
**Proyecto:** `lab14_api_get`
**Demo web:** https://jhoanchq.github.io/aplicaciones-moviles-labs/lab14_api_get/

## Objetivo

Consumir una API pública con el método **GET**, convertir el JSON en objetos
Dart y mostrar los datos en una lista con estados de carga y error.

Se usa `https://jsonplaceholder.typicode.com/posts` como API de prueba.

## Qué aprenderás

- Hacer peticiones HTTP con el paquete `http`.
- Validar el `statusCode` antes de leer el cuerpo.
- Decodificar JSON con `jsonDecode`.
- Convertir mapas JSON a modelos con un constructor `fromJson`.
- Mostrar carga, error y datos con `FutureBuilder`.
- Recargar con `RefreshIndicator` y un botón de reintento.

## Estructura

```
lib/
├── services/api_service.dart     # GET y modelo PostApi
└── screens/api_screen.dart       # Lista, carga y errores
```

## Explicación del código

### Servicio

`ApiService` separa la red de la interfaz. La pantalla no sabe qué es `http`
ni cómo se decodifica el JSON.

```dart
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
```

### Modelo

`PostApi.fromJson` traduce las claves del servidor (`id`, `title`, `body`) a
propiedades tipadas de Dart. Si una clave no coincide, falla la conversión.

### Pantalla

`FutureBuilder` decide qué mostrar según el estado del `Future`:

```dart
if (snapshot.connectionState == ConnectionState.waiting) {
  return const CircularProgressIndicator();
}

if (snapshot.hasError) {
  return BotonDeReintento();
}

final posts = snapshot.data ?? [];
```

`RefreshIndicator` permite deslizar hacia abajo para volver a consultar la API.

**Nota:** la app debe probarse en Android/iOS; no requiere permisos especiales
porque usa HTTPS.

## Ejecutar el proyecto

```bash
flutter pub get
flutter run
```

## Generar el APK

```bash
flutter build apk --release
```

El APK queda en:

```
build/app/outputs/flutter-apk/app-release.apk
```

También se entrega una copia en `../dist/lab14_api_get.apk`.

Instalar en un teléfono conectado por USB:

```bash
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

## Ejecutar en web (demostración)

```bash
flutter run -d chrome
```

En el navegador no existe `sqflite`: la app cambia automáticamente a un
almacenamiento en memoria, muestra un aviso y conserva toda la interfaz CRUD.
En Android/iOS se sigue usando SQLite real. La exportación del laboratorio 13
se descarga como archivo JSON desde el navegador.
