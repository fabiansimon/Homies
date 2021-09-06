import 'package:homies/screens/home-screen.dart';

class Player {
  Player({
    this.name,
    this.points,
    this.id,
    this.playerMode,
  });
  String? name;
  int? points;
  String? id;
  PlayerMode? playerMode;
}

Player currentPlayer = Player();
