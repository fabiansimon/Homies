import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:homies/data/prompts-data.dart';
import 'package:homies/models/players.dart';
import 'package:homies/screens/game-screen.dart';
import 'package:homies/utils/database.dart';
import 'package:homies/widgets/deck-card.dart';
import 'package:homies/widgets/deck-carousel.dart';
import 'package:homies/widgets/headline.dart';
import 'package:homies/widgets/icon-bubble.dart';
import 'package:homies/widgets/input-container.dart';
import 'package:homies/widgets/main-button.dart';
import 'package:homies/widgets/name-chip.dart';
import 'package:random_string/random_string.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

enum PlayerMode {
  HOST_MODE,
  GUEST_MODE,
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final PageController _pageController = PageController();
  final PageController _carouselPageController = PageController();

  // Current Page between Home - Create/Join - Lobby
  int _currentPage = 0;

  // Choose a deck as the HOST
  int _chosenDeck = 0;

  // Check if loading
  bool _isLoading = false;
  // Check if screen is changed
  final bool _screenChanged = false;

  // final LobbyID
  String _lobbyID = '';

  PlayerMode _playerMode = PlayerMode.GUEST_MODE;

  final Duration _duration = const Duration(milliseconds: 200);
  final Curve _curve = Curves.easeIn;

  Future<void> _nextScreen(int screen, PlayerMode playerMode) async {
    if (FocusScope.of(context).isFirstFocus) {
      FocusScope.of(context).unfocus();
    }
    if (screen == 1 && _nameController.text.isNotEmpty) {
      // Animate to choose Deck Screen
      setState(() {
        _playerMode = playerMode;
      });
      _pageController.animateToPage(screen, duration: _duration, curve: _curve);
    } else if (screen == 0) {
      // Animate to First Screen
      _idController.clear();
      _pageController.animateToPage(screen, duration: _duration, curve: _curve);
      setState(() {
        _chosenDeck = 0;
        _currentPage = 0;
        _isLoading = false;
      });
    } else if (screen == 2) {
      _pageController.animateToPage(screen, duration: _duration, curve: _curve);
    } else {
      showOkAlertDialog(context: context, message: 'Please submit a name');
    }
  }

