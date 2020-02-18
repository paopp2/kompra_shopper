import 'package:flutter/material.dart';
import 'package:kompra_shopper/domain/models/shopper.dart';
import 'package:kompra_shopper/domain/models/transaction.dart';

class CurrentUser extends ChangeNotifier {
  CurrentUser({
    this.shopper,
  });
  Shopper shopper;
  notifyListeners();
}

class AcceptedTransaction extends ChangeNotifier {
  AcceptedTransaction({
    this.transaction,
  });
  Transaction transaction;
  notifyListeners();
}