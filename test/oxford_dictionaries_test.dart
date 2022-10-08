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
      final term = 'smart';
      final dictionary = OxfordDictionaries(
          appId: GMConsultKeys.oxfordDictionariesHeaders['app_id'] as String,
          appKey: GMConsultKeys.oxfordDictionariesHeaders['app_key'] as String);
      final definitions = await dictionary.definitionsFor(term);
      final inflections = await dictionary.inflectionsOf(term);
      final phrases = await dictionary.phrasesWith(term);
      print('Thesaurus methods on "$term":');
      print('Definitions:   $definitions');
      print('Inflections:   $inflections');
      print('Phrases:       $phrases');
    });
  });
}
