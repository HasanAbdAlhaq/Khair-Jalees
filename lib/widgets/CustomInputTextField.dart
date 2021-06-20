import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomInputTextField extends StatefulWidget {
  final String label;
  final Function onSaved;
  final Function validator;
  final double width;
  final TextInputType keyboardType;
  final bool obscureText;
  final FocusNode focusNode;
  final FocusNode nextTextField;
  final String initialValue;
  final Function onchanged;
  final int maxLines;
  final int maxLength;
  final dynamic controller;
  final bool enabled;

  CustomInputTextField(
      {@required this.label,
      @required this.onSaved,
      @required this.validator,
      this.width = 280,
      this.keyboardType,
      this.obscureText = false,
      this.focusNode,
      this.nextTextField,
      this.initialValue,
      this.onchanged,
      this.maxLines,
      this.maxLength,
      this.controller,
      this.enabled = true});

  @override
  _CustomInputTextFieldState createState() => _CustomInputTextFieldState();
}

class _CustomInputTextFieldState extends State<CustomInputTextField> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: this.widget.width,
      margin: EdgeInsets.only(bottom: 10),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: TextFormField(
          focusNode: this.widget.focusNode,
          onFieldSubmitted: (_) {
            FocusScope.of(context).requestFocus(this.widget.nextTextField);
          },
          maxLines: (this.widget.obscureText || this.widget.maxLines == null)
              ? 1
              : this.widget.maxLines,
          maxLength: this.widget.maxLength,
          maxLengthEnforcement: MaxLengthEnforcement.enforced,
          onChanged: this.widget.onchanged,
          validator: this.widget.validator,
          controller: this.widget.controller,
          onSaved: this.widget.onSaved,
          keyboardType: this.widget.keyboardType,
          obscureText: this.widget.obscureText,
          enabled: this.widget.enabled,
          initialValue: this.widget.initialValue,
          style: TextStyle(
            fontSize: 20,
            color: theme.primaryColor,
          ),
          decoration: new InputDecoration(
            fillColor: theme.scaffoldBackgroundColor,
            filled: !this.widget.enabled,
            contentPadding: EdgeInsets.all(15),
            labelText: this.widget.label,
            labelStyle: TextStyle(
              fontSize: 18,
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: theme.primaryColor,
                style: BorderStyle.solid,
                width: 1.5,
              ),
              borderRadius: const BorderRadius.all(
                const Radius.circular(40),
              ),
            ),
            border: new OutlineInputBorder(
              borderSide: BorderSide(
                color: theme.primaryColor,
                style: BorderStyle.solid,
                width: 1.5,
              ),
              borderRadius: const BorderRadius.all(
                Radius.circular(40),
              ),
            ),
            disabledBorder: new OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.grey.shade300,
                style: BorderStyle.solid,
                width: 1.5,
              ),
              borderRadius: const BorderRadius.all(
                Radius.circular(40),
              ),
            ),
            counterStyle: TextStyle(
              color: Theme.of(context).primaryColorLight,
              fontWeight: FontWeight.w700,
              fontSize: 22,
            ),
          ),
        ),
      ),
    );
  }
}
