// Flutter Packages
import 'package:flutter/material.dart';

class CustomIcon extends StatelessWidget {
  const CustomIcon({
    Key key,
    @required this.child,
    @required this.value,
  });

  final Widget child;
  final String value;

  //To check if the notifications number
  Widget ifMoreThanZero(BuildContext context) {
    Widget tmp;
    if (int.parse(this.value) > 0)
      tmp = Positioned(
        right: -10,
        top: -10,
        child: Container(
          padding: EdgeInsets.all(2.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100.0),
            color: Theme.of(context).primaryColorDark,
          ),
          constraints: BoxConstraints(
            minWidth: 20,
            minHeight: 20,
          ),
          child: Text(
            this.value,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ),
      );
    else
      tmp = Container();
    return tmp;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [this.child, ifMoreThanZero(context)],
    );
  }
}
