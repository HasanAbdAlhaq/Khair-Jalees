// Flutter Packages
import 'package:flutter/material.dart';

// Models
import '../models/HexColors.dart';

class CustomLabel extends StatelessWidget {
  // Properties
  final String labelText;
  // Constructor
  CustomLabel(this.labelText);

  Widget buildColoredContainer(String colorHexCode) {
    return Container(
      width: 200,
      height: 50,
      decoration: BoxDecoration(
        color: HexColor(colorHexCode),
        borderRadius: BorderRadius.all(Radius.circular(15)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        Positioned(
          top: -10,
          right: -25,
          child: buildColoredContainer("ffad05"),
        ),
        Positioned(
          bottom: -10,
          left: -25,
          child: buildColoredContainer("7acafa"),
        ),
        Positioned(
          height: 50,
          width: 200,
          child: buildColoredContainer("4c064d"),
        ),
        Text(
          this.labelText,
          style: TextStyle(
            color: theme.accentColor,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ],
    );
  }
}
