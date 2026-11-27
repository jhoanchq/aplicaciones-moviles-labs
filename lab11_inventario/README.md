
# Lab 11 — Inventario con CRUD en memoria

**Curso:** Aplicaciones Móviles · 2026-II
**Proyecto:** `lab11_inventario`

## Objetivo

Construir la primera versión de **Mi Inventario**: una app que lista productos,
calcula el valor del inventario y permite agregar, editar y eliminar registros.
En este laboratorio los datos viven **solo en memoria**.

## Qué aprenderás

- Organizar un proyecto Flutter por carpetas (`models`, `components`, `screens`).
- Compartir estado entre pantallas con `ValueNotifier` y `ValueListenableBuilder`.
- Navegar con `Navigator.push` y `MaterialPageRoute`.
- Abrir un formulario en un `showModalBottomSheet` y devolver datos con `Navigator.pop`.
- Validar entradas con `Form`, `GlobalKey<FormState>` y `TextFormField`.

## Estructura

```
lib/
├── main.dart                     # Estado en memoria y tema de la app
├── models/producto.dart          # Modelo Producto
├── components/
│   ├── menu-card.dart            # Acceso rápido del inicio
│   ├── producto-card.dart        # Tarjeta de un producto
│   ├── producto-form.dart        # Formulario de alta/edición
│   └── empty-state.dart          # Lista vacía
└── screens/
    ├── home-screen.dart          # Inicio e indicadores
    └── productos-screen.dart     # CRUD en memoria
```

## Explicación del código

### Estado compartido

`main.dart` crea un `ValueNotifier` con los productos de ejemplo. El mismo
objeto se pasa a `HomeScreen` y a `ProductosScreen`, por lo que ambas pantallas
se mantienen sincronizadas.

```dart
final ValueNotifier<List<Producto>> _productos =
    ValueNotifier<List<Producto>>([
  const Producto(id: 1, nombre: 'Laptop HP', precio: 2500, stock: 5),
  const Producto(id: 2, nombre: 'Mouse Logitech', precio: 45, stock: 20),
]);
```

### Indicadores del inicio

`HomeScreen` escucha el notifier y suma `precio * stock` de cada producto:

```dart
final total = lista.fold<double>(
  0,
  (suma, producto) => suma + producto.valorInventario,
);
```

### Crear, editar y eliminar

En `productos-screen.dart` cada operación crea una **lista nueva** y la asigna
a `productos.value`. Esa asignación es la que reconstruye la interfaz.

```dart
final lista = List<Producto>.from(widget.productos.value);

if (producto == null) {
  final mayorId = lista.fold<int>(0, (m, p) => p.id > m ? p.id : m);
  lista.add(resultado.copyWith(id: mayorId + 1));
} else {
  final indice = lista.indexWhere((p) => p.id == producto.id);
  if (indice != -1) lista[indice] = resultado;
}

widget.productos.value = lista;
```

Eliminar es filtrar la lista:

```dart
widget.productos.value = widget.productos.value
    .where((item) => item.id != producto.id)
    .toList();
```

### Formulario

`producto-form.dart` no guarda nada: valida los campos y devuelve un `Producto`
con `Navigator.pop(context, producto)`. La pantalla que lo abrió decide qué
hacer con el resultado.

## Limitación de este laboratorio

Al cerrar la app, los cambios se pierden porque la lista vive en RAM.
El **Laboratorio 12** resuelve esto guardando los productos en SQLite.

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

También se entrega una copia en `../dist/lab11_inventario.apk`.

Instalar en un teléfono conectado por USB:

```bash
adb install -r build/app/outputs/flutter-apk/app-release.apk
```
