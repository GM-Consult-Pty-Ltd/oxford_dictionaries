// Copyright ©2022, GM Consult (Pty) Ltd.
// BSD 3-Clause License
// All rights reserved

import 'package:gmconsult_dart_core/type_definitions.dart';
import 'package:oxford_dictionaries/src/_index.dart';
import 'oxford_dictionaries_endpoint.dart';
import 'package:dictosaurus/dictosaurus.dart';

/// Retrieve words that are similar/opposite in meaning to the input word
/// (synonym /antonym).
class ThesaurusEndpoint extends OdApiEndpoint<DictionaryEntry> {
//

  /// Queries the [ThesaurusEndpoint] for a [DictionaryEntry] for the [term] and
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
      ThesaurusEndpoint._(term, apiKeys, language, strictMatch, fields).get();

  /// Const default generative constructor.
  ThesaurusEndpoint._(
      this.term, this.headers, this.language, this.strictMatch, this.fields);

  @override
  final String term;

  @override
  final Language language;

  @override
  String get path =>
      'api/v2/thesaurus/${language.toLanguageTag().toLowerCase()}/${term.toLowerCase()}';

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

  @override
  Map<String, String> get queryParameters {
    final qp = {'strictMatch': strictMatch.toString()};
    if (fields != null) {
      qp['fields'] = fields!.toParameter;
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
              final pronunciations = e.pronunciations(term, language);
              final etymologies = e.etymologies;
              // phonetic = phonetic ?? e.lexicalEntriesEntryPhonetic;
              final senses = e.getJsonList('senses');
              for (final s in senses) {
                final synonyms = s.getTextValues('synonyms', 'text');
                final antonyms = s.getTextValues('antonyms', 'text');
                phrases.addAll(s.getTextValues('examples', 'text'));
                final subsenses = s.getJsonList('subsenses');
                for (final ss in subsenses) {
                  phrases.addAll(ss.getTextValues('examples', 'text'));
                  synonyms.addAll(ss.getTextValues('synonyms', 'text'));
                  antonyms.addAll(ss.getTextValues('antonyms', 'text'));
                }

                final variant = TermVariant(
                    term: term,
                    language: language,
                    pronunciations: pronunciations,
                    etymologies: etymologies,
                    lemmas: {},
                    partOfSpeech: partOfSpeech,
                    definition: '',
                    phrases: phrases,
                    antonyms: antonyms,
                    inflections: inflections,
                    synonyms: synonyms);
                variants.add(variant);
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
  'id': 'high',
  'metadata': {
    'operation': 'retrieve',
    'provider': 'Oxford University Press',
    'schema': 'ThesaurusEndpoint'
  },
  'results': [
    {
      'id': 'high',
      'language': 'en-gb',
      'lexicalEntries': [
        {
          'entries': [
            {
              'senses': [
                {
                  'antonyms': [
                    {'language': 'en', 'text': 'short'}
                  ],
                  'examples': [
                    {'text': 'the top of a high mountain'}
                  ],
                  'id': 't_en_gb0006975.001',
                  'subsenses': [
                    {
                      'id': 'id99bff77a-c383-4f33-aa96-b15f1b3dca98',
                      'synonyms': [
                        {'language': 'en', 'text': 'multistorey'},
                        {'language': 'en', 'text': 'high-rise'},
                        {'language': 'en', 'text': 'sky-scraping'}
                      ]
                    }
                  ],
                  'synonyms': [
                    {'language': 'en', 'text': 'tall'},
                    {'language': 'en', 'text': 'lofty'},
                    {'language': 'en', 'text': 'towering'},
                    {'language': 'en', 'text': 'soaring'},
                    {'language': 'en', 'text': 'elevated'},
                    {'language': 'en', 'text': 'giant'},
                    {'language': 'en', 'text': 'big'}
                  ]
                },
                {
                  'antonyms': [
                    {'language': 'en', 'text': 'low-ranking'},
                    {'language': 'en', 'text': 'lowly'}
                  ],
                  'examples': [
                    {'text': 'he is in a high position in the government'}
                  ],
                  'id': 't_en_gb0006975.002',
                  'subsenses': [
                    {
                      'id': 'idfaa0127e-1a9a-4fd4-8968-1ffdd956a8a3',
                      'regions': [
                        {'id': 'north_american', 'text': 'North American'}
                      ],
                      'synonyms': [
                        {'language': 'en', 'text': 'ranking'}
                      ]
                    },
                    {
                      'id': 'id1101da9b-2256-424d-9ce4-e78a1af8fec9',
                      'registers': [
                        {'id': 'informal', 'text': 'Informal'}
                      ],
                      'synonyms': [
                        {'language': 'en', 'text': 'top-notch'}
                      ]
                    }
                  ],
                  'synonyms': [
                    {'language': 'en', 'text': 'high-ranking'},
                    {'language': 'en', 'text': 'high-level'},
                    {'language': 'en', 'text': 'leading'},
                    {'language': 'en', 'text': 'top'},
                    {'language': 'en', 'text': 'top-level'},
                    {'language': 'en', 'text': 'prominent'},
                    {'language': 'en', 'text': 'eminent'},
                    {'language': 'en', 'text': 'pre-eminent'},
                    {'language': 'en', 'text': 'foremost'},
                    {'language': 'en', 'text': 'senior'},
                    {'language': 'en', 'text': 'influential'},
                    {'language': 'en', 'text': 'distinguished'},
                    {'language': 'en', 'text': 'powerful'},
                    {'language': 'en', 'text': 'important'},
                    {'language': 'en', 'text': 'elevated'},
                    {'language': 'en', 'text': 'notable'},
                    {'language': 'en', 'text': 'principal'},
                    {'language': 'en', 'text': 'prime'},
                    {'language': 'en', 'text': 'premier'},
                    {'language': 'en', 'text': 'chief'},
                    {'language': 'en', 'text': 'main'},
                    {'language': 'en', 'text': 'upper'},
                    {'language': 'en', 'text': 'ruling'},
                    {'language': 'en', 'text': 'exalted'},
                    {'language': 'en', 'text': 'illustrious'}
                  ]
                },
                {
                  'antonyms': [
                    {'language': 'en', 'text': 'amoral'}
                  ],
                  'examples': [
                    {'text': 'you should hold on to your high principles'}
                  ],
                  'id': 't_en_gb0006975.003',
                  'synonyms': [
                    {'language': 'en', 'text': 'high-minded'},
                    {'language': 'en', 'text': 'noble-minded'},
                    {'language': 'en', 'text': 'lofty'},
                    {'language': 'en', 'text': 'moral'},
                    {'language': 'en', 'text': 'ethical'},
                    {'language': 'en', 'text': 'honourable'},
                    {'language': 'en', 'text': 'admirable'},
                    {'language': 'en', 'text': 'upright'},
                    {'language': 'en', 'text': 'principled'},
                    {'language': 'en', 'text': 'honest'},
                    {'language': 'en', 'text': 'virtuous'},
                    {'language': 'en', 'text': 'righteous'}
                  ]
                },
                {
                  'antonyms': [
                    {'language': 'en', 'text': 'reasonable'}
                  ],
                  'examples': [
                    {'text': 'shop around to avoid high prices'}
                  ],
                  'id': 't_en_gb0006975.004',
                  'subsenses': [
                    {
                      'id': 'id7b859112-7996-438e-9abc-ee99c03e32b7',
                      'regions': [
                        {'id': 'british', 'text': 'British'}
                      ],
                      'synonyms': [
                        {'language': 'en', 'text': 'over the odds'}
                      ]
                    },
                    {
                      'id': 'id52735bc8-ce64-4e37-82d8-433d4c8952d4',
                      'registers': [
                        {'id': 'informal', 'text': 'Informal'}
                      ],
                      'synonyms': [
                        {'language': 'en', 'text': 'steep'},
                        {'language': 'en', 'text': 'stiff'},
                        {'language': 'en', 'text': 'pricey'},
                        {'language': 'en', 'text': 'over the top'},
                        {'language': 'en', 'text': 'OTT'},
                        {'language': 'en', 'text': 'criminal'}
                      ]
                    }
                  ],
                  'synonyms': [
                    {'language': 'en', 'text': 'inflated'},
                    {'language': 'en', 'text': 'excessive'},
                    {'language': 'en', 'text': 'unreasonable'},
                    {'language': 'en', 'text': 'overpriced'},
                    {'language': 'en', 'text': 'sky-high'},
                    {'language': 'en', 'text': 'unduly expensive'},
                    {'language': 'en', 'text': 'dear'},
                    {'language': 'en', 'text': 'costly'},
                    {'language': 'en', 'text': 'top'},
                    {'language': 'en', 'text': 'exorbitant'},
                    {'language': 'en', 'text': 'extortionate'},
                    {'language': 'en', 'text': 'outrageous'},
                    {'language': 'en', 'text': 'prohibitive'}
                  ]
                },
                {
                  'antonyms': [
                    {'language': 'en', 'text': 'poor'},
                    {'language': 'en', 'text': 'deplorable'}
                  ],
                  'examples': [
                    {'text': 'I have always insisted upon high standards'}
                  ],
                  'id': 't_en_gb0006975.005',
                  'subsenses': [
                    {
                      'id': 'id0b41f831-732a-4603-9301-3c6683106583',
                      'registers': [
                        {'id': 'informal', 'text': 'Informal'}
                      ],
                      'synonyms': [
                        {'language': 'en', 'text': 'tip-top'},
                        {'language': 'en', 'text': 'A1'},
                        {'language': 'en', 'text': 'top-notch'}
                      ]
                    },
                    {
                      'id': 'id85c274cc-0d52-4aaf-a9f7-408bbbae08a5',
                      'registers': [
                        {'id': 'rare', 'text': 'Rare'}
                      ],
                      'synonyms': [
                        {'language': 'en', 'text': 'applaudable'}
                      ]
                    }
                  ],
                  'synonyms': [
                    {'language': 'en', 'text': 'excellent'},
                    {'language': 'en', 'text': 'outstanding'},
                    {'language': 'en', 'text': 'exemplary'},
                    {'language': 'en', 'text': 'exceptional'},
                    {'language': 'en', 'text': 'admirable'},
                    {'language': 'en', 'text': 'fine'},
                    {'language': 'en', 'text': 'great'},
                    {'language': 'en', 'text': 'good'},
                    {'language': 'en', 'text': 'very good'},
                    {'language': 'en', 'text': 'first-class'},
                    {'language': 'en', 'text': 'first-rate'},
                    {'language': 'en', 'text': 'superior'},
                    {'language': 'en', 'text': 'superlative'},
                    {'language': 'en', 'text': 'superb'},
                    {'language': 'en', 'text': 'commendable'},
                    {'language': 'en', 'text': 'laudable'},
                    {'language': 'en', 'text': 'praiseworthy'},
                    {'language': 'en', 'text': 'meritorious'},
                    {'language': 'en', 'text': 'blameless'},
                    {'language': 'en', 'text': 'faultless'},
                    {'language': 'en', 'text': 'flawless'},
                    {'language': 'en', 'text': 'impeccable'},
                    {'language': 'en', 'text': 'irreproachable'},
                    {'language': 'en', 'text': 'unimpeachable'},
                    {'language': 'en', 'text': 'perfect'},
                    {'language': 'en', 'text': 'unequalled'},
                    {'language': 'en', 'text': 'unparalleled'}
                  ]
                },
                {
                  'antonyms': [
                    {'language': 'en', 'text': 'light'},
                    {'language': 'en', 'text': 'calm'}
                  ],
                  'examples': [
                    {'text': 'it was freezing cold with high winds'}
                  ],
                  'id': 't_en_gb0006975.006',
                  'subsenses': [
                    {
                      'id': 'idb853bfae-88ec-48e7-9ff2-90817db21372',
                      'synonyms': [
                        {'language': 'en', 'text': 'blustery'},
                        {'language': 'en', 'text': 'gusty'},
                        {'language': 'en', 'text': 'stormy'},
                        {'language': 'en', 'text': 'squally'},
                        {'language': 'en', 'text': 'tempestuous'},
                        {'language': 'en', 'text': 'turbulent'}
                      ]
                    },
                    {
                      'id': 'id5fb73ddf-a633-42ff-8191-452eba46f366',
                      'registers': [
                        {'id': 'rare', 'text': 'Rare'}
                      ],
                      'synonyms': [
                        {'language': 'en', 'text': 'boisterous'}
                      ]
                    }
                  ],
                  'synonyms': [
                    {'language': 'en', 'text': 'strong'},
                    {'language': 'en', 'text': 'powerful'},
                    {'language': 'en', 'text': 'violent'},
                    {'language': 'en', 'text': 'intense'},
                    {'language': 'en', 'text': 'extreme'},
                    {'language': 'en', 'text': 'forceful'},
                    {'language': 'en', 'text': 'sharp'},
                    {'language': 'en', 'text': 'stiff'}
                  ]
                },
                {
                  'antonyms': [
                    {'language': 'en', 'text': 'abstemious'}
                  ],
                  'examples': [
                    {
                      'text':
                          'he lived the high life among the London glitterati'
                    }
                  ],
                  'id': 't_en_gb0006975.007',
                  'subsenses': [
                    {
                      'id': 'id8442304b-6839-4fe1-9f61-44fa23399b25',
                      'synonyms': [
                        {'language': 'en', 'text': 'prodigal'},
                        {'language': 'en', 'text': 'overindulgent'},
                        {'language': 'en', 'text': 'intemperate'},
                        {'language': 'en', 'text': 'immoderate'}
                      ]
                    },
                    {
                      'id': 'id284fea99-44fd-40d4-932a-baa98e82f39c',
                      'regions': [
                        {'id': 'british', 'text': 'British'}
                      ],
                      'synonyms': [
                        {'language': 'en', 'text': 'upmarket'}
                      ]
                    },
                    {
                      'id': 'id8f75e36d-ee27-4fab-9866-5053e0ac5dd8',
                      'regions': [
                        {'id': 'north_american', 'text': 'North American'}
                      ],
                      'synonyms': [
                        {'language': 'en', 'text': 'upscale'}
                      ]
                    },
                    {
                      'id': 'id2e39737c-f2d9-4c32-986b-67e20d1cb9be',
                      'registers': [
                        {'id': 'informal', 'text': 'Informal'}
                      ],
                      'synonyms': [
                        {'language': 'en', 'text': 'fancy'},
                        {'language': 'en', 'text': 'classy'},
                        {'language': 'en', 'text': 'swanky'}
                      ]
                    }
                  ],
                  'synonyms': [
                    {'language': 'en', 'text': 'luxurious'},
                    {'language': 'en', 'text': 'lavish'},
                    {'language': 'en', 'text': 'extravagant'},
                    {'language': 'en', 'text': 'rich'},
                    {'language': 'en', 'text': 'grand'},
                    {'language': 'en', 'text': 'sybaritic'},
                    {'language': 'en', 'text': 'hedonistic'},
                    {'language': 'en', 'text': 'opulent'}
                  ]
                },
                {
                  'antonyms': [
                    {'language': 'en', 'text': 'unfavourable'}
                  ],
                  'examples': [
                    {'text': 'I have a high opinion of your talents'}
                  ],
                  'id': 't_en_gb0006975.008',
                  'subsenses': [
                    {
                      'id': 'id5314ff76-34b0-4c00-8fc8-547a0592861d',
                      'registers': [
                        {'id': 'rare', 'text': 'Rare'}
                      ],
                      'synonyms': [
                        {'language': 'en', 'text': 'panegyrical'},
                        {'language': 'en', 'text': 'acclamatory'},
                        {'language': 'en', 'text': 'laudative'},
                        {'language': 'en', 'text': 'encomiastical'}
                      ]
                    }
                  ],
                  'synonyms': [
                    {'language': 'en', 'text': 'favourable'},
                    {'language': 'en', 'text': 'good'},
                    {'language': 'en', 'text': 'positive'},
                    {'language': 'en', 'text': 'approving'},
                    {'language': 'en', 'text': 'admiring'},
                    {'language': 'en', 'text': 'complimentary'},
                    {'language': 'en', 'text': 'commendatory'},
                    {'language': 'en', 'text': 'appreciative'},
                    {'language': 'en', 'text': 'flattering'},
                    {'language': 'en', 'text': 'glowing'},
                    {'language': 'en', 'text': 'adulatory'},
                    {'language': 'en', 'text': 'approbatory'},
                    {'language': 'en', 'text': 'rapturous'},
                    {'language': 'en', 'text': 'full of praise'}
                  ]
                },
                {
                  'antonyms': [
                    {'language': 'en', 'text': 'low-pitched'},
                    {'language': 'en', 'text': 'deep'}
                  ],
                  'examples': [
                    {'text': 'the voices rose to hit a high note'}
                  ],
                  'id': 't_en_gb0006975.009',
                  'synonyms': [
                    {'language': 'en', 'text': 'high-pitched'},
                    {'language': 'en', 'text': 'high-frequency'},
                    {'language': 'en', 'text': 'soprano'},
                    {'language': 'en', 'text': 'treble'},
                    {'language': 'en', 'text': 'falsetto'},
                    {'language': 'en', 'text': 'shrill'},
                    {'language': 'en', 'text': 'acute'},
                    {'language': 'en', 'text': 'sharp'},
                    {'language': 'en', 'text': 'piping'},
                    {'language': 'en', 'text': 'piercing'},
                    {'language': 'en', 'text': 'penetrating'}
                  ]
                },
                {
                  'antonyms': [
                    {'language': 'en', 'text': 'sober'}
                  ],
                  'examples': [
                    {
                      'text':
                          'some of them were already high on alcohol and Ecstasy'
                    }
                  ],
                  'id': 't_en_gb0006975.010',
                  'registers': [
                    {'id': 'informal', 'text': 'Informal'}
                  ],
                  'subsenses': [
                    {
                      'id': 'id2a5c027d-936b-4625-af2e-921080082d0a',
                      'registers': [
                        {'id': 'informal', 'text': 'Informal'}
                      ],
                      'synonyms': [
                        {'language': 'en', 'text': 'on a high'},
                        {'language': 'en', 'text': 'stoned'},
                        {'language': 'en', 'text': 'turned on'},
                        {'language': 'en', 'text': 'on a trip'},
                        {'language': 'en', 'text': 'tripping'},
                        {'language': 'en', 'text': 'hyped up'},
                        {'language': 'en', 'text': 'freaked out'},
                        {'language': 'en', 'text': 'spaced out'},
                        {'language': 'en', 'text': 'zonked'},
                        {'language': 'en', 'text': 'wasted'},
                        {'language': 'en', 'text': 'wrecked'},
                        {'language': 'en', 'text': 'high as a kite'},
                        {'language': 'en', 'text': "off one's head"},
                        {'language': 'en', 'text': "out of one's mind"},
                        {'language': 'en', 'text': 'flying'},
                        {'language': 'en', 'text': 'charged up'}
                      ]
                    },
                    {
                      'id': 'id435295bb-4e0a-4a12-b256-2a4945ecd8b8',
                      'regions': [
                        {'id': 'north_american', 'text': 'North American'}
                      ],
                      'registers': [
                        {'id': 'informal', 'text': 'Informal'}
                      ],
                      'synonyms': [
                        {'language': 'en', 'text': 'blitzed'},
                        {'language': 'en', 'text': 'ripped'}
                      ]
                    },
                    {
                      'id': 'id2a586a04-a02f-4537-a07f-470ce1a9d119',
                      'regions': [
                        {'id': 'us', 'text': 'Us'}
                      ],
                      'registers': [
                        {'id': 'informal', 'text': 'Informal'}
                      ],
                      'synonyms': [
                        {'language': 'en', 'text': 'jacked'},
                        {'language': 'en', 'text': 'turnt'}
                      ]
                    }
                  ],
                  'synonyms': [
                    {'language': 'en', 'text': 'intoxicated'},
                    {'language': 'en', 'text': 'inebriated'},
                    {'language': 'en', 'text': 'on drugs'},
                    {'language': 'en', 'text': 'drugged'},
                    {'language': 'en', 'text': 'stupefied'},
                    {'language': 'en', 'text': 'befuddled'},
                    {'language': 'en', 'text': 'delirious'},
                    {'language': 'en', 'text': 'hallucinating'}
                  ]
                },
                {
                  'antonyms': [
                    {'language': 'en', 'text': 'fresh'},
                    {'language': 'en', 'text': 'aromatic'}
                  ],
                  'examples': [
                    {'text': 'the partridges were pretty high'}
                  ],
                  'id': 't_en_gb0006975.011',
                  'subsenses': [
                    {
                      'id': 'id3c687080-104d-4d9d-9cb8-6e75bbc37af7',
                      'synonyms': [
                        {'language': 'en', 'text': 'stinking'},
                        {'language': 'en', 'text': 'reeking'},
                        {'language': 'en', 'text': 'rank'},
                        {'language': 'en', 'text': 'malodorous'},
                        {'language': 'en', 'text': 'going bad'},
                        {'language': 'en', 'text': 'going off'},
                        {'language': 'en', 'text': 'off'},
                        {'language': 'en', 'text': 'rotting'},
                        {'language': 'en', 'text': 'spoiled'},
                        {'language': 'en', 'text': 'tainted'}
                      ]
                    },
                    {
                      'id': 'ide7dc98b6-42b4-4e40-80e0-079202ec8c57',
                      'regions': [
                        {'id': 'british', 'text': 'British'}
                      ],
                      'registers': [
                        {'id': 'informal', 'text': 'Informal'}
                      ],
                      'synonyms': [
                        {'language': 'en', 'text': 'pongy'},
                        {'language': 'en', 'text': 'niffy'},
                        {'language': 'en', 'text': 'whiffy'}
                      ]
                    },
                    {
                      'id': 'ide85237d7-804f-42e2-b651-117c0f441304',
                      'regions': [
                        {'id': 'north_american', 'text': 'North American'}
                      ],
                      'registers': [
                        {'id': 'informal', 'text': 'Informal'}
                      ],
                      'synonyms': [
                        {'language': 'en', 'text': 'funky'}
                      ]
                    },
                    {
                      'id': 'idd403de6b-5fb3-4716-9abd-26dd914d371e',
                      'registers': [
                        {'id': 'literary', 'text': 'Literary'}
                      ],
                      'synonyms': [
                        {'language': 'en', 'text': 'noisome'},
                        {'language': 'en', 'text': 'miasmic'}
                      ]
                    }
                  ],
                  'synonyms': [
                    {'language': 'en', 'text': 'gamy'},
                    {'language': 'en', 'text': 'smelly'},
                    {'language': 'en', 'text': 'strong-smelling'}
                  ]
                }
              ]
            }
          ],
          'language': 'en-gb',
          'lexicalCategory': {'id': 'adjective', 'text': 'Adjective'},
          'text': 'high'
        },
        {
          'entries': [
            {
              'senses': [
                {
                  'antonyms': [
                    {'language': 'en', 'text': 'low'}
                  ],
                  'examples': [
                    {'text': 'commodity prices were actually at a rare high'}
                  ],
                  'id': 't_en_gb0006975.015',
                  'subsenses': [
                    {
                      'id': 'idb0c7dd74-a350-4259-af04-aea924f1b5c0',
                      'synonyms': [
                        {'language': 'en', 'text': 'top'},
                        {'language': 'en', 'text': 'pinnacle'},
                        {'language': 'en', 'text': 'zenith'},
                        {'language': 'en', 'text': 'apex'},
                        {'language': 'en', 'text': 'acme'},
                        {'language': 'en', 'text': 'apogee'},
                        {'language': 'en', 'text': 'apotheosis'},
                        {'language': 'en', 'text': 'culmination'},
                        {'language': 'en', 'text': 'climax'},
                        {'language': 'en', 'text': 'height'},
                        {'language': 'en', 'text': 'summit'}
                      ]
                    }
                  ],
                  'synonyms': [
                    {'language': 'en', 'text': 'high level'},
                    {'language': 'en', 'text': 'high point'},
                    {'language': 'en', 'text': 'record level'},
                    {'language': 'en', 'text': 'peak'},
                    {'language': 'en', 'text': 'record'},
                    {'language': 'en', 'text': 'high water mark'}
                  ]
                }
              ]
            }
          ],
          'language': 'en-gb',
          'lexicalCategory': {'id': 'noun', 'text': 'Noun'},
          'text': 'high'
        },
        {
          'entries': [
            {
              'senses': [
                {
                  'antonyms': [
                    {'language': 'en', 'text': 'low'}
                  ],
                  'examples': [
                    {'text': 'a jet was flying high overhead'}
                  ],
                  'id': 't_en_gb0006975.017',
                  'subsenses': [
                    {
                      'id': 'id56d78015-3488-4049-b2eb-8402e0d85337',
                      'synonyms': [
                        {'language': 'en', 'text': 'in the air'},
                        {'language': 'en', 'text': 'in the sky'},
                        {'language': 'en', 'text': 'on high'},
                        {'language': 'en', 'text': 'aloft'},
                        {'language': 'en', 'text': 'overhead'},
                        {'language': 'en', 'text': "above one's head"},
                        {'language': 'en', 'text': "over one's head"}
                      ]
                    }
                  ],
                  'synonyms': [
                    {'language': 'en', 'text': 'at great height'},
                    {'language': 'en', 'text': 'high up'},
                    {'language': 'en', 'text': 'far up'},
                    {'language': 'en', 'text': 'way up'},
                    {'language': 'en', 'text': 'at altitude'}
                  ]
                }
              ]
            }
          ],
          'language': 'en-gb',
          'lexicalCategory': {'id': 'adverb', 'text': 'Adverb'},
          'text': 'high'
        }
      ],
      'type': 'headword',
      'word': 'high'
    }
  ],
  'word': 'high'
};
