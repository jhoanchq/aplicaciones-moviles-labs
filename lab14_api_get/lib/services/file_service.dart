// ============================================================================
// SELECTOR DE IMPLEMENTACIÓN
// ============================================================================
//
// En Android/iOS/escritorio se usa dart:io + path_provider.
// En web se descarga el JSON desde el navegador.
//
// La importación condicional la resuelve el compilador según la plataforma.
// ============================================================================

export 'file_service_io.dart'
    if (dart.library.html) 'file_service_web.dart';
