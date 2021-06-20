import 'package:flutter/material.dart';

class CustomPageLabel extends StatelessWidget {
  // Propertoies
  final labelText;

  // Constructor
  CustomPageLabel(this.labelText);

  @override
  Widget build(BuildContext context) {
    // Variable
    final theme = Theme.of(context);
    return Container(
      margin: EdgeInsets.only(top: 20, bottom: 20),
      child: Row(children: <Widget>[
        Expanded(
          child: new Container(
            margin: const EdgeInsets.only(left: 20.0, right: 20.0),
            child: Divider(
              color: theme.primaryColor,
              thickness: 2,
              // height: 50,
            ),
          ),
        ),
        Text(
          labelText,
          style: TextStyle(
            color: theme.primaryColor,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(
          child: new Container(
            margin: const EdgeInsets.only(left: 20.0, right: 20.0),
            child: Divider(
              color: theme.primaryColor,
              thickness: 2,
              // height: 50,
            ),
          ),
        ),
      ]),
    );
  }
}
