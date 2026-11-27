// ============================================================================
// LABORATORIO 11 — PRUEBA DEL CRUD EN MEMORIA
// ============================================================================
//
// Comprueba que la app arranca con los cuatro productos de ejemplo y que
// los indicadores del inicio calculan el valor total.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lab11_inventario/components/producto-card.dart';
import 'package:lab11_inventario/main.dart';
import 'package:lab11_inventario/models/producto.dart';

void main() {
  test('valorInventario multiplica precio por stock', () {
    const producto = Producto(
      id: 1,
      nombre: 'Prueba',
      precio: 25.5,
      stock: 4,
    );

    expect(producto.valorInventario, 102.0);
  });

  testWidgets('muestra los productos y el total en memoria', (tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MiInventarioApp());
    await tester.pumpAndSettle();

    expect(find.text('Mi Inventario'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
    expect(find.text('S/ 20180.00'), findsOneWidget);

    await tester.tap(find.text('Productos'));
    await tester.pumpAndSettle();

    expect(find.text('Laptop HP'), findsOneWidget);
    expect(find.byType(ProductoCard), findsNWidgets(4));
  });
}
