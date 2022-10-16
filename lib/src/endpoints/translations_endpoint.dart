// Copyright ©2022, GM Consult (Pty) Ltd.
// BSD 3-Clause License
// All rights reserved

import 'package:gmconsult_dart_core/dart_core.dart';
import 'package:gmconsult_dart_core/type_definitions.dart';
import 'package:oxford_dictionaries/src/_index.dart';
import 'package:gmconsult_dart_core/extensions.dart';
import 'endpoint.dart';
import 'package:dictosaurus/dictosaurus.dart';

/// Retrieve definitions, pronunciations  example sentences, grammatical
/// information and word origins.
///
/// ONLY works for dictionary headwords. You may need to use the Lemmas endpoint first to link an inflected form back to its headword (e.g., pixels --> pixel). Use filters to limit the entry information that is returned. For example, you may only require definitions and not everything else, or just pronunciations. The full list of filters can be retrieved from the filters Utility endpoint. You can also specify values within the filter using '='. For example 'grammaticalFeatures=singular'. Filters can also be combined.
/// Combining different filters will build a query using 'AND' operators, while if a filter contains more than one value it will build a query using 'OR' operators. For example, a combination of filters like '?grammaticalFeatures=singular&lexicalCategory=noun,verb' will return entries which match the query ('noun' OR 'verb') AND 'singular'.
class EntriesEndpoint extends Endpoint {
//

  /// Queries the [EntriesEndpoint] for a [TermProperties] for the [term] and
  /// optional parameters.
  static Future<TermProperties?> query(String term, Map<String, String> apiKeys,
          {String sourceLanguage = 'en-us',
          bool strictMatch = false,
          Iterable<String>? fields,
          Iterable<String>? registers,
          Iterable<String>? grammaticalFeatures,
          PartOfSpeech? lexicalCategory,
          Iterable<String>? domains}) =>
      EntriesEndpoint._(term, apiKeys, sourceLanguage, strictMatch, fields,
              registers, grammaticalFeatures, lexicalCategory, domains)
          .get();

  /// Const default generative constructor.
  EntriesEndpoint._(
      this.term,
      this.headers,
      String sourceLanguage,
      this.strictMatch,
      this.fields,
      this.registers,
      this.grammaticalFeatures,
      this.lexicalCategory,
      this.domains)
      : _sourceLanguage = sourceLanguage.toLocale();

  @override
  final String term;

  @override
  Language get sourceLanguage => _sourceLanguage;

  final Language _sourceLanguage;

  @override
  String get path =>
      'api/v2/entries/${sourceLanguage.toLanguageTag().toLowerCase()}/${term.toLowerCase()}';

  @override
  final Map<String, String> headers;

  /// Specifies whether diacritics must match exactly.
  ///
  /// If [strictMatch] is false, near-homographs for the given [term] will
  /// also be selected (e.g. `rose` matches both `rose` and `rosé` and,
  /// similarly, `rosé` matches both `rose` and `rosé`).
  final bool strictMatch;

  /// A comma-separated list of data fields to return for the matched entries.
  ///
  /// Valid field names are:
  /// 'definitions', 'domains', 'etymologies', 'examples', 'pronunciations',
  /// 'regions', 'registers' and 'variantForms'.
  ///
  /// If null, all available fields for each [term] are returned.
  ///
  /// If specified and empty, the minimum payload for each [term] is returned.
  ///
  /// If more field names are specified, then the minimum payload plus the
  /// specified fields for each [term] are returned.
  final Iterable<String>? fields;

  /// A comma-separated list of [registers] ids to match on.
  ///
  /// The filter keeps all the senses and subsenses in the response whose
  /// registers "id" matches the values in the [registers] parameter.
  ///
  /// The available registers for a given language (or language pair) can be
  /// obtained from the /registers/ endpoint.
  ///
  /// If [registers] is null variants in all registers are returned.
  final Iterable<String>? registers;

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

  /// A comma-separated list of domains ids to match on.
  ///
  /// The filter keeps all the senses and subsenses in the response whose
  /// domains "id" matches the values in the [domains] parameter.
  ///
  /// The available domains for a given language (or language pair) can be
  /// obtained from the /domains/ endpoint.
  ///
  /// If [domains] is null variants in all domains are returned.
  final Iterable<String>? domains;

