// Copyright ©2022, GM Consult (Pty) Ltd.
// BSD 3-Clause License
// All rights reserved

import 'package:gmconsult_dart_core/type_definitions.dart';
import 'package:oxford_dictionaries/src/_index.dart';
import 'oxford_dictionaries_endpoint.dart';
import 'package:dictosaurus/dictosaurus.dart';

/// Return translations for a given word.
///
/// In the event that a word in the dataset does not have a direct translation,
/// the response will be a definition in the target language.
class TranslationsEndpoint extends OdApiEndpoint<DictionaryEntry> {
//

  /// Queries the [TranslationsEndpoint] for a [DictionaryEntry] for the [term] and
  /// optional parameters.
  static Future<DictionaryEntry?> query(
          String term, Map<String, String> apiKeys,
          {required Language targetLanguage,
          Language sourceLanguage = Language.en,
          bool strictMatch = false,
          Iterable<String>? fields,
          Iterable<String>? registers,
          Iterable<String>? grammaticalFeatures,
          PartOfSpeech? lexicalCategory,
          Iterable<String>? domains}) =>
      TranslationsEndpoint._(
              term,
              targetLanguage,
              apiKeys,
              sourceLanguage,
              strictMatch,
              fields,
              registers,
              grammaticalFeatures,
              lexicalCategory,
              domains)
          .get();

  /// Const default generative constructor.
  TranslationsEndpoint._(
      this.term,
      this._targetLanguage,
      this.headers,
      this._sourceLanguage,
      this.strictMatch,
      this.fields,
      this.registers,
      this.grammaticalFeatures,
      this.lexicalCategory,
      this.domains);
  @override
  final String term;

  final Language _targetLanguage;

  /// Returns translations for [term] from [language] to [targetLanguage] as
  /// a collection of [TermVariant] objects.
  static Future<Set<TermVariant>> translate(Map<String, String> apiKeys,
      {required String term,
      required Language sourceLanguage,
      required Language targetLanguage,
      bool strictMatch = false,
      Iterable<String>? fields,
      Iterable<String>? registers,
      Iterable<String>? grammaticalFeatures,
      PartOfSpeech? lexicalCategory,
      Iterable<String>? domains}) async {
    final json = await TranslationsEndpoint._(
            term,
            targetLanguage,
            apiKeys,
            sourceLanguage,
            strictMatch,
            fields,
            registers,
            grammaticalFeatures,
            lexicalCategory,
            domains)
        .getJson();
    return json?.translations(targetLanguage) ?? {};
  }

  /// The language of the term that is translated.
  Language get targetLanguage => Language(_targetLanguage.languageCode);

  /// Private placeholder variable for field [language].
  final Language _sourceLanguage;
  @override
  Language get language => Language(_sourceLanguage.languageCode);

  @override
  Future<Map<String, dynamic>?> getJson() async {
    //
    if (language != Language.en && targetLanguage != Language.en) {
      return null;
    }
    if (language == Language.en &&
        !OxfordDictionariesLanguage.targetLanguages.contains(targetLanguage)) {
      return null;
    }
    return await super.getJson();
  }

  @override
  String get path =>
      'api/v2/translations/${language.toLanguageTag().toLowerCase()}/'
      '${targetLanguage.toLanguageTag().toLowerCase()}/${term.toLowerCase()}';

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
  OxfordDictionariesEndpoint get endpoint =>
      OxfordDictionariesEndpoint.translations;

  @override
  JsonDeserializer<DictionaryEntry> get deserializer =>
      (json) => json.toDictionaryEntry(language, targetLanguage);
}

extension _OxfordDictionariesHashmapExtension on Map<String, dynamic> {
  //

