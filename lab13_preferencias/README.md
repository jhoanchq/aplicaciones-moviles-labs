
# Lab 13 — Preferencias y archivos

**Curso:** Aplicaciones Móviles · 2026-II
**Proyecto:** `lab13_preferencias`

## Objetivo

Agregar al inventario dos formas de almacenamiento local:

1. **`shared_preferences`** para datos simples (nombre de la tienda, moneda).
2. **`path_provider` + `File`** para exportar el inventario a un archivo JSON.

## Qué aprenderás

- Guardar y leer pares clave-valor con `SharedPreferences`.
- Usar `getApplicationDocumentsDirectory()` para escribir en el sandbox de la app.
- Convertir objetos a JSON con `jsonEncode`.
- Manejar estados de carga y errores en una pantalla con formulario.

## Estructura

```
lib/
├── services/
│   ├── preferences_service.dart  # Claves, lectura y escritura
│   └── file_service.dart         # Exportación a JSON
└── screens/preferences_screen.dart
```

## Explicación del código

### Preferencias

`PreferencesService` concentra las claves y los valores por defecto. Si el dato
no existe, devuelve un valor inicial en lugar de `null`.

```dart
static const _keyTienda = 'tienda_nombre';

final prefs = await SharedPreferences.getInstance();
return prefs.getString(_keyTienda) ?? 'Mi Inventario';
```

Guardar es asíncrono; se espera la escritura antes de avisar al usuario:

```dart
await prefs.setString(_keyTienda, tienda);
await prefs.setString(_keyMoneda, moneda);
```

### Exportar a JSON

`FileService` obtiene la carpeta privada de documentos, crea el archivo y
escribe la lista convertida a JSON con sangría para que sea legible.

```dart
final carpeta = await getApplicationDocumentsDirectory();
final archivo = File('${carpeta.path}/inventario_export.json');

final datos = productos.map((p) => p.toMap()).toList();
final contenido = const JsonEncoder.withIndent('  ').convert(datos);

await archivo.writeAsString(contenido);
```

### La pantalla

`PreferencesScreen` recibe el `ValueNotifier` del inventario para poder
exportarlo. En `initState` carga las preferencias y llena los campos. Al
exportar guarda la ruta en las preferencias y la muestra con `SelectableText`.

No se piden permisos porque el archivo vive dentro del almacenamiento privado
de la aplicación.

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

También se entrega una copia en `../dist/lab13_preferencias.apk`.

Instalar en un teléfono conectado por USB:

```bash
adb install -r build/app/outputs/flutter-apk/app-release.apk
```
