import 'package:flutter/material.dart';

class InputContainer extends StatefulWidget {
  const InputContainer({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.inputType,
  });

  final TextEditingController controller;
  final TextInputType inputType;
  final String hintText;

  @override
  _InputContainerState createState() => _InputContainerState();
}

class _InputContainerState extends State<InputContainer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: const BorderRadius.all(
          Radius.circular(10),
        ),
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            blurRadius: 10,
            color: Colors.black12,
          )
        ],
      ),
      child: TextField(
        textCapitalization: TextCapitalization.characters,
        enableSuggestions: false,
        autocorrect: false,
        keyboardType: widget.inputType,
        cursorColor: Colors.grey.shade500,
        maxLength: 12,
        cursorWidth: 3,
        controller: widget.controller,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          hintText: widget.hintText,
          hintStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontSize: 15,
          ),
          counterText: '',
        ),
      ),
    );
  }
}
