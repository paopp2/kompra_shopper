import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:kompra_shopper/constants.dart';
import 'package:kompra_shopper/ui/components/floating_action_buttons.dart';

class AwaitingClientResponse extends StatelessWidget {
  static String id = 'awaiting_client_response';
  bool isAccepted = true;
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => Scaffold(
        backgroundColor: Colors.blueGrey[900],
        floatingActionButton: DefaultExtendedFAB(
          onPressed: () {
//          TODO: Implement cancel appointment
//          temporary function --> Show accepted/declined dialog
            showDialog<void>(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  title: Text(
                    (isAccepted) ? 'Accepted' : 'Declined',
                    style: TextStyle(
                      color: (isAccepted) ? Colors.green : Colors.red,
                    ),
                  ),
                  content: Text(
                    (isAccepted) ? 'Client has accepted your offer' : 'Client has declined your offer',
                  ),
                  actions: <Widget>[
                    FlatButton(
                      child: Text(
                        (isAccepted) ? 'CONTINUE' : 'OK',
                      ),
                      onPressed: () {
                        print('Pressed');
                      },
                    ),
                  ],
                );
              }
            );
          },
          label: 'Cancel',
          icon: Icons.close,
        ),
        body: Stack(
          children: <Widget>[
            Center(
              child: SpinKitRipple(
                borderWidth: 10,
                color: kPrimaryColor,
                size: constraints.maxHeight * 40,
              ),
            ),
            Center(
              child: SizedBox(
                height: 50,
                child: kKompraShopperWordLogo,
              ),
            ),
            Positioned(
              bottom: 150,
              right: 50,
              left: 50,
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  '''Awaiting client response
                  . . .''',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
