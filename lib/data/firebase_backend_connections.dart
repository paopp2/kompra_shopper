import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geoflutterfire/geoflutterfire.dart';

final fireAuth = FirebaseAuth.instance;
final fireStore = Firestore.instance;
final fireStorage = FirebaseStorage.instance;
final Geoflutterfire geo = Geoflutterfire();

final CollectionReference shoppersCollection = fireStore.collection('shoppers');
final CollectionReference pendingTransactionsCollection = fireStore.collection('pending_transactions');
final CollectionReference completedTransactionsCollection = fireStore.collection('completed_transactions');