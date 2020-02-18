import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kompra_shopper/constants.dart';
import 'package:kompra_shopper/domain/firebase_tasks.dart';
import 'package:kompra_shopper/ui/components/floating_action_buttons.dart';
import 'package:kompra_shopper/ui/providers/providers.dart';
import 'package:kompra_shopper/ui/screens/pending_requests_screen.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  static String id = 'login_screen';
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  String email;
  String password;
  String _loginError;
  bool isLoading;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) =>
          ModalProgressHUD(
            inAsyncCall: isLoading ?? false,
            child: Scaffold(
              appBar: AppBar(
                title: Text(
                  'Login to account',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                backgroundColor: kAccentColor,
              ),
              body: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 50,
                    horizontal: 25,
                  ),
                  child: ListView(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 20
                        ),
                        child: SizedBox(
                          height: 50,
                          child: Hero(
                            tag: kKompraShopperWordLogoHeroTag,
                            child: kKompraShopperWordLogo,
                          ),
                        ),
                      ),
                      TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (value) {
                          if (_loginError != null) {
                            setState(() {
                              _loginError = null;
                            });
                          }
                          email = value;
                        },
                        validator: (value) {
                          if (value.isEmpty ) {
                            return 'Email required';
                          } else if (_loginError == 'ERROR_INVALID_EMAIL' || _loginError == 'ERROR_USER_NOT_FOUND') {
                            return 'Invalid email';
                          }
                          return null;
                        },
                        decoration: kDefaultTextFieldFormDecoration.copyWith(
                          hintText: 'Enter your email',
                          labelText: 'Email',
                        ),
                      ),

                      SizedBox(height: 15),


                      TextFormField(
                        keyboardType: TextInputType.text,
                        obscureText: true,
                        onChanged: (value) {
                          if (_loginError != null) {
                            setState(() {
                              _loginError = null;
                            });
                          }
                          password = value;
                        },
                        validator: (value) {
                          if (value.isEmpty ) {
                            return 'Password required';
                          } else if(value.length < 6) {
                            return 'Password must be at least 6 characters';
                          } else if (_loginError == 'ERROR_WRONG_PASSWORD') {
                            return 'Invalid password';
                          }
                          return null;
                        },
                        decoration: kDefaultTextFieldFormDecoration.copyWith(
                          hintText: 'Enter password',
                          labelText: 'Password',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              floatingActionButton: DefaultFAB(
                icon: Icons.arrow_forward,
                onPressed: () async {
                  if (_formKey.currentState.validate()) {
                    print(email);
                    print(password);
                    AuthResult existingUser;
                    try {
                      setState(() {isLoading = true;});
                      existingUser = await FirebaseTasks.logInUserWithEmailAndPass(
                        email: email,
                        password: password,
                      );
                    } on PlatformException catch (error) {
                      print('Log in error: ${error.code}');
                      _formKey.currentState.setState(() {
                        isLoading = false;
                        _loginError = error.code;
                        _formKey.currentState.validate();
                      });
                    }
                    if(existingUser != null) {
                      setState(() {isLoading = false;});
                      Navigator.of(context).pushNamed(PendingRequestsScreen.id);
                      await FirebaseTasks.getShopper(email: email).then((shopper) {
                        Provider.of<CurrentUser>(context, listen: false).shopper = shopper;
                        print('Current user: ${Provider.of<CurrentUser>(context, listen: false).shopper.shopperEmail}');
                      });
                    }
                  }
                },
              ),
            ),
          ),
    );
  }
}
