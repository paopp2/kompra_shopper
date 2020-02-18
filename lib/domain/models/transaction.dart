import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kompra_shopper/domain/location.dart';

import 'client.dart';
import 'shopper.dart';

enum TransactionPhase {
  finding,
  accepted,
  arrived,
  shopping,
  paying,
  coming,
  completed,
}

class Transaction {
  Transaction({
    this.client,
    this.shopper,
    this.location,
    this.locationName,
    this.timestamp,
    this.groceryList,
    this.phase,
    this.docID,
    this.shopperLocation,
  });

  Client client;
  Shopper shopper;
  var location;
  LatLng shopperLocation;
  Timestamp timestamp;
  String groceryList;
  String locationName;
  TransactionPhase phase;
  String docID;

  @override
  String toString() {
    print('Client: $client, '
          'Shopper:$shopper, '
          'clientLocation:[${location['geopoint'].toString()}]'
          'shopperLocation:[${shopperLocation.lat} , ${shopperLocation.lng}]'
          'timeStamp : ${timestamp.toString()}');
  }
}
