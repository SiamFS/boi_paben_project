class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String? photoURL;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoURL,
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      photoURL: map['photoURL'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }
}
