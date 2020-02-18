import 'dart:ui';
import 'package:kompra_shopper/domain/firebase_tasks.dart';
import 'package:kompra_shopper/domain/models/transaction.dart';
import 'package:kompra_shopper/ui/components/floating_action_buttons.dart';
import 'package:flutter/material.dart';
import 'package:kompra_shopper/constants.dart';
import 'package:kompra_shopper/ui/providers/providers.dart';
import 'package:kompra_shopper/ui/screens/goto_client_screen.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class GroceryListScreen extends StatefulWidget {
  static String id = 'grocery_list_screen';
  @override
  _GroceryListScreenState createState() => _GroceryListScreenState();
}

class _GroceryListScreenState extends State<GroceryListScreen> {

  String _groceryList;
  int index = 0;
  double progress = (1/5);

  @override
  Widget build(BuildContext context) {
    Transaction temp = Provider.of<AcceptedTransaction>(context, listen: false).transaction;
    String docID = temp.docID;
    TextEditingController locationTextFieldController = TextEditingController();
    TextEditingController groceryListTextFieldController = TextEditingController();
    TextEditingController clientNameTextFieldController = TextEditingController();
    clientNameTextFieldController.text = Provider.of<AcceptedTransaction>(context, listen: false).transaction.client.clientName;
    locationTextFieldController.text = Provider.of<AcceptedTransaction>(context, listen: false).transaction.locationName;
    groceryListTextFieldController.text = Provider.of<AcceptedTransaction>(context, listen: false).transaction.groceryList;
//    locationTextFieldFormController.text = Provider.of<AcceptedTransaction>(context, listen: false).transaction.locationName;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Grocery List',
            ),
            backgroundColor: kDarkerAccentColor,
          ),
          body: ListView(
            children: <Widget>[
              SizedBox(height: 30,),
              Container(
                height: constraints.maxHeight * 0.8,
                width: constraints.maxWidth * 0.9,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 30,
                  ),
                  child: ListView(
                    children: <Widget>[
                      TextFormField(
                        maxLines: 1,
                        readOnly: true,
                        controller: clientNameTextFieldController,
                        decoration: kDefaultTextFieldFormDecoration.copyWith(
                            labelText: 'Client Name'
                        ),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                      SizedBox(height: 15,),
                      TextFormField(
                        maxLines: 2,
                        readOnly: true,
                        controller: locationTextFieldController,
                        decoration: kDefaultTextFieldFormDecoration.copyWith(
                            labelText: 'Address'
                        ),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 15,
                        ),
                        child: LinearPercentIndicator(
                          animation: true,
                          lineHeight: 40,
                          animationDuration: 500,
                          animateFromLastPercent: true,
                          percent: progress,
                          center: Text(
                            kGroceryPhases[index]['progressMessage'],
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          linearStrokeCap: LinearStrokeCap.roundAll,
                          progressColor: kPrimaryColor,
                          backgroundColor: kAccentColor,
                        ),
                      ),
                      TextField(
                        onChanged: (value) {
                          _groceryList = value;
                        },
                        readOnly: true,
                        maxLines: 10,
                        controller: groceryListTextFieldController,
                        decoration: kDefaultTextFieldFormDecoration.copyWith(
                          labelText: 'Grocery List',
                          alignLabelWithHint: true,
                          hintText: 'Enter your grocery list in bullet form',
                        ),
                        style: TextStyle(
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: DefaultExtendedFAB(
              icon: kGroceryPhases[index]['fabIcon'],
              label: kGroceryPhases[index]['fabLabel'],
              onPressed: () {
                setState(() {
                  index++;
                  progress = ((index+1)/(kGroceryPhases.length));
                });
                Provider.of<AcceptedTransaction>(context, listen: false).transaction.phase = kGroceryPhases[index]['groceryPhase'];
                FirebaseTasks.updateTransactionPhase(docID, kGroceryPhases[index]['groceryPhase']);
                if(index == (kGroceryPhases.length - 1)) {
                  Provider.of<AcceptedTransaction>(context, listen: false).transaction.phase = TransactionPhase.coming;
                  print('Transaction details   : '
                      '${temp.location['geohash']},'
                      ' ${temp.client.clientEmail},'
                      ' ${temp.groceryList},'
                      ' ${temp.phase},'
                      ' ${temp.locationName}');
                  FirebaseTasks.updateTransactionPhase(docID, TransactionPhase.coming);
                  Navigator.pushNamed(context, GotoClientScreen.id);
                }
              }
          ),
        );
      }
    );
  }
}
