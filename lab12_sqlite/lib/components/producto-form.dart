// ignore_for_file: file_names
// ============================================================================
// FORMULARIO DE PRODUCTO
// ============================================================================
//
// Este componente SOLO recoge y valida los datos del producto.
// No guarda en SQLite: devuelve un Producto a ProductosScreen mediante
// Navigator.pop(context, producto).
//
// ProductosScreen es quien decide si llama a insertarProducto() o a
// actualizarProducto() en DatabaseHelper.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/producto.dart';

class ProductoForm extends StatefulWidget {
  final Producto? producto;

  const ProductoForm({super.key, this.producto});

  @override
  State<ProductoForm> createState() => _ProductoFormState();
}

class _ProductoFormState extends State<ProductoForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombreController;
  late final TextEditingController _precioController;
  late final TextEditingController _stockController;

  bool get _esEdicion => widget.producto != null;

  @override
  void initState() {
    super.initState();
    // Si el formulario se abre para editar, los campos se llenan con los
    // datos actuales del producto. Si es un producto nuevo, quedan vacíos.
    _nombreController = TextEditingController(
      text: widget.producto?.nombre ?? '',
    );
    _precioController = TextEditingController(
      text: widget.producto != null
          ? widget.producto!.precio.toStringAsFixed(2)
          : '',
    );
    _stockController = TextEditingController(
      text: widget.producto?.stock.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _precioController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  void _guardar() {
    if (!_formKey.currentState!.validate()) return;

    final precio = double.parse(
      _precioController.text.trim().replaceAll(',', '.'),
    );
    final stock = int.parse(_stockController.text.trim());

    // Se devuelve el producto a ProductosScreen.
    //
    // - Producto nuevo: widget.producto es null, así que el id queda en 0.
    //   DatabaseHelper lo quitará del mapa y SQLite generará el id real.
    // - Edición: se conserva el id original para que el UPDATE sepa qué fila
    //   modificar.
    Navigator.pop(
      context,
      Producto(
        id: widget.producto?.id ?? 0,
        nombre: _nombreController.text.trim(),
        precio: precio,
        stock: stock,
      ),
    );
  }

  InputDecoration _decoracion({
    required String label,
    required IconData icono,
    String? prefixText,
    String? hintText,
  }) {
    final borde = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
    );

    return InputDecoration(
      labelText: label,
      hintText: hintText,
      prefixIcon: Icon(icono, size: 20),
      prefixText: prefixText,
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: borde,
      enabledBorder: borde,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFEF4444)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _esEdicion ? 'Editar producto' : 'Nuevo producto',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _esEdicion
                        ? 'Actualiza los datos del producto seleccionado.'
                        : 'Completa los datos para registrar el producto.',
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 22),
                  TextFormField(
                    controller: _nombreController,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    decoration: _decoracion(
                      label: 'Nombre del producto',
                      icono: Icons.inventory_2_outlined,
                      hintText: 'Ej. Laptop HP',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El nombre es obligatorio';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _precioController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    textInputAction: TextInputAction.next,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                    ],
                    decoration: _decoracion(
                      label: 'Precio',
                      icono: Icons.payments_outlined,
                      prefixText: 'S/ ',
                      hintText: '0.00',
                    ),
                    validator: (value) {
                      final texto = value?.trim() ?? '';
                      if (texto.isEmpty) {
                        return 'El precio es obligatorio';
                      }
                      final precio = double.tryParse(
                        texto.replaceAll(',', '.'),
                      );
                      if (precio == null) {
                        return 'Ingresa un precio válido';
                      }
                      if (precio <= 0) {
                        return 'El precio debe ser mayor que cero';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _stockController,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: _decoracion(
                      label: 'Stock',
                      icono: Icons.numbers_rounded,
                      hintText: '0',
                    ),
                    validator: (value) {
                      final texto = value?.trim() ?? '';
                      if (texto.isEmpty) {
                        return 'El stock es obligatorio';
                      }
                      final stock = int.tryParse(texto);
                      if (stock == null) {
                        return 'Ingresa un número entero';
                      }
                      if (stock < 0) {
                        return 'El stock debe ser igual o mayor que cero';
                      }
                      return null;
                    },
                    onFieldSubmitted: (_) => _guardar(),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _guardar,
                      icon: const Icon(Icons.save_outlined, size: 20),
                      label: Text(
                        _esEdicion ? 'Guardar cambios' : 'Guardar producto',
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
