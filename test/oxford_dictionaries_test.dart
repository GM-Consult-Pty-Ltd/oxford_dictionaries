// Copyright ©2022, GM Consult (Pty) Ltd.
// BSD 3-Clause License
// All rights reserved

// ignore_for_file: unused_import, unused_local_variable

@Timeout(Duration(minutes: 5))

import 'package:oxford_dictionaries/oxford_dictionaries.dart';
import 'package:gmconsult_proprietary/gmconsult_proprietary.dart';
import 'package:oxford_dictionaries/src/endpoints/_index.dart';
import 'package:oxford_dictionaries/src/endpoints/thesaurus_endpoint.dart';
import 'package:test/test.dart';
import 'package:gmconsult_dev/gmconsult_dev.dart';

void main() {
  group('ENDPOINTS', () {
    //

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

    test('WordsEndpoint', () async {
      // define a term with incorrect spelling.
      final misspeltterm = 'appel';

      // define a correctly spelled term.
      final term = 'swimming';

      final props = await WordsEndpoint.query(
          term, GMConsultKeys.oxfordDictionariesHeaders);

      expect(props != null, true);
      if (props != null) {
        _printTermProps(props);
      }
    });

    test('ThesaurusEndpoint', () async {
      // define a term with incorrect spelling.
      final misspeltterm = 'appel';

      // define a correctly spelled term.
      final term = 'low';

      final props = await ThesaurusEndpoint.query(
          term, GMConsultKeys.oxfordDictionariesHeaders);

      expect(props != null, true);
      if (props != null) {
        _printTermProps(props);
      }
    });

    test('LemmasEndpoint', () async {
      // define a correctly spelled term.
      final term = 'swimming';

      final props = await LemmasEndpoint.query(
          term, GMConsultKeys.oxfordDictionariesHeaders);

      expect(props != null, true);
      if (props != null) {
        _printTermProps(props);
      }
    });
  });
}

void _printTermProps(TermProperties props) {
  final results = [
    {'Property': 'Term', 'TestResult': props.term},
    {'Property': 'Stem', 'TestResult': props.stem},
    {'Property': 'Definitions', 'TestResult': props.definitionsFor()},
    {'Property': 'Lemmas', 'TestResult': props.lemmasOf()},
    {'Property': 'Etymologies', 'TestResult': props.etymologiesOf()},
    {
      'Property': 'Pronunciations',
      'TestResult': props.pronunciationsOf().map((e) => e.phoneticSpelling)
    },
    {'Property': 'Synonyms', 'TestResult': props.synonymsOf()},
    {'Property': 'Antonyms', 'TestResult': props.antonymsOf()},
    {'Property': 'Inflections', 'TestResult': props.inflectionsOf()},
    {'Property': 'Usage', 'TestResult': props.phrasesWith()}
  ];

  Console.out(
      title: '[DictoSaurus] METHODS EXAMPLE',
      results: results,
      minPrintWidth: 140,
      maxColWidth: 120);
}
