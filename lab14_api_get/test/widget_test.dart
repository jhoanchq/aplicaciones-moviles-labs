// ============================================================================
// PRUEBA DE LA FASE 2
// ============================================================================
//
// Usa sqflite_common_ffi para ejecutar SQLite real en la máquina de pruebas.
// Así se verifica el flujo completo:
//
//   UI -> ProductoForm -> ProductosScreen -> DatabaseHelper -> SQLite
//
// No se prueba un mock: se crea una base de datos temporal, se ejecuta el
// CRUD y se comprueba que los cambios se reflejan en la interfaz.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lab14_api_get/components/producto-card.dart';
import 'package:lab14_api_get/database/database-helper.dart';
import 'package:lab14_api_get/main.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    // Inicializa SQLite para la VM de pruebas (Windows/Linux/macOS).
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    // Cierra cualquier conexión anterior y elimina la BD de prueba.
    await DatabaseHelper().cerrar();

    final ruta = p.join(await getDatabasesPath(), 'inventario.db');
    if (await databaseExists(ruta)) {
      await deleteDatabase(ruta);
    }
  });

  tearDown(() async {
    await DatabaseHelper().cerrar();
  });

  /// Espera hasta que se cumpla una condición, permitiendo I/O real.
  ///
  /// En las pruebas de widgets el tiempo es "falso"; `runAsync` permite
  /// esperar operaciones reales de disco (abrir, insertar, consultar).
  Future<void> esperarCondicion(
    WidgetTester tester,
    bool Function() condicion, {
    Duration timeout = const Duration(seconds: 8),
  }) async {
    final limite = DateTime.now().add(timeout);

    while (DateTime.now().isBefore(limite)) {
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 100));
      });
      await tester.pump();

      if (condicion()) break;
    }

    await tester.pumpAndSettle();
  }

  testWidgets('FASE 2: CRUD persistente en SQLite', (tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MiInventarioApp());

    // La app consulta SQLite al iniciar; esperamos a que termine la carga.
    await esperarCondicion(
      tester,
      () => find.text('Mi Inventario').evaluate().isNotEmpty,
    );

    // Los 4 productos iniciales vienen de la base de datos.
    expect(find.text('Mi Inventario'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
    expect(find.text('S/ 20180.00'), findsOneWidget);

    // Ir a Productos.
    await tester.tap(find.text('Productos'));
    await tester.pumpAndSettle();

    expect(find.text('Laptop HP'), findsOneWidget);

    // CREATE: agregar un producto (se guarda en SQLite).
    await tester.tap(find.text('Agregar'));
    await tester.pumpAndSettle();

    expect(find.text('Nuevo producto'), findsOneWidget);

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'Producto de prueba',
    );
    await tester.enterText(
      find.byType(TextFormField).at(1),
      '99.90',
    );
    await tester.enterText(
      find.byType(TextFormField).at(2),
      '3',
    );

    await tester.ensureVisible(find.text('Guardar producto'));
    await tester.tap(find.text('Guardar producto'));
    await esperarCondicion(
      tester,
      () => find
          .descendant(
            of: find.byType(ProductoCard),
            matching: find.text('Producto de prueba'),
          )
          .evaluate()
          .isNotEmpty,
    );

    expect(
      find.descendant(
        of: find.byType(ProductoCard),
        matching: find.text('Producto de prueba'),
      ),
      findsOneWidget,
    );

    // UPDATE: editar el producto y comprobar el cambio en la lista.
    final tarjetaNueva = find.ancestor(
      of: find.text('Producto de prueba'),
      matching: find.byType(ProductoCard),
    );
    await tester.tap(
      find.descendant(of: tarjetaNueva, matching: find.text('Editar')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Editar producto'), findsOneWidget);

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'Producto editado',
    );

    await tester.ensureVisible(find.text('Guardar cambios'));
    await tester.tap(find.text('Guardar cambios'));
    await esperarCondicion(
      tester,
      () => find
          .descendant(
            of: find.byType(ProductoCard),
            matching: find.text('Producto editado'),
          )
          .evaluate()
          .isNotEmpty,
    );

    expect(
      find.descendant(
        of: find.byType(ProductoCard),
        matching: find.text('Producto editado'),
      ),
      findsOneWidget,
    );

    // DELETE: eliminar y confirmar.
    final tarjetaEditada = find.ancestor(
      of: find.text('Producto editado'),
      matching: find.byType(ProductoCard),
    );
    await tester.tap(
      find.descendant(of: tarjetaEditada, matching: find.text('Eliminar')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Eliminar producto'), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Eliminar'),
      ),
    );
    await esperarCondicion(
      tester,
      () => find
          .descendant(
            of: find.byType(ProductoCard),
            matching: find.text('Producto editado'),
          )
          .evaluate()
          .isEmpty,
    );

    expect(
      find.descendant(
        of: find.byType(ProductoCard),
        matching: find.text('Producto editado'),
      ),
      findsNothing,
    );

    // Volver al inicio: los indicadores reflejan la BD.
    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('4'), findsOneWidget);
    expect(find.text('S/ 20180.00'), findsOneWidget);
  });
}
