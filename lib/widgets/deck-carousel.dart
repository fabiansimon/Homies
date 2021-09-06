import 'package:flutter/material.dart';
import 'package:homies/data/prompts-data.dart';
import 'package:homies/widgets/deck-card.dart';

class DeckCarousel extends StatefulWidget {
  @override
  DeckCarouselState createState() => DeckCarouselState();
}

class DeckCarouselState extends State<DeckCarousel> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 170,
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 28.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const <Widget>[
                Text(
                  'Get more decks',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  'More than +1200 new prompts',
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 28.0, left: 28.0),
              itemCount: allPromptDecks.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * .55,
                    child: DeckCard(
                      onTap: () => print('hey'),
                      promptDeck: allPromptDecks[index],
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
