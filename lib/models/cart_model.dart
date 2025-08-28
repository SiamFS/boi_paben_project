class CartItem {
  final String id;
  final String bookId;
  final String bookTitle;
  final String authorName;
  final String category;
  final double price;
  final String imageUrl;
  final String description;
  final String userId;
  final DateTime addedAt;
  int quantity; // Made mutable for optimistic updates

  CartItem({
    required this.id,
    required this.bookId,
    required this.bookTitle,
    required this.authorName,
    required this.category,
    required this.price,
    required this.imageUrl,
    required this.description,
    required this.userId,
    required this.addedAt,
    this.quantity = 1,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] ?? '',
      bookId: json['bookId'] ?? '',
      bookTitle: json['bookTitle'] ?? '',
      authorName: json['authorName'] ?? '',
      category: json['category'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      imageUrl: json['imageUrl'] ?? '',
      description: json['description'] ?? '',
      userId: json['userId'] ?? '',
      addedAt: json['addedAt']?.toDate() ?? DateTime.now(),
      quantity: json['quantity'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookId': bookId,
      'bookTitle': bookTitle,
      'authorName': authorName,
      'category': category,
      'price': price,
      'imageUrl': imageUrl,
      'description': description,
      'userId': userId,
      'addedAt': addedAt,
      'quantity': quantity,
    };
  }

  CartItem copyWith({
    String? id,
    String? bookId,
    String? bookTitle,
    String? authorName,
    String? category,
    double? price,
    String? imageUrl,
    String? description,
    String? userId,
    DateTime? addedAt,
    int? quantity,
  }) {
    return CartItem(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      bookTitle: bookTitle ?? this.bookTitle,
      authorName: authorName ?? this.authorName,
      category: category ?? this.category,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      userId: userId ?? this.userId,
      addedAt: addedAt ?? this.addedAt,
      quantity: quantity ?? this.quantity,
    );
  }
}

class Order {
  final String id;
  final String userId;
  final List<CartItem> items;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final String deliveryAddress;
  final String city;
  final String paymentMethod;
  final String status;
  final DateTime orderDate;

  Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.deliveryAddress,
    required this.city,
    required this.paymentMethod,
    required this.status,
    required this.orderDate,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      items: (json['items'] as List<dynamic>?)
          ?.map((item) => CartItem.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      deliveryFee: (json['deliveryFee'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
      deliveryAddress: json['deliveryAddress'] ?? '',
      city: json['city'] ?? '',
      paymentMethod: json['paymentMethod'] ?? '',
      status: json['status'] ?? 'pending',
      orderDate: json['orderDate']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'total': total,
      'deliveryAddress': deliveryAddress,
      'city': city,
      'paymentMethod': paymentMethod,
      'status': status,
      'orderDate': orderDate,
    };
  }
}
