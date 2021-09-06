import 'dart:html';

import 'package:flutter/material.dart';

class Headline extends StatefulWidget {
  const Headline({
    Key? key,
    required this.topText,
    required this.bottomText,
  }) : super(key: key);
  final String topText, bottomText;

  @override
  _HeadlineState createState() => _HeadlineState();
}

class _HeadlineState extends State<Headline> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          widget.topText,
          style: const TextStyle(
            fontSize: 30,
            color: Colors.black87,
          ),
        ),
        Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            Positioned(bottom: -10, child: Image.asset('assets/underline.png')),
            Text(
              widget.bottomText,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
