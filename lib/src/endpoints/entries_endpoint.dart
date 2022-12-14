// Copyright ©2022, GM Consult (Pty) Ltd.
// BSD 3-Clause License
// All rights reserved

import 'package:gmconsult_dart_core/type_definitions.dart';
import 'package:oxford_dictionaries/src/_index.dart';
import 'oxford_dictionaries_endpoint.dart';
import 'package:dictosaurus/dictosaurus.dart';

/// Retrieve definitions, pronunciations example sentences, grammatical
/// information and word origins.
///
/// ONLY works for dictionary headwords. You may need to use the LemmasEndpoint
/// endpoint first to link an inflected form back to its headword (e.g., pixels
/// --> pixel). Use filters to limit the entry information that is returned.
/// For example, you may only require definitions and not everything else, or
/// just pronunciations. The full list of filters can be retrieved from the
/// filters Utility endpoint. You can also specify values within the filter
/// using '='. For example 'grammaticalFeatures=singular'. Filters can also
/// be combined.
///
/// Combining different filters will build a query using 'AND' operators,
/// while if a filter contains more than one value it will build a query
/// using 'OR' operators. For example, a combination of filters like
/// ?grammaticalFeatures=singular&lexicalCategory=noun,verb' will
/// eturn entries which match the query ('noun' OR 'verb') AND 'singular'.
class EntriesEndpoint extends OdApiEndpoint<DictionaryEntry> {
//

  /// Queries the [EntriesEndpoint] for a [DictionaryEntry] for the [term] and
  /// optional parameters.
  static Future<DictionaryEntry?> query(
          String term, Map<String, String> apiKeys,
          {Language language = Language.en_US,
          bool strictMatch = false,
          Iterable<String>? fields,
          Iterable<String>? registers,
          Iterable<String>? grammaticalFeatures,
          PartOfSpeech? lexicalCategory,
          Iterable<String>? domains}) =>
      EntriesEndpoint._(term, apiKeys, language, strictMatch, fields, registers,
              grammaticalFeatures, lexicalCategory, domains)
          .get();

  /// Const default generative constructor.
  EntriesEndpoint._(
      this.term,
      this.headers,
      this.language,
      this.strictMatch,
      this.fields,
      this.registers,
      this.grammaticalFeatures,
      this.lexicalCategory,
      this.domains);

  @override
  final String term;

  @override
  final Language language;

  @override
  String get path =>
      'api/v2/entries/${language.toLanguageTag().toLowerCase()}/${term.toLowerCase()}';

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
  OxfordDictionariesEndpoint get endpoint => OxfordDictionariesEndpoint.entries;

  @override
  JsonDeserializer<DictionaryEntry> get deserializer =>
      (json) => json.toDictionaryEntry(language);
}

extension _OxfordDictionariesHashmapExtension on Map<String, dynamic> {
  //

