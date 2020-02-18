import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kompra_shopper/domain/firebase_tasks.dart';
import 'package:kompra_shopper/domain/location.dart' as location;
import 'package:kompra_shopper/domain/models/transaction.dart' as my;
import 'package:kompra_shopper/domain/models/client.dart';
import 'package:flutter/material.dart';
import 'package:kompra_shopper/constants.dart';
import 'package:connectivity/connectivity.dart';
import 'package:kompra_shopper/ui/components/request_tile.dart';
import 'package:kompra_shopper/ui/providers/providers.dart';
import 'package:kompra_shopper/ui/screens/welcome_screen.dart';
import 'package:provider/provider.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kompra_shopper/domain/location.dart' as my;
import 'package:geoflutterfire/geoflutterfire.dart';

class PendingRequestsScreen extends StatefulWidget {
  static String id = 'pending_requests_screen';
  @override
  _PendingRequestsScreenState createState() => _PendingRequestsScreenState();
}

class _PendingRequestsScreenState extends State<PendingRequestsScreen> {
  my.LatLng shopperLocation;
  StreamSubscription<Position> positionStream;
  StreamSubscription connectivityStreamSubscription;
  ConnectivityResult connectionStatus;
  String shopperEmail;
  Geolocator geolocator = Geolocator();

  void _getLocation() async {
    var currentLocation = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    setState(() {
      LatLng temp = LatLng(currentLocation.latitude, currentLocation.longitude);
      shopperLocation = my.LatLng(
        lat: temp.latitude,
        lng: temp.longitude,
      );
      print(shopperLocation.lat);
    });
  }

  void checkIfThereIsInternet(ConnectivityResult result, Function onPressed) {
    if(result == ConnectivityResult.none) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('No internet connection'),
              actions: <Widget>[
                RaisedButton(
                  child: Text(
                    'Retry',
                  ),
                  onPressed: onPressed,
                ),
              ],
            );
          }
      );
    }
  }

  @override
  void initState() {
    super.initState();
    connectivityStreamSubscription =
        Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
          connectionStatus = result;
          if (connectionStatus == ConnectivityResult.none) {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('No internet connection'),
                    actions: <Widget>[
                      RaisedButton(
                        child: Text(
                          'Retry',
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          connectionStatus = null;
                        },
                      ),
                    ],
                  );
                }
            );
          }
        });
  }

  @override
  void dispose() {
    positionStream.cancel();
    connectivityStreamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    var locationOptions = LocationOptions(accuracy: LocationAccuracy.bestForNavigation, distanceFilter: 5);
    if(Provider.of<CurrentUser>(context, listen: false).shopper != null) setState(() {
      shopperEmail = Provider.of<CurrentUser>(context, listen: false).shopper.shopperEmail;
    });
    if (positionStream == null) {
      positionStream = geolocator.getPositionStream(locationOptions).listen((Position position) {
        print(position == null ? 'Unknown' : position.latitude.toString() + ', ' + position.longitude.toString());
        if(position != null) {
          setState(() {
            LatLng temp = LatLng(position.latitude, position.longitude);
            shopperLocation = my.LatLng(
              lat: temp.latitude,
              lng: temp.longitude,
            );
          });
//          String email = Provider.of<CurrentUser>(context, listen: false).shopper.shopperEmail;
          FirebaseTasks.updateLocation(
            email: shopperEmail,
            location : FirebaseTasks.getGeoFlutterPoint(my.LatLng(
                lat: position.latitude,
                lng: position.longitude,
              ),
            ),
          );
        }
      });
    }

    var data = Provider.of<QuerySnapshot>(context);
    List<my.Transaction> transactions = [];
    List<RequestTile> requestTiles = [];

    if (data != null) {
      List<DocumentSnapshot> docs;
      docs = data.documents;
      for(var doc in docs) {
        GeoPoint geoPoint = doc.data['location']['geopoint'];
        my.Transaction temp =
          my.Transaction(
            client: Client(
              clientEmail: doc.data['clientEmail'],
              clientName: doc.data['clientName'],
              clientPhoneNum: doc.data['clientPhoneNum'],
            ),
            locationName: doc.data['locationName'],
            location: FirebaseTasks.getGeoFlutterPoint(my.LatLng(
                lat: geoPoint.latitude,
                lng: geoPoint.longitude,
              ),
            ),
            shopperLocation: shopperLocation,
            groceryList: doc.data['groceryList'],
            phase: EnumToString.fromString(my.TransactionPhase.values, doc.data['transactionPhase']),
            docID: doc.documentID,
          );
        if(!transactions.contains(temp)) {
          transactions.add(temp);
        }
      }
    }
    return WillPopScope(
      onWillPop: () {
        SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        return Future.value(true);
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          for (var trans in transactions) {
            requestTiles.add(RequestTile(
              constraints: constraints,
              transaction: trans,
            ));
          }
          return Scaffold(
            appBar: AppBar(
              title: SizedBox(
                child: kKompraShopperWordLogoWhite,
                height: 35,
              ),
              leading: IconButton(
                icon: Icon(
                  Icons.menu,
                  color: Colors.white,
                ),
                onPressed: () {
                  //TODO: Menu
                },
              ),
              backgroundColor: kDarkerAccentColor,
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.more_vert),
                  onPressed: () {
                    FirebaseTasks.signOut();
                    positionStream.cancel();
                    Navigator.of(context).pushNamedAndRemoveUntil(WelcomeScreen.id, (Route<dynamic> route) => false);
                    Provider
                        .of<CurrentUser>(context, listen: false)
                        .shopper = null;
                    print('Current user : ${Provider
                        .of<CurrentUser>(context, listen: false)
                        .shopper}');
                  },
                ),
              ],
            ),
            body: Padding(
              padding: EdgeInsets.all(20),
              //TODO: Change to Listview.builder
              child: (requestTiles.length == 0) ?
                Center(
                    child: Text('No pending requests'),
                ) :
                Column(
                  children: <Widget>[
                    SizedBox(
                      height: 20,
                    ),
                    Expanded(
                      child: Container(
                        child: ListView.builder(
                          itemCount: requestTiles.length,
                          itemBuilder: (context, index) {
                            return requestTiles[index];
                          },
                        ),
                      ),
                    ),
                  ],
              ),
            ),
          );
        }
      ),
    );
  }
}
