import 'package:flutter/material.dart';

class IconBubble extends StatefulWidget {
  @override
  _IconBubbleState createState() => _IconBubbleState();
}

class _IconBubbleState extends State<IconBubble> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      width: 45,
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        shape: BoxShape.circle,
      ),
      child: Padding(
        padding: const EdgeInsets.only(
            top: 10.0, left: 7.0, right: 10.0, bottom: 10.0),
        child: Image.asset(
          'assets/h-alone.png',
          height: 20,
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}
