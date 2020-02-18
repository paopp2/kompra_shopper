import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kompra_shopper/domain/firebase_tasks.dart';
import 'package:kompra_shopper/ui/screens/grocery_list_screen.dart';
import 'package:kompra_shopper/ui/screens/loading_screen.dart';
import 'constants.dart';
import 'package:kompra_shopper/ui/screens/awaiting_client_screen.dart';
import 'package:kompra_shopper/ui/screens/goto_client_screen.dart';
import 'package:kompra_shopper/ui/screens/login_screen.dart';
import 'package:kompra_shopper/ui/screens/pending_requests_screen.dart';
import 'package:kompra_shopper/ui/screens/sign_up_screen.dart';
import 'package:kompra_shopper/ui/screens/welcome_screen.dart';
import 'package:provider/provider.dart';
import 'package:kompra_shopper/ui/providers/providers.dart';
import 'package:location/location.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<CurrentUser>(create: (context) => CurrentUser(),),
        ChangeNotifierProvider<AcceptedTransaction>(create: (context) => AcceptedTransaction(),),
        StreamProvider<QuerySnapshot>.value(
          value: FirebaseTasks.getPendingTransactionsStream(),
        ),
      ],
      child:MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  String initialRoute;

  Future<void> getInitialRoute() {
    FirebaseTasks.getCurrentUser().then((firebaseUser) {
      setState(() {
        if (firebaseUser == null) {
          //signed out
          initialRoute = WelcomeScreen.id;
        } else {
          //signed in
          initialRoute = PendingRequestsScreen.id;
          FirebaseTasks.getShopper(email: firebaseUser.email).then((shopper) {
            Provider.of<CurrentUser>(context, listen: false).shopper = shopper;
            print('1: ${Provider.of<CurrentUser>(context, listen: false).shopper.shopperImageUrl}');
            print('Current user: ${Provider.of<CurrentUser>(context, listen: false).shopper.shopperEmail}');
          });
        }
      });
    });
    return null;
  }

  void checkIfLocationEnabled () async {
    Location locationService = Location();
    bool isEnabled = await locationService.serviceEnabled();
    if (!isEnabled) {
      locationService.requestService();
    }
  }

  @override
  void initState() {
    super.initState();
    getInitialRoute();
    checkIfLocationEnabled();
  }

  @override
  Widget build(BuildContext context) {
    return (initialRoute == null) ? LoadingScreen() : MaterialApp(
      title: 'Kompra Shopper',
      theme: ThemeData(
        primaryColor: kPrimaryColor,
      ),
      initialRoute: initialRoute,
//      initialRoute: SignUpScreen.id,
//      initialRoute: GroceryListScreen.id,
//      initialRoute: WelcomeScreen.id,
//      initialRoute: RegisterScreen.id,
//      initialRoute: AwaitingClientResponse.id,
//      initialRoute: PendingRequestsScreen.id,
//      initialRoute: GotoClientScreen.id,
      routes: {
        WelcomeScreen.id : (context) => WelcomeScreen(),
        LoginScreen.id : (context) => LoginScreen(),
        SignUpScreen.id : (context) => SignUpScreen(),
        AwaitingClientResponse.id : (context) => AwaitingClientResponse(),
        PendingRequestsScreen.id : (context) => PendingRequestsScreen(),
        GotoClientScreen.id : (context) => GotoClientScreen(),
        LoadingScreen.id : (context) => LoadingScreen(),
        GroceryListScreen.id : (context) => GroceryListScreen(),
      },
    );
  }
}