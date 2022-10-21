// Copyright ©2022, GM Consult (Pty) Ltd.
// BSD 3-Clause License
// All rights reserved

import 'package:gmconsult_dart_core/type_definitions.dart';
import 'package:oxford_dictionaries/src/_index.dart';
import 'endpoint.dart';
import 'package:dictosaurus/dictosaurus.dart';

/// Retrieve definitions, pronunciations, example sentences, grammatical
/// information and word origins.
class Words extends Endpoint<DictionaryEntry> {
//

  /// Queries the [Words] for a [DictionaryEntry] for the [term] and
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
      Words._(term, apiKeys, language, strictMatch, fields, registers,
              grammaticalFeatures, lexicalCategory, domains)
          .get();

  /// Const default generative constructor.
  Words._(
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
  String get path => 'api/v2/words/${language.toLanguageTag().toLowerCase()}';

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
    final qp = {'q': term.toLowerCase(), 'strictMatch': strictMatch.toString()};

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
  JsonDeserializer<DictionaryEntry> get deserializer =>
      (json) => json.toDictionaryEntry(language);
}

extension _OxfordDictionariesHashmapExtension on Map<String, dynamic> {
  //

  /// Returns the `id` field of the Map<String, dynamic> response as `String?`.
  String? get term => this['query'] is String ? this['query'] as String : null;

