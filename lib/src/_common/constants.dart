// Copyright ©2022, GM Consult (Pty) Ltd.
// BSD 3-Clause License
// All rights reserved

import 'oxford_dictionaries_endpoint.dart';

/// Constant values used by the Oxford Dictionaries API.
///
/// See https://developer.oxforddictionaries.com/documentation#!/ for more
/// information.
abstract class Constants {
  //

  /// Available language codes for each endpoint.
  ///
  /// See https://developer.oxforddictionaries.com/documentation/languages for
  /// latest or to update this map.
  static const sourceLanguages = {
    OxFordDictionariesEndpoint.entries: {
      'en-gb',
      'en-us',
      'fr',
      'gu',
      'hi',
      'lv',
      'ro',
      'es',
      'sw',
      'ta'
    },
    OxFordDictionariesEndpoint.words: {
      'en-gb',
      'en-us',
      'fr',
      'gu',
      'hi',
      'lv',
      'ro',
      'es',
      'sw',
      'ta'
    },
    OxFordDictionariesEndpoint.inflections: {
      'en-gb',
      'en-us',
      'hi',
      'lv',
      'ro',
      'es',
      'sw',
      'ta'
    },
    OxFordDictionariesEndpoint.lemmas: {
      'en',
      'de',
      'hi',
      'it',
      'lv',
      'pt',
      'ro',
      'tn',
      'es',
      'sw',
      'ta'
    },
    OxFordDictionariesEndpoint.search: {
      'en-gb',
      'en-us',
      'fr',
      'gu',
      'hi',
      'lv',
      'ro',
      'es',
      'sw',
      'ta'
    },
    OxFordDictionariesEndpoint.searchTranslations: {
      'en',
      'ar',
      'zh',
      'de',
      'el',
      'ha',
      'hi',
      'id',
      'xh',
      'zu',
      'it',
      'ms',
      'mr',
      'nso',
      'pt',
      'qu',
      'ru',
      'tn',
      'es',
      'tt',
      'te',
      'tpi',
      'tk',
      'ur'
    },
    OxFordDictionariesEndpoint.searchThesaurus: {'en'},
    OxFordDictionariesEndpoint.translations: {
      'en',
      'ar',
      'zh',
      'de',
      'el',
      'ha',
      'hi',
      'id',
      'xh',
      'zu',
      'it',
      'ms',
      'mr',
      'nso',
      'pt',
      'qu',
      'ru',
      'tn',
      'es',
      'tt',
      'te',
      'tpi',
      'tk',
      'ur'
    },
    OxFordDictionariesEndpoint.thesaurus: {'en'},
    OxFordDictionariesEndpoint.sentences: {'en', 'es'},
  };
}
