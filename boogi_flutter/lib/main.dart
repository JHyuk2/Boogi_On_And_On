import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Boogi On & On',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF4FA095),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4FA095),
          primary: const Color(0xFF4FA095),
          secondary: const Color(0xFF6DEBE1),
          surface: const Color(0xFFF7FDFD),
        ),
        fontFamily: 'Pretendard', // 기본 감성 한글 가독성 폰트 매칭 대비
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E5257)),
          bodyLarge: TextStyle(color: Color(0xFF2E4E52)),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
      },
    );
  }
}
