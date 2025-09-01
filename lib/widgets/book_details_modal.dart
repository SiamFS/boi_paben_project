import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/book_model.dart';
import '../utils/app_theme.dart';

class BookDetailsModal extends StatelessWidget {
  final Book book;

  const BookDetailsModal({
    super.key,
    required this.book,
  });

  static void show(BuildContext context, Book book) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BookDetailsModal(book: book),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  'Book Details',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Book Image and Basic Info
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          book.imageURL,
                          width: 120,
                          height: 160,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 120,
                            height: 160,
                            color: Colors.grey[200],
                            child: const Icon(Icons.book, size: 50),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              book.bookTitle,
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'by ${book.authorName}',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: AppColors.textGray,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primaryOrange.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                book.category,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: AppColors.primaryOrange,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'TK${book.price}',
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryOrange,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Book Details Section
                  _buildInfoSection('Book Information', [
                    _buildInfoRow('Publisher', book.publisher ?? 'Not specified'),
                    _buildInfoRow('Edition', book.edition ?? 'Not specified'),
                    _buildInfoRow('Condition', book.productCondition),
                    _buildInfoRow('Authenticity', book.authenticity),
                    _buildInfoRow('Availability', book.availability ?? 'Available'),
                  ]),
                  
                  const SizedBox(height: 20),
                  
                  // Description
                  _buildInfoSection('Description', [
                    Text(
                      book.bookDescription.isNotEmpty ? book.bookDescription : 'No description available.',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ]),
                  
                  const SizedBox(height: 20),
                  
                  // Seller Info (Only name, no email)
                  _buildInfoSection('Seller Information', [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.lightGray.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppColors.primaryOrange,
                            child: Text(
                              (book.seller?.isNotEmpty == true) ? book.seller![0].toUpperCase() : 'S',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              book.seller ?? 'Unknown Seller',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textGray,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
