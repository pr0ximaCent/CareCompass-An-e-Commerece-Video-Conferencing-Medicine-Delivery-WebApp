import 'dart:convert';

import 'package:carecompass/common/service/notification_service.dart';
import 'package:carecompass/common/widgets/bottom_bar.dart';
import 'package:carecompass/constants/error_handling.dart';
import 'package:carecompass/constants/global_variables.dart';
import 'package:carecompass/constants/utils.dart';
import 'package:carecompass/features/admin/screens/admin_screen.dart';
import 'package:carecompass/models/user.dart';
import 'package:carecompass/providers/socket_provider.dart';
import 'package:carecompass/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // sign up user
  void signUpUser({
    required BuildContext context,
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      User user = User(
        id: '',
        name: name,
        password: password,
        email: email,
        address: '',
        type: UserType.USER,
        token: '',
        balance: 0,
        cart: [],
      );

      http.Response res = await http.post(
        Uri.parse('$uri/api/signup'),
        body: user.toJson(),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          showSnackBar(
            context,
            'Account created! Login with the same credentials!',
          );
        },
      );
    } catch (e) {
      print(e.toString());
      showSnackBar(context, e.toString());
    }
  }

  // sign in user
  void signInUser({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    try {
      http.Response res = await http.post(
        Uri.parse('$uri/api/signin'),
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      // print(res.body);
      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () async {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          Provider.of<UserProvider>(context, listen: false).setUser(res.body);
          await prefs.setString('x-auth-token', jsonDecode(res.body)['token']);
          // TODO: init after login
          Provider.of<SocketIOProvider>(context, listen: false).initSocket(
              Provider.of<UserProvider>(context, listen: false).user.id);
          LocalNotificationService().init();
          // showNotificationAndroid("TESTing", "FIguring out");
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) {
              // print(jsonDecode(res.body)['type']);
              // print(jsonDecode(res.body)['type'].runtimeType);
              // print(UserType.ADMIN.index);
              // print(UserType.ADMIN.index.runtimeType);
              // print(jsonDecode(res.body)['type'] == UserType.ADMIN.index);
              return (jsonDecode(res.body)['type'] == UserType.ADMIN.index)
                  ? const AdminScreen()
                  : const BottomBar();
            }),
          );
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  // get user data
  void getUserData(
    BuildContext context,
  ) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('x-auth-token');

      if (token == null) {
        prefs.setString('x-auth-token', '');
      }

      var tokenRes = await http.post(
        Uri.parse('$uri/tokenIsValid'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token!
        },
      );

      var response = jsonDecode(tokenRes.body);

      if (response == true) {
        http.Response userRes = await http.get(
          Uri.parse('$uri/'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'x-auth-token': token
          },
        );

        var userProvider = Provider.of<UserProvider>(context, listen: false);
        userProvider.setUser(userRes.body);
      }
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }
}
