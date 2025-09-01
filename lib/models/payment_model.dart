class Payment {
  final String id;
  final String orderId;
  final String buyerId;
  final String buyerEmail;
  final String buyerName;
  final String buyerPhone;
  final String deliveryAddress;
  final String city;
  final String district;
  final String zipCode;
  final List<PaymentItem> items;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final String paymentMethod; // COD, Online, etc.
  final String status; // pending, processing, delivered, cancelled
  final DateTime createdAt;
  final DateTime? deliveredAt;
  final String? notes;

  Payment({
    required this.id,
    required this.orderId,
    required this.buyerId,
    required this.buyerEmail,
    required this.buyerName,
    required this.buyerPhone,
    required this.deliveryAddress,
    required this.city,
    required this.district,
    required this.zipCode,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
    this.deliveredAt,
    this.notes,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] ?? '',
      orderId: json['orderId'] ?? '',
      buyerId: json['buyerId'] ?? '',
      buyerEmail: json['buyerEmail'] ?? '',
      buyerName: json['buyerName'] ?? '',
      buyerPhone: json['buyerPhone'] ?? '',
      deliveryAddress: json['deliveryAddress'] ?? '',
      city: json['city'] ?? '',
      district: json['district'] ?? '',
      zipCode: json['zipCode'] ?? '',
      items: (json['items'] as List<dynamic>?)
          ?.map((item) => PaymentItem.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      deliveryFee: (json['deliveryFee'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
      paymentMethod: json['paymentMethod'] ?? 'COD',
      status: json['status'] ?? 'pending',
      createdAt: json['createdAt']?.toDate() ?? DateTime.now(),
      deliveredAt: json['deliveredAt']?.toDate(),
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'buyerId': buyerId,
      'buyerEmail': buyerEmail,
      'buyerName': buyerName,
      'buyerPhone': buyerPhone,
      'deliveryAddress': deliveryAddress,
      'city': city,
      'district': district,
      'zipCode': zipCode,
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'total': total,
      'paymentMethod': paymentMethod,
      'status': status,
      'createdAt': createdAt,
      'deliveredAt': deliveredAt,
      'notes': notes,
    };
  }

  Payment copyWith({
    String? status,
    DateTime? deliveredAt,
    String? notes,
  }) {
    return Payment(
      id: id,
      orderId: orderId,
      buyerId: buyerId,
      buyerEmail: buyerEmail,
      buyerName: buyerName,
      buyerPhone: buyerPhone,
      deliveryAddress: deliveryAddress,
      city: city,
      district: district,
      zipCode: zipCode,
      items: items,
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      total: total,
      paymentMethod: paymentMethod,
      status: status ?? this.status,
      createdAt: createdAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      notes: notes ?? this.notes,
    );
  }
}

class PaymentItem {
  final String bookId;
  final String bookTitle;
  final String authorName;
  final String imageUrl;
  final double price;
  final int quantity;
  final String sellerId;
  final String sellerEmail;

  PaymentItem({
    required this.bookId,
    required this.bookTitle,
    required this.authorName,
    required this.imageUrl,
    required this.price,
    required this.quantity,
    required this.sellerId,
    required this.sellerEmail,
  });

  factory PaymentItem.fromJson(Map<String, dynamic> json) {
    return PaymentItem(
      bookId: json['bookId'] ?? '',
      bookTitle: json['bookTitle'] ?? '',
      authorName: json['authorName'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 1,
      sellerId: json['sellerId'] ?? '',
      sellerEmail: json['sellerEmail'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookId': bookId,
      'bookTitle': bookTitle,
      'authorName': authorName,
      'imageUrl': imageUrl,
      'price': price,
      'quantity': quantity,
      'sellerId': sellerId,
      'sellerEmail': sellerEmail,
    };
  }
}

// Dashboard Sales Model for sellers
class SalesData {
  final String sellerId;
  final String sellerEmail;
  final List<SoldBook> soldBooks;
  final double totalEarnings;
  final int totalBooksSold;

  SalesData({
    required this.sellerId,
    required this.sellerEmail,
    required this.soldBooks,
    required this.totalEarnings,
    required this.totalBooksSold,
  });

  factory SalesData.fromSoldBooks(String sellerId, String sellerEmail, List<SoldBook> books) {
    double totalEarnings = books.fold(0, (sum, book) => sum + book.salePrice);
    int totalBooksSold = books.length;
    
    return SalesData(
      sellerId: sellerId,
      sellerEmail: sellerEmail,
      soldBooks: books,
      totalEarnings: totalEarnings,
      totalBooksSold: totalBooksSold,
    );
  }
}

class SoldBook {
  final String bookId;
  final String bookTitle;
  final String authorName;
  final String imageUrl;
  final double salePrice;
  final String buyerEmail;
  final DateTime soldAt;
  final String status;
  final String paymentId;

  SoldBook({
    required this.bookId,
    required this.bookTitle,
    required this.authorName,
    required this.imageUrl,
    required this.salePrice,
    required this.buyerEmail,
    required this.soldAt,
    required this.status,
    required this.paymentId,
  });

  factory SoldBook.fromJson(Map<String, dynamic> json) {
    return SoldBook(
      bookId: json['bookId'] ?? '',
      bookTitle: json['bookTitle'] ?? '',
      authorName: json['authorName'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      salePrice: (json['salePrice'] ?? 0).toDouble(),
      buyerEmail: json['buyerEmail'] ?? '',
      soldAt: json['soldAt']?.toDate() ?? DateTime.now(),
      status: json['status'] ?? 'processing',
      paymentId: json['paymentId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookId': bookId,
      'bookTitle': bookTitle,
      'authorName': authorName,
      'imageUrl': imageUrl,
      'salePrice': salePrice,
      'buyerEmail': buyerEmail,
      'soldAt': soldAt,
      'status': status,
      'paymentId': paymentId,
    };
  }
}
