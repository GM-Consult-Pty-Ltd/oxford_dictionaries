// Copyright ©2022, GM Consult (Pty) Ltd.
// BSD 3-Clause License
// All rights reserved

import 'package:gmconsult_dart_core/type_definitions.dart';
import '../_common/oxford_dictionaries_endpoint.dart';
import 'endpoint.dart';
import 'package:dictosaurus/dictosaurus.dart';

/// Retrieve definitions, pronunciations, example sentences, grammatical
/// information and word origins.
class LemmasEndpoint extends Endpoint {
//

  /// Queries the [LemmasEndpoint] for a [TermProperties] for the [term] and
  /// optional parameters.
  static Future<TermProperties?> query(String term, Map<String, String> apiKeys,
          {String sourceLanguage = 'en-us',
          Iterable<String>? grammaticalFeatures,
          PartOfSpeech? lexicalCategory}) =>
      LemmasEndpoint._(term, apiKeys, sourceLanguage, grammaticalFeatures,
              lexicalCategory)
          .get();

  /// Const default generative constructor.
  const LemmasEndpoint._(this.term, this.headers, String sourceLanguage,
      this.grammaticalFeatures, this.lexicalCategory)
      : _sourceLanguage = sourceLanguage;

  @override
  final String term;

  @override
  String get sourceLanguage =>
      _sourceLanguage.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '-');
  final String _sourceLanguage;

  @override
  String get path => 'api/v2/lemmas/$sourceLanguage/${term.toLowerCase()}';

  @override
  final Map<String, String> headers;

  /// A comma-separated list of [grammaticalFeatures] ids to match on.
  ///
  /// The filter keeps all the senses and subsenses in the response whose
  /// grammaticalFeatures "id" matches the values in the [grammaticalFeatures]
  /// parameter.
  ///
  /// The available registers for a given language (or language pair) can be
  /// obtained from the /registers/ endpoint.
  ///
  /// If [grammaticalFeatures] is null variants with any grammaticalFeatures
  /// are returned.
  final Iterable<String>? grammaticalFeatures;

  ///  A comma-separated list of lexical categories ids to match on
  ///
  /// Only term variants for the [lexicalCategory] are returned from the
  /// endpoint.
  ///
  /// The available lexical categories for a given language (or language pair)
  /// can be obtained from the /lexicalcategories/ endpoint.
  ///
  /// If null, variants for all parts of speech are returned.
  final PartOfSpeech? lexicalCategory;

  @override
  Map<String, String> get queryParameters {
    final qp = <String, String>{};
    if (grammaticalFeatures != null) {
      qp['grammaticalFeatures'] = grammaticalFeatures!.toParameter;
    }
    if (lexicalCategory != null) {
      qp['lexicalCategory'] = lexicalCategory!.name;
    }
    return qp;
  }

  @override
  OxFordDictionariesEndpoint get endpoint => OxFordDictionariesEndpoint.entries;

  @override
  JsonDeserializer<TermProperties> get deserializer =>
      (json) => json.toTermProperties();
}

extension _OxfordDictionariesHashmapExtension on Map<String, dynamic> {
  //

  TermProperties toTermProperties() {
    String? term;
    String sourceLanguage = '';
    final Iterable<Map<String, dynamic>> results = getJsonList('results');
    if (results.isNotEmpty) {
      sourceLanguage = sourceLanguage.isEmpty
          ? results.first.language ?? ''
          : sourceLanguage;
      final stem = this['porter2stem'] as String;
      final variants = <TermVariant>{};
      for (final r in results) {
        term = term ?? r.term;
        final lexicalEntries = r.getJsonList('lexicalEntries');
        for (final le in lexicalEntries) {
          final partOfSpeech = le.getPoS('lexicalCategory');
          if (partOfSpeech != null) {
            final lemmas = le.getTextValues('inflectionOf', 'text');
            final variant = TermVariant(
                term: term ?? '',
                pronunciations: {},
                etymologies: {},
                lemmas: lemmas,
                partOfSpeech: partOfSpeech,
                definition: '',
                phrases: {},
                antonyms: {},
                inflections: lemmas,
                synonyms: {});
            variants.add(variant);
          }
        }
      }
      if (term is String && term.isNotEmpty) {
        return TermProperties(
            term: term,
            stem: stem,
            languageCode: sourceLanguage,
            variants: variants);
      }
    }
    throw ('The json object does not represent a TermProperties object.');
  }

  /// Returns the `id` field of the Map<String, dynamic> response as `String?`.
  String? get term => this['id'] is String ? this['id'] as String : null;
}

// ignore: unused_element
final _sampleBody = {
  'metadata': {'provider': 'Oxford University Press'},
  'results': [
    {
      'id': 'swimming',
      'language': 'en',
      'lexicalEntries': [
        {
          'inflectionOf': [
            {'id': 'swim', 'text': 'swim'}
          ],
          'language': 'en',
          'lexicalCategory': {'id': 'verb', 'text': 'Verb'},
          'text': 'swimming'
        },
        {
          'grammaticalFeatures': [
            {'id': 'mass', 'text': 'Mass', 'type': 'Countability'}
          ],
          'inflectionOf': [
            {'id': 'swimming', 'text': 'swimming'}
          ],
          'language': 'en',
          'lexicalCategory': {'id': 'noun', 'text': 'Noun'},
          'text': 'swimming'
        }
      ],
      'word': 'swimming'
    }
  ]
};
