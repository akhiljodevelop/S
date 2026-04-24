import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/main_screen.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://wdquptbkicyzzvjyzdyn.supabase.co',
    anonKey: 'sb_publishable_m46Uh53QJTxB0KNm0b9mlw_8auRxMtp',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CMS Dashboard',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.grey,
        scaffoldBackgroundColor: const Color(0xFF121212),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final session = snapshot.data?.session;
        final user = snapshot.data?.session?.user;

        if (session != null && user != null && user.id == 'b8b9a181-4e37-4c32-a1fd-170466a9905c') {
          return const MainScreen();
        }

        return const LoginScreen();
      },
    );
  }
}
