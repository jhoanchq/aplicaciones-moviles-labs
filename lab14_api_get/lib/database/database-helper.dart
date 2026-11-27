// ignore_for_file: file_names
// ============================================================================
// FASE 2: ACCESO A SQLITE
// ============================================================================
//
// Esta clase es la única que conoce SQLite. Las pantallas y los componentes
// no escriben SQL: solo llaman a los métodos públicos de [DatabaseHelper].
//
// Responsabilidades:
//   1. Abrir (o crear) el archivo `inventario.db`.
//   2. Crear la tabla `productos` la primera vez.
//   3. Ejecutar las operaciones CRUD con consultas parametrizadas.
//
// Se usa el patrón Singleton para reutilizar una sola conexión durante toda
// la vida de la aplicación y evitar abrir la base de datos varias veces.
// ============================================================================

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/producto.dart';

class DatabaseHelper {
  // --------------------------------------------------------------------------
  // SINGLETON
  // --------------------------------------------------------------------------
  // `_instancia` es el único objeto DatabaseHelper que existirá.
  // El constructor de fábrica siempre devuelve esa misma instancia.
  static final DatabaseHelper _instancia = DatabaseHelper._interno();

  factory DatabaseHelper() => _instancia;

  DatabaseHelper._interno();

  // Aquí se guarda la conexión abierta. Es `static` porque pertenece a la
  // clase, no a un objeto concreto.
  static Database? _baseDatos;

  /// Devuelve la conexión abierta. Si todavía no existe, la inicializa.
  ///
  /// El patrón `if (_baseDatos != null)` evita abrir el archivo en cada
  /// llamada: la primera vez se crea la conexión y luego se reutiliza.
  Future<Database> get database async {
    if (_baseDatos != null) {
      return _baseDatos!;
    }

    _baseDatos = await _inicializarBaseDatos();
    return _baseDatos!;
  }

  // --------------------------------------------------------------------------
  // APERTURA Y CREACIÓN DE LA BASE DE DATOS
  // --------------------------------------------------------------------------

  /// Abre el archivo `inventario.db` y, si no existe, lo crea.

  Future<Database> _inicializarBaseDatos() async {
    // getDatabasesPath() devuelve la carpeta que el sistema asigna a la app
    // para guardar sus bases de datos.
    //
    // join() (del paquete path) une la carpeta con el nombre del archivo
    // usando el separador correcto de cada sistema operativo.
    final ruta = join(await getDatabasesPath(), 'inventario.db');

    // openDatabase abre el archivo. Si es la primera vez que se ejecuta la
    // app, el archivo no existe y SQLite llama automáticamente a `onCreate`.
    //
    // `version` permite controlar cambios futuros del esquema. En esta
    // práctica trabajamos con la versión 1.
    return openDatabase(ruta, version: 1, onCreate: _onCreate);
  }

  /// Se ejecuta UNA SOLA VEZ, cuando la base de datos se crea por primera vez.
  ///
  /// Aquí se define el esquema inicial: la tabla `productos` y sus columnas.
  Future<void> _onCreate(Database db, int version) async {
    // CREATE TABLE define la estructura:
    //   - id: entero, clave primaria, se genera solo (AUTOINCREMENT).
    //   - nombre: texto obligatorio (NOT NULL).
    //   - precio: número real obligatorio.
    //   - stock: entero obligatorio.
    //
    // Usamos `db.execute` porque CREATE TABLE no devuelve filas.
    await db.execute('''
      CREATE TABLE productos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        precio REAL NOT NULL,
        stock INTEGER NOT NULL
      )
    ''');

    // Datos de ejemplo para conservar la vista inicial del laboratorio.
    // Este bloque es opcional: si quieres que la app empiece con la base
    // vacía, comenta la siguiente línea y borra el método _insertarDatosIniciales.
    await _insertarDatosIniciales(db);
  }

  /// Inserta los cuatro productos de ejemplo la primera vez que se crea la BD.
  ///
  /// Se usa `db.insert()` con mapas y no SQL concatenado. Así sqflite escapa
  /// los valores y evita errores con comillas o caracteres especiales.
  Future<void> _insertarDatosIniciales(Database db) async {
    final productosIniciales = [
      {'nombre': 'Laptop HP', 'precio': 2500.00, 'stock': 5},
      {'nombre': 'Mouse Logitech', 'precio': 45.00, 'stock': 20},
      {'nombre': 'Teclado Genius', 'precio': 65.00, 'stock': 12},
      {'nombre': 'Monitor Samsung', 'precio': 750.00, 'stock': 8},
    ];

    for (final producto in productosIniciales) {
      await db.insert('productos', producto);
    }
  }

  // --------------------------------------------------------------------------
  // OPERACIONES CRUD
  // --------------------------------------------------------------------------
  //
  // Todas usan `async`/`await` porque el acceso al disco es asíncrono:
  // la app no debe bloquearse mientras SQLite lee o escribe.
  //
  // Todas usan consultas parametrizadas (`where: 'id = ?'` + `whereArgs`).
  // Nunca se concatena el valor directamente en el SQL; así se evita la
  // inyección SQL y se manejan correctamente los tipos de datos.
  // --------------------------------------------------------------------------

  /// CREATE: registra un producto nuevo.
  ///
  /// Devuelve el `id` que SQLite generó automáticamente.
  Future<int> insertarProducto(Producto producto) async {
    final db = await database;

    // toMap() incluye el id. En una inserción nueva el id todavía no existe,
    // así que lo eliminamos para que AUTOINCREMENT lo genere.
    final datos = producto.toMap()..remove('id');

    // insert() devuelve el id del registro insertado.
    return db.insert('productos', datos);
  }

  /// READ: obtiene todos los productos ordenados por id.
  Future<List<Producto>> obtenerProductos() async {
    final db = await database;

    // query() equivale a: SELECT * FROM productos ORDER BY id ASC
    final filas = await db.query('productos', orderBy: 'id ASC');

    // Cada fila de SQLite se convierte en un objeto Producto de Dart.
    return filas
        .map((fila) => Producto.fromMap(Map<String, dynamic>.from(fila)))
        .toList();
  }

  /// UPDATE: modifica un producto existente.
  ///
  /// Devuelve la cantidad de filas actualizadas (1 si encontró el id).
  Future<int> actualizarProducto(Producto producto) async {
    final db = await database;

    // El id no se actualiza: se usa únicamente para ubicar la fila.
    final datos = producto.toMap()..remove('id');

    // El `where` usa `?` para evitar concatenar el id en el SQL.
    // `whereArgs` proporciona el valor real de forma segura.
    return db.update(
      'productos',
      datos,
      where: 'id = ?',
      whereArgs: [producto.id],
    );
  }

  /// DELETE: elimina el producto cuyo id coincide.
  ///
  /// Devuelve la cantidad de filas eliminadas.
  Future<int> eliminarProducto(int id) async {
    final db = await database;

    return db.delete('productos', where: 'id = ?', whereArgs: [id]);
  }

  /// Cierra la conexión y limpia la referencia.
  ///
  /// Es útil al terminar la app o al ejecutar pruebas automatizadas, para
  /// que la siguiente llamada vuelva a abrir la base de datos desde cero.
  Future<void> cerrar() async {
    if (_baseDatos != null) {
      await _baseDatos!.close();
      _baseDatos = null;
    }
  }
}
