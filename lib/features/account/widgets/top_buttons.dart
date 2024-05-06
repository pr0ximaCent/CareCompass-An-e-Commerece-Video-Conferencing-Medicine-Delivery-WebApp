import 'package:carecompass/features/account/services/account_services.dart';
import 'package:carecompass/features/account/widgets/account_button.dart';
import 'package:carecompass/features/account/screens/recharge.dart';
import 'package:flutter/material.dart';

class TopButtons extends StatelessWidget {
  const TopButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            AccountButton(
              text: 'Your Orders',
              onTap: () {},
            ),
            AccountButton(
              text: 'Log Out',
              onTap: () => AccountServices().logOut(context),
            ),
            AccountButton(
                text: 'Recharge',
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => RechargeScreen()));
                })
          ],
        ),
      ],
    );
  }
}
