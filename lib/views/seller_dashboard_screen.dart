import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/payment_model.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../services/payment_service.dart';
import '../utils/app_theme.dart';

class SellerDashboardScreen extends StatelessWidget {
  const SellerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Seller Dashboard',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primaryOrange,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      body: Consumer<AuthViewModel>(
        builder: (context, auth, child) {
          if (!auth.isAuthenticated) {
            return _buildNotLoggedIn(context);
          }

          return FutureBuilder<SalesData>(
            future: PaymentService().getSellerSalesData(auth.user!.email),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return _buildError();
              }

              final salesData = snapshot.data ?? SalesData(
                sellerId: '',
                sellerEmail: auth.user!.email,
                soldBooks: [],
                totalEarnings: 0,
                totalBooksSold: 0,
              );

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatsCards(salesData),
                    const SizedBox(height: 24),
                    _buildSoldBooksList(salesData.soldBooks),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildNotLoggedIn(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.login,
            size: 64,
            color: AppColors.textGray,
          ),
          const SizedBox(height: 16),
          Text(
            'Please log in to view dashboard',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textGray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load dashboard data',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(SalesData salesData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sales Overview',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Total Earnings',
                value: '৳${salesData.totalEarnings.toStringAsFixed(0)}',
                icon: Icons.attach_money,
                color: AppColors.green,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                title: 'Books Sold',
                value: '${salesData.totalBooksSold}',
                icon: Icons.book,
                color: AppColors.primaryOrange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Average Price',
                value: salesData.totalBooksSold > 0 
                    ? '৳${(salesData.totalEarnings / salesData.totalBooksSold).toStringAsFixed(0)}'
                    : '৳0',
                icon: Icons.trending_up,
                color: AppColors.primaryOrange,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                title: 'This Month',
                value: '${_getThisMonthSales(salesData.soldBooks)}',
                icon: Icons.calendar_month,
                color: AppColors.green,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.textGray,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSoldBooksList(List<SoldBook> soldBooks) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sold Books',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        if (soldBooks.isEmpty)
          _buildEmptyState()
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: soldBooks.length,
            itemBuilder: (context, index) {
              final book = soldBooks[index];
              return _buildSoldBookCard(book);
            },
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.book_outlined,
              size: 48,
              color: AppColors.textGray,
            ),
            const SizedBox(height: 16),
            Text(
              'No books sold yet',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textGray,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your sold books will appear here',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.textGray,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSoldBookCard(SoldBook book) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Book Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                book.imageUrl,
                width: 60,
                height: 75,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 60,
                  height: 75,
                  color: AppColors.lightGray,
                  child: const Icon(Icons.broken_image),
                ),
              ),
            ),
            const SizedBox(width: 16),
            
            // Book Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.bookTitle,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'by ${book.authorName}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.textGray,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Sale info
                  Row(
                    children: [
                      Icon(Icons.person, size: 16, color: AppColors.textGray),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Sold to: ${book.buyerEmail}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.textGray,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: AppColors.textGray),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(book.soldAt),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.textGray,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Price and Status
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '৳${book.salePrice.toStringAsFixed(0)}',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.green,
                  ),
                ),
                const SizedBox(height: 8),
                _buildStatusChip(book.status),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    IconData icon;
    
    switch (status.toLowerCase()) {
      case 'processing':
        color = AppColors.primaryOrange;
        icon = Icons.autorenew;
        break;
      case 'delivered':
        color = AppColors.green;
        icon = Icons.check_circle;
        break;
      case 'cancelled':
        color = AppColors.red;
        icon = Icons.cancel;
        break;
      default:
        color = AppColors.textGray;
        icon = Icons.info;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 4),
          Text(
            status.substring(0, 1).toUpperCase() + status.substring(1),
            style: GoogleFonts.poppins(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  int _getThisMonthSales(List<SoldBook> soldBooks) {
    final now = DateTime.now();
    return soldBooks.where((book) => 
      book.soldAt.year == now.year && book.soldAt.month == now.month
    ).length;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
