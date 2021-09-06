import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:homies/models/prompt-deck.dart';

class DeckCard extends StatefulWidget {
  const DeckCard({
    Key? key,
    required this.onTap,
    required this.promptDeck,
  });

  final Function() onTap;
  final PromptDeck promptDeck;

  @override
  _DeckCardState createState() => _DeckCardState();
}

class _DeckCardState extends State<DeckCard> {
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
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 50),
        opacity: _isPressed ? .8 : 1,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(left: 10),
              width: 170,
              decoration: BoxDecoration(
                color: Theme.of(context).accentColor,
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    blurRadius: 10,
                    color: Theme.of(context).accentColor.withOpacity(.3),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    widget.promptDeck.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6.0),
                  Text(
                    widget.promptDeck.description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            if (widget.promptDeck.isLocked)
              Container(
                width: 170,
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.all(
                    Radius.circular(11),
                  ),
                ),
                child: const Center(
                  child: Icon(
                    CupertinoIcons.lock_circle_fill,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
}
