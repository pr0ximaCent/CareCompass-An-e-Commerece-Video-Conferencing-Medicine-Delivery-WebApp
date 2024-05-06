import 'package:carecompass/constants/global_variables.dart';
import 'package:carecompass/constants/utils.dart';
import 'package:carecompass/features/account/screens/account_screen.dart';
import 'package:carecompass/features/home/screens/home_screen.dart';
import 'package:carecompass/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RechargeScreen extends StatefulWidget {
  const RechargeScreen({Key? key}) : super(key: key);

  @override
  _RechargeScreenState createState() => _RechargeScreenState();
}

class _RechargeScreenState extends State<RechargeScreen> {
  final TextEditingController amountController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Amount is required';
    }
    if (int.tryParse(value) == null) {
      return 'Amount should be a number';
    }
    if (int.parse(value) < 0) {
      return 'Amount should be positive';
    }
    return null;
  }

  Future<void> recharge(BuildContext context, String _id) async {
    if (_formKey.currentState!.validate()) {
      // Perform the recharge logic here.
      // You can use userIdController.text and amountController.text
      // to get the user_id and amount.
      // Replace this with your actual recharge processing code.
      final String userId = _id;
      final int amount = int.parse(amountController.text);
      await addBalance(context, userId, amount);

      // Send a request to your backend API to add balance.
      // You can use a package like http to make the request.
      // Example: http.post('/admin/add_balance', body: {'user_id': userId, 'amount': amount});
    }
  }

  @override
  void dispose() {
    super.dispose();
    amountController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text('Recharge'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(userProvider.user.email),
              TextFormField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Amount',
                  hintText: 'Enter recharge amount',
                ),
                validator: validateAmount,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  recharge(context, userProvider.user.id);
                },
                child: Text('Recharge Now'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// For encoding JSON

// Function to add balance to a user's account
Future<Map<String, dynamic>> addBalance(
    BuildContext context, String userId, int amount) async {
  // Replace this with your actual endpoint URL
  final String apiUrl = '$uri/admin/add_balance';

  final Map<String, dynamic> requestBody = {
    'user_id': userId,
    'amount': amount,
  };

  try {
    // Send a POST request to the API
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'x-auth-token':
            Provider.of<UserProvider>(context, listen: false).user.token
      },
      body: jsonEncode(requestBody),
    );

    // Check if the request was successful (status code 200)
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      userProvider.setUser(userProvider.user
          .copyWith(balance: amount + userProvider.user.balance)
          .toJson());

      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => AccountScreen()));
      return responseData;
    } else {
      // Handle API errors here
      showSnackBar(context,
          "Failed to add balance. Status code: ${response.statusCode}'");
      throw Exception(
          'Failed to add balance. Status code: ${response.statusCode}');
    }
  } catch (e) {
    showSnackBar(context, 'Failed to add balance: $e');
    // Handle network errors or exceptions
    throw Exception('Failed to add balance: $e');
  }
}
