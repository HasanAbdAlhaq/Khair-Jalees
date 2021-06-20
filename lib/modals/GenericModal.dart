// Flutter Packages
import 'package:flutter/material.dart';

class GenericModal extends StatelessWidget {
  // Properties
  final Function hideModalFunction;
  final Widget childWidget;
  final double height;
  final Alignment alignment;

  // Constructor
  GenericModal({
    @required this.hideModalFunction,
    @required this.childWidget,
    this.height = 500,
    this.alignment = Alignment.topCenter,
  });

  BorderRadius get borderRadius {
    if (this.alignment == Alignment.topCenter)
      return BorderRadius.only(
        bottomLeft: Radius.circular(40),
        bottomRight: Radius.circular(40),
      );
    if (this.alignment == Alignment.bottomCenter)
      return BorderRadius.only(
        topLeft: Radius.circular(40),
        topRight: Radius.circular(40),
      );
    else
      return null;
  }

  @override
  Widget build(BuildContext context) {
    // Main Variables
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    // Actual Build Method
    return Stack(
      alignment: this.alignment,
      children: [
        GestureDetector(
          child: Container(
            height: mediaQuery.size.height,
            width: mediaQuery.size.width,
            color: theme.primaryColor.withOpacity(0.3),
          ),
          onTap: this.hideModalFunction,
        ),
        Container(
          height: mediaQuery.viewInsets.bottom == 0 ? this.height : 450, // 450
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: this.borderRadius,
          ),
          child: this.childWidget,
        ),
      ],
    );
  }
}
