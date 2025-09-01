import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/cart_model.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/cart_viewmodel.dart';
import '../viewmodels/book_viewmodel.dart';
import '../services/payment_service.dart';
import '../utils/app_theme.dart';
import '../utils/routes.dart';
import '../utils/app_snackbar.dart';

class CODCheckoutScreen extends StatefulWidget {
  final List<CartItem> cartItems;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final String deliveryCity;

  const CODCheckoutScreen({
    super.key,
    required this.cartItems,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.deliveryCity,
  });

  @override
  State<CODCheckoutScreen> createState() => _CODCheckoutScreenState();
}

class _CODCheckoutScreenState extends State<CODCheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _paymentService = PaymentService();
  
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _districtController = TextEditingController();
  final _zipController = TextEditingController();
  final _notesController = TextEditingController();
  
  bool _isProcessing = false;
  Map<String, bool> _booksAvailability = {};

  @override
  void initState() {
    super.initState();
    _checkBooksAvailability();
  }

  Future<void> _checkBooksAvailability() async {
    final bookIds = widget.cartItems.map((item) => item.bookId).toList();
    final availability = await _paymentService.checkBooksAvailability(bookIds);
    setState(() {
      _booksAvailability = availability;
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthViewModel>(context);
    final cart = Provider.of<CartViewModel>(context);

    // Check if any books are unavailable
    final unavailableBooks = _booksAvailability.entries
        .where((entry) => !entry.value)
        .map((entry) => entry.key)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Cash on Delivery Checkout',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primaryOrange,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      body: _booksAvailability.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : unavailableBooks.isNotEmpty
              ? _buildUnavailableWarning(cart, unavailableBooks)
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildOrderSummary(),
                        const SizedBox(height: 24),
                        _buildDeliveryForm(),
                        const SizedBox(height: 24),
                        _buildPaymentInfo(),
                        const SizedBox(height: 32),
                        _buildPlaceOrderButton(auth, cart),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildUnavailableWarning(CartViewModel cart, List<String> unavailableBookIds) {
    final unavailableItems = widget.cartItems
        .where((item) => unavailableBookIds.contains(item.bookId))
        .toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: 64,
            color: AppColors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Some Books Are No Longer Available',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.red,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'The following books have been sold to other customers and are no longer available:',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.textGray,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          
          // List unavailable books
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.red.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: unavailableItems.map((item) => ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    item.imageUrl,
                    width: 50,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 50,
                      height: 60,
                      color: AppColors.lightGray,
                      child: const Icon(Icons.broken_image),
                    ),
                  ),
                ),
                title: Text(
                  item.bookTitle,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  'by ${item.authorName}',
                  style: GoogleFonts.poppins(fontSize: 12),
                ),
                trailing: Text(
                  '৳${item.price.toStringAsFixed(0)}',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: AppColors.red,
                  ),
                ),
              )).toList(),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.primaryOrange),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    'Go Back',
                    style: GoogleFonts.poppins(
                      color: AppColors.primaryOrange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    // Remove unavailable items from cart
                    final success = await _paymentService.removeUnavailableFromCart(
                      cart.cartItems.first.userId,
                      unavailableBookIds,
                    );
                    
                    if (success) {
                      // Refresh cart
                      final auth = Provider.of<AuthViewModel>(context, listen: false);
                      cart.loadCartItems(auth.user!.uid);
                      
                        
                        AppSnackBar.showSuccess(
                          context,
                          'Unavailable books removed from cart',
                        );                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryOrange,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    'Remove & Continue',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Summary',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            // Books list
            ...widget.cartItems.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item.imageUrl,
                      width: 50,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 50,
                        height: 60,
                        color: AppColors.lightGray,
                        child: const Icon(Icons.broken_image),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.bookTitle,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'by ${item.authorName}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.textGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '৳${item.price.toStringAsFixed(0)}',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryOrange,
                    ),
                  ),
                ],
              ),
            )).toList(),
            
            const Divider(),
            
            // Totals
            _buildSummaryRow('Subtotal', widget.subtotal),
            _buildSummaryRow('Delivery Fee', widget.deliveryFee),
            const Divider(),
            _buildSummaryRow('Total', widget.total, isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '৳${amount.toStringAsFixed(0)}',
            style: GoogleFonts.poppins(
              fontSize: isTotal ? 16 : 14,
              fontWeight: FontWeight.bold,
              color: isTotal ? AppColors.primaryOrange : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryForm() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Delivery Information',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Full Name *',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your full name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Phone Number *',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your phone number';
                }
                if (value.trim().length < 11) {
                  return 'Please enter a valid phone number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: 'Delivery Address *',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.location_on),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your delivery address';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _districtController,
                    decoration: InputDecoration(
                      labelText: 'District *',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter district';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _zipController,
                    decoration: InputDecoration(
                      labelText: 'ZIP Code',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: 'Special Instructions (Optional)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.note),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentInfo() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Method',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.green.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.money, color: AppColors.green),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cash on Delivery (COD)',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            color: AppColors.green,
                          ),
                        ),
                        Text(
                          'Pay ৳${widget.total.toStringAsFixed(0)} when your books are delivered',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.textGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.lightGray,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.textGray, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Your order will be processed and delivered within 2-5 business days.',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textGray,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceOrderButton(AuthViewModel auth, CartViewModel cart) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isProcessing ? null : () => _placeOrder(auth, cart),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryOrange,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 2,
        ),
        child: _isProcessing
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                'Place COD Order - ৳${widget.total.toStringAsFixed(0)}',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
      ),
    );
  }

  Future<void> _placeOrder(AuthViewModel auth, CartViewModel cart) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final paymentId = await _paymentService.processCODPayment(
        buyerId: auth.user!.uid,
        buyerEmail: auth.user!.email,
        buyerName: _nameController.text.trim(),
        buyerPhone: _phoneController.text.trim(),
        deliveryAddress: _addressController.text.trim(),
        city: widget.deliveryCity,
        district: _districtController.text.trim(),
        zipCode: _zipController.text.trim(),
        cartItems: widget.cartItems,
        subtotal: widget.subtotal,
        deliveryFee: widget.deliveryFee,
        total: widget.total,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );

      if (paymentId != null) {
        // Force refresh book data to reflect availability changes
        final bookViewModel = Provider.of<BookViewModel>(context, listen: false);
        await bookViewModel.forceRefresh();
        
        // Show success and navigate to order confirmation
        AppSnackBar.showSuccess(
          context,
          'Order placed successfully!',
        );

        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.home,
          (route) => false,
        );
      } else {
        throw Exception('Failed to process payment');
      }
    } catch (e) {
      AppSnackBar.showError(
        context,
        'Failed to place order. Please try again.',
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _districtController.dispose();
    _zipController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