  @override
  Map<String, String> get queryParameters {
    final qp = {'strictMatch': strictMatch.toString()};
    if (fields != null) {
      qp['fields'] = fields!.toParameter;
    }
    if (registers != null) {
      qp['registers'] = registers!.toParameter;
    }
    if (grammaticalFeatures != null) {
      qp['grammaticalFeatures'] = grammaticalFeatures!.toParameter;
    }
    if (domains != null) {
      qp['domains'] = domains!.toParameter;
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
    final term = this.term;
    String sourceLanguage = '';
    final Iterable<Map<String, dynamic>> results = getJsonList('results');
    if (results.isNotEmpty && term is String) {
      sourceLanguage = sourceLanguage.isEmpty
          ? results.first.language ?? ''
          : sourceLanguage;
      final stem = this['porter2stem'] as String;
      final variants = <TermVariant>{};

      for (final r in results) {
        final lexicalEntries = r.getJsonList('lexicalEntries');
        for (final le in lexicalEntries) {
          final partOfSpeech = le.getPoS('lexicalCategory');
          final phrases = <String>{};
          if (partOfSpeech != null) {
            final entries = le.getJsonList('entries');
            for (final e in entries) {
              final inflections =
                  e.getTextValues('inflections', 'inflectedForm');
              final etymologies = e.etymologies;
              final pronunciations = e.pronunciations(term);
              final senses = e.getJsonList('senses');
              for (final s in senses) {
                final synonyms = s.getTextValues('synonyms', 'text');
                final definitions = s.getStringList('definitions');
                for (final definition in definitions) {
                  phrases.addAll(s.getTextValues('examples', 'text'));
                  final variant = TermVariant(
                      term: term,
                      pronunciations: pronunciations,
                      etymologies: etymologies,
                      lemmas: {},
                      partOfSpeech: partOfSpeech,
                      definition: definition,
                      phrases: phrases,
                      antonyms: {},
                      inflections: inflections,
                      synonyms: synonyms);
                  variants.add(variant);
                }
                final subsenses = s.getJsonList('subsenses');
                for (final ss in subsenses) {
                  final definitions = ss.getStringList('definitions');
                  for (final definition in definitions) {
                    phrases.addAll(ss.getTextValues('examples', 'text'));
                    synonyms.addAll(ss.getTextValues('synonyms', 'text'));
                    final variant = TermVariant(
                        term: term,
                        pronunciations: pronunciations,
                        etymologies: etymologies,
                        lemmas: {},
                        partOfSpeech: partOfSpeech,
                        definition: definition,
                        phrases: phrases,
                        antonyms: {},
                        inflections: inflections,
                        synonyms: synonyms);
                    variants.add(variant);
                  }
                }
              }
            }
          }
        }
      }
      return TermProperties(
          term: term,
          stem: stem,
          languageCode: sourceLanguage,
          variants: variants);
    }
    throw ('The json object does not represent a TermProperties object.');
  }

  /// Returns the `id` field of the Map<String, dynamic> response as `String?`.
  String? get term => this['id'] is String ? this['id'] as String : null;
}

// ignore: unused_element
final _sampleBody = {
  'id': 'swimming',
  'metadata': {
    'operation': 'translations',
    'provider': 'Oxford University Press',
    'schema': 'RetrieveTranslations'
  },
  'results': [
    {
      'id': 'swimming',
      'language': 'en',
      'lexicalEntries': [
        {
          'entries': [
            {
              'pronunciations': [
                {
                  'audioFile':
                      'https://audio.oxforddictionaries.com/en/mp3/swimming_gb_1.mp3',
                  'dialects': ['British English'],
                  'phoneticNotation': 'IPA',
                  'phoneticSpelling': 'ˈswɪmɪŋ'
                },
                {
                  'audioFile':
                      'https://audio.oxforddictionaries.com/en/mp3/swimming_us_1.mp3',
                  'dialects': ['American English'],
                  'phoneticNotation': 'IPA',
                  'phoneticSpelling': 'ˈswɪmɪŋ'
                }
              ],
              'senses': [
                {
                  'datasetCrossLinks': [
                    {
                      'entry_id': 'swimming',
                      'language': 'en-gb',
                      'sense_id': 'm_en_gbus1021020.005'
                    }
                  ],
                  'examples': [
                    {
                      'text': 'like swimming',
                      'translations': [
                        {'language': 'de', 'text': 'gern schwimmen'}
                      ]
                    }
                  ],
                  'id': 'b-en-de0034028.002',
                  'translations': [
                    {
                      'grammaticalFeatures': [
                        {'id': 'neuter', 'text': 'Neuter', 'type': 'Gender'}
                      ],
                      'language': 'de',
                      'text': 'Schwimmen'
                    }
                  ]
                }
              ]
            }
          ],
          'language': 'en',
          'lexicalCategory': {'id': 'noun', 'text': 'Noun'},
          'text': 'swimming'
        },
        {
          'entries': [
            {
              'notes': [
                {'text': 'attrib', 'type': 'grammaticalNote'}
              ],
              'pronunciations': [
                {
                  'audioFile':
                      'https://audio.oxforddictionaries.com/en/mp3/swimming_gb_1.mp3',
                  'dialects': ['British English'],
                  'phoneticNotation': 'IPA',
                  'phoneticSpelling': 'ˈswɪmɪŋ'
                },
                {
                  'audioFile':
                      'https://audio.oxforddictionaries.com/en/mp3/swimming_us_1.mp3',
                  'dialects': ['American English'],
                  'phoneticNotation': 'IPA',
                  'phoneticSpelling': 'ˈswɪmɪŋ'
                }
              ],
              'senses': [
                {
                  'id': 'b-en-de0034028.004',
                  'translations': [
                    {'language': 'de', 'text': 'schwimmend'}
                  ]
                }
              ]
            }
          ],
          'language': 'en',
          'lexicalCategory': {'id': 'adjective', 'text': 'Adjective'},
          'text': 'swimming'
        }
      ],
      'type': 'headword',
      'word': 'swimming'
    }
  ],
  'word': 'swimming'
};