  DictionaryEntry toDictionaryEntry(
      Language language, Language targetLanguage) {
    final term = this.term;

    final Iterable<Map<String, dynamic>> results = getJsonList('results');
    if (results.isNotEmpty && term is String) {
      final stem = this['porter2stem'] as String;
      final variants = <TermVariant>{};

      for (final r in results) {
        final lexicalEntries = r.getJsonList('lexicalEntries');
        for (final le in lexicalEntries) {
          final partOfSpeech = le.getPoS('lexicalCategory');
          if (partOfSpeech != null) {
            final entries = le.getJsonList('entries');
            for (final e in entries) {
              final inflections =
                  e.getTextValues('inflections', 'inflectedForm');
              final pronunciations = e.pronunciations(term, language);
              final senses = e.getJsonList('senses');
              for (final s in senses) {
                final phrases = s.getTextValues('examples', 'text');
                final variant = TermVariant(
                    term: term,
                    language: language,
                    pronunciations: pronunciations,
                    etymologies: {},
                    lemmas: {},
                    partOfSpeech: partOfSpeech,
                    definition: '',
                    phrases: phrases,
                    antonyms: {},
                    inflections: inflections,
                    synonyms: {});
                variants.add(variant);
              }
            }
          }
        }
      }
      variants.addAll(translations(targetLanguage));
      return DictionaryEntry(
          term: term, stem: stem, language: language, variants: variants);
    }
    throw ('The json object does not represent a DictionaryEntry object.');
  }

  Set<TermVariant> translations(Language targetLanguage) {
    final term = this.term;
    final Iterable<Map<String, dynamic>> results = getJsonList('results');
    if (results.isNotEmpty && term is String) {
      final variants = <TermVariant>{};

      for (final r in results) {
        final lexicalEntries = r.getJsonList('lexicalEntries');
        for (final le in lexicalEntries) {
          final partOfSpeech = le.getPoS('lexicalCategory');
          if (partOfSpeech != null) {
            final entries = le.getJsonList('entries');
            for (final e in entries) {
              final senses = e.getJsonList('senses');
              for (final s in senses) {
                final phrases = <String>{};
                final examples = s.getJsonList('examples');
                for (final example in examples) {
                  phrases.addAll(example.getTextValues('translations', 'text'));
                }
                final translations = s.getTextValues('translations', 'text');
                for (final translation in translations) {
                  final variant = TermVariant(
                      term: translation,
                      language: targetLanguage,
                      pronunciations: {},
                      etymologies: {},
                      lemmas: {translation},
                      partOfSpeech: partOfSpeech,
                      definition: '',
                      phrases: phrases,
                      antonyms: {},
                      inflections: {translation},
                      synonyms: {});
                  variants.add(variant);
                }
              }
            }
          }
        }
      }
      return variants;
    }
    throw ('The json object does not represent a DictionaryEntry object.');
  }

  /// Returns the `id` field of the Map<String, dynamic> response as `String?`.
  String? get term => this['id'] is String ? this['id'] as String : null;
}

// ignore: unused_element
final _sampleRequestUrl =
    'https://od-api.oxforddictionaries.com/api/v2/translations/en/de/swim?strictMatch=false';

