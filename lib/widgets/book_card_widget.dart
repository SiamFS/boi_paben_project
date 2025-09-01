import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/book_model.dart';
import '../models/cart_model.dart';
import '../utils/app_theme.dart';
import '../widgets/book_details_modal.dart';
import 'book_cart_button.dart';

class BookCardWidget extends StatelessWidget {
  final Book? book;
  final CartItem? cartItem;
  final bool showCartButton;
  final VoidCallback? onRemove;

  const BookCardWidget({
    super.key,
    this.book,
    this.cartItem,
    this.showCartButton = true,
    this.onRemove,
  }) : assert(book != null || cartItem != null, 'Either book or cartItem must be provided');

  @override
  Widget build(BuildContext context) {
    final String title = book?.bookTitle ?? cartItem!.bookTitle;
    final String author = book?.authorName ?? cartItem!.authorName;
    final String category = book?.category ?? cartItem!.category;
    final String price = book?.price ?? cartItem!.price.toString();
    final String imageUrl = book?.imageURL ?? cartItem!.imageUrl;

    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                GestureDetector(
                  onTap: book != null 
                    ? () => BookDetailsModal.show(context, book!)
                    : null,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(color: AppColors.lightGray),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.broken_image, size: 50),
                    ),
                  ),
                ),
                if (book != null && showCartButton)
                  BookCartButton(book: book!),
                if (cartItem != null && onRemove != null)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
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
                        onPressed: onRemove,
                        icon: Icon(
                          Icons.remove_shopping_cart,
                          color: AppColors.red,
                          size: 20,
                        ),
                        constraints: BoxConstraints.tightFor(
                          width: 36,
                          height: 36,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _truncateText(title, 18),
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _truncateText('by $author', 18),
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: AppColors.textGray,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primaryOrange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _truncateText(category, 12),
                      style: GoogleFonts.poppins(
                        fontSize: 9,
                        color: AppColors.primaryOrange,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _truncateText('৳$price', 10),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryOrange,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }
}
