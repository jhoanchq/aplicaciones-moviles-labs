// ignore_for_file: file_names
// ============================================================================
// ESTADO VACÍO
// ============================================================================
//
// Se muestra cuando la tabla `productos` no tiene registros. El botón
// opcional permite abrir el formulario desde la pantalla de productos.
// ============================================================================

import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final VoidCallback? onAction;

  const EmptyState({super.key, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: const BoxDecoration(
                color: Color(0xFFEFF6FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                size: 46,
                color: Color(0xFF2563EB),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No hay productos todavía',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Agrega tu primer producto para comenzar a gestionar tu inventario.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: Color(0xFF64748B),
              ),
            ),
            if (onAction != null) ...[
              const SizedBox(height: 22),
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add, size: 20),
                label: const Text('Agregar producto'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
