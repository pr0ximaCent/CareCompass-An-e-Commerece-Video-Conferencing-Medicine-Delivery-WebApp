import 'dart:convert';
import 'dart:ffi';

enum UserType {
  USER,
  ADMIN,
  DOCTOR,
}

class User {
  final String id;
  final String name;
  final String email;
  final String password;
  final String address;
  final UserType type;
  final String token;
  final int balance;
  final List<dynamic> cart;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.address,
    required this.type,
    required this.token,
    required this.cart,
    required this.balance,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'address': address,
      'type': type.index,
      'token': token,
      'cart': cart,
      'balance': balance,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['_id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      address: map['address'] ?? '',
      type: convertStringToUserType(map['type']),
      token: map['token'] ?? '',
      balance: map['balance'] ?? 0.0,
      cart: List<Map<String, dynamic>>.from(
        map['cart']?.map(
          (x) => Map<String, dynamic>.from(x),
        ),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) => User.fromMap(json.decode(source));

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? password,
    String? address,
    UserType? type,
    String? token,
    int? balance,
    List<dynamic>? cart,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      address: address ?? this.address,
      type: type ?? this.type,
      token: token ?? this.token,
      cart: cart ?? this.cart,
      balance: balance ?? this.balance,
    );
  }
}

UserType convertStringToUserType(int userTypeString) {
  switch (userTypeString) {
    case 0:
      return UserType.USER;
    case 1:
      return UserType.ADMIN;
    case 2:
      return UserType.DOCTOR;
    default:
      throw Exception('Invalid user type string: $userTypeString');
  }
}
