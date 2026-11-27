# Aplicaciones Móviles — Laboratorios 11 a 15

Cinco proyectos **Flutter independientes y acumulativos**. Cada carpeta es una
app completa que se compila y se instala por separado, con su propio APK.

| Carpeta | Laboratorio | Qué agrega |
|---------|-------------|------------|
| [`lab11_inventario`](lab11_inventario/) | 11 | Inventario con CRUD en memoria |
| [`lab12_sqlite`](lab12_sqlite/) | 12 | Persistencia con SQLite |
| [`lab13_preferencias`](lab13_preferencias/) | 13 | Preferencias y exportación a JSON |
| [`lab14_api_get`](lab14_api_get/) | 14 | Consumo de API REST (GET) |
| [`lab15_api_post`](lab15_api_post/) | 15 | Envío de datos a API REST (POST) |

Cada laboratorio parte del anterior: el 12 conserva la interfaz del 11 y cambia
el almacenamiento; el 13 agrega preferencias y archivos; el 14 agrega GET; el 15
agrega POST. **No son pantallas de una sola app**: son cinco proyectos distintos.

## APKs

Los APK compilados están en la carpeta [`dist/`](dist/):

| Laboratorio | APK |
|-------------|-----|
| 11 | `dist/lab11_inventario.apk` |
| 12 | `dist/lab12_sqlite.apk` |
| 13 | `dist/lab13_preferencias.apk` |
| 14 | `dist/lab14_api_get.apk` |
| 15 | `dist/lab15_api_post.apk` |

También se publican como archivos adjuntos en la sección **Releases** del
repositorio.

## Requisitos

- Flutter 3.x
- Android Studio con Android SDK
- Teléfono Android o emulador

## Ejecutar un laboratorio

```bash
cd lab11_inventario
flutter pub get
flutter run
```

Cambia `lab11_inventario` por la carpeta que quieras probar.

## Compilar un APK

```bash
cd lab11_inventario
flutter build apk --release
```

Salida:

```
build/app/outputs/flutter-apk/app-release.apk
```

## Contenido técnico

- **Lab 11:** `ValueNotifier`, `ValueListenableBuilder`, `Navigator`,
  `showModalBottomSheet`, `Form` y validaciones.
- **Lab 12:** `sqflite`, `openDatabase`, `onCreate`, CRUD parametrizado,
  `toMap`/`fromMap` y pruebas con `sqflite_common_ffi`.
- **Lab 13:** `shared_preferences`, `path_provider`, `File`, `jsonEncode` y
  exportación a JSON.
- **Lab 14:** `http.get`, `jsonDecode`, `FutureBuilder`, `RefreshIndicator` y
  manejo de errores.
- **Lab 15:** `http.post`, cabeceras JSON, `jsonEncode`, respuesta `201` y
  estados de envío.

## Nota sobre iOS

Los proyectos incluyen la carpeta `ios/`, pero compilar para iPhone requiere
macOS con Xcode. En Windows solo se puede generar el APK de Android.

## Docente

Jhoan Benito Chite Quispe · Aplicaciones Móviles · 2026-II
