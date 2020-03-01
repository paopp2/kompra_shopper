import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:flutter/material.dart';
import 'package:kompra_shopper/constants.dart';
import 'package:expandable/expandable.dart';
import 'package:kompra_shopper/domain/firebase_tasks.dart';
import 'package:kompra_shopper/domain/models/transaction.dart';
import 'package:kompra_shopper/ui/components/rounded_button.dart';
import 'package:kompra_shopper/ui/providers/providers.dart';
import 'package:kompra_shopper/ui/screens/grocery_list_screen.dart';
import 'package:kompra_shopper/ui/screens/loading_screen.dart';
import 'package:provider/provider.dart';
import 'package:kompra_shopper/domain/distance_and_travel_time.dart';
import 'order_summary_table.dart';

class RequestTile extends StatelessWidget {
  const RequestTile({
    @required this.constraints,
    @required this.transaction,
  });

  final BoxConstraints constraints;
  final Transaction transaction;

  RequestTileContent requestTileContent({bool isExpanded}) {
    return RequestTileContent(
      constraints: constraints,
      isExpanded: isExpanded,
      transaction: transaction,
      deliveryFee: transaction.serviceFee,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ExpandableNotifier(
      child: Expandable(
        collapsed: ExpandableButton(
          child: requestTileContent(
              isExpanded: false
          ),
        ),
        expanded: ExpandableButton(
          child: requestTileContent(
              isExpanded: true
          ),
        ),
      ),
    );
  }
}

class RequestTileContent extends StatefulWidget {
  const RequestTileContent({
    Key key,
    @required this.constraints,
    @required this.isExpanded,
    @required this.transaction,
    @required this.deliveryFee,
  }) : super(key: key);

  final BoxConstraints constraints;
  final bool isExpanded;
  final double deliveryFee;
  final Transaction transaction;

  @override
  _RequestTileContentState createState() => _RequestTileContentState();
}

class _RequestTileContentState extends State<RequestTileContent> {

  String kmsAway;

  Future<void> getDistance() async {
    if (widget.transaction.shopperLocation != null) {
      firestore.GeoPoint geoPoint = widget.transaction.location['geopoint'];
      print('Passed here, ${widget.transaction.shopperLocation.lat}, ${geoPoint.latitude}');
      Map<String, dynamic> map = await Distance.getDistance(
        origLat: widget.transaction.shopperLocation.lat,
        origLng: widget.transaction.shopperLocation.lng,
        destLat: geoPoint.latitude,
        destLng: geoPoint.longitude,
      );
      setState(() {
        kmsAway = map['distance']['text'];
        print(kmsAway);
      });
    }
    return;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if(kmsAway == null) {
      getDistance();
    }
    TextEditingController issueController = TextEditingController();
    TextEditingController priceController = TextEditingController();
//    issueController.text = widget.transaction.groceryList;
//    issueController.text = 'temporary: change this shit';
    priceController.text = 'Php ${widget.deliveryFee}';
    final _formKey = GlobalKey<FormState>();

    List<Widget> requestTileInnerWidgets =
    <Widget>[
      ListTile(
        title: Text(
          widget.transaction.client.clientName,
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: Icon(
          Icons.person,
          color: kPrimaryColor,
        ),
        dense: true,
      ),
      ListTile(
        title: Text(
          widget.transaction.locationName,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        leading: Icon(
          Icons.location_on,
          color: kPrimaryColor,
        ),
        dense: true,
      ),
      Text(
        //TODO: Fix kms away in request tile
        (!widget.isExpanded) ?
          (kmsAway == null) ? 'Calculating distance...' : '$kmsAway(s) away'
            : '',
        style: TextStyle(
          color: kPrimaryColor,
        ),
      ),
    ];

    if(widget.isExpanded) {
      requestTileInnerWidgets.addAll([
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 8.0,
            horizontal: 20,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
//                TextField(
//                  readOnly: true,
//                  maxLines: 10,
//                  controller: issueController,
//                  decoration: kDefaultTextFieldFormDecoration.copyWith(
//                    labelText: 'Grocery List',
//                    alignLabelWithHint: true,
//                  ),
//                  style: TextStyle(
//                    height: 1.5,
//                  ),
//                ),
                Container(
                  height: 200,
                  child: ListView(
                    children: <Widget>[
                      OrderSummaryTable(
                        itemMap: widget.transaction.groceryList,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 15,),
                TextFormField(
                  readOnly: true,
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value.isEmpty ) {
                      return 'Please set an estimated price';
                    }
                    return null;
                  },
                  textAlign: TextAlign.center,
                  decoration: kDefaultTextFieldFormDecoration.copyWith(
                    labelText: 'Service fee',
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                      BorderSide(color: Colors.black, width: 1.0),
                      borderRadius: BorderRadius.all(Radius.circular(32.0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                      BorderSide(color: Colors.black, width: 2.0),
                      borderRadius: BorderRadius.all(Radius.circular(32.0)),
                    ),
                  ),
                ),
                RoundedButton(
                  text: Text(
                    'Accept',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  colour: kDarkerAccentColor,
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      FirebaseTasks.updateTransactionPhase(widget.transaction.docID, TransactionPhase.accepted);
                      print(Provider.of<CurrentUser>(context, listen: false).shopper.shopperImageUrl);
                      Transaction temp = widget.transaction;
                      temp.shopper = Provider.of<CurrentUser>(context, listen: false).shopper;
                      Provider.of<AcceptedTransaction>(context, listen: false).transaction = temp;
                      FirebaseTasks.setShopper(
                        widget.transaction.docID,
                        Provider.of<CurrentUser>(context, listen: false).shopper,
                      );
                      print(Provider.of<AcceptedTransaction>(context, listen: false).transaction.docID);
                      Navigator.pushNamed(context, GroceryListScreen.id);
                    }
                  },
                ),
                SizedBox(height: 15,),

              ],
            ),
          ),
        ),
      ]);
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: widget.constraints.maxWidth * 0.9,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: kElevationToShadow[4],
        ),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
              children: requestTileInnerWidgets
          ),
        ),
      ),
    );
  }
}