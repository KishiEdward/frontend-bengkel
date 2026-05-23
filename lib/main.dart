import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'ui/screens/login_screen.dart';
import 'providers/pesanan_provider.dart';
import 'providers/detail_pesanan_provider.dart';
import 'providers/laporan_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PesananProvider()),
        ChangeNotifierProvider(create: (_) => DetailPesananProvider()),
        ChangeNotifierProvider(create: (_) => LaporanProvider()),
      ],
      child: MaterialApp(
        title: 'Bengkel Bubut ABC',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: 'Roboto', // Opsional, bisa diganti nanti
        ),
        home: const LoginScreen(), // Set halaman utama ke LoginScreen
      ),
    );
  }
}
