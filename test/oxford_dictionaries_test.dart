// Copyright ©2022, GM Consult (Pty) Ltd.
// BSD 3-Clause License
// All rights reserved

// ignore_for_file: unused_import, unused_local_variable

@Timeout(Duration(minutes: 5))

import 'package:oxford_dictionaries/oxford_dictionaries.dart';
import 'package:gmconsult_proprietary/gmconsult_proprietary.dart';
import 'package:oxford_dictionaries/src/endpoints/_index.dart';
import 'package:test/test.dart';
import 'package:gmconsult_dev/gmconsult_dev.dart';

final appId = GMConsultKeys.oxfordDictionariesHeaders['app_id'] as String;
final appKey = GMConsultKeys.oxfordDictionariesHeaders['app_key'] as String;

void main() {
  group('ENDPOINTS', () {
    //

    test('EntriesEndpoint', () async {
      // define a correctly spelled term.
      final term = 'swim';

      final props = await EntriesEndpoint.query(
          term, GMConsultKeys.oxfordDictionariesHeaders);

      expect(props != null, true);
      if (props != null) {
        _printTermProps(props);
      }
    });

    test('TranslationsEndpoint', () async {
      // define a correctly spelled term.
      final term = 'swim';

      final translations =
          await OxfordDictionaries(appId: appId, appKey: appKey)
              .translate(term, OxfordDictionariesLanguage.de);
      print(translations.map((e) => e.term));
    });

    test('WordsEndpoint', () async {
      // define a correctly spelled term.
      final term = 'swimming';

      final props = await OxfordDictionaries(
              appId: appId,
              appKey: appKey,
              language: OxfordDictionariesLanguage.en_GB)
          .getEntry(term, OxfordDictionariesEndpoint.words);

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

      final props = await OxfordDictionaries(
              appId: appId,
              appKey: appKey,
              language: OxfordDictionariesLanguage.en_GB)
          .getEntry(term, OxfordDictionariesEndpoint.lemmas);
      // await LemmasEndpoint.query(
      // term, GMConsultKeys.oxfordDictionariesHeaders);

      expect(props != null, true);
      if (props != null) {
        _printTermProps(props);
      }
    });

    test('SearchEndpoint', () async {
      // define a correctly spelled term.
      final term = 'teh';

      final results = await SearchEndpoint.query(
          term, GMConsultKeys.oxfordDictionariesHeaders,
          prefix: true, limit: 100);
      print(results);
    });

    test('OxfordDictionaries.suggestionsFor', () async {
      // define a correctly spelled term.
      final term = 'teh';

      final results = await OxfordDictionaries(appId: appId, appKey: appKey)
          .suggestionsFor(term, 20);
      print(results);
    });
  });
}

void _printTermProps(DictionaryEntry props) {
  final results = [
    {'Property': 'Term', 'TestResult': props.term},
    {'Property': 'Stem', 'TestResult': props.stem},
    {'Property': 'Definitions', 'TestResult': props.definitionsFor()},
    {'Property': 'LemmasEndpoint', 'TestResult': props.lemmasOf()},
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
