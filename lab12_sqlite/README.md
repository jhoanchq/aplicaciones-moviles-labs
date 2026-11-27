
# Lab 12 — Persistencia con SQLite

**Curso:** Aplicaciones Móviles · 2026-II
**Proyecto:** `lab12_sqlite`
**Demo web:** https://jhoanchq.github.io/aplicaciones-moviles-labs/lab12_sqlite/

## Objetivo

Partir del inventario del Laboratorio 11 y reemplazar la lista en memoria por
una base de datos **SQLite** local, de modo que los productos sobrevivan al
cierre de la app.

## Qué aprenderás

- Abrir y crear una base de datos con `sqflite`.
- Definir una tabla con `CREATE TABLE`.
- Implementar CRUD con `insert`, `query`, `update` y `delete`.
- Usar consultas parametrizadas (`where: 'id = ?'`) para evitar inyección SQL.
- Convertir filas de SQLite a objetos Dart con `fromMap`.
- Probar SQLite real en la VM con `sqflite_common_ffi`.

## Estructura

```
lib/
├── main.dart                     # Carga inicial desde SQLite
├── models/producto.dart          # toMap / fromMap
├── database/database-helper.dart # Única clase que conoce SQLite
├── components/                   # Tarjetas, formulario y estado vacío
└── screens/
    ├── home-screen.dart          # Indicadores reales
    └── productos-screen.dart     # CRUD contra la base de datos
test/
└── widget_test.dart              # CRUD completo con SQLite en la VM
```

## Explicación del código

### Abrir la base de datos una sola vez

`DatabaseHelper` es un **Singleton**: siempre devuelve la misma instancia y
reutiliza la conexión abierta.

```dart
Future<Database> get database async {
  if (_baseDatos != null) return _baseDatos!;
  _baseDatos = await _inicializarBaseDatos();
  return _baseDatos!;
}
```

### Crear la tabla

`onCreate` se ejecuta una única vez, cuando el archivo `inventario.db` todavía
no existe.

```dart
await db.execute('''
  CREATE TABLE productos (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nombre TEXT NOT NULL,
    precio REAL NOT NULL,
    stock INTEGER NOT NULL
  )
''');
```

### CRUD seguro

Insertar devuelve el id generado. El `id` se quita del mapa porque
`AUTOINCREMENT` lo crea solo:

```dart
final datos = producto.toMap()..remove('id');
return db.insert('productos', datos);
```

Actualizar y eliminar usan parámetros, nunca concatenación de texto:

```dart
return db.update(
  'productos',
  datos,
  where: 'id = ?',
  whereArgs: [producto.id],
);

return db.delete('productos', where: 'id = ?', whereArgs: [id]);
```

### La base de datos es la fuente de verdad

Después de cada operación, `ProductosScreen` vuelve a consultar la tabla y
actualiza el notifier. Así la lista siempre refleja lo que quedó guardado.

```dart
await db.insertarProducto(resultado);
await _recargarProductos();
```

### Prueba automatizada

`test/widget_test.dart` inicializa SQLite para la máquina con
`sqflite_common_ffi`, borra la base temporal y prueba crear, editar y eliminar
desde la interfaz.

## Ejecutar las pruebas

```bash
flutter test
```

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

También se entrega una copia en `../dist/lab12_sqlite.apk`.

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
