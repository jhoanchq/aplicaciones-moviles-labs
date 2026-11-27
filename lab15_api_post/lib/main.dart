// ============================================================================
// PUNTO DE ENTRADA DE LA APLICACIÓN
// ============================================================================
//
// Flujo de arranque en la FASE 2:
//
//   1. main() inicia la app.
//   2. MiInventarioApp abre la base de datos mediante DatabaseHelper.
//   3. Los productos se cargan desde SQLite en un ValueNotifier.
//   4. HomeScreen escucha ese notifier y muestra los indicadores reales.
//
// Mientras SQLite responde se muestra una pantalla de carga. Si ocurre un
// error, se muestra una pantalla con opción de reintentar.
// ============================================================================

import 'package:flutter/material.dart';

import 'database/database-helper.dart';
import 'models/producto.dart';
import 'screens/home-screen.dart';

void main() {
  // Necesario antes de usar plugins de plataforma (como sqflite).
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MiInventarioApp());
}

class MiInventarioApp extends StatefulWidget {
  const MiInventarioApp({super.key});

  @override
  State<MiInventarioApp> createState() => _MiInventarioAppState();
}

class _MiInventarioAppState extends State<MiInventarioApp> {
  // --------------------------------------------------------------------------
  // ESTADO COMPARTIDO
  // --------------------------------------------------------------------------
  // `ValueNotifier` es una forma sencilla y nativa de Flutter para compartir
  // datos entre pantallas. HomeScreen y ProductosScreen escuchan este mismo
  // notifier mediante ValueListenableBuilder.
  //
  // En la FASE 2 empieza vacío: los datos reales se cargan desde SQLite.
  final ValueNotifier<List<Producto>> _productos =
      ValueNotifier<List<Producto>>([]);

  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    // initState no puede ser async, por eso llamamos a un método aparte.
    _cargarProductos();
  }

  /// Consulta todos los productos guardados en SQLite y actualiza la UI.
  ///
  /// Este es el primer contacto de la app con la base de datos. Si la tabla
  /// todavía no existe, DatabaseHelper la crea y siembra los datos iniciales.
  Future<void> _cargarProductos() async {
    try {
      final lista = await DatabaseHelper().obtenerProductos();

      // `mounted` evita llamar a setState si la pantalla ya se cerró.
      if (!mounted) return;

      _productos.value = lista;

      setState(() {
        _cargando = false;
        _error = null;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _cargando = false;
        _error = 'No se pudo abrir la base de datos.';
      });
    }
  }

  /// Vuelve a intentar la carga cuando el usuario presiona "Reintentar".
  void _reintentar() {
    setState(() {
      _cargando = true;
      _error = null;
    });
    _cargarProductos();
  }

  @override
  void dispose() {
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

      // Mientras se consulta SQLite se muestra una pantalla de carga.
      // Si hubo un error, se muestra una pantalla con reintento.
      // Cuando todo está listo, se muestra la pantalla principal.
      home: _cargando
          ? const _PantallaCarga()
          : _error != null
              ? _PantallaError(
                  mensaje: _error!,
                  onReintentar: _reintentar,
                )
              : HomeScreen(productos: _productos),
    );
  }
}

// ============================================================================
// PANTALLAS DE APOYO
// ============================================================================

class _PantallaCarga extends StatelessWidget {
  const _PantallaCarga();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Cargando inventario...',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PantallaError extends StatelessWidget {
  final String mensaje;
  final VoidCallback onReintentar;

  const _PantallaError({
    required this.mensaje,
    required this.onReintentar,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 56,
                color: Color(0xFFEF4444),
              ),
              const SizedBox(height: 16),
              Text(
                mensaje,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Verifica que la base de datos esté disponible e intenta de nuevo.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF64748B),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: onReintentar,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
