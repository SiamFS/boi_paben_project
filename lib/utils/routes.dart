import 'package:flutter/material.dart';
import '../views/home_screen.dart';
import '../views/login_screen.dart';
import '../views/signup_screen.dart';
import '../views/sell_book_screen.dart';
import '../views/manage_books_screen.dart';
import '../views/edit_book_screen.dart';
import '../views/create_post_screen.dart';
import '../views/cart_screen.dart';
import '../views/shop_screen.dart';
import '../widgets/floating_tab_capsule.dart';
import '../models/book_model.dart';

class AppRoutes {
  static const String home = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String sellBook = '/sell-book';
  static const String manageBooks = '/manage-books';
  static const String editBook = '/edit-book';
  static const String blog = '/blog';
  static const String createPost = '/create-post';
  static const String cart = '/cart';
  static const String shop = '/shop';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      home: (context) => HomeWithBlogTabs(homeScreen: const HomeScreen()),
      login: (context) => const LoginScreen(),
      signup: (context) => const SignUpScreen(),
      sellBook: (context) => const SellBookScreen(),
      manageBooks: (context) => const ManageBooksScreen(),
      blog: (context) => HomeWithBlogTabs(homeScreen: const HomeScreen(), initialTabIndex: 1),
      createPost: (context) => const CreatePostScreen(),
    };
  }

  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (context) => HomeWithBlogTabs(homeScreen: const HomeScreen()));
      case login:
        return MaterialPageRoute(builder: (context) => const LoginScreen());
      case signup:
        return MaterialPageRoute(builder: (context) => const SignUpScreen());
      case sellBook:
        return MaterialPageRoute(builder: (context) => const SellBookScreen());
      case manageBooks:
        return MaterialPageRoute(builder: (context) => const ManageBooksScreen());
      case blog:
        return MaterialPageRoute(builder: (context) => HomeWithBlogTabs(homeScreen: const HomeScreen(), initialTabIndex: 1));
      case createPost:
        return MaterialPageRoute(builder: (context) => const CreatePostScreen());
      case cart:
        return MaterialPageRoute(builder: (context) => const CartScreen());
      case shop:
        return MaterialPageRoute(builder: (context) => const ShopScreen());
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
