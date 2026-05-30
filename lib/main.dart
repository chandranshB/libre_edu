import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'src/routing/app_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  
  runApp(
    const ProviderScope(
      child: LibreEduApp(),
    ),
  );
}

class LibreEduApp extends StatelessWidget {
  const LibreEduApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (PointerDownEvent event) {
        if (event.buttons == 8) { // 8 is kBackMouseButton
          if (goRouter.canPop()) {
            goRouter.pop();
          }
        }
      },
      child: MaterialApp.router(
        title: 'Libre Edu',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF4A148C), // Deep Purple
            brightness: Brightness.light,
          ),
          textTheme: const TextTheme(
            displayLarge: TextStyle(fontWeight: FontWeight.bold, letterSpacing: -1.0),
            titleLarge: TextStyle(fontWeight: FontWeight.w600),
          ),
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
          ),
          cardTheme: const CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
          ),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF4A148C),
            brightness: Brightness.dark,
          ),
          textTheme: const TextTheme(
            displayLarge: TextStyle(fontWeight: FontWeight.bold, letterSpacing: -1.0),
            titleLarge: TextStyle(fontWeight: FontWeight.w600),
          ),
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
          ),
          cardTheme: const CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
          ),
        ),
        themeMode: ThemeMode.system,
        routerConfig: goRouter,
      ),
    );
  }
}
