
# Lab 15 — Envío de datos a API REST (POST)

**Curso:** Aplicaciones Móviles · 2026-II
**Proyecto:** `lab15_api_post`
**Demo web:** https://jhoanchq.github.io/aplicaciones-moviles-labs/lab15_api_post/

## Objetivo

Completar el laboratorio 14 enviando datos a la API con el método **POST**.
El usuario escribe un título y un contenido; la app los envía en JSON y muestra
la respuesta del servidor.

## Qué aprenderás

- Construir un `POST` con `http.post`.
- Enviar cabeceras `Content-Type: application/json`.
- Serializar un mapa con `jsonEncode`.
- Interpretar el código **201 Created**.
- Deshabilitar el botón mientras se envía y conservar los datos si falla.

## Estructura

```
lib/
├── services/api_service.dart     # GET (lab 14) + POST (lab 15)
└── screens/envio_screen.dart     # Formulario y respuesta
```

## Explicación del código

### Enviar el POST

```dart
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

return PostApi.fromJson(jsonDecode(respuesta.body));
```

- **headers** indica al servidor que el cuerpo es JSON.
- **body** es el texto JSON, no un `Map`.
- **201** significa que el recurso fue creado.

### Formulario

`EnvioScreen` valida con `Form`, muestra un indicador mientras `_enviando` es
`true` y bloquea el botón para evitar envíos duplicados. Si ocurre un error, se
muestra en una tarjeta roja sin borrar lo que el usuario escribió.

### API de prueba

JSONPlaceholder responde como un servidor real, pero **no guarda** los datos de
forma permanente. En un proyecto propio se cambiaría `_base` por la URL del
servidor de la institución.

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

También se entrega una copia en `../dist/lab15_api_post.apk`.

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
