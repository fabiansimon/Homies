import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MainButton extends StatefulWidget {
  const MainButton({
    Key? key,
    required this.borderColor,
    required this.backgroundColor,
    required this.textColor,
    required this.shadowColor,
    required this.string,
    required this.onTap,
  }) : super(key: key);
  final Color borderColor, textColor, shadowColor, backgroundColor;
  final String string;
  final Function() onTap;

  @override
  _MainButtonState createState() => _MainButtonState();
}

class _MainButtonState extends State<MainButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onTap();
      },
      onTapDown: (TapDownDetails details) {
        setState(() {
          _isPressed = true;
        });
      },
      onTapCancel: () {
        setState(() {
          _isPressed = false;
        });
      },
      onTapUp: (TapUpDetails details) {
        setState(() {
          _isPressed = false;
        });
      },
      child: SizedBox(
        height: 50,
        child: AnimatedPadding(
          curve: Curves.elasticInOut,
          duration: const Duration(milliseconds: 100),
          padding: EdgeInsets.symmetric(
              horizontal: _isPressed ? 3 : 0, vertical: _isPressed ? 1 : 0),
          child: Container(
            height: _isPressed ? 45 : 50,
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              border: Border.all(width: 2, color: widget.borderColor),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  blurRadius: 10,
                  color: widget.shadowColor.withOpacity(.3),
                )
              ],
              borderRadius: const BorderRadius.all(
                Radius.circular(10),
              ),
            ),
            child: Center(
              child: Text(
                widget.string,
                style: TextStyle(
                  color: _isPressed
                      ? widget.textColor.withOpacity(.85)
                      : widget.textColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
