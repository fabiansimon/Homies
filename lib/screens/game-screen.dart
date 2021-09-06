import 'dart:async';
import 'dart:collection';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';
import 'package:homies/models/answer.dart';
import 'package:homies/models/players.dart';
import 'package:homies/models/round-information.dart';
import 'package:homies/models/user-ranking.dart';
import 'package:homies/utils/database.dart';
import 'package:homies/widgets/answers-wrap.dart';
import 'package:homies/widgets/keyboard-container.dart';
import 'package:homies/widgets/main-button.dart';
import 'package:homies/widgets/top-bar.dart';

import 'home-screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({
    Key? key,
    required this.playerMode,
    required this.lobbyId,
  });
  final PlayerMode playerMode;
  final String lobbyId;

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // init bool
  bool _isInit = false;

  // Boolean for Loading
  bool _isLoading = false;

  // current Round Information
  RoundInfo _currentRoundInfo = RoundInfo(points: 0, prompt: '', round: 0);

  // multiplicator int
  int _currentMultiplicator = 1;

  // Keyboard Controller
  final TextEditingController _controller = TextEditingController();

  // Controller to control the PageView and the animation details
  final PageController _pageController = PageController();
  final Duration _duration = const Duration(milliseconds: 200);
  final Curve _curve = Curves.easeIn;

  final List<Answer> _answerList = <Answer>[];
  final List<UserRanking> _currentRanking = <UserRanking>[];

  // definitely not done - value is not getting changed from an AnswerWrapWidget
  final int _chosenAnswer = 0;

  Future<void> _getRankingInfo() async {
    final CollectionReference<Map<String, dynamic>> db = FirebaseFirestore
        .instance
        .collection('lobbies')
        .doc(widget.lobbyId)
        .collection('players');

    try {
      final QuerySnapshot<Map<String, dynamic>> data = await db.get();

      _currentRanking.clear();

      for (int i = 0; i < data.docs.length; i++) {
        _currentRanking.add(UserRanking(
          name: data.docs[i]['name'] as String,
          points: data.docs[i]['points'] as int,
        ));
      }

      setState(() {
        _currentRanking.sort(
            (UserRanking a, UserRanking b) => a.points.compareTo(b.points));
      });

      print(_currentRanking[0].points);
    } catch (e) {
      showOkAlertDialog(context: context, message: e.toString());
    }
  }

  // Function to change state as Host
  Future<void> _nextState(String state) async {
    if (widget.playerMode == PlayerMode.HOST_MODE) {
      await DatabaseConnection.changeState(
        context,
        state,
        widget.lobbyId,
      );
    }
  }

  // Submit Voting Info
  Future<void> _submitVoting() async {
    print(_chosenAnswer);
  }

  // Get ranking Data
  Future<void> _getVotingInfo() async {
    final FirebaseFirestore db = FirebaseFirestore.instance;

    try {
      final QuerySnapshot<Map<String, dynamic>> data = await db
          .collection('lobbies')
          .doc(widget.lobbyId)
          .collection('prompts')
          .get();

      final dynamic answers =
          data.docs[_currentRoundInfo.round].data()['answers'];
      final answersLength = answers.length as int;

      _answerList.clear();

      for (int i = 0; i < answersLength; i++) {
        setState(() {
          _answerList.add(
            Answer(
              answer: answers[i]['answer-string'] as String,
              author: answers[i]['author'] as String,
              multiplicator: answers[i]['multiplicator'] as int,
            ),
          );
        });
      }
      print(_answerList.length);
    } catch (e) {
      print(e);
    }
  }

  // send Prompt Answer
  Future<void> _sendAnswer() async {
    final DocumentReference<Map<String, dynamic>> db =
        FirebaseFirestore.instance.collection('lobbies').doc(widget.lobbyId);

    try {
      final String answerString = _controller.text.toUpperCase().trim();
      _controller.clear();
      final DocumentSnapshot<Map<String, dynamic>> currentPlayerInfo =
          await db.collection('players').doc(currentPlayer.id).get();

      if (currentPlayerInfo['did-submit'] == false) {
        await db
            .collection('players')
            .doc(currentPlayer.id)
            .update(<String, dynamic>{
          'did-submit': true,
        });
        await DatabaseConnection.submitAnswer(
          context,
          _currentMultiplicator,
          currentPlayer.id ?? 'INVALID',
          answerString,
          widget.lobbyId,
          _currentRoundInfo.round,
        );
        final QuerySnapshot<Map<String, dynamic>> promptsData =
            await db.collection('prompts').get();

        final QuerySnapshot<Map<String, dynamic>> playersData =
            await db.collection('players').get();

        final int answersLength =
            promptsData.docs[0].data()['answers'].length as int;
        final int playersLength = playersData.docs.length;

        if (answersLength == playersLength) {
          await DatabaseConnection.changeState(
              context, 'voting', widget.lobbyId);
        }
        await _getVotingInfo();
      }
    } catch (e) {
      showOkAlertDialog(context: context, message: e.toString());
    }
  }

  // Get inital Data
  Future<void> _getInitalData() async {
    final FirebaseFirestore db = FirebaseFirestore.instance;

    setState(() {
      _isLoading = true;
    });

    try {
      final DocumentSnapshot<Map<String, dynamic>> roundData =
          await db.collection('lobbies').doc(widget.lobbyId).get();

      final QuerySnapshot<Map<String, dynamic>> playerData = await db
          .collection('lobbies')
          .doc(widget.lobbyId)
          .collection('players')
          .where('player-id', isEqualTo: currentPlayer.id)
          .get();

      final QuerySnapshot<Map<String, dynamic>> promptData = await db
          .collection('lobbies')
          .doc(widget.lobbyId)
          .collection('prompts')
          .get();

      final int points = playerData.docs[0].data()['points'] as int;
      final int round = roundData.data()!['current-round'] as int;
      final String prompt = promptData.docs[_currentRoundInfo.round]
          .data()['prompt-string'] as String;

      setState(() {
        _currentRoundInfo =
            RoundInfo(prompt: prompt, points: points, round: round);
        _isLoading = false;
      });
    } catch (e) {
      print(e);
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void didUpdateWidget(covariant GameScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _getInitalData();
    _getVotingInfo();
  }

  @override
  void initState() {
    super.initState();
    if (!_isInit) {
      _getInitalData();
      _isInit = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size _screenSize = MediaQuery.of(context).size;
    final ThemeData _theme = Theme.of(context);
    final FirebaseFirestore db = FirebaseFirestore.instance;
    return GestureDetector(
      onTap: () {
        if (FocusScope.of(context).isFirstFocus) {
          FocusScope.of(context).unfocus();
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: _isLoading
            ? Container(
                color: _theme.backgroundColor,
                child: const Center(
                  child: Text(
                    'GETTING NEXT ROUNDS\n INFORMATION',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                    ),
                  ),
                ),
              )
            : StreamBuilder<DocumentSnapshot<Object>>(
                stream:
                    db.collection('lobbies').doc(widget.lobbyId).snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<DocumentSnapshot<Object>> snapshot) {
                  // if (snapshot.connectionState == ConnectionState.waiting) {
                  //   return const Center(
                  //     child: CupertinoActivityIndicator(),
                  //   );
                  // }
                  if (!snapshot.data!.exists) {
                    WidgetsBinding.instance!.addPostFrameCallback((_) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute<BuildContext>(
                          builder: (BuildContext context) => HomeScreen(),
                        ),
                      );
                    });
                    return const SizedBox();
                  }
                  if (!snapshot.hasData) {
                    return const Center(
                      child: Text('No data wth'),
                    );
                  }
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('Something went wrong'),
                    );
                  }

                  final String state = snapshot.data!.get('state') as String;
                  // print("state  " + state.toString());

                  if (state == 'ranking') {
                    if (_pageController.hasClients &&
                        _pageController.page != 2) {
                      _getRankingInfo();
                      _pageController.animateToPage(2,
                          duration: _duration, curve: _curve);
                    }
                  }

                  if (state == 'voting') {
                    if (_pageController.hasClients &&
                        _pageController.page != 1) {
                      _pageController.animateToPage(1,
                          duration: _duration, curve: _curve);
                    }
                  }

                  if (state == 'playing') {
                    if (_pageController.hasClients &&
                        _pageController.page != 0) {
                      _pageController.animateToPage(0,
                          duration: _duration, curve: _curve);
                    }
                  }

                  return Container(
                    height: _screenSize.height,
                    width: _screenSize.width,
                    color: Colors.white,
                    child: Stack(
                      children: <Widget>[
                        Opacity(
                          opacity: .5,
                          child: Image.asset(
                            'assets/doodle.png',
                            fit: BoxFit.fitHeight,
                          ),
                        ),
                        PageView(
                          physics: const NeverScrollableScrollPhysics(),
                          controller: _pageController,
                          children: <Widget>[
                            buildGameView(_theme),
                            buildVotingView(_theme),
                            buildRankingView(_theme),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget buildGameView(ThemeData _theme) {
    return Stack(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SizedBox(height: 50),
              TopBar(
                points: _currentRoundInfo.points,
                isVoting: false,
              ),
              const SizedBox(height: 10),
              FAProgressBar(
                backgroundColor: _theme.accentColor.withOpacity(.3),
                progressColor: _theme.accentColor,
                maxValue: 60,
                currentValue: 60,
                borderRadius: const BorderRadius.all(
                  Radius.circular(10),
                ),
                displayText: ' seconds',
              ),
              const SizedBox(height: 70),
              Text(
                // "WHAT IS THE WEIRDEST THING OBAMA EVER DID?",
                _currentRoundInfo.prompt,
                style: const TextStyle(
                  letterSpacing: -.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                  fontSize: 30,
                ),
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 38.0),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: KeyboardContainer(
              multplicator: _currentMultiplicator,
              controller: _controller,
              onSend: () async {
                _sendAnswer();
              },
            ),
          ),
        )
      ],
    );
  }

  Widget buildVotingView(ThemeData _theme) {
    return Stack(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SizedBox(height: 50),
              const TopBar(
                points: 1,
                isVoting: true,
              ),
              const SizedBox(height: 10),
              FAProgressBar(
                backgroundColor: _theme.accentColor.withOpacity(.3),
                progressColor: _theme.accentColor,
                maxValue: 60,
                currentValue: 60,
                borderRadius: const BorderRadius.all(
                  Radius.circular(10),
                ),
                displayText: ' seconds',
              ),
              const SizedBox(height: 70),
              Text(
                // "WHAT IS THE WEIRDEST THING OBAMA EVER DID?",
                _currentRoundInfo.prompt,
                style: const TextStyle(
                  letterSpacing: -.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                  fontSize: 30,
                ),
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 50.0),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  AnswersWrap(
                    answers: _answerList,
                    chosenAnswer: _chosenAnswer,
                  ),
                  const SizedBox(height: 100),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28.0),
                    child: MainButton(
                      borderColor: _theme.primaryColor,
                      backgroundColor: _theme.primaryColor,
                      textColor: Colors.white,
                      shadowColor: _theme.primaryColor,
                      string: 'Submit',
                      onTap: () async => _submitVoting(),
                      // onTap: () async => _nextState("ranking"),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Align(
                    child: Text(
                      '2/4',
                      style: TextStyle(
                        letterSpacing: -.5,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildRankingView(ThemeData _theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 34.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text(
              'Current Ranking',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                fontSize: 30.0,
              ),
            ),
            const SizedBox(height: 25.0),
            Container(
              decoration: BoxDecoration(
                color: _theme.primaryColor,
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    blurRadius: 10,
                    color: _theme.primaryColor.withOpacity(.5),
                  )
                ],
                borderRadius: const BorderRadius.all(
                  Radius.circular(10),
                ),
              ),
              child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: MediaQuery.removePadding(
                    context: context,
                    removeTop: true,
                    removeBottom: true,
                    child: ListView.builder(
                      reverse: true,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _currentRanking.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 6.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                // ignore: lines_longer_than_80_chars
                                '${_currentRanking.length - index}. ${_currentRanking[index].name}',
                                style: const TextStyle(
                                  fontSize: 18.0,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${_currentRanking[index].points} pts.',
                                style: const TextStyle(
                                  fontSize: 18.0,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  )),
            ),
            const SizedBox(height: 25.0),
            MainButton(
              borderColor: widget.playerMode == PlayerMode.HOST_MODE
                  ? _theme.primaryColor
                  : Colors.black12,
              backgroundColor: widget.playerMode == PlayerMode.HOST_MODE
                  ? _theme.primaryColor
                  : Colors.grey.shade300,
              textColor: widget.playerMode == PlayerMode.HOST_MODE
                  ? Colors.white
                  : Colors.grey,
              shadowColor: widget.playerMode == PlayerMode.HOST_MODE
                  ? _theme.primaryColor
                  : Colors.white,
              string: widget.playerMode == PlayerMode.HOST_MODE
                  ? 'Start'
                  : 'Wait for host to start',
              onTap: () {
                _getRankingInfo();
                // _nextState("playing");
              },
            ),
          ],
        ),
      ),
    );
  }
}
