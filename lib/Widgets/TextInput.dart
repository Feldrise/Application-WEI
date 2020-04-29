import 'package:flutter/material.dart';

class TextInput extends StatelessWidget {
  const TextInput({
    Key key, 
    this.obscureText = false,
    this.inputType = TextInputType.text,
    @required this.controller,
    @required this.inputDecoration,
    @required this.validator,
  }) : super(key: key);

  final bool obscureText;
  final TextEditingController controller;
  final InputDecoration inputDecoration;
  final String Function(String) validator;

  final TextInputType inputType;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(2.0)),
        color: Colors.blueGrey[100],
      ),
      child: TextFormField(
        obscureText: obscureText,
        controller: controller,
        keyboardType: inputType,
        decoration: inputDecoration,
        validator: validator,
      ),
    );
  }
}