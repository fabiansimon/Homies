import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:homies/utils/database.dart';

class KeyboardContainer extends StatefulWidget {
  KeyboardContainer({
    Key? key,
    required this.onSend,
    required this.controller,
    required this.multplicator,
  }) : super(key: key);
  final Function() onSend;
  final TextEditingController controller;
  int multplicator;

  @override
  _KeyboardContainerState createState() => _KeyboardContainerState();
}

class _KeyboardContainerState extends State<KeyboardContainer> {
  @override
  Widget build(BuildContext context) {
    final ThemeData _theme = Theme.of(context);

    return KeyboardVisibilityBuilder(
      builder: (BuildContext context, bool isKeyboardVisible) {
        return AnimatedPadding(
          duration: const Duration(milliseconds: 400),
          curve: Curves.fastLinearToSlowEaseIn,
          padding: EdgeInsets.only(
              bottom: isKeyboardVisible
                  ? MediaQuery.of(context).viewInsets.bottom - 20
                  : 20),
          child: Container(
            width: MediaQuery.of(context).size.width * .9,
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color(0xFFDEDEDE),
              ),
              color: Colors.white,
              boxShadow: const <BoxShadow>[
                BoxShadow(blurRadius: 10, color: Colors.black12),
              ],
              borderRadius: const BorderRadius.all(
                Radius.circular(14),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              if (widget.multplicator == 2) {
                                widget.multplicator = 1;
                              } else {
                                widget.multplicator = 2;
                              }
                            });
                          },
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: widget.multplicator == 2
                                  ? _theme.primaryColor.withOpacity(1)
                                  : _theme.primaryColor.withOpacity(.5),
                              borderRadius: const BorderRadius.all(
                                Radius.circular(10),
                              ),
                            ),
                            child: const Center(
                              child: Text(
                                '2X',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              if (widget.multplicator == 3) {
                                widget.multplicator = 1;
                              } else {
                                widget.multplicator = 3;
                              }
                            });
                          },
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: widget.multplicator == 3
                                  ? _theme.primaryColor.withOpacity(1)
                                  : _theme.primaryColor.withOpacity(.5),
                              borderRadius: const BorderRadius.all(
                                Radius.circular(10),
                              ),
                            ),
                            child: const Center(
                              child: Text(
                                '3X',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: const BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Icon(
                            CupertinoIcons.pencil_circle_fill,
                            color: Colors.grey.shade400,
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            cursorColor: Colors.black,
                            maxLength: 30,
                            showCursor: false,
                            controller: widget.controller,
                            style: const TextStyle(
                              fontSize: 15.0,
                              color: Colors.black87,
                            ),
                            onSubmitted: (String value) => widget.onSend(),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              isCollapsed: true,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              hintText: 'Say something',
                              hintStyle: TextStyle(
                                fontWeight: FontWeight.w400,
                                color: Colors.grey.shade400,
                                fontSize: 15,
                              ),
                              counterText: '',
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: GestureDetector(
                            onTap: () => widget.onSend(),
                            child: Container(
                              height: 33,
                              width: 33,
                              decoration: BoxDecoration(
                                color: _theme.primaryColor,
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(10),
                                ),
                              ),
                              child: const Icon(
                                CupertinoIcons.paperplane_fill,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