// ignore: unused_element
final _sampleBody = {
  {
    'id': 'swim',
    'metadata': {
      'operation': 'translations',
      'provider': 'Oxford University Press',
      'schema': 'RetrieveTranslations'
    },
    'results': [
      {
        'id': 'swim',
        'language': 'en',
        'lexicalEntries': [
          {
            'entries': [
              {
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
                    'inflectedForm': 'swimming'
                  },
                  {
                    'grammaticalFeatures': [
                      {
                        'id': 'intransitive',
                        'text': 'Intransitive',
                        'type': 'Subcategorization'
                      }
                    ],
                    'inflectedForm': 'swam',
                    'pronunciations': [
                      {'phoneticNotation': 'IPA', 'phoneticSpelling': 'swæm'}
                    ]
                  },
                  {
                    'grammaticalFeatures': [
                      {
                        'id': 'intransitive',
                        'text': 'Intransitive',
                        'type': 'Subcategorization'
                      }
                    ],
                    'inflectedForm': 'swum',
                    'pronunciations': [
                      {'phoneticNotation': 'IPA', 'phoneticSpelling': 'swʌm'}
                    ]
                  }
                ],
                'pronunciations': [
                  {
                    'audioFile':
                        'https://audio.oxforddictionaries.com/en/mp3/swim_gb_1.mp3',
                    'dialects': ['British English'],
                    'phoneticNotation': 'IPA',
                    'phoneticSpelling': 'swɪm'
                  },
                  {
                    'audioFile':
                        'https://audio.oxforddictionaries.com/en/mp3/swim_us_1.mp3',
                    'dialects': ['American English'],
                    'phoneticNotation': 'IPA',
                    'phoneticSpelling': 'swɪm'
                  }
                ],
                'senses': [
                  {
                    'datasetCrossLinks': [
                      {
                        'entry_id': 'swim',
                        'language': 'en-gb',
                        'sense_id': 'm_en_gbus1020960.013'
                      }
                    ],
                    'examples': [
                      {
                        'registers': [
                          {'id': 'figurative', 'text': 'Figurative'}
                        ],
                        'text': 'swim with/against the tide/stream',
                        'translations': [
                          {
                            'language': 'de',
                            'text': 'mit dem/gegen den Strom schwimmen'
                          }
                        ]
                      }
                    ],
                    'id': 'b-en-de0034026.002',
                    'translations': [
                      {'language': 'de', 'text': 'schwimmen'}
                    ]
                  },
                  {
                    'datasetCrossLinks': [
                      {
                        'entry_id': 'swim',
                        'language': 'en-gb',
                        'sense_id': 'm_en_gbus1020960.023'
                      }
                    ],
                    'examples': [
                      {
                        'text': 'swim with / in sth',
                        'translations': [
                          {'language': 'de', 'text': 'in etw. (Dat.) schwimmen'}
                        ]
                      },
                      {
                        'text': 'her eyes swam with tears',
                        'translations': [
                          {'language': 'de', 'text': 'ihre Augen schwammen'}
                        ]
                      },
                      {
                        'text': 'the deck was swimming with water',
                        'translations': [
                          {
                            'language': 'de',
                            'text': 'das Deck stand unter Wasser'
                          }
                        ]
                      }
                    ],
                    'id': 'b-en-de0034026.003',
                    'notes': [
                      {'text': 'be flooded, overflow', 'type': 'indicator'}
                    ],
                    'registers': [
                      {'id': 'figurative', 'text': 'Figurative'}
                    ]
                  },
                  {
                    'datasetCrossLinks': [
                      {
                        'entry_id': 'swim',
                        'language': 'en-gb',
                        'sense_id': 'm_en_gbus1020960.025'
                      }
                    ],
                    'examples': [
                      {
                        'text': "swim [before sb's eyes]",
                        'translations': [
                          {
                            'language': 'de',
                            'text': '[vor jmds. Augen] verschwimmen'
                          }
                        ]
                      }
                    ],
                    'id': 'b-en-de0034026.004',
                    'notes': [
                      {'text': 'appear to whirl', 'type': 'indicator'}
                    ]
                  },
                  {
                    'datasetCrossLinks': [
                      {
                        'entry_id': 'swim',
                        'language': 'en-gb',
                        'sense_id': 'm_en_gbus1020960.026'
                      }
                    ],
                    'examples': [
                      {
                        'crossReferenceMarkers': ['sink'],
                        'crossReferences': [
                          {'id': 'sink', 'text': 'sink', 'type': 'see also'}
                        ],
                        'text': 'my head was swimming',
                        'translations': [
                          {'language': 'de', 'text': 'mir war schwindelig'}
                        ]
                      }
                    ],
                    'id': 'b-en-de0034026.005',
                    'notes': [
                      {'text': 'have dizzy sensation', 'type': 'indicator'}
                    ]
                  }
                ]
              },
              {
                'grammaticalFeatures': [
                  {
                    'id': 'transitive',
                    'text': 'Transitive',
                    'type': 'Subcategorization'
                  }
                ],
                'inflections': [
                  {
                    'grammaticalFeatures': [
                      {
                        'id': 'transitive',
                        'text': 'Transitive',
                        'type': 'Subcategorization'
                      }
                    ],
                    'inflectedForm': 'swimming'
                  },
                  {
                    'grammaticalFeatures': [
                      {
                        'id': 'transitive',
                        'text': 'Transitive',
                        'type': 'Subcategorization'
                      }
                    ],
                    'inflectedForm': 'swam'
                  },
                  {
                    'grammaticalFeatures': [
                      {
                        'id': 'transitive',
                        'text': 'Transitive',
                        'type': 'Subcategorization'
                      }
                    ],
                    'inflectedForm': 'swum'
                  }
                ],
                'pronunciations': [
                  {
                    'audioFile':
                        'https://audio.oxforddictionaries.com/en/mp3/swim_gb_1.mp3',
                    'dialects': ['British English'],
                    'phoneticNotation': 'IPA',
                    'phoneticSpelling': 'swɪm'
                  },
                  {
                    'audioFile':
                        'https://audio.oxforddictionaries.com/en/mp3/swim_us_1.mp3',
                    'dialects': ['American English'],
                    'phoneticNotation': 'IPA',
                    'phoneticSpelling': 'swɪm'
                  }
                ],
                'senses': [
                  {
                    'datasetCrossLinks': [
                      {
                        'entry_id': 'swim',
                        'language': 'en-gb',
                        'sense_id': 'm_en_gbus1020960.013'
                      },
                      {
                        'entry_id': 'swim',
                        'language': 'en-gb',
                        'sense_id': 'm_en_gbus1020960.019'
                      }
                    ],
                    'examples': [
                      {
                        'text': 'swim [the] breaststroke/crawl',
                        'translations': [
                          {'language': 'de', 'text': 'brustschwimmen/kraulen'}
                        ]
                      }
                    ],
                    'id': 'b-en-de0034026.007',
                    'translations': [
                      {
                        'collocations': [
                          {'id': 'Strecke', 'text': 'Strecke', 'type': 'object'}
                        ],
                        'language': 'de',
                        'text': 'schwimmen'
                      },
                      {
                        'collocations': [
                          {'id': 'Fluss', 'text': 'Fluss', 'type': 'object'},
                          {'id': 'See', 'text': 'See', 'type': 'object'}
                        ],
                        'language': 'de',
                        'text': 'durchschwimmen'
                      }
                    ]
                  }
                ]
              }
            ],
            'language': 'en',
            'lexicalCategory': {'id': 'verb', 'text': 'Verb'},
            'text': 'swim'
          },
          {
            'entries': [
              {
                'pronunciations': [
                  {
                    'audioFile':
                        'https://audio.oxforddictionaries.com/en/mp3/swim_gb_1.mp3',
                    'dialects': ['British English'],
                    'phoneticNotation': 'IPA',
                    'phoneticSpelling': 'swɪm'
                  },
                  {
                    'audioFile':
                        'https://audio.oxforddictionaries.com/en/mp3/swim_us_1.mp3',
                    'dialects': ['American English'],
                    'phoneticNotation': 'IPA',
                    'phoneticSpelling': 'swɪm'
                  }
                ],
                'senses': [
                  {
                    'datasetCrossLinks': [
                      {
                        'entry_id': 'swim',
                        'language': 'en-gb',
                        'sense_id': 'm_en_gbus1020960.029'
                      }
                    ],
                    'examples': [
                      {
                        'text': 'have a/go for a swim',
                        'translations': [
                          {
                            'language': 'de',
                            'text': 'schwimmen/schwimmen gehen'
                          }
                        ]
                      },
                      {
                        'text': 'do you fancy a swim?',
                        'translations': [
                          {
                            'language': 'de',
                            'text': 'möchtest du schwimmen gehen?'
                          }
                        ]
                      },
                      {
                        'text': 'a refreshing swim',
                        'translations': [
                          {'language': 'de', 'text': 'ein erfrischendes Bad'}
                        ]
                      },
                      {
                        'text': 'I like an early morning swim',
                        'translations': [
                          {
                            'language': 'de',
                            'text': 'ich gehe gern frühmorgens schwimmen'
                          }
                        ]
                      }
                    ],
                    'id': 'b-en-de0034026.009'
                  },
                  {
                    'examples': [
                      {
                        'text': 'be in the swim [of things]',
                        'translations': [
                          {'language': 'de', 'text': 'mitten im Geschehen sein'}
                        ]
                      }
                    ],
                    'id': 'b-en-de0034026.010'
                  }
                ]
              }
            ],
            'language': 'en',
            'lexicalCategory': {'id': 'noun', 'text': 'Noun'},
            'text': 'swim'
          }
        ],
        'type': 'headword',
        'word': 'swim'
      }
    ],
    'word': 'swim'
  }
};
