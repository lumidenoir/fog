import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/write_files.dart';
import 'screens/weather_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FOG',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        cardColor: const Color(0xFF1A1A1A),
        primaryColor: Colors.white,
        textTheme: TextTheme(
          headlineLarge: GoogleFonts.bebasNeue(
            fontWeight: FontWeight.w900,
            fontSize: 64,
            color: Colors.white,
          ),
          bodyLarge: GoogleFonts.bebasNeue(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.white70,
          ),
          bodyMedium: GoogleFonts.bebasNeue(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: Colors.white60,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white70),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.black,
          elevation: 0,
          titleTextStyle: GoogleFonts.bebasNeue(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  Future<void> _initializeApp() async {
    try {
      await createHourlyJson();
      await createDailyJson();
      print("JSON files initialized successfully.");
    } catch (e) {
      print("Error during initialization: $e");
      throw Exception("Initialization failed");
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initializeApp(),
      builder: (BuildContext context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text(
                'Initialization Failed: ${snapshot.error}',
                textAlign: TextAlign.center,
                style: GoogleFonts.bebasNeue(fontSize: 16, color: Colors.red),
              ),
            ),
          );
        } else {
          Future.microtask(() {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const WeatherScreen()),
            );
          });
          return const SizedBox.shrink();
        }
      },
    );
  }
}
