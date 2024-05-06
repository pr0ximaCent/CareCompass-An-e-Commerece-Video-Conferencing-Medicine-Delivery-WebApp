import 'dart:convert';

import 'package:carecompass/constants/global_variables.dart';
import 'package:carecompass/models/user.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UserProvider extends ChangeNotifier {
  User _user = User(
    id: '',
    name: '',
    email: '',
    password: '',
    address: '',
    type: UserType.USER,
    token: '',
    balance: 0,
    cart: [],
  );

  User get user => _user;
  
  void setUser(String user) {
    _user = User.fromJson(user);
    notifyListeners();
  }

  void setUserFromModel(User user) {
    _user = user;
    notifyListeners();
  }

}
