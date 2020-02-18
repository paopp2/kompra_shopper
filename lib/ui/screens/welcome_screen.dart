import 'package:flutter/material.dart';
import 'package:kompra_shopper/constants.dart';
import 'package:kompra_shopper/ui/components/rounded_button.dart';
import 'package:kompra_shopper/ui/screens/login_screen.dart';
import 'package:kompra_shopper/ui/screens/sign_up_screen.dart';

class WelcomeScreen extends StatelessWidget {
  static String id = 'welcome_screen';
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) =>
          Scaffold(
            backgroundColor: Colors.white,
            body: Stack(
              children: <Widget>[
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(80),
                    child: Hero(
                      tag: kKompraShopperWordLogoHeroTag,
                      child: kKompraShopperWordLogo,
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    RoundedButton(
                      text: kSignUpText,
                      onPressed: () {
                        Navigator.pushNamed(context, SignUpScreen.id);
                      },
                      colour: kAccentColor,
                    ),
                    RoundedButton(
                      text: kLoginText,
                      onPressed: () {
                        Navigator.pushNamed(context, LoginScreen.id);
                      },
                      colour: Colors.white,
                    ),
                    SizedBox(
                      height: constraints.maxHeight * (1/5),
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
  }
}