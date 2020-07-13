import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomInputText extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final bool autofocus;
  final int maxLines;
  final TextInputType inputType;  
  final List<TextInputFormatter> inputFormatters;
  final Function(String) validator;
  final Function(String) onSaved;

  CustomInputText({
    this.controller,
    @required this.hint,
    this.autofocus = false,
    this.obscure = false,
    this.maxLines,
    this.inputType = TextInputType.text,    
    this.inputFormatters,
    this.validator,
    this.onSaved,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: this.controller,
      autofocus: this.autofocus,
      obscureText: this.obscure,
      keyboardType: this.inputType,
      inputFormatters: this.inputFormatters,
      validator: this.validator,
      onSaved: this.onSaved,
      maxLines: this.maxLines,
      style: TextStyle(fontSize: 20),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
        hintText: this.hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }
}
