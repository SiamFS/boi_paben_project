import 'package:flutter/material.dart';
import '../views/home_screen.dart';
import '../views/login_screen.dart';
import '../views/signup_screen.dart';
import '../views/sell_book_screen.dart';
import '../views/manage_books_screen.dart';
import '../views/edit_book_screen.dart';
import '../models/book_model.dart';

class AppRoutes {
  static const String home = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String sellBook = '/sell-book';
  static const String manageBooks = '/manage-books';
  static const String editBook = '/edit-book';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      home: (context) => const HomeScreen(),
      login: (context) => const LoginScreen(),
      signup: (context) => const SignUpScreen(),
      sellBook: (context) => const SellBookScreen(),
      manageBooks: (context) => const ManageBooksScreen(),
      // editBook route is handled in generateRoute method since it needs arguments
    };
  }

  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (context) => const HomeScreen());
      case login:
        return MaterialPageRoute(builder: (context) => const LoginScreen());
      case signup:
        return MaterialPageRoute(builder: (context) => const SignUpScreen());
      case sellBook:
        return MaterialPageRoute(builder: (context) => const SellBookScreen());
      case manageBooks:
        return MaterialPageRoute(builder: (context) => const ManageBooksScreen());
      case editBook:
        final book = settings.arguments as Book?;
        return MaterialPageRoute(
          builder: (context) => EditBookScreen(book: book),
        );
      default:
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
