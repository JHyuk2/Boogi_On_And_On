import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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

      // ── 한국어 로케일 설정 (Material 위젯 한글화 + 텍스트 렌더링 안정성) ──
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ko', 'KR'),
        Locale('en', 'US'),
      ],

      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF4FA095),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4FA095),
          primary: const Color(0xFF4FA095),
          secondary: const Color(0xFF6DEBE1),
          surface: const Color(0xFFF7FDFD),
        ),

        // ── 로컬 NotoSansKR 지정 및 이모지 폴백 ──
        fontFamily: 'NotoSansKR',
        fontFamilyFallback: const [
          'Apple Color Emoji', // iOS / macOS 이모지 폰트
          'Segoe UI Emoji', // Windows 이모지 폰트
          'Noto Color Emoji', // Android / Linux 이모지 폰트
        ],

        // ── 텍스트 테마 전역 정의 ──
        // 가중치(Weight)별로 로컬 폰트 에셋이 정확하게 맵핑되어 흐릿함(Faux Bold) 현상을 원천 방지합니다.
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            fontWeight: FontWeight.bold, // w700 -> NotoSansKR-Bold.ttf 대응
            color: Color(0xFF1E5257),
          ),
          bodyLarge: TextStyle(
            fontWeight: FontWeight.w500, // w500 -> NotoSansKR-Medium.ttf 대응
            color: Color(0xFF2E4E52),
          ),
          bodyMedium: TextStyle(
            fontWeight: FontWeight.w400, // w400 -> NotoSansKR-Regular.ttf 대응
            color: Color(0xFF2E4E52),
          ),
          bodySmall: TextStyle(
            fontWeight: FontWeight.w300, // w300 -> NotoSansKR-Light.ttf 대응
            color: Color(0xFF5A7D82),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
      },
    );
  }
}
