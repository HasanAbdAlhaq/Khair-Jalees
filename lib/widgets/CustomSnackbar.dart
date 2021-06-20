// Flutter Packages
import 'package:flutter/material.dart';

class CustomSnackBar {
  // Properties
  final String textContent;

  // Constructor
  CustomSnackBar(this.textContent);

  SnackBar build(BuildContext ctx) {
    return SnackBar(
      duration: Duration(seconds: 2),
      content: Text(
        textContent,
        textAlign: TextAlign.right,
        style: TextStyle(
          color: Theme.of(ctx).accentColor,
          fontWeight: FontWeight.w400,
          fontSize: 18,
          letterSpacing: 2,
        ),
      ),
      backgroundColor: Theme.of(ctx).primaryColor,
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
    );
  }
}
