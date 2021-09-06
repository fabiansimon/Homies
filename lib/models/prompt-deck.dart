import 'package:homies/models/prompt.dart';

class PromptDeck {
  PromptDeck({
    required this.title,
    required this.description,
    required this.prompts,
    required this.isLocked,
  });
  String title;
  String description;
  List<Prompt> prompts;
  bool isLocked;
}
