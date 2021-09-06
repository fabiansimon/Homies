import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:homies/models/answer.dart';

class AnswersWrap extends StatefulWidget {
  AnswersWrap({
    Key? key,
    required this.answers,
    required this.chosenAnswer,
  }) : super(key: key);
  final List<Answer> answers;
  int chosenAnswer;

  @override
  _AnswersWrapState createState() => _AnswersWrapState();
}

class _AnswersWrapState extends State<AnswersWrap> {
  @override
  Widget build(BuildContext context) {
    final ThemeData _theme = Theme.of(context);
    return Wrap(
      runSpacing: 10,
      spacing: 10,
      children: List<Widget>.generate(
        widget.answers.length,
        (int index) {
          return Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              AnswerContainer(
                onTap: () {
                  setState(() {
                    widget.chosenAnswer = index;
                  });
                },
                chosenAnswer: widget.chosenAnswer,
                theme: _theme,
                answer: widget.answers[index].answer,
                index: index,
              ),
              if (widget.chosenAnswer == index)
                Positioned(
                  right: -10,
                  top: -10,
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: Icon(
                      CupertinoIcons.check_mark_circled_solid,
                      color: _theme.accentColor,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class AnswerContainer extends StatefulWidget {
  const AnswerContainer({
    Key? key,
    required ThemeData theme,
    required this.index,
    required this.chosenAnswer,
    required this.answer,
    required this.onTap,
  })  : _theme = theme,
        super(key: key);

  final ThemeData _theme;
  final Function() onTap;
  final int index;
  final int chosenAnswer;
  final String answer;

  @override
  _AnswerContainerState createState() => _AnswerContainerState();
}

class _AnswerContainerState extends State<AnswerContainer> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.onTap(),
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: _isPressed
              ? widget._theme.primaryColor.withOpacity(.8)
              : widget._theme.primaryColor,
          borderRadius: const BorderRadius.all(
            Radius.circular(10),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Text(
            widget.answer,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
