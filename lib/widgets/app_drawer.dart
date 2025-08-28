import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../utils/app_theme.dart';
import '../utils/routes.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
        return Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(
                  color: AppColors.primaryOrange,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BoiPaben',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (authViewModel.isAuthenticated)
                      Text(
                        'Welcome, ${authViewModel.user?.email ?? 'User'}',
                        style: GoogleFonts.poppins(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 14,
                        ),
                      )
                    else
                      Text(
                        'Please log in to access all features',
                        style: GoogleFonts.poppins(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 14,
                        ),
                      ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home_outlined),
                title: Text('Home', style: GoogleFonts.poppins()),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.home,
                    (route) => false,
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.storefront_outlined),
                title: Text('Shop', style: GoogleFonts.poppins()),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, AppRoutes.shop);
                },
              ),
              ListTile(
                leading: const Icon(Icons.article_outlined),
                title: Text('Book Blog Community', style: GoogleFonts.poppins()),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, AppRoutes.blog);
                },
              ),
              ListTile(
                leading: const Icon(Icons.sell_outlined),
                title: Text('Sell Your Books', style: GoogleFonts.poppins()),
                onTap: () {
                  Navigator.pop(context);
                  if (authViewModel.isAuthenticated) {
                    Navigator.pushNamed(context, AppRoutes.sellBook);
                  } else {
                    _showLoginRequired(context);
                  }
                },
              ),
              if (authViewModel.isAuthenticated)
                ListTile(
                  leading: const Icon(Icons.library_books_outlined),
                  title: Text('Manage Books', style: GoogleFonts.poppins()),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRoutes.manageBooks);
                  },
                ),
              const Divider(),
              if (authViewModel.isAuthenticated)
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: Text('Logout', style: GoogleFonts.poppins()),
                  onTap: () {
                    Navigator.pop(context);
                    _showLogoutDialog(context, authViewModel);
                  },
                )
              else
                ListTile(
                  leading: const Icon(Icons.login),
                  title: Text('Login', style: GoogleFonts.poppins()),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRoutes.login);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  void _showLoginRequired(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please log in to sell books.'),
        backgroundColor: AppColors.red,
      ),
    );
    Navigator.pushNamed(context, AppRoutes.login);
  }

  void _showLogoutDialog(BuildContext context, AuthViewModel authViewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout', style: GoogleFonts.poppins()),
        content: Text(
          'Are you sure you want to logout?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              authViewModel.signOut();
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.home,
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Logout', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }
}
