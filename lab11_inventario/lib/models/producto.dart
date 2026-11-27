/// Modelo que representa un producto del inventario.
///
/// Cada instancia de [Producto] equivale a una fila de la tabla `productos`
/// en SQLite. Sus propiedades coinciden con las columnas de la tabla:
///
/// | Propiedad | Columna  | Tipo SQLite |
/// |-----------|----------|-------------|
/// | id        | id       | INTEGER     |
/// | nombre    | nombre   | TEXT        |
/// | precio    | precio   | REAL        |
/// | stock     | stock    | INTEGER     |
///
/// Los métodos [toMap] y [fromMap] son el puente entre Dart y SQLite.
class Producto {
  final int id;
  final String nombre;
  final double precio;
  final int stock;

  const Producto({
    required this.id,
    required this.nombre,
    required this.precio,
    required this.stock,
  });

  /// Valor total de este producto dentro del inventario.
  ///
  /// Se usa en la pantalla de inicio para calcular el valor referencial:
  /// `precio * stock`.
  double get valorInventario => precio * stock;

  /// Convierte el objeto Dart en un `Map` que SQLite puede guardar.
  ///
  /// Las claves del mapa deben coincidir con los nombres de las columnas
  /// de la tabla `productos`. sqflite usa este mapa en `insert()` y `update()`.
  ///
  /// Nota: al insertar un producto nuevo, [DatabaseHelper.insertarProducto]
  /// elimina la clave `id` para que SQLite lo genere automáticamente
  /// gracias a `AUTOINCREMENT`.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'precio': precio,
      'stock': stock,
    };
  }

  /// Construye un [Producto] a partir de una fila devuelta por SQLite.
  ///
  /// SQLite devuelve los números como `num`; por eso `precio` se convierte
  /// explícitamente a `double` antes de crear el objeto.
  factory Producto.fromMap(Map<String, dynamic> map) {
    return Producto(
      id: map['id'] as int,
      nombre: map['nombre'] as String,
      precio: (map['precio'] as num).toDouble(),
      stock: map['stock'] as int,
    );
  }

  /// Devuelve una copia del producto cambiando solo los campos indicados.
  ///
  /// Es útil para actualizar un producto sin modificar el objeto original,
  /// por ejemplo después de que SQLite asigna un nuevo `id`.
  Producto copyWith({
    int? id,
    String? nombre,
    double? precio,
    int? stock,
  }) {
    return Producto(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      precio: precio ?? this.precio,
      stock: stock ?? this.stock,
    );
  }
}
