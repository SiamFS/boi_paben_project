import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book_model.dart';
import '../models/cart_model.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/cart_viewmodel.dart';
import '../utils/app_theme.dart';
import '../utils/routes.dart';

class BookCartButton extends StatelessWidget {
  final Book book;

  const BookCartButton({
    super.key,
    required this.book,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 8,
      right: 8,
      child: Consumer<AuthViewModel>(
        builder: (context, auth, child) {
          // Don't show cart button if user is the seller of this book
          if (auth.user?.email == book.email) {
            return SizedBox.shrink();
          }
          
          return Consumer<CartViewModel>(
            builder: (context, cart, child) {
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: () async {
                    if (!auth.isAuthenticated) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please log in to add items to cart'),
                          backgroundColor: AppColors.red,
                        ),
                      );
                      Navigator.pushNamed(context, AppRoutes.login);
                      return;
                    }
                    
                    // Check if user is trying to buy their own book
                    if (book.email == auth.user?.email) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('You cannot buy your own book'),
                          backgroundColor: AppColors.red,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      return;
                    }
                    
                    // Check if book is already in cart
                    final isAlreadyInCart = cart.cartItems.any((item) => item.bookId == book.id);
                    
                    if (isAlreadyInCart) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Book "${book.bookTitle}" is already in your cart'),
                          backgroundColor: AppColors.primaryOrange,
                        ),
                      );
                      return;
                    }
                    
                    // Create CartItem and add to cart
                    final cartItem = CartItem(
                      id: '', // Will be set by Firestore
                      bookId: book.id ?? '',
                      bookTitle: book.bookTitle,
                      authorName: book.authorName,
                      category: book.category,
                      price: double.tryParse(book.price) ?? 0.0,
                      imageUrl: book.imageURL,
                      description: book.bookDescription,
                      userId: auth.user?.uid ?? '',
                      addedAt: DateTime.now(),
                      quantity: 1,
                    );
                    
                    final success = await cart.addToCart(cartItem);
                    
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Added "${book.bookTitle}" to cart'),
                          backgroundColor: AppColors.green,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to add item to cart'),
                          backgroundColor: AppColors.red,
                        ),
                      );
                    }
                  },
                  icon: Icon(
                    Icons.add_shopping_cart,
                    color: AppColors.primaryOrange,
                    size: 20,
                  ),
                  constraints: BoxConstraints.tightFor(
                    width: 36,
                    height: 36,
                  ),
                  padding: EdgeInsets.zero,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
