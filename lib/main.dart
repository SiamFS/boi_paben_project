import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/book_viewmodel.dart';
import 'utils/app_theme.dart';
import 'utils/routes.dart';

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
        initialRoute: AppRoutes.home,
        onGenerateRoute: AppRoutes.generateRoute,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
