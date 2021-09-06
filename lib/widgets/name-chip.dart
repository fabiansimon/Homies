import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NameChip extends StatefulWidget {
  const NameChip({
    Key? key,
    required this.name,
    required this.isHost,
  }) : super(key: key);
  final String name;
  final bool isHost;

  @override
  _NameChipState createState() => _NameChipState();
}

class _NameChipState extends State<NameChip> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 35,
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Theme.of(context).accentColor,
        borderRadius: const BorderRadius.all(
          Radius.circular(100),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              widget.name,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (widget.isHost)
              const Padding(
                padding: EdgeInsets.only(left: 4.0),
                child: Icon(
                  CupertinoIcons.house_fill,
                  size: 14,
                  color: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