  DictionaryEntry toDictionaryEntry(Language language) {
    final term = this.term;
    final Iterable<Map<String, dynamic>> results = getJsonList('results');
    if (results.isNotEmpty && term is String) {
      final variants = <TermVariant>{};
      final stem = this['porter2stem'] as String;
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
              final pronunciations = e.pronunciations(term, language);
              final etymologies = e.etymologies;
              final senses = e.getJsonList('senses');
              for (final s in senses) {
                final synonyms = s.getTextValues('synonyms', 'text');
                final lemmas = s.getTextValues('thesaurusLinks', 'entry_id');
                final definitions = s.getStringList('definitions');
                for (final definition in definitions) {
                  phrases.addAll(s.getTextValues('examples', 'text'));
                  final variant = TermVariant(
                      term: term,
                      language: language,
                      pronunciations: pronunciations,
                      etymologies: etymologies,
                      partOfSpeech: partOfSpeech,
                      definition: definition,
                      phrases: phrases,
                      lemmas: lemmas,
                      antonyms: {},
                      inflections: inflections,
                      synonyms: synonyms);
                  variants.add(variant);
                }
                final subsenses = s.getJsonList('subsenses');
                for (final ss in subsenses) {
                  final definitions = ss.getStringList('definitions');
                  final lemmas = s.getTextValues('thesaurusLinks', 'entry_id');
                  for (final definition in definitions) {
                    phrases.addAll(ss.getTextValues('examples', 'text'));
                    synonyms.addAll(ss.getTextValues('synonyms', 'text'));
                    final variant = TermVariant(
                        term: term,
                        language: language,
                        pronunciations: pronunciations,
                        etymologies: etymologies,
                        partOfSpeech: partOfSpeech,
                        definition: definition,
                        lemmas: lemmas,
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
}

// ignore: unused_element
final _uri =
    'https://od-api.oxforddictionaries.com/api/v2/words/en-gb?q=swimming';

// ignore: unused_element
final _sampleBody = {
  'metadata': {
    'operation': 'retrieve',
    'provider': 'Oxford University Press',
    'schema': 'RetrieveEntry'
  },
  'query': 'swimming',
  'results': [
    {
      'id': 'swimming',
      'language': 'en-gb',
      'lexicalEntries': [
        {
          'entries': [
            {
              'grammaticalFeatures': [
                {'id': 'mass', 'text': 'Mass', 'type': 'Countability'}
              ],
              'inflections': [
                {'inflectedForm': 'swimming'}
              ],
              'pronunciations': [
                {
                  'audioFile':
                      'https://audio.oxforddictionaries.com/en/mp3/swimming__gb_2.mp3',
                  'dialects': ['British English'],
                  'phoneticNotation': 'IPA',
                  'phoneticSpelling': 'ˈswɪmɪŋ'
                }
              ],
              'senses': [
                {
                  'definitions': [
                    'the sport or activity of propelling oneself through water using the limbs'
                  ],
                  'domainClasses': [
                    {'id': 'swimming', 'text': 'Swimming'}
                  ],
                  'examples': [
                    {'text': 'Rachel had always loved swimming'},
                    {
                      'notes': [
                        {'text': 'as modifier', 'type': 'grammaticalNote'}
                      ],
                      'text': 'a swimming instructor'
                    }
                  ],
                  'id': 'm_en_gbus1021020.005',
                  'semanticClasses': [
                    {'id': 'water_sport', 'text': 'Water_Sport'}
                  ],
                  'shortDefinitions': [
                    'sport or activity of propelling oneself through water using limbs'
                  ]
                }
              ]
            }
          ],
          'language': 'en-gb',
          'lexicalCategory': {'id': 'noun', 'text': 'Noun'},
          'text': 'swimming'
        }
      ],
      'type': 'headword',
      'word': 'swimming'
    },
    {
      'id': 'swim',
      'language': 'en-gb',
      'lexicalEntries': [
        {
          'derivatives': [
            {'id': 'swimmable', 'text': 'swimmable'}
          ],
          'entries': [
            {
              'etymologies': [
                'Old English swimman (verb), of Germanic origin; related to Dutch zwemmen and German schwimmen'
              ],
              'grammaticalFeatures': [
                {
                  'id': 'intransitive',
                  'text': 'Intransitive',
                  'type': 'Subcategorization'
                }
              ],
              'inflections': [
                {
                  'grammaticalFeatures': [
                    {
                      'id': 'intransitive',
                      'text': 'Intransitive',
                      'type': 'Subcategorization'
                    }
                  ],
                  'inflectedForm': 'swims'
                },
                {
                  'grammaticalFeatures': [
                    {
                      'id': 'intransitive',
                      'text': 'Intransitive',
                      'type': 'Subcategorization'
                    }
                  ],
                  'inflectedForm': 'swimming'
                },
                {
                  'grammaticalFeatures': [
                    {
                      'id': 'intransitive',
                      'text': 'Intransitive',
                      'type': 'Subcategorization'
                    },
                    {'id': 'past', 'text': 'Past', 'type': 'Tense'}
                  ],
                  'inflectedForm': 'swam',
                  'pronunciations': [
                    {
                      'audioFile':
                          'https://audio.oxforddictionaries.com/en/mp3/swam__gb_1.mp3',
                      'dialects': ['British English'],
                      'phoneticNotation': 'IPA',
                      'phoneticSpelling': 'swam'
                    }
                  ]
                },
                {
                  'grammaticalFeatures': [
                    {
                      'id': 'intransitive',
                      'text': 'Intransitive',
                      'type': 'Subcategorization'
                    },
                    {
                      'id': 'pastParticiple',
                      'text': 'Past Participle',
                      'type': 'Non Finiteness'
                    }
                  ],
                  'inflectedForm': 'swum',
                  'pronunciations': [
                    {
                      'audioFile':
                          'https://audio.oxforddictionaries.com/en/mp3/swum__gb_1.mp3',
                      'dialects': ['British English'],
                      'phoneticNotation': 'IPA',
                      'phoneticSpelling': 'swʌm'
                    }
                  ]
                },
                {'inflectedForm': 'swam'},
                {'inflectedForm': 'swim'},
                {'inflectedForm': 'swimming'},
                {'inflectedForm': 'swims'},
                {'inflectedForm': 'swum'}
              ],
              'notes': [
                {
                  'text':
                      'In standard English the past tense of swim is swam (she swam to the shore) and the past participle is swum (she had never swum there before). In the 17th and 18th centuries swam and swum were used interchangeably for the past participle, but this is not acceptable in standard modern English',
                  'type': 'editorialNote'
                }
              ],
              'pronunciations': [
                {
                  'audioFile':
                      'https://audio.oxforddictionaries.com/en/mp3/swim__gb_1.mp3',
                  'dialects': ['British English'],
                  'phoneticNotation': 'IPA',
                  'phoneticSpelling': 'swɪm'
                }
              ],
              'senses': [
                {
                  'definitions': [
                    'propel the body through water by using the limbs, or (in the case of a fish or other aquatic animal) by using fins, tail, or other bodily movement'
                  ],
                  'domainClasses': [
                    {'id': 'swimming', 'text': 'Swimming'}
                  ],
                  'examples': [
                    {'text': 'they swam ashore'},
                    {'text': 'he swims thirty lengths twice a week'}
                  ],
                  'id': 'm_en_gbus1020960.013',
                  'shortDefinitions': [
                    'propel body through water by using limbs, or by using fins, tail'
                  ],
                  'subsenses': [
                    {
                      'definitions': [
                        'cross (a particular stretch of water) by swimming'
                      ],
                      'domainClasses': [
                        {'id': 'swimming', 'text': 'Swimming'}
                      ],
                      'examples': [
                        {'text': 'she swam the Channel'}
                      ],
                      'id': 'm_en_gbus1020960.019',
                      'notes': [
                        {'text': 'with object', 'type': 'grammaticalNote'}
                      ],
                      'shortDefinitions': ['cross stretch of water by swimming']
                    },
                    {
                      'definitions': ['float on or at the surface of a liquid'],
                      'examples': [
                        {'text': 'bubbles swam on the surface'}
                      ],
                      'id': 'm_en_gbus1020960.020',
                      'shortDefinitions': ['float on or at surface of liquid']
                    },
                    {
                      'definitions': ['cause to float or move across water'],
                      'examples': [
                        {
                          'text':
                              'they were able to swim their infantry carriers across'
                        }
                      ],
                      'id': 'm_en_gbus1020960.021',
                      'notes': [
                        {'text': 'with object', 'type': 'grammaticalNote'}
                      ],
                      'shortDefinitions': [
                        'cause to float or move across water'
                      ]
                    }
                  ],
                  'synonyms': [
                    {'language': 'en', 'text': 'bathe'},
                    {'language': 'en', 'text': 'go swimming'},
                    {'language': 'en', 'text': 'take a dip'},
                    {'language': 'en', 'text': 'dip'},
                    {'language': 'en', 'text': 'splash around'}
                  ],
                  'thesaurusLinks': [
                    {'entry_id': 'swim', 'sense_id': 't_en_gb0014530.001'}
                  ]
                },
                {
                  'definitions': ['be immersed in or covered with liquid'],
                  'examples': [
                    {'text': 'mashed potatoes swimming in gravy'}
                  ],
                  'id': 'm_en_gbus1020960.023',
                  'shortDefinitions': ['be immersed in or covered with liquid'],
                  'synonyms': [
                    {'language': 'en', 'text': 'be saturated in'},
                    {'language': 'en', 'text': 'be drenched in'},
                    {'language': 'en', 'text': 'be soaked in'},
                    {'language': 'en', 'text': 'be steeped in'},
                    {'language': 'en', 'text': 'be immersed in'},
                    {'language': 'en', 'text': 'be covered in'},
                    {'language': 'en', 'text': 'be full of'}
                  ],
                  'thesaurusLinks': [
                    {'entry_id': 'swim', 'sense_id': 't_en_gb0014530.002'}
                  ]
                },
                {
                  'definitions': ["appear to reel or whirl before one's eyes"],
                  'examples': [
                    {
                      'text':
                          'Emily rubbed her eyes as the figures swam before her eyes'
                    }
                  ],
                  'id': 'm_en_gbus1020960.025',
                  'shortDefinitions': [
                    "appear to reel or whirl before one's eyes"
                  ],
                  'subsenses': [
                    {
                      'definitions': [
                        "experience a dizzily confusing sensation in one's head"
                      ],
                      'examples': [
                        {'text': 'the drink made his head swim'}
                      ],
                      'id': 'm_en_gbus1020960.026',
                      'shortDefinitions': [
                        "experience dizzily confusing sensation in one's head"
                      ]
                    }
                  ],
                  'synonyms': [
                    {'language': 'en', 'text': 'go round'},
                    {'language': 'en', 'text': 'go round and round'},
                    {'language': 'en', 'text': 'whirl'},
                    {'language': 'en', 'text': 'spin'},
                    {'language': 'en', 'text': 'revolve'},
                    {'language': 'en', 'text': 'gyrate'},
                    {'language': 'en', 'text': 'swirl'},
                    {'language': 'en', 'text': 'twirl'},
                    {'language': 'en', 'text': 'turn'},
                    {'language': 'en', 'text': 'wheel'},
                    {'language': 'en', 'text': 'swim'}
                  ],
                  'thesaurusLinks': [
                    {'entry_id': 'reel', 'sense_id': 't_en_gb0012249.003'}
                  ]
                }
              ]
            }
          ],
          'language': 'en-gb',
          'lexicalCategory': {'id': 'verb', 'text': 'Verb'},
          'phrases': [
            {'id': 'in_the_swim', 'text': 'in the swim'},
            {'id': 'swim_against_the_tide', 'text': 'swim against the tide'},
            {'id': 'swim_with_the_tide', 'text': 'swim with the tide'}
          ],
          'text': 'swim'
        }
      ],
      'type': 'headword',
      'word': 'swim'
    }
  ]
};
