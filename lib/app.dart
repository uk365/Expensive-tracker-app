import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/router/app_router.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Finance Tracker',
      debugShowCheckedModeBanner: false,
      theme: FlexThemeData.light(
        scheme: FlexScheme.indigo,
        surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
        blendLevel: 9,
        subThemesData: const FlexSubThemesData(
          blendOnLevel: 10,
          blendOnColors: false,
          useTextTheme: true,
          useM2StyleDividerInM3: true,
          alignedDropdown: true,
          useInputDecoratorThemeInDialogs: true,
          cardRadius: 16,
          inputDecoratorRadius: 12,
          fabRadius: 16,
          bottomNavigationBarSelectedLabelSchemeColor: SchemeColor.primary,
          bottomNavigationBarUnselectedLabelSchemeColor: SchemeColor.onSurface,
        ),
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
        useMaterial3: true,
        fontFamily: GoogleFonts.inter().fontFamily,
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF6366F1),
          secondary: Color(0xFF10B981),
          error: Color(0xFFEF4444),
          surface: Color(0xFFFFFFFF),
        ),
      ),
      darkTheme: FlexThemeData.dark(
        scheme: FlexScheme.indigo,
        surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
        blendLevel: 15,
        subThemesData: const FlexSubThemesData(
          blendOnLevel: 20,
          useTextTheme: true,
          useM2StyleDividerInM3: true,
          alignedDropdown: true,
          useInputDecoratorThemeInDialogs: true,
          cardRadius: 16,
          inputDecoratorRadius: 12,
          fabRadius: 16,
          bottomNavigationBarSelectedLabelSchemeColor: SchemeColor.primary,
        ),
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
        useMaterial3: true,
        fontFamily: GoogleFonts.inter().fontFamily,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF818CF8),
          secondary: Color(0xFF34D399),
          error: Color(0xFFEF4444),
          surface: Color(0xFF1E293B),
          surfaceContainerHighest: Color(0xFF334155),
        ),
      ),
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