  DictionaryEntry toDictionaryEntry(Language language) {
    final term = this.term;
    final Iterable<Map<String, dynamic>> results = getJsonList('results');
    if (results.isNotEmpty && term is String) {
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
              final pronunciations = e.pronunciations(term, language);
              final senses = e.getJsonList('senses');
              for (final s in senses) {
                final synonyms = s.getTextValues('synonyms', 'text');
                final definitions = s.getStringList('definitions');
                for (final definition in definitions) {
                  phrases.addAll(s.getTextValues('examples', 'text'));
                  final variant = TermVariant(
                      term: term,
                      language: language,
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
                        language: language,
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
      return DictionaryEntry(
          term: term, stem: stem, language: language, variants: variants);
    }
    throw ('The json object does not represent a DictionaryEntry object.');
  }

  /// Returns the `id` field of the Map<String, dynamic> response as `String?`.
  String? get term => this['id'] is String ? this['id'] as String : null;
}

// ignore: unused_element
final _sampleBody = {
  'id': 'ace',
  'metadata': {
    'operation': 'retrieve',
    'provider': 'Oxford University Press',
    'schema': 'RetrieveEntry'
  },
  'results': [
    {
      'id': 'ace',
      'language': 'en-gb',
      'lexicalEntries': [
        {
          'entries': [
            {
              'etymologies': [
                'Middle English (denoting the ‘one’ on dice): via Old French from Latin as ‘unity, a unit’'
              ],
              'homographNumber': '100',
              'pronunciations': [
                {
                  'audioFile':
                      'https://audio.oxforddictionaries.com/en/mp3/ace__gb_3.mp3',
                  'dialects': ['British English'],
                  'phoneticNotation': 'IPA',
                  'phoneticSpelling': 'eɪs'
                }
              ],
              'senses': [
                {
                  'definitions': [
                    'a playing card with a single spot on it, ranked as the highest card in its suit in most card games'
                  ],
                  'domainClasses': [
                    {'id': 'cards', 'text': 'Cards'}
                  ],
                  'examples': [
                    {'text': 'the ace of diamonds'},
                    {
                      'registers': [
                        {'id': 'figurative', 'text': 'Figurative'}
                      ],
                      'text': 'life had started dealing him aces again'
                    }
                  ],
                  'id': 'm_en_gbus0005680.006',
                  'semanticClasses': [
                    {'id': 'playing_card', 'text': 'Playing_Card'}
                  ],
                  'shortDefinitions': [
                    'playing card with single spot on it, ranked as highest card in its suit in most card games'
                  ]
                },
                {
                  'definitions': [
                    'a person who excels at a particular sport or other activity'
                  ],
                  'domainClasses': [
                    {'id': 'sport', 'text': 'Sport'}
                  ],
                  'examples': [
                    {'text': 'a motorcycle ace'}
                  ],
                  'id': 'm_en_gbus0005680.010',
                  'registers': [
                    {'id': 'informal', 'text': 'Informal'}
                  ],
                  'semanticClasses': [
                    {'id': 'sports_player', 'text': 'Sports_Player'}
                  ],
                  'shortDefinitions': [
                    'person who excels at particular sport or other activity'
                  ],
                  'subsenses': [
                    {
                      'definitions': [
                        'a pilot who has shot down many enemy aircraft'
                      ],
                      'domainClasses': [
                        {'id': 'air_force', 'text': 'Air_Force'}
                      ],
                      'examples': [
                        {'text': 'a Battle of Britain ace'}
                      ],
                      'id': 'm_en_gbus0005680.011',
                      'semanticClasses': [
                        {'id': 'aviator', 'text': 'Aviator'}
                      ],
                      'shortDefinitions': [
                        'pilot who has shot down many enemy aircraft'
                      ]
                    }
                  ],
                  'synonyms': [
                    {'language': 'en', 'text': 'expert'},
                    {'language': 'en', 'text': 'master'},
                    {'language': 'en', 'text': 'genius'},
                    {'language': 'en', 'text': 'virtuoso'},
                    {'language': 'en', 'text': 'maestro'},
                    {'language': 'en', 'text': 'professional'},
                    {'language': 'en', 'text': 'adept'},
                    {'language': 'en', 'text': 'past master'},
                    {'language': 'en', 'text': 'doyen'},
                    {'language': 'en', 'text': 'champion'},
                    {'language': 'en', 'text': 'star'},
                    {'language': 'en', 'text': 'winner'}
                  ],
                  'thesaurusLinks': [
                    {'entry_id': 'ace', 'sense_id': 't_en_gb0000173.001'}
                  ]
                },
                {
                  'definitions': [
                    '(in tennis and similar games) a service that an opponent is unable to return and thus wins a point'
                  ],
                  'domainClasses': [
                    {'id': 'tennis', 'text': 'Tennis'}
                  ],
                  'examples': [
                    {'text': 'Nadal banged down eight aces in the set'}
                  ],
                  'id': 'm_en_gbus0005680.013',
                  'semanticClasses': [
                    {'id': 'stroke', 'text': 'Stroke'}
                  ],
                  'shortDefinitions': [
                    '(in tennis and similar games) service that opponent is unable to return and thus wins point'
                  ],
                  'subsenses': [
                    {
                      'definitions': ['a hole in one'],
                      'domainClasses': [
                        {'id': 'golf', 'text': 'Golf'}
                      ],
                      'domains': [
                        {'id': 'golf', 'text': 'Golf'}
                      ],
                      'examples': [
                        {
                          'text':
                              "his hole in one at the 15th was Senior's second ace as a professional"
                        }
                      ],
                      'id': 'm_en_gbus0005680.014',
                      'registers': [
                        {'id': 'informal', 'text': 'Informal'}
                      ],
                      'semanticClasses': [
                        {'id': 'golf_stroke', 'text': 'Golf_Stroke'}
                      ],
                      'shortDefinitions': ['hole in one']
                    }
                  ]
                }
              ]
            }
          ],
          'language': 'en-gb',
          'lexicalCategory': {'id': 'noun', 'text': 'Noun'},
          'phrases': [
            {
              'id': 'an_ace_up_one%27s_sleeve',
              'text': "an ace up one's sleeve"
            },
            {'id': 'hold_all_the_aces', 'text': 'hold all the aces'},
            {'id': 'play_one%27s_ace', 'text': "play one's ace"},
            {'id': 'within_an_ace_of', 'text': 'within an ace of'}
          ],
          'text': 'ace'
        },
        {
          'entries': [
            {
              'homographNumber': '101',
              'pronunciations': [
                {
                  'audioFile':
                      'https://audio.oxforddictionaries.com/en/mp3/ace__gb_3.mp3',
                  'dialects': ['British English'],
                  'phoneticNotation': 'IPA',
                  'phoneticSpelling': 'eɪs'
                }
              ],
              'senses': [
                {
                  'definitions': ['very good'],
                  'examples': [
                    {'text': 'an ace swimmer'},
                    {
                      'notes': [
                        {'text': 'as exclamation', 'type': 'grammaticalNote'}
                      ],
                      'text': "Ace! You've done it!"
                    }
                  ],
                  'id': 'm_en_gbus0005680.016',
                  'registers': [
                    {'id': 'informal', 'text': 'Informal'}
                  ],
                  'shortDefinitions': ['very good'],
                  'synonyms': [
                    {'language': 'en', 'text': 'excellent'},
                    {'language': 'en', 'text': 'very good'},
                    {'language': 'en', 'text': 'first-rate'},
                    {'language': 'en', 'text': 'first-class'},
                    {'language': 'en', 'text': 'marvellous'},
                    {'language': 'en', 'text': 'wonderful'},
                    {'language': 'en', 'text': 'magnificent'},
                    {'language': 'en', 'text': 'outstanding'},
                    {'language': 'en', 'text': 'superlative'},
                    {'language': 'en', 'text': 'formidable'},
                    {'language': 'en', 'text': 'virtuoso'},
                    {'language': 'en', 'text': 'masterly'},
                    {'language': 'en', 'text': 'expert'},
                    {'language': 'en', 'text': 'champion'},
                    {'language': 'en', 'text': 'fine'},
                    {'language': 'en', 'text': 'consummate'},
                    {'language': 'en', 'text': 'skilful'},
                    {'language': 'en', 'text': 'adept'}
                  ],
                  'thesaurusLinks': [
                    {'entry_id': 'ace', 'sense_id': 't_en_gb0000173.002'}
                  ]
                }
              ]
            }
          ],
          'language': 'en-gb',
          'lexicalCategory': {'id': 'adjective', 'text': 'Adjective'},
          'phrases': [
            {
              'id': 'an_ace_up_one%27s_sleeve',
              'text': "an ace up one's sleeve"
            },
            {'id': 'hold_all_the_aces', 'text': 'hold all the aces'},
            {'id': 'play_one%27s_ace', 'text': "play one's ace"},
            {'id': 'within_an_ace_of', 'text': 'within an ace of'}
          ],
          'text': 'ace'
        },
        {
          'entries': [
            {
              'grammaticalFeatures': [
                {
                  'id': 'transitive',
                  'text': 'Transitive',
                  'type': 'Subcategorization'
                }
              ],
              'homographNumber': '102',
              'pronunciations': [
                {
                  'audioFile':
                      'https://audio.oxforddictionaries.com/en/mp3/ace__gb_3.mp3',
                  'dialects': ['British English'],
                  'phoneticNotation': 'IPA',
                  'phoneticSpelling': 'eɪs'
                }
              ],
              'senses': [
                {
                  'definitions': [
                    '(in tennis and similar games) serve an ace against (an opponent)'
                  ],
                  'domainClasses': [
                    {'id': 'tennis', 'text': 'Tennis'}
                  ],
                  'examples': [
                    {
                      'text':
                          'he can ace opponents with serves of no more than 62 mph'
                    }
                  ],
                  'id': 'm_en_gbus0005680.020',
                  'registers': [
                    {'id': 'informal', 'text': 'Informal'}
                  ],
                  'shortDefinitions': [
                    '(in tennis and similar games) serve ace against'
                  ],
                  'subsenses': [
                    {
                      'definitions': [
                        'score an ace on (a hole) or with (a shot)'
                      ],
                      'domainClasses': [
                        {'id': 'golf', 'text': 'Golf'}
                      ],
                      'domains': [
                        {'id': 'golf', 'text': 'Golf'}
                      ],
                      'examples': [
                        {
                          'text':
                              'there was a prize for the first player to ace the hole'
                        }
                      ],
                      'id': 'm_en_gbus0005680.026',
                      'shortDefinitions': ['score ace on hole or with']
                    }
                  ]
                },
                {
                  'definitions': ['achieve high marks in (a test or exam)'],
                  'examples': [
                    {'text': 'I aced my grammar test'}
                  ],
                  'id': 'm_en_gbus0005680.028',
                  'regions': [
                    {'id': 'north_american', 'text': 'North_American'}
                  ],
                  'registers': [
                    {'id': 'informal', 'text': 'Informal'}
                  ],
                  'shortDefinitions': ['achieve high marks in'],
                  'subsenses': [
                    {
                      'definitions': [
                        'outdo someone in a competitive situation'
                      ],
                      'examples': [
                        {
                          'text':
                              'the magazine won an award, acing out its rivals'
                        }
                      ],
                      'id': 'm_en_gbus0005680.029',
                      'notes': [
                        {'text': '"ace someone out"', 'type': 'wordFormNote'}
                      ],
                      'shortDefinitions': [
                        'outdo someone in competitive situation'
                      ]
                    }
                  ]
                }
              ]
            }
          ],
          'language': 'en-gb',
          'lexicalCategory': {'id': 'verb', 'text': 'Verb'},
          'phrases': [
            {
              'id': 'an_ace_up_one%27s_sleeve',
              'text': "an ace up one's sleeve"
            },
            {'id': 'hold_all_the_aces', 'text': 'hold all the aces'},
            {'id': 'play_one%27s_ace', 'text': "play one's ace"},
            {'id': 'within_an_ace_of', 'text': 'within an ace of'}
          ],
          'text': 'ace'
        }
      ],
      'type': 'headword',
      'word': 'ace'
    },
    {
      'id': 'ace',
      'language': 'en-gb',
      'lexicalEntries': [
        {
          'entries': [
            {
              'etymologies': [
                'early 21st century: abbreviation of asexual, with alteration of spelling on the model of ace'
              ],
              'homographNumber': '200',
              'pronunciations': [
                {
                  'audioFile':
                      'https://audio.oxforddictionaries.com/en/mp3/ace__gb_3.mp3',
                  'dialects': ['British English'],
                  'phoneticNotation': 'IPA',
                  'phoneticSpelling': 'eɪs'
                }
              ],
              'senses': [
                {
                  'definitions': ['an asexual person'],
                  'domainClasses': [
                    {'id': 'sex', 'text': 'Sex'}
                  ],
                  'examples': [
                    {
                      'text':
                          'both asexual, they have managed to connect with other aces offline'
                    }
                  ],
                  'id': 'm_en_gbus1190638.004',
                  'semanticClasses': [
                    {'id': 'type_of_person', 'text': 'Type_Of_Person'}
                  ],
                  'shortDefinitions': ['asexual person']
                }
              ]
            }
          ],
          'language': 'en-gb',
          'lexicalCategory': {'id': 'noun', 'text': 'Noun'},
          'text': 'ace'
        },
        {
          'entries': [
            {
              'homographNumber': '201',
              'pronunciations': [
                {
                  'audioFile':
                      'https://audio.oxforddictionaries.com/en/mp3/ace__gb_3.mp3',
                  'dialects': ['British English'],
                  'phoneticNotation': 'IPA',
                  'phoneticSpelling': 'eɪs'
                }
              ],
              'senses': [
                {
                  'definitions': ['(of a person) asexual'],
                  'domainClasses': [
                    {'id': 'sex', 'text': 'Sex'}
                  ],
                  'examples': [
                    {'text': "I didn't realize that I was ace for a long time"}
                  ],
                  'id': 'm_en_gbus1190638.006',
                  'shortDefinitions': ['asexual']
                }
              ]
            }
          ],
          'language': 'en-gb',
          'lexicalCategory': {'id': 'adjective', 'text': 'Adjective'},
          'text': 'ace'
        }
      ],
      'type': 'headword',
      'word': 'ace'
    }
  ],
  'word': 'ace'
};