  Future<void> _joinLobby(String name) async {
    setState(() {
      _isLoading = true;
    });

    if (_playerMode == PlayerMode.HOST_MODE) {
      // Create lobby and get LobbyID
      final String lobbyId =
          await DatabaseConnection.createLobby(context, _chosenDeck);

      // Join Lobby with ID and Name
      await DatabaseConnection.joinLobby(
              context, lobbyId, _nameController.text.toUpperCase(), _playerMode)
          .then((_) async {
        // Choose prompts and upload them
        await DatabaseConnection.submitPrompts(context, lobbyId, _chosenDeck);
        setState(() {
          _lobbyID = lobbyId;
        });
        _nextScreen(2, _playerMode);
      });
    } else {
      final bool exists = await DatabaseConnection.validLobby(
          context, _idController.text.toUpperCase());

      final bool nameValid = await DatabaseConnection.validName(context,
          _idController.text.toUpperCase(), _nameController.text.toUpperCase());

      if (!exists) {
        showOkAlertDialog(
            context: context,
            message: 'Not a valid ID or the game already started');
        return;
      }
      if (!nameValid) {
        showOkAlertDialog(
            context: context, message: 'Please choose another name');
        return;
      }

      if (exists && nameValid) {
        await DatabaseConnection.joinLobby(
            context,
            _idController.text.toUpperCase(),
            _nameController.text,
            _playerMode);

        setState(() {
          _lobbyID = _idController.text.toUpperCase();
        });
        _nextScreen(2, _playerMode);
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _cancelLobby() async {
    final FirebaseFirestore db = FirebaseFirestore.instance;

    try {
      if (_playerMode == PlayerMode.HOST_MODE) {
        _nextScreen(0, _playerMode);
        await db.collection('lobbies').doc(_lobbyID).delete();
      } else {
        _nextScreen(0, _playerMode);
        await db
            .collection('lobbies')
            .doc(_lobbyID)
            .collection('players')
            .doc(currentPlayer.id)
            .delete();
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size _screenSize = MediaQuery.of(context).size;
    final ThemeData _theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        if (FocusScope.of(context).isFirstFocus) {
          FocusScope.of(context).unfocus();
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                        left: 38.0,
                        top: 50.0,
                        bottom: _screenSize.height * .12),
                    child: IconBubble(),
                  ),
                  Expanded(
                    child: PageView(
                      physics: const NeverScrollableScrollPhysics(),
                      controller: _pageController,
                      children: [
                        buildMainView(_theme),
                        buildJoinView(_theme),
                        if (_lobbyID != '') buildLobbyView(_theme),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildMainView(ThemeData _theme) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 54.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Headline(
                topText: 'Welcome to',
                bottomText: 'HOMIES',
              ),
              const SizedBox(height: 20),
              const Text(
                'Type in your name and start having fun!',
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 40),
              InputContainer(
                controller: _nameController,
                inputType: TextInputType.name,
                hintText: 'Your name',
              ),
              const SizedBox(height: 30),
              MainButton(
                string: 'Create game',
                backgroundColor: _theme.primaryColor,
                borderColor: _theme.primaryColor,
                shadowColor: _theme.primaryColor,
                textColor: Colors.white,
                onTap: () => _nextScreen(1, PlayerMode.HOST_MODE),
              ),
              const SizedBox(height: 10),
              MainButton(
                string: 'Join game',
                backgroundColor: Colors.white,
                borderColor: _theme.accentColor,
                shadowColor: _theme.accentColor,
                textColor: _theme.accentColor,
                onTap: () => _nextScreen(1, PlayerMode.GUEST_MODE),
              ),
            ],
          ),
        ),
        const Spacer(),
        DeckCarousel(),
      ],
    );
  }

  Widget buildJoinView(ThemeData _theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 54.0),
          child: Headline(
            topText: _playerMode == PlayerMode.HOST_MODE
                ? "Let's get this"
                : 'Enter the',
            bottomText:
                _playerMode == PlayerMode.HOST_MODE ? 'STARTED' : 'LOBBYCODE',
          ),
        ),
        const SizedBox(height: 40),
        if (_playerMode == PlayerMode.HOST_MODE)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              buildChoseDeckCarousel(),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 54.0),
                child: _isLoading
                    ? const Center(
                        child: CupertinoActivityIndicator(),
                      )
                    : Column(
                        children: <Widget>[
                          MainButton(
                            string: 'Next',
                            backgroundColor: _theme.primaryColor,
                            borderColor: _theme.primaryColor,
                            shadowColor: _theme.primaryColor,
                            textColor: Colors.white,
                            onTap: () => _joinLobby(_nameController.text),
                          ),
                          const SizedBox(height: 10),
                          MainButton(
                            string: 'Back',
                            backgroundColor: Colors.white,
                            borderColor: _theme.accentColor,
                            shadowColor: _theme.accentColor,
                            textColor: _theme.accentColor,
                            onTap: () => _nextScreen(0, PlayerMode.HOST_MODE),
                          ),
                        ],
                      ),
              ),
            ],
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 54.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 50),
                InputContainer(
                  controller: _idController,
                  inputType: TextInputType.number,
                  hintText: 'Lobby Code',
                ),
                const SizedBox(height: 20),
                if (_isLoading)
                  const Center(
                    child: CupertinoActivityIndicator(),
                  )
                else
                  Column(
                    children: <Widget>[
                      MainButton(
                        borderColor: _theme.primaryColor,
                        backgroundColor: _theme.primaryColor,
                        textColor: Colors.white,
                        shadowColor: _theme.primaryColor,
                        string: 'Join',
                        onTap: () => _joinLobby(_nameController.text),
                      ),
                      const SizedBox(height: 10),
                      MainButton(
                        borderColor: _theme.accentColor,
                        backgroundColor: Colors.white,
                        textColor: _theme.accentColor,
                        shadowColor: _theme.accentColor,
                        string: 'Back',
                        onTap: () => _nextScreen(0, PlayerMode.GUEST_MODE),
                      ),
                    ],
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget buildLobbyView(ThemeData _theme) {
    final FirebaseFirestore db = FirebaseFirestore.instance;
    int playersLength = 0;

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 54.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Headline(
                topText: 'Share the code to',
                bottomText: 'JOIN',
              ),
              const SizedBox(height: 50),
              SizedBox(
                width: double.infinity,
                child: Column(
                  children: <Widget>[
                    const Text(
                      'LOBBY CODE',
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(100),
                        ),
                        color: Colors.black87,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18.0, vertical: 4.0),
                        child: Text(
                          _lobbyID,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const Divider(
                      thickness: 2,
                      color: Colors.black12,
                      height: 40,
                    ),
                    const Text(
                      'CURRENT PLAYERS',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    StreamBuilder<DocumentSnapshot<Object>>(
                      stream:
                          db.collection('lobbies').doc(_lobbyID).snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<DocumentSnapshot<Object?>> snapshot) {
                        if (!snapshot.data!.exists) {
                          _nextScreen(0, _playerMode);
                          return const SizedBox();
                        }

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CupertinoActivityIndicator(),
                          );
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

                        final String state =
                            snapshot.data!.get('state') as String;

                        if (state == 'playing') {
                          WidgetsBinding.instance!.addPostFrameCallback((_) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute<BuildContext>(
                                builder: (BuildContext context) => GameScreen(
                                  lobbyId: _lobbyID,
                                  playerMode: _playerMode,
                                ),
                              ),
                            );
                          });
                        }

                        return StreamBuilder<QuerySnapshot<Object>>(
                          stream: db
                              .collection('lobbies')
                              .doc(_lobbyID)
                              .collection('players')
                              .snapshots(),
                          builder: (BuildContext context,
                              AsyncSnapshot<QuerySnapshot<Object>> snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CupertinoActivityIndicator(),
                              );
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

                            playersLength = snapshot.data!.docs.length;
                            final List<QueryDocumentSnapshot<Object>> players =
                                snapshot.data!.docs.toList();

                            return Wrap(
                              alignment: WrapAlignment.center,
                              children: List<Widget>.generate(
                                playersLength,
                                (int index) {
                                  return NameChip(
                                    name: players[index]['name'] as String,
                                    isHost: players[index]['player-mode'] ==
                                        'PlayerMode.HOST_MODE',
                                  );
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),
              MainButton(
                borderColor: _playerMode == PlayerMode.HOST_MODE
                    ? _theme.primaryColor
                    : Colors.black12,
                backgroundColor: _playerMode == PlayerMode.HOST_MODE
                    ? _theme.primaryColor
                    : Colors.grey.shade300,
                textColor: _playerMode == PlayerMode.HOST_MODE
                    ? Colors.white
                    : Colors.grey,
                shadowColor: _playerMode == PlayerMode.HOST_MODE
                    ? _theme.primaryColor
                    : Colors.white,
                string: _playerMode == PlayerMode.HOST_MODE
                    ? 'Start'
                    : 'Wait for host to start',
                onTap: () {
                  if (_playerMode == PlayerMode.HOST_MODE &&
                      playersLength > 1) {
                    DatabaseConnection.changeState(
                        context, 'playing', _lobbyID);
                  } else if (_playerMode == PlayerMode.HOST_MODE) {
                    showOkAlertDialog(
                        context: context,
                        message: 'You need at least 2 Players');
                  }
                },
              ),
              const SizedBox(height: 10),
              MainButton(
                borderColor: _theme.accentColor,
                backgroundColor: Colors.white,
                textColor: _theme.accentColor,
                shadowColor: _theme.accentColor,
                string: 'Cancel',
                onTap: () => _cancelLobby(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildChoseDeckCarousel() {
    return Stack(
      children: <Widget>[
        Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
              ),
            ],
          ),
          height: MediaQuery.of(context).size.height * .235,
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 28.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const <Widget>[
                      Text(
                        'Choose a deck',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'Or get some new ones to spicy it up!',
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 80,
                  child: PageView.builder(
                    controller: _carouselPageController,
                    physics: const BouncingScrollPhysics(),
                    itemCount: allPromptDecks.length,
                    onPageChanged: (int value) {
                      setState(() {
                        _currentPage = value;
                      });
                    },
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18.0),
                        child: Stack(
                          fit: StackFit.expand,
                          alignment: Alignment.center,
                          children: <Widget>[
                            DeckCard(
                              onTap: () {
                                if (!allPromptDecks[index].isLocked) {
                                  setState(() {
                                    _chosenDeck = index;
                                    print(_chosenDeck);
                                  });
                                } else {
                                  print('PURCHASE NOW');
                                }
                              },
                              promptDeck: allPromptDecks[index],
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 12.0),
                                child: Icon(
                                  CupertinoIcons.check_mark_circled,
                                  color: _chosenDeck == index
                                      ? Colors.white
                                      : Colors.transparent,
                                  size: 30,
                                ),
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List<Widget>.generate(
                    allPromptDecks.length,
                    (int index) {
                      return Container(
                        margin: const EdgeInsets.only(right: 3.0),
                        height: 7,
                        width: 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentPage == index
                              ? Colors.black38
                              : Colors.black12,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              height: 200,
              width: 20,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: <Color>[
                    Colors.white.withOpacity(.3),
                    Colors.white.withOpacity(0)
                  ],
                ),
              ),
            ),
            Container(
              height: 210,
              width: 20,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: <Color>[
                    Colors.white.withOpacity(0),
                    Colors.white.withOpacity(.3)
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
