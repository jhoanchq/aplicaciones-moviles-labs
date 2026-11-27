// ignore_for_file: file_names
// ============================================================================
// LABORATORIO 11 — PANTALLA DE PRODUCTOS (CRUD EN MEMORIA)
// ============================================================================
//
// El CRUD se hace sobre el ValueNotifier que viene desde main.dart:
//
//   - CREATE: se agrega un Producto con un id nuevo.
//   - READ:   la lista se muestra con ValueListenableBuilder.
//   - UPDATE: se reemplaza el producto que tiene el mismo id.
//   - DELETE: se filtran los productos y se quita el seleccionado.
//
// Cada operación crea una LISTA NUEVA y la asigna a `productos.value`.
// Asignar un valor nuevo es lo que dispara la reconstrucción de la interfaz.
// ============================================================================

import 'package:flutter/material.dart';

import '../components/empty-state.dart';
import '../components/producto-card.dart';
import '../components/producto-form.dart';
import '../models/producto.dart';

class ProductosScreen extends StatefulWidget {
  final ValueNotifier<List<Producto>> productos;
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

    // Si venimos de "Agregar producto", abrimos el formulario en cuanto la
    // pantalla esté construida.
    if (widget.abrirFormulario) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _abrirFormulario();
      });
    }
  }

  /// Abre el formulario y aplica el resultado en memoria.
  Future<void> _abrirFormulario([Producto? producto]) async {
    // El formulario devuelve un Producto con Navigator.pop.
    final resultado = await showModalBottomSheet<Producto>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProductoForm(producto: producto),
    );

    if (resultado == null || !mounted) return;

    // Copia de la lista actual. Nunca se modifica la lista "original" que
    // está siendo escuchada: se crea una nueva y se asigna al notifier.
    final lista = List<Producto>.from(widget.productos.value);

    if (producto == null) {
      // CREATE: el id nuevo es el mayor id actual + 1.
      final mayorId = lista.fold<int>(
        0,
        (mayor, item) => item.id > mayor ? item.id : mayor,
      );
      lista.add(resultado.copyWith(id: mayorId + 1));
    } else {
      // UPDATE: se busca por id y se reemplaza el objeto.
      final indice = lista.indexWhere((item) => item.id == producto.id);
      if (indice != -1) {
        lista[indice] = resultado;
      }
    }

    widget.productos.value = lista;
  }

  /// DELETE: pide confirmación y quita el producto de la lista.
  Future<void> _eliminar(Producto producto) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Eliminar producto'),
        content: Text('¿Seguro que deseas eliminar "${producto.nombre}"?'),
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

    widget.productos.value = widget.productos.value
        .where((item) => item.id != producto.id)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
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
                child: productos.isEmpty
                    ? EmptyState(onAction: () => _abrirFormulario())
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                        itemCount: productos.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
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
