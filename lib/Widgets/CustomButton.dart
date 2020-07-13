import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final Color colorText;
  final VoidCallback onPressed;

  CustomButton({
    @required this.text,
    this.colorText = Colors.white,
    this.onPressed
  });

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
      ),
      color: Color(0xff9c27b0),
      padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
      child: Text(
        this.text,
        style: TextStyle(
          color: colorText,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      onPressed: this.onPressed,
    );
  }
}
