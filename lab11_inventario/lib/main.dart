// ============================================================================
// LABORATORIO 11 — PUNTO DE ENTRADA (CRUD EN MEMORIA)
// ============================================================================
//
// Esta primera versión del inventario guarda los productos en una lista de
// Dart. No hay base de datos: al cerrar la app, los cambios se pierden.
//
// Ese límite es intencional: en el laboratorio 12 se reemplaza la lista por
// SQLite y los datos pasan a ser persistentes.
//
// Flujo:
//   1. main() inicia la app.
//   2. El estado se crea con cuatro productos de ejemplo.
//   3. HomeScreen escucha el ValueNotifier y muestra los indicadores.
//   4. ProductosScreen modifica la lista y notifica a la interfaz.
// ============================================================================

import 'package:flutter/material.dart';

import 'models/producto.dart';
import 'screens/home-screen.dart';

void main() {
  runApp(const MiInventarioApp());
}

class MiInventarioApp extends StatefulWidget {
  const MiInventarioApp({super.key});

  @override
  State<MiInventarioApp> createState() => _MiInventarioAppState();
}

class _MiInventarioAppState extends State<MiInventarioApp> {
  // --------------------------------------------------------------------------
  // ESTADO COMPARTIDO EN MEMORIA
  // --------------------------------------------------------------------------
  // ValueNotifier guarda una lista y avisa a quienes la escuchan cada vez que
  // cambia. HomeScreen y ProductosScreen usan el MISMO notifier, por eso los
  // indicadores del inicio se actualizan al agregar, editar o eliminar.
  final ValueNotifier<List<Producto>> _productos =
      ValueNotifier<List<Producto>>([
    const Producto(id: 1, nombre: 'Laptop HP', precio: 2500, stock: 5),
    const Producto(id: 2, nombre: 'Mouse Logitech', precio: 45, stock: 20),
    const Producto(id: 3, nombre: 'Teclado Genius', precio: 65, stock: 12),
    const Producto(id: 4, nombre: 'Monitor Samsung', precio: 750, stock: 8),
  ]);

  @override
  void dispose() {
    // Libera el notifier cuando la app se destruye.
    _productos.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF2563EB),
    );

    return MaterialApp(
      title: 'Mi Inventario',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: const Color(0xFFF4F7FC),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF4F7FC),
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
          iconTheme: IconThemeData(color: Color(0xFF0F172A)),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size(0, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF2563EB),
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
      ),
      home: HomeScreen(productos: _productos),
    );
  }
}
