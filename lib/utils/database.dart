import 'dart:math';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:homies/data/prompts-data.dart';
import 'package:homies/models/players.dart';
import 'package:homies/models/prompt.dart';
import 'package:homies/screens/home-screen.dart';
import 'package:random_string/random_string.dart';

class DatabaseConnection {
  DatabaseConnection._();

  static Future<String> createLobby(
      BuildContext context, int chosenDeck) async {
    final FirebaseFirestore db = FirebaseFirestore.instance;
    final String lobbyId = randomNumeric(5).toUpperCase();

    try {
      final bool isExisting = await db
          .collection('lobbies')
          .doc(lobbyId)
          .get()
          .then((DocumentSnapshot<Map<String, dynamic>> value) => value.exists);

      if (!isExisting) {
        await db.collection('lobbies').doc(lobbyId).set(
          <String, dynamic>{
            'state': 'lobby',
            'created-at': Timestamp.now(),
            'chosen-deck': chosenDeck,
            'current-round': 0,
          },
        );

        return lobbyId;
      } else {
        createLobby(context, chosenDeck);
      }
    } catch (e) {
      showOkCancelAlertDialog(
        context: context,
        message: e.toString(),
      );
    }
    return 'INVALID';
  }

  static Future<bool> validLobby(BuildContext context, String lobbyId) async {
    final FirebaseFirestore db = FirebaseFirestore.instance;

    try {
      if (lobbyId.isEmpty) return false;

      final DocumentSnapshot<Map<String, dynamic>> data =
          await db.collection('lobbies').doc(lobbyId.toUpperCase()).get();

      if (data.exists && data.data()!['state'] == 'lobby') return true;
    } catch (e) {
      showOkAlertDialog(
        context: context,
        message: e.toString(),
      );
    }

    return false;
  }

  static Future<void> joinLobby(BuildContext context, String lobbyId,
      String name, PlayerMode playerMode) async {
    final FirebaseFirestore db = FirebaseFirestore.instance;

    try {
      await db.collection('lobbies').doc(lobbyId).collection('players').add(
        {
          'player-mode': playerMode.toString(),
          'name': name.toUpperCase(),
          'points': 0,
          'did-submit': false,
        },
      ).then((DocumentReference<Map<String, dynamic>> value) {
        db
            .collection('lobbies')
            .doc(lobbyId)
            .collection('players')
            .doc(value.id)
            .update(
          {
            'player-mode': playerMode.toString(),
            'name': name.toUpperCase(),
            'points': 0,
            'player-id': value.id,
            'did-submit': false,
          },
        );

        currentPlayer =
            Player(id: value.id, name: name, playerMode: playerMode, points: 0);
      });
    } catch (e) {
      print('2');
      showOkAlertDialog(
        context: context,
        message: e.toString(),
      );
    }
  }

  static Future<bool> validName(
      BuildContext context, String lobbyId, String name) async {
    final FirebaseFirestore db = FirebaseFirestore.instance;

    try {
      final QuerySnapshot<Map<String, dynamic>> data = await db
          .collection('lobbies')
          .doc(lobbyId)
          .collection('players')
          .get();

      if (data.size > 0) {
        final int length = data.size;
        for (int i = 0; i < length; i++) {
          if (data.docs[i].data()['name'] == name) {
            return false;
          }
        }
      }
      return true;
    } catch (e) {
      showOkAlertDialog(
        context: context,
        message: e.toString(),
      );
    }
    return false;
  }

  static Future<void> changeState(
      BuildContext context, String state, String lobbyId) async {
    final FirebaseFirestore db = FirebaseFirestore.instance;

    try {
      await db.collection('lobbies').doc(lobbyId).update(
        <String, dynamic>{
          'state': state,
        },
      );
    } catch (e) {
      showOkAlertDialog(
        context: context,
        message: e.toString(),
      );
    }
  }

  static Future<void> submitPrompts(
      BuildContext context, String lobbyId, int chosenDeck) async {
    final FirebaseFirestore db = FirebaseFirestore.instance;

    try {
      final List<Prompt> promptList = allPromptDecks[chosenDeck].prompts;
      final List<String> promptsToUse = <String>[];
      final Random random = Random();
      const int roundLength = 5;

      for (int i = 0; i < roundLength; i++) {
        final int randomNr = random.nextInt(promptList.length);
        promptsToUse.add(promptList[randomNr].prompt);
        await db
            .collection('lobbies')
            .doc(lobbyId)
            .collection('prompts')
            .add(<String, dynamic>{
          'prompt-string': promptsToUse[i],
          'answers': <dynamic>[],
        });
      }
    } catch (e) {
      showOkAlertDialog(
        context: context,
        message: e.toString(),
      );
    }
  }

  static Future<void> submitAnswer(BuildContext context, int multiplicator,
      String author, String answerSubmitted, String lobbyId, int round) async {
    final FirebaseFirestore db = FirebaseFirestore.instance;

    try {
      final QuerySnapshot<Map<String, dynamic>> data = await db
          .collection('lobbies')
          .doc(lobbyId)
          .collection('prompts')
          .get();

      await db
          .collection('lobbies')
          .doc(lobbyId)
          .collection('prompts')
          .doc(data.docs[round].id)
          .update({
        'answers': FieldValue.arrayUnion(
          <Map<String, dynamic>>[
            <String, dynamic>{
              'author': author,
              'answer-string': answerSubmitted,
              'multiplicator': multiplicator
            }
          ],
        )
      });

      print(data.docs[0].data()['answers']);
    } catch (e) {
      showOkAlertDialog(
        context: context,
        message: e.toString(),
      );
    }
  }
}
