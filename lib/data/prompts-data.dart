import 'package:homies/models/prompt-deck.dart';
import 'package:homies/models/prompt.dart';

List<Prompt> promptsNormal = <Prompt>[
  Prompt(prompt: 'What is Andreas dumbest story? (N-0)', isUsed: false),
  Prompt(prompt: 'Why is Clembo always stressed out? (N-1)', isUsed: false),
  Prompt(prompt: "What is Dennis's favourite color? (N-3)", isUsed: false),
  Prompt(prompt: 'Why is Jennelie blonde? (N-4)', isUsed: false),
  Prompt(prompt: 'Is Sharoon actually cool? (N-5)', isUsed: false),
  Prompt(prompt: 'What is Kathis pet? (N-6)', isUsed: false),
];
List<Prompt> promptsAdvanced = <Prompt>[
  Prompt(prompt: 'Advanced-0', isUsed: false),
  Prompt(prompt: 'Advanced-1', isUsed: false),
  Prompt(prompt: 'Advanced-2', isUsed: false),
  Prompt(prompt: 'Advanced-3', isUsed: false),
  Prompt(prompt: 'Advanced-4', isUsed: false),
  Prompt(prompt: 'Advanced-5', isUsed: false),
  Prompt(prompt: 'Advanced-6', isUsed: false),
  Prompt(prompt: 'Advanced-7', isUsed: false),
  Prompt(prompt: 'Advanced-8', isUsed: false),
  Prompt(prompt: 'Advanced-9', isUsed: false),
];
List<Prompt> promptsSpicy = <Prompt>[
  Prompt(prompt: 'Spicy-0', isUsed: false),
  Prompt(prompt: 'Spicy-1', isUsed: false),
  Prompt(prompt: 'Spicy-2', isUsed: false),
  Prompt(prompt: 'Spicy-3', isUsed: false),
  Prompt(prompt: 'Spicy-4', isUsed: false),
  Prompt(prompt: 'Spicy-5', isUsed: false),
  Prompt(prompt: 'Spicy-6', isUsed: false),
  Prompt(prompt: 'Spicy-7', isUsed: false),
  Prompt(prompt: 'Spicy-8', isUsed: false),
  Prompt(prompt: 'Spicy-9', isUsed: false),
];
List<Prompt> promptsParty = <Prompt>[
  Prompt(prompt: 'Party-0', isUsed: false),
  Prompt(prompt: 'Party-1', isUsed: false),
  Prompt(prompt: 'Party-2', isUsed: false),
  Prompt(prompt: 'Party-3', isUsed: false),
  Prompt(prompt: 'Party-4', isUsed: false),
  Prompt(prompt: 'Party-5', isUsed: false),
  Prompt(prompt: 'Party-6', isUsed: false),
  Prompt(prompt: 'Party-7', isUsed: false),
  Prompt(prompt: 'Party-8', isUsed: false),
  Prompt(prompt: 'Party-9', isUsed: false),
];
List<Prompt> promptsAdult = <Prompt>[
  Prompt(prompt: 'Adult-0', isUsed: false),
  Prompt(prompt: 'Adult-1', isUsed: false),
  Prompt(prompt: 'Adult-2', isUsed: false),
  Prompt(prompt: 'Adult-3', isUsed: false),
  Prompt(prompt: 'Adult-4', isUsed: false),
  Prompt(prompt: 'Adult-5', isUsed: false),
  Prompt(prompt: 'Adult-6', isUsed: false),
  Prompt(prompt: 'Adult-7', isUsed: false),
  Prompt(prompt: 'Adult-8', isUsed: false),
  Prompt(prompt: 'Adult-9', isUsed: false),
];

List<PromptDeck> allPromptDecks = <PromptDeck>[
  PromptDeck(
    title: 'Normal',
    description: 'Normal description',
    prompts: promptsNormal,
    isLocked: false,
  ),
  PromptDeck(
    title: 'Advanced',
    description: 'Advanced description',
    prompts: promptsAdvanced,
    isLocked: true,
  ),
  PromptDeck(
    title: 'Spicy',
    description: 'Spicy description',
    prompts: promptsSpicy,
    isLocked: true,
  ),
  PromptDeck(
    title: 'Party',
    description: 'Party description',
    prompts: promptsSpicy,
    isLocked: true,
  ),
  PromptDeck(
    title: 'Adult',
    description: 'Adult description',
    prompts: promptsAdult,
    isLocked: true,
  ),
];
