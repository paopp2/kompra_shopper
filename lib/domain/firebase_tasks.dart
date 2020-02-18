import 'dart:io';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:kompra_shopper/data/firebase_backend_connections.dart';
import 'package:kompra_shopper/domain/location.dart';
import 'package:kompra_shopper/domain/models/shopper.dart';
import 'package:kompra_shopper/domain/models/transaction.dart' as my;
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseTasks {

  //TODO fix return
  static Future<List> createNewUserWithEmailAndPass(
      {
        @required String name,
        @required String phoneNum,
        @required String email,
        @required String password,
        @required File file,
        @required String filename
      }) async {

    final newUser = await fireAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
    );

    StorageReference storageReference;
    storageReference = fireStorage.ref().child("images/profile_pictures/shoppers/$filename");
    final StorageUploadTask uploadTask = storageReference.putFile(file);
    final StorageTaskSnapshot downloadUrl = (await uploadTask.onComplete);
    final String url = (await downloadUrl.ref.getDownloadURL());

    if (newUser != null) {
      shoppersCollection.document(email).setData({
        'shopperName' : name,
        'shopperPhoneNum' : phoneNum,
        'shopperEmail' : email,
        'shopperImageUrl' : url,
      });
      print('Sign up success');
      return [newUser, url];
    }
  }

  static Future<AuthResult> logInUserWithEmailAndPass (
      {String email, String password}) {
    final existingUser = fireAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    if(existingUser != null) {
      print('Log in successful');
      return existingUser;
    }
  }

  static Future<Shopper> getShopper({String email}) async {
    DocumentSnapshot snapshot = await shoppersCollection.document(email).get();
    String em = snapshot.data['shopperEmail'];
    String name = snapshot.data['shopperName'];
    String phoneNum = snapshot.data['shopperPhoneNum'];
    String url = snapshot.data['shopperImageUrl'];
    return Shopper(
      shopperEmail: em,
      shopperName: name,
      shopperPhoneNum: phoneNum,
      shopperImageUrl: url,
    );
  }

  static Future<FirebaseUser> getCurrentUser() {
    return fireAuth.currentUser();
  }

  static void signOut() {
    fireAuth.signOut();
  }

  static void deleteDocument(String docID) async {
    pendingTransactionsCollection.document(docID).delete();
  }

  static Stream<QuerySnapshot> getPendingTransactionsStream() {
    return pendingTransactionsCollection.where('transactionPhase', isEqualTo: my.TransactionPhase.finding.toString()).snapshots();
  }
  
  static void updateTransactionPhase(String docID, my.TransactionPhase phase) {
    pendingTransactionsCollection.document(docID).updateData({
        'transactionPhase' : phase.toString(),
      }
    );
  }

  static void setShopper(String docID, Shopper shopper) {
    pendingTransactionsCollection.document(docID).updateData({
      'shopperEmail' : shopper.shopperEmail,
      'shopperName' : shopper.shopperName,
      'shopperPhoneNum' : shopper.shopperPhoneNum,
      'shopperImageUrl' : shopper.shopperImageUrl
    });
  }

  static void updateLocation({String email, var location}) {
    shoppersCollection.document(email).updateData({
      'location' : location,
    });
  }

  static getGeoFlutterPoint(LatLng latlng) {
    GeoFirePoint location = geo.point(latitude: latlng.lat, longitude: latlng.lng);
    return location.data;
  }

  static void addToCompletedTransactions(my.Transaction transaction, String docID) {
    FirebaseTasks.updateTransactionPhase(docID, my.TransactionPhase.completed);
    completedTransactionsCollection.add(
      {
        'clientName' : transaction.client.clientName,
        'clientEmail' : transaction.client.clientEmail,
        'clientPhoneNum' : transaction.client.clientPhoneNum,
        'shopperName' : transaction.shopper.shopperName,
        'shopperEmail' : transaction.shopper.shopperEmail,
        'shopperPhoneNum' : transaction.shopper.shopperPhoneNum,
        'shopperImageUrl' :transaction.shopper.shopperImageUrl,
        'groceryList' : transaction.groceryList,
        'location' : transaction.location,
        'timestamp' : transaction.timestamp,
        'transactionPhase' : transaction.phase.toString(),
      }
    );
    FirebaseTasks.deleteDocument(docID);
  }
}