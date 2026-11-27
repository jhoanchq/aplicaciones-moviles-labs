// ignore_for_file: file_names
// ============================================================================
// PANTALLA DE INICIO
// ============================================================================
//
// Los indicadores NO están hardcodeados. Se calculan a partir de la lista
// que main.dart carga desde SQLite y que ProductosScreen actualiza después
// de cada operación CRUD.
//
// HomeScreen no conoce SQLite: solo escucha el ValueNotifier compartido.
// ============================================================================

import 'package:flutter/material.dart';

import '../components/menu-card.dart';
import '../models/producto.dart';
import 'productos-screen.dart';

class HomeScreen extends StatelessWidget {
  final ValueNotifier<List<Producto>> productos;

  const HomeScreen({super.key, required this.productos});

  void _abrirProductos(BuildContext context, {bool agregar = false}) {
    // Se comparte el mismo notifier con ProductosScreen para que los cambios
    // realizados allí se reflejen también en los indicadores del inicio.
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ProductosScreen(productos: productos, abrirFormulario: agregar),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Producto>>(
      valueListenable: productos,
      builder: (context, lista, _) {
        // `lista` es el valor actual del notifier. main.dart lo llena desde
        // SQLite y ProductosScreen lo reemplaza después de insertar, editar
        // o eliminar un producto.
        //
        // El valor total se recalcula automáticamente:
        // suma de (precio * stock) de todos los productos.
        final total = lista.fold<double>(
          0,
          (suma, producto) => suma + producto.valorInventario,
        );

        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Encabezado(),
                  const SizedBox(height: 22),
                  _Bienvenida(),
                  const SizedBox(height: 22),
                  _Resumen(cantidad: lista.length, total: total),
                  const SizedBox(height: 28),
                  const Text(
                    'Accesos rápidos',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  MenuCard(
                    icono: Icons.inventory_2_rounded,
                    titulo: 'Productos',
                    subtitulo:
                        'Consulta, agrega, edita y elimina tus productos.',
                    color: const Color(0xFF2563EB),
                    onTap: () => _abrirProductos(context),
                  ),
                  const SizedBox(height: 12),
                  MenuCard(
                    icono: Icons.add_box_outlined,
                    titulo: 'Agregar producto',
                    subtitulo: 'Registra un nuevo producto en tu inventario.',
                    color: const Color(0xFF10B981),
                    onTap: () => _abrirProductos(context, agregar: true),
                  ),
                  const SizedBox(height: 20),
                  const _TipCard(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Encabezado extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mi Inventario',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: Color(0xFF0F172A),
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Gestiona tus productos de forma sencilla',
                style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE8EEF7)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Icon(
            Icons.inventory_2_rounded,
            color: Color(0xFF2563EB),
            size: 26,
          ),
        ),
      ],
    );
  }
}

class _Bienvenida extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -6,
                top: -18,
                child: Icon(
                  Icons.inventory_2,
                  size: 110,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '¡Hola! 👋',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Bienvenido a tu inventario',
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Administra tus productos y mantén el control de tu stock.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Resumen extends StatelessWidget {
  final int cantidad;
  final double total;

  const _Resumen({required this.cantidad, required this.total});

  @override
  Widget build(BuildContext context) {
    // Estas dos tarjetas son los indicadores solicitados en el laboratorio:
    // cantidad total de productos y valor referencial del inventario.
    final tarjetas = [
      _ResumenCard(
        icono: Icons.inventory_2_outlined,
        titulo: 'Productos registrados',
        valor: '$cantidad',
        color: const Color(0xFF2563EB),
      ),
      _ResumenCard(
        icono: Icons.payments_outlined,
        titulo: 'Valor del inventario',
        valor: 'S/ ${total.toStringAsFixed(2)}',
        color: const Color(0xFF10B981),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 360) {
          return Column(
            children: [tarjetas[0], const SizedBox(height: 12), tarjetas[1]],
          );
        }

        return Row(
          children: [
            Expanded(child: tarjetas[0]),
            const SizedBox(width: 12),
            Expanded(child: tarjetas[1]),
          ],
        );
      },
    );
  }
}

class _ResumenCard extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String valor;
  final Color color;

  const _ResumenCard({
    required this.icono,
    required this.titulo,
    required this.valor,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8EEF7)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icono, color: color, size: 22),
          ),
          const SizedBox(height: 14),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              valor,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  const _TipCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDBEAFE)),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.lightbulb_outline_rounded,
            color: Color(0xFF2563EB),
            size: 22,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Consejo: mantén tu stock actualizado para tener un inventario confiable.',
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: Color(0xFF1E40AF),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
