// ignore_for_file: file_names
// ============================================================================
// PANTALLA DE PRODUCTOS
// ============================================================================
//
// FASE 2: esta pantalla ya no guarda los productos en una lista en memoria.
// Ahora el flujo es:
//
//   Formulario -> DatabaseHelper -> SQLite -> recargar lista -> UI
//
// La base de datos es la fuente de verdad. Después de insertar, actualizar o
// eliminar, se vuelve a consultar la tabla para mostrar los datos reales.
//
// Importante: aquí NO se escribe SQL. Todo el acceso a SQLite está concentrado
// en DatabaseHelper (lib/database/database-helper.dart).
// ============================================================================

import 'package:flutter/material.dart';

import '../components/empty-state.dart';
import '../components/producto-card.dart';
import '../components/producto-form.dart';
import '../database/database-helper.dart';
import '../models/producto.dart';

/// Pantalla de listado y gestión de productos.
///
/// Recibe el [ValueNotifier] de productos desde main.dart. Así, cuando la
/// lista cambia, se actualizan tanto esta pantalla como los indicadores
/// de HomeScreen.
class ProductosScreen extends StatefulWidget {
  final ValueNotifier<List<Producto>> productos;

  /// Si es `true`, abre el formulario automáticamente al entrar.
  /// Se usa cuando el usuario toca "Agregar producto" en el inicio.
  final bool abrirFormulario;

  const ProductosScreen({
    super.key,
    required this.productos,
    this.abrirFormulario = false,
  });

  @override
  State<ProductosScreen> createState() => _ProductosScreenState();
}

class _ProductosScreenState extends State<ProductosScreen> {
  @override
  void initState() {
    super.initState();

    // Si venimos desde el acceso rápido "Agregar producto", abrimos el
    // formulario después del primer frame para que la pantalla ya exista.
    if (widget.abrirFormulario) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _abrirFormulario();
      });
    }
  }

  /// Abre el formulario para crear o editar un producto.
  ///
  /// - Si [producto] es `null`, es un registro nuevo: se inserta en SQLite.
  /// - Si [producto] tiene datos, es una edición: se actualiza por su id.
  Future<void> _abrirFormulario([Producto? producto]) async {
    // showModalBottomSheet devuelve el Producto que el formulario construyó
    // con Navigator.pop(context, producto).
    final resultado = await showModalBottomSheet<Producto>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProductoForm(producto: producto),
    );

    // Si el usuario canceló o cerró el formulario, no hacemos nada.
    if (resultado == null || !mounted) return;

    try {
      final db = DatabaseHelper();

      if (producto == null) {
        // CREATE: el formulario devuelve id = 0; DatabaseHelper lo elimina
        // del mapa para que SQLite genere el id con AUTOINCREMENT.
        await db.insertarProducto(resultado);
      } else {
        // UPDATE: el id del producto se conserva y se usa en el WHERE.
        await db.actualizarProducto(resultado);
      }

      // Volvemos a leer la tabla para reflejar exactamente lo que quedó
      // guardado en SQLite (incluido el id generado).
      await _recargarProductos();
    } catch (error) {
      debugPrint('Error al guardar el producto: $error');
      if (mounted) {
        _mostrarError('No se pudo guardar el producto.');
      }
    }
  }

  /// Consulta nuevamente todos los productos y actualiza el notifier.
  ///
  /// Al cambiar `widget.productos.value`, se reconstruyen automáticamente:
  /// - esta pantalla (ValueListenableBuilder);
  /// - la pantalla de inicio (también escucha el mismo notifier).
  Future<void> _recargarProductos() async {
    final lista = await DatabaseHelper().obtenerProductos();

    if (!mounted) return;
    widget.productos.value = lista;
  }

  /// Pide confirmación y elimina el producto de SQLite.
  Future<void> _eliminar(Producto producto) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Eliminar producto'),
        content: Text(
          '¿Seguro que deseas eliminar "${producto.nombre}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar != true || !mounted) return;

    try {
      // DELETE: se usa el id como parámetro seguro del WHERE.
      await DatabaseHelper().eliminarProducto(producto.id);
      await _recargarProductos();
    } catch (_) {
      if (mounted) {
        _mostrarError('No se pudo eliminar el producto.');
      }
    }
  }

  /// Muestra un aviso breve si una operación de SQLite falla.
  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ValueListenableBuilder escucha los cambios del notifier compartido.
    // Cada vez que se recarga la lista desde SQLite, la UI se reconstruye.
    return ValueListenableBuilder<List<Producto>>(
      valueListenable: widget.productos,
      builder: (context, productos, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Productos'),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${productos.length} ${productos.length == 1 ? 'producto' : 'productos'}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 6, 20, 14),
                child: Text(
                  'Administra tu inventario',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
              Expanded(
                // Si la tabla está vacía, se muestra el estado vacío.
                // Si tiene registros, se construye la lista de tarjetas.
                child: productos.isEmpty
                    ? EmptyState(onAction: () => _abrirFormulario())
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                        itemCount: productos.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final producto = productos[index];
                          return ProductoCard(
                            producto: producto,
                            onEditar: () => _abrirFormulario(producto),
                            onEliminar: () => _eliminar(producto),
                          );
                        },
                      ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _abrirFormulario(),
            icon: const Icon(Icons.add),
            label: const Text('Agregar'),
          ),
        );
      },
    );
  }
}
