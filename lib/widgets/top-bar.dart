import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TopBar extends StatefulWidget {
  const TopBar({
    Key? key,
    required this.points,
    required this.isVoting,
  }) : super(key: key);
  final int points;
  final bool isVoting;

  @override
  _TopBarState createState() => _TopBarState();
}

class _TopBarState extends State<TopBar> {
  @override
  Widget build(BuildContext context) {
    final ThemeData _theme = Theme.of(context);
    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: _theme.primaryColor,
        borderRadius: const BorderRadius.all(
          Radius.circular(10),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            blurRadius: 10,
            color: Colors.black.withOpacity(.2),
          ),
        ],
      ),
      child: widget.isVoting
          ? const Center(
              child: Text(
                'PLEASE VOTE NOW',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 20.0,
                ),
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Row(
                  children: const <Widget>[
                    Icon(
                      Icons.timer,
                      color: Colors.white,
                    ),
                    SizedBox(width: 2.0),
                    Text(
                      '3rd Round',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        fontSize: 15.0,
                      ),
                    )
                  ],
                ),
                Row(
                  children: const <Widget>[
                    Icon(
                      Icons.star,
                      color: Colors.white,
                    ),
                    SizedBox(width: 2.0),
                    Text(
                      '1st',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        fontSize: 15.0,
                      ),
                    )
                  ],
                ),
                Row(
                  children: <Widget>[
                    const Icon(
                      Icons.money,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 2.0),
                    Text(
                      widget.points.toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        fontSize: 15.0,
                      ),
                    )
                  ],
                ),
              ],
            ),
    );
  }
}
