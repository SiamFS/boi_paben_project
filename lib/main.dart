import 'package:boi_paben_project/viewmodels/book_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'utils/app_theme.dart';
import 'views/login_screen.dart';
import 'views/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => BookViewModel()),
      ],
      child: MaterialApp(
        title: 'BoiPaben',
        theme: AppTheme.lightTheme,
        home: Consumer<AuthViewModel>(
          builder: (context, authViewModel, child) {
            // Show loading screen while initializing
            if (!authViewModel.isInitialized) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
            
            // Always show home screen - app works without login
            return const HomeScreen();
          },
        ),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
