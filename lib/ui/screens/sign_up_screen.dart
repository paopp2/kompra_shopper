import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kompra_shopper/domain/models/shopper.dart';
import 'package:kompra_shopper/domain/firebase_tasks.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kompra_shopper/constants.dart';
import 'package:kompra_shopper/ui/components/floating_action_buttons.dart';
import 'package:kompra_shopper/ui/components/rounded_button.dart';
import 'package:kompra_shopper/ui/providers/providers.dart';
import 'package:kompra_shopper/ui/screens/pending_requests_screen.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

class SignUpScreen extends StatefulWidget {
  static String id = 'register_screen';
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {

  String _signupError;
  String email;
  String firstName;
  String lastName;
  String phoneNum;
  String password;
  String rePassword;
  bool isLoading;
  File _image;
  final _formKey = GlobalKey<FormState>();

  Future takePicture() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      _image = image;
    });
  }

  Future chooseFromGallery() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) =>
      ModalProgressHUD(
        inAsyncCall: isLoading ?? false,
        child: Scaffold(
          appBar: AppBar(
            iconTheme: IconThemeData(
              color: Colors.white, //change your color here
            ),
            title: Text(
              'Create an account',
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
                        child: kKompraShopperWordLogo,
                        tag: kKompraShopperWordLogoHeroTag,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            actions: <Widget>[
                              Column(
                                children: <Widget>[
                                  RoundedButton(
                                    text: Text(
                                      'Take a photo',
                                      style: TextStyle(
                                        color: Colors.white
                                      ),
                                    ),
                                    colour: kDarkerAccentColor,
                                    onPressed: () {
                                      takePicture();
                                      Navigator.pop(context);
                                    },
                                  ),
                                  RoundedButton(
                                    text: Text(
                                      'Select from gallery',
                                      style: TextStyle(
                                          color: Colors.white
                                      ),
                                    ),
                                    colour: kDarkerAccentColor,
                                    onPressed: () {
                                      chooseFromGallery();
                                      Navigator.pop(context);
                                    },
                                  )
                                ],
                              ),
                            ],
                          );
                        }
                      );
                    },
                    child: Center(
                      child: CircleAvatar(
                        backgroundColor: kDarkerAccentColor,
                        child: (_image == null) ? Center(
                          child: Icon(
                            Icons.add_a_photo,
                            size: constraints.maxHeight * 0.03,
                            color: Colors.white,
                          ),
                        ) : null,
                        backgroundImage: (_image == null) ? null :
                          FileImage(_image),
                        radius: constraints.maxHeight * 0.05,
                      ),
                    ),
                  ),
                  SizedBox(height: 7,),
                  Text(
                    (_image == null) ? 'Set a profile picture' : 'Looking great!',
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 28,),
                  TextFormField(
                    textCapitalization: TextCapitalization.words,
                    keyboardType: TextInputType.text,
                    onChanged: (value) {
                      firstName = value;
                    },
                    validator: (value) {
                      if (value.isEmpty ) {
                        return 'First name required';
                      }
                      return null;
                    },
                    decoration: kDefaultTextFieldFormDecoration.copyWith(
                      hintText: 'Enter your first name',
                      labelText: 'First Name',
                    ),
                  ),

                  SizedBox(height: 15),

                  TextFormField(
                    textCapitalization: TextCapitalization.words,
                    keyboardType: TextInputType.text,
                    onChanged: (value) {
                      lastName = value;
                    },
                    validator: (value) {
                      if (value.isEmpty ) {
                        return 'Last name required';
                      }
                      return null;
                    },
                    decoration: kDefaultTextFieldFormDecoration.copyWith(
                      hintText: 'Enter your last name',
                      labelText: 'Last Name',
                    ),
                  ),

                  SizedBox(height: 15),

                  TextFormField(
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      phoneNum = value;
                    },
                    validator: (value) {
                      if (value.isEmpty ) {
                        return 'Phone number required';
                      }
                      return null;
                    },
                    decoration: kDefaultTextFieldFormDecoration.copyWith(
                      hintText: 'Enter phone number',
                      labelText: 'Phone Number',
                    ),
                  ),

                  SizedBox(height: 15),

                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (value) {
                      if (_signupError != null) {
                        setState(() {
                          _signupError = null;
                        });
                      }
                      email = value;
                    },
                    validator: (value) {
                      if (value.isEmpty ) {
                        return 'Email required';
                      } else if (_signupError == 'ERROR_EMAIL_ALREADY_IN_USE') {
                        return 'This email is already being used';
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
                      password = value;
                    },
                    validator: (value) {
                      if (value.isEmpty ) {
                        return 'Password required';
                      } else if(value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                    decoration: kDefaultTextFieldFormDecoration.copyWith(
                      hintText: 'Enter password',
                      labelText: 'Password',
                    ),
                  ),

                  SizedBox(height: 15),

                  TextFormField(
                    keyboardType: TextInputType.text,
                    obscureText: true,
                    onChanged: (value) {
                      rePassword = value;
                    },
                    validator: (value) {
                      if (value.isEmpty ) {
                        return 'Please re-enter password';
                      } else if(value != password) {
                        return 'Passwords does not match';
                      } else if(value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                    decoration: kDefaultTextFieldFormDecoration.copyWith(
                      hintText: 'Re-enter password',
                      labelText: 'Re-enter Password',
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
                List result = List(2);
                if(_image == null) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        actions: <Widget>[
                          FlatButton(
                            child: Text(
                              'OK',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ],
                        title: Text(
                          'Please set a profile picture',
                          style: TextStyle(
                            color: Colors.white
                          ),
                        ),
                        backgroundColor: kDarkerAccentColor,
                      );
                    }
                  );
                } else {
                  try {
                    setState(() {isLoading = true;});
                    result = await FirebaseTasks.createNewUserWithEmailAndPass(
                        email: email,
                        password: password,
                        name: ('$firstName $lastName'),
                        phoneNum: phoneNum,
                        file: _image,
                        filename: email,
                    );
                  } on PlatformException catch (error) {
                    print('Sign up error: ${error.message}');
                    _formKey.currentState.setState(() {
                      isLoading = false;
                      _signupError = error.code;
                      _formKey.currentState.validate();
                    });
                  }
                  if(result[0] != null) {
                    setState(() {isLoading = false;});
                    FirebaseUser user = await FirebaseTasks.getCurrentUser();
                    print(user.email);
                    Provider.of<CurrentUser>(context, listen: false).shopper =
                        Shopper(
                          shopperEmail: email,
                          shopperName: ('$firstName $lastName'),
                          shopperPhoneNum: phoneNum,
                          shopperImageUrl: result[1],
                        );
                    print('url: ${result[1]}');
                    print('Current user: ${Provider.of<CurrentUser>(context, listen: false).shopper.shopperEmail}');
                    Navigator.of(context).pushNamed(PendingRequestsScreen.id);
                  }
                }
              }
            },
          ),
        ),
      ),
    );
  }
}
