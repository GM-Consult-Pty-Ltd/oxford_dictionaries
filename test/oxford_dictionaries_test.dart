// Copyright ©2022, GM Consult (Pty) Ltd.
// BSD 3-Clause License
// All rights reserved

// ignore_for_file: unused_import, unused_local_variable

import 'package:oxford_dictionaries/oxford_dictionaries.dart';
import 'package:gmconsult_proprietary/gmconsult_proprietary.dart';
import 'package:oxford_dictionaries/src/endpoints/_index.dart';
import 'package:test/test.dart';
import 'package:gmconsult_dev/gmconsult_dev.dart';

void main() {
  group('ENDPOINTS', () {
    //

    test('WordsEndpoint', () async {
      // define a term with incorrect spelling.
      final misspeltterm = 'appel';

      // define a correctly spelled term.
      final term = 'swim';

      final props = await WordsEndpoint.query(
          term, GMConsultKeys.oxfordDictionariesHeaders);

      expect(props != null, true);
      if (props != null) {
        _printTermProps(props);
      }
    });

    test('EntriesEndpoint', () async {
      // define a term with incorrect spelling.
      final misspeltterm = 'appel';

      // define a correctly spelled term.
      final term = 'swim';

      final props = await EntriesEndpoint.query(
          term, GMConsultKeys.oxfordDictionariesHeaders);

      expect(props != null, true);
      if (props != null) {
        _printTermProps(props);
      }
    });
  });
}

void _printTermProps(TermProperties props) {
  final results = <Map<String, dynamic>>[];

  final term = props.term;

  // get the defintions
  final definitions = props.definitionsFor();

  // get the synonyms
  final synonyms = props.synonymsOf();

  // get the lemmas
  final lemmas = props.lemmasOf();

  // get the antonyms
  final antonyms = props.antonymsOf();

  // get the inflections
  final inflections = props.inflectionsOf();

  // get the phrases
  final phrases = props.phrasesWith();

  results.add({'Method': 'definitionsFor("$term")', 'TestResult': definitions});
  results.add({'Method': 'synonymsOf("$term")', 'TestResult': synonyms});
  results.add({'Method': 'lemmasOf("$term")', 'TestResult': synonyms});
  results.add({'Method': 'antonymsOf("$term")', 'TestResult': antonyms});
  results.add({'Method': 'inflectionsOf("$term")', 'TestResult': inflections});
  results.add({'Method': 'phrasesWith("$term")', 'TestResult': phrases});

  Console.out(title: '[DictoSaurus] METHODS EXAMPLE', results: results);
}
