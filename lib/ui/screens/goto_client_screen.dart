import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:flutter/material.dart';
import 'package:flutter_mapbox_navigation/flutter_mapbox_navigation.dart';
import 'package:kompra_shopper/constants.dart';
import 'package:kompra_shopper/domain/location.dart' as my;
import 'package:kompra_shopper/ui/components/rounded_button.dart';
import 'package:kompra_shopper/ui/screens/loading_screen.dart';
import 'package:kompra_shopper/domain/models/transaction.dart';
import 'package:kompra_shopper/ui/screens/pending_requests_screen.dart';
import 'package:provider/provider.dart';
import 'package:kompra_shopper/ui/providers/providers.dart';
import 'package:kompra_shopper/domain/firebase_tasks.dart';

class GotoClientScreen extends StatefulWidget {
  static String id = 'goto_client_screen_id';

  @override
  _GotoClientScreenState createState() => _GotoClientScreenState();
}

class _GotoClientScreenState extends State<GotoClientScreen> {
  MapboxNavigation _directions;
  double _distanceRemaining;
  double _durationRemaining;
  bool _arrived;
  bool inNavigationMode = false;

  @override
  void initState() {
    super.initState();
    _directions = MapboxNavigation(onRouteProgress: (arrived) async{
      _distanceRemaining = await _directions.distanceRemaining;
      _durationRemaining = await _directions.durationRemaining;
      setState(() {
        _arrived = arrived;
        inNavigationMode = _distanceRemaining != null;
      });
      if(arrived)
        await _directions.finishNavigation();
        String docID = Provider.of<AcceptedTransaction>(context, listen: false).transaction.docID;
        FirebaseTasks.updateTransactionPhase(docID, TransactionPhase.arrived);
    });
  }

  @override
  Widget build(BuildContext context) {
      Transaction temp = Provider.of<AcceptedTransaction>(context, listen: false).transaction;
      String origName = 'Kani lng sa';
      my.LatLng origLatLng = temp.shopperLocation;
      String destName = temp.locationName;
      firestore.GeoPoint geoPoint = temp.location['geopoint'];
      my.LatLng destLatLng = my.LatLng(
        lat: geoPoint.latitude,
        lng: geoPoint.longitude,
      );
      final origin = Location(name: origName, latitude: origLatLng.lat, longitude: origLatLng.lng);
      final destination = Location(name: destName, latitude: destLatLng.lat, longitude: destLatLng.lng);
      _directions.startNavigation(
          origin: origin,
          destination: destination,
          mode: NavigationMode.drivingWithTraffic,
          simulateRoute: false);
      return Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'Delivering to customer...',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 25,
                color: kDarkerPrimaryColor
              ),
            ),
            SizedBox(
              height: 30,
            ),
            RoundedButton(
              colour: kDarkerAccentColor,
              text: Text(
                'Press me when transaction completed',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              onPressed: () {
                String docID = Provider.of<AcceptedTransaction>(context, listen: false).transaction.docID;
                Transaction temp = Provider.of<AcceptedTransaction>(context, listen: false).transaction;
                temp.timestamp = firestore.Timestamp.now();
                temp.phase = TransactionPhase.completed;
                FirebaseTasks.addToCompletedTransactions(temp, docID);
                Navigator.popUntil(context, ModalRoute.withName(PendingRequestsScreen.id));
              },
            ),
          ],
        ),
      );
  }
}
