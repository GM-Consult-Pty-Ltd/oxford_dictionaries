// Copyright ©2022, GM Consult (Pty) Ltd.
// BSD 3-Clause License
// All rights reserved

import 'package:gmconsult_dart_core/type_definitions.dart';
import 'package:oxford_dictionaries/src/_index.dart';
import 'endpoint.dart';
import 'package:dictosaurus/dictosaurus.dart';

/// Check if a word exists in the dictionary, or what 'root' form it links to
/// (e.g., swimming > swim). The response tells you the possible lemmas for a
/// given inflected word. This can then be combined with other endpoints to
/// retrieve more information.
///
/// The results can be filtered by lexicalCategories and/or grammaticalFeatures.
///
/// Filters can be combined.
///
/// Combining different filters will build a query using 'AND' operators,
/// while if a filter contains more than one value it will build a query
/// using 'OR' operators. For example, a combination of filters like
/// '?grammaticalFeatures=singular&lexicalCategory=noun,verb' will return
/// entries which match the query ('noun' OR 'verb') AND 'singular'.
class Lemmas extends Endpoint<DictionaryEntry> {
//

  /// Queries the [Lemmas] for a [DictionaryEntry] for the [term] and
  /// optional parameters.
  static Future<DictionaryEntry?> query(
          String term, Map<String, String> apiKeys,
          {Language language = Language.en_US,
          Iterable<String>? grammaticalFeatures,
          PartOfSpeech? lexicalCategory}) =>
      Lemmas._(term, apiKeys, language, grammaticalFeatures, lexicalCategory)
          .get();

  /// Const default generative constructor.
  Lemmas._(this.term, this.headers, this.language, this.grammaticalFeatures,
      this.lexicalCategory);

  @override
  final String term;

  @override
  final Language language;

  @override
  String get path =>
      'api/v2/lemmas/${language.toLanguageTag().toLowerCase()}/${term.toLowerCase()}';

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
  JsonDeserializer<DictionaryEntry> get deserializer =>
      (json) => json.toDictionaryEntry(language);
}

extension _OxfordDictionariesHashmapExtension on Map<String, dynamic> {
  //

  DictionaryEntry toDictionaryEntry(Language language) {
    String? term;

    final Iterable<Map<String, dynamic>> results = getJsonList('results');
    if (results.isNotEmpty) {
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
                language: language,
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
        return DictionaryEntry(
            term: term, stem: stem, language: language, variants: variants);
      }
    }
    throw ('The json object does not represent a DictionaryEntry object.');
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
