import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/router/app_router.dart';

const _lightColorScheme = ColorScheme.light(
  primary: Color(0xFF6366F1),
  secondary: Color(0xFF10B981),
  error: Color(0xFFEF4444),
  surface: Color(0xFFFFFFFF),
  onPrimary: Colors.white,
  onSecondary: Colors.white,
  onError: Colors.white,
  onSurface: Color(0xFF1E293B),
);

const _darkColorScheme = ColorScheme.dark(
  primary: Color(0xFF818CF8),
  secondary: Color(0xFF34D399),
  error: Color(0xFFEF4444),
  surface: Color(0xFF1E293B),
  onPrimary: Colors.white,
  onSecondary: Colors.white,
  onError: Colors.white,
  onSurface: Color(0xFFE2E8F0),
);

ThemeData _buildTheme(ColorScheme colorScheme) {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    fontFamily: GoogleFonts.inter().fontFamily,
    visualDensity: VisualDensity.comfortable,
  );

  return base.copyWith(
    cardTheme: base.cardTheme.copyWith(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      color: colorScheme.surface,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      filled: true,
      fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.4),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      indicatorColor: colorScheme.primaryContainer,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return TextStyle(
            color: colorScheme.primary,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          );
        }
        return TextStyle(
          color: colorScheme.onSurface,
          fontSize: 12,
        );
      }),
    ),
    dividerTheme: DividerThemeData(
      color: colorScheme.outlineVariant,
      thickness: 1,
    ),
  );
}

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Finance Tracker',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(_lightColorScheme),
      darkTheme: _buildTheme(_darkColorScheme),
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
