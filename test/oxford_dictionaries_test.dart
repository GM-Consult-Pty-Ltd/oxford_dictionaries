// Copyright ©2022, GM Consult (Pty) Ltd.
// BSD 3-Clause License
// All rights reserved

// ignore_for_file: unused_import

import 'package:oxford_dictionaries/oxford_dictionaries.dart';
import 'package:gmconsult_proprietary/gmconsult_proprietary.dart';
import 'package:test/test.dart';
import 'package:gmconsult_dev/gmconsult_dev.dart';

void main() {
  group('A group of tests', () {
    setUp(() {
      // Additional setup goes here.
    });

    test('First Test', () async {
      final results = <Map<String, dynamic>>[];

      // define a term with incorrect spelling.
      final misspeltterm = 'appel';

      // define a correctly spelled term.
      final term = 'swim';
      final dictoSaurus = OxfordDictionaries(
          appId: GMConsultKeys.oxfordDictionariesHeaders['app_id'] as String,
          appKey: GMConsultKeys.oxfordDictionariesHeaders['app_key'] as String);
      // get spelling correction suggestions
      final corrections = await dictoSaurus.suggestionsFor(misspeltterm, 5);

      // expand the term
      final expansions = await dictoSaurus.expandTerm(term, 5);

      final props = await dictoSaurus.getEntry(term);

      // get the defintions
      final definitions = await dictoSaurus.synonymsOf(term);

      // get the synonyms
      final synonyms = await dictoSaurus.synonymsOf(term);

      // get the antonyms
      final antonyms = await dictoSaurus.antonymsOf(term);

      // get the inflections
      final inflections = await dictoSaurus.inflectionsOf(term);

      // get the phrases
      final phrases = await dictoSaurus.phrasesWith(term);

      results.add({
        'Method': 'suggestionsFor("$misspeltterm")',
        'TestResult': corrections
      });
      results.add({'Method': 'expandTerm("$term")', 'TestResult': expansions});
      results.add(
          {'Method': 'definitionsFor("$term")', 'TestResult': definitions});
      results.add({'Method': 'synonymsOf("$term")', 'TestResult': synonyms});
      results.add({'Method': 'antonymsOf("$term")', 'TestResult': antonyms});
      results
          .add({'Method': 'inflectionsOf("$term")', 'TestResult': inflections});
      results.add({'Method': 'phrasesWith("$term")', 'TestResult': phrases});

      Console.out(title: '[DictoSaurus] METHODS EXAMPLE', results: results);
    });
  });
}
