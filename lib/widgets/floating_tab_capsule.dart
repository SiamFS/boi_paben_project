import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';
import '../views/blog_screen.dart';

class FloatingTabCapsule extends StatefulWidget {
  final Widget homeWidget;
  final int initialTabIndex;

  const FloatingTabCapsule({
    super.key, 
    required this.homeWidget,
    this.initialTabIndex = 0,
  });

  @override
  State<FloatingTabCapsule> createState() => _FloatingTabCapsuleState();
}

class _FloatingTabCapsuleState extends State<FloatingTabCapsule>
    with SingleTickerProviderStateMixin {
  late int _selectedIndex;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTabIndex;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTabSelected(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
      _animationController.forward(from: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main content
          AnimatedBuilder(
            animation: _slideAnimation,
            builder: (context, child) {
              return IndexedStack(
                index: _selectedIndex,
                children: [
                  widget.homeWidget,
                  const BlogScreen(),
                ],
              );
            },
          ),
          
          // Floating tab capsule
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: _buildFloatingCapsule(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingCapsule() {
    return Container(
      height: 56,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkGray.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: AppColors.darkGray.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTabItem(
            index: 0,
            icon: Icons.home_rounded,
            label: 'Home',
            isSelected: _selectedIndex == 0,
          ),
          _buildTabItem(
            index: 1,
            icon: Icons.article_rounded,
            label: 'Blog',
            isSelected: _selectedIndex == 1,
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem({
    required int index,
    required IconData icon,
    required String label,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => _onTabSelected(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryOrange : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                icon,
                key: ValueKey('$index-$isSelected'),
                color: isSelected ? AppColors.white : AppColors.textGray,
                size: 20,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    color: AppColors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Wrapper widget to replace the home screen in your main app
class HomeWithBlogTabs extends StatelessWidget {
  final Widget homeScreen;
  final int initialTabIndex;

  const HomeWithBlogTabs({
    super.key, 
    required this.homeScreen,
    this.initialTabIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingTabCapsule(
      homeWidget: homeScreen,
      initialTabIndex: initialTabIndex,
    );
  }
}
