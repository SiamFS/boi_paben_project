class Book {
  final String? id;
  final String bookTitle;
  final String authorName;
  final String imageURL;
  final String category;
  final String price;
  final String bookDescription;
  final String? email;
  final String? publisher;
  final String? edition;
  final String streetAddress;
  final String cityTown;
  final String district;
  final String zipCode;
  final String contactNumber;
  final String authenticity;
  final String productCondition;
  final String? availability;
  final String? seller;

  Book({
    this.id,
    required this.bookTitle,
    required this.authorName,
    required this.imageURL,
    required this.category,
    required this.price,
    required this.bookDescription,
    this.email,
    this.publisher,
    this.edition,
    required this.streetAddress,
    required this.cityTown,
    required this.district,
    required this.zipCode,
    required this.contactNumber,
    required this.authenticity,
    required this.productCondition,
    this.availability,
    this.seller,
  });

  Map<String, dynamic> toJson() {
    return {
      'bookTitle': bookTitle,
      'authorName': authorName,
      'imageURL': imageURL,
      'category': category,
      'Price': price,
      'bookDescription': bookDescription,
      'email': email,
      'publisher': publisher,
      'edition': edition,
      'streetAddress': streetAddress,
      'cityTown': cityTown,
      'district': district,
      'zipCode': zipCode,
      'contactNumber': contactNumber,
      'authenticity': authenticity,
      'productCondition': productCondition,
      'availability': availability,
      'seller': seller,
    };
  }

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['_id'],
      bookTitle: json['bookTitle'],
      authorName: json['authorName'],
      imageURL: json['imageURL'],
      category: json['category'],
      price: json['Price'],
      bookDescription: json['bookDescription'],
      email: json['email'],
      publisher: json['publisher'],
      edition: json['edition'],
      streetAddress: json['streetAddress'],
      cityTown: json['cityTown'],
      district: json['district'],
      zipCode: json['zipCode'],
      contactNumber: json['contactNumber'],
      authenticity: json['authenticity'],
      productCondition: json['productCondition'],
      availability: json['availability'],
      seller: json['seller'],
    );
  }
}
