import 'package:flutter/material.dart';

class AppTheme {
  // Definís tus colores personalizados
  static const Color verde        = Color(0xFF00D09E);
  static const Color verdeOscuro  = Color(0xFF093030);
  static const Color blancoPalido = Color(0xFFF1FFF3);
  static const Color verdePalido  = Color(0xFFDFF7E2);

  // También podés exponer una lista si querés recorrerlos
  static const List<Color> customColors = [
    verde,
    verdeOscuro,
    blancoPalido,
    verdePalido,
  ];

  static ThemeData getTheme() => ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: verde,
          onPrimary: Colors.white,
          secondary: blancoPalido,
          onSecondary: verdeOscuro,
          tertiary: verdePalido,
          onTertiary: Colors.white,
          error: Color(0xFFB00020),
          onError: Colors.white,
          surface: Colors.white,
          onSurface: Colors.black,
        ),
      );
}
