import 'package:flutter/material.dart';
import 'package:homies/models/players.dart';

class Players with ChangeNotifier {
  late Player _item;

  Player get items {
    return _item;
  }
}
