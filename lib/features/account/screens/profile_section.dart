import 'package:carecompass/models/user.dart';
import 'package:carecompass/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileSection extends StatelessWidget {
  const ProfileSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            offset: Offset(0, 2),
            blurRadius: 4.0,
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            // Add your profile picture here
            radius: 30,
            backgroundColor: Colors.grey,
            // backgroundImage: AssetImage('path_to_your_image'),
          ),
          SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                 Provider.of<UserProvider>(context).user.name,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text("Email: " + Provider.of<UserProvider>(context).user.email),
              Text("Balance: " +
                  Provider.of<UserProvider>(context).user.balance.toString()),
              Text("Address: " +
                  Provider.of<UserProvider>(context).user.address),
            ],
          ),
        ],
      ),
    );
  }
}
