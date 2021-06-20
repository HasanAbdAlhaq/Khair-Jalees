import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  // Properties
  final String text;
  final Function onPressed;
  final double width;
  final double fontsize;

  // Constructor
  CustomButton({
    @required this.text,
    @required this.onPressed,
    this.width = 100.0,
    this.fontsize = 26,
  });

  @override
  Widget build(BuildContext context) {
    // Main Variables
    final theme = Theme.of(context);

    // Actual Build Method
    return SizedBox(
      width: this.width,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: ElevatedButton(
          onPressed: this.onPressed,
          child: Text(
            this.text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: this.fontsize,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: ElevatedButton.styleFrom(
            primary: theme.primaryColor,
            onPrimary: theme.accentColor,
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
          ),
        ),
      ),
    );
  }
}
