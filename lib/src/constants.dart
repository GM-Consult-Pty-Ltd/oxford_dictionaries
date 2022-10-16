// Copyright ©2022, GM Consult (Pty) Ltd.
// BSD 3-Clause License
// All rights reserved

import 'package:oxford_dictionaries/src/_index.dart';
import 'package:oxford_dictionaries/src/oxford_dictionaries_language.dart';

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
    OxFordDictionariesEndpoint.entries: [
      OxfordDictionariesLanguage.en_GB,
      OxfordDictionariesLanguage.en_US,
      OxfordDictionariesLanguage.fr,
      OxfordDictionariesLanguage.gu,
      OxfordDictionariesLanguage.hi,
      OxfordDictionariesLanguage.lv,
      OxfordDictionariesLanguage.ro,
      OxfordDictionariesLanguage.es,
      OxfordDictionariesLanguage.sw,
      OxfordDictionariesLanguage.ta
    ],
    OxFordDictionariesEndpoint.words: [
      OxfordDictionariesLanguage.en_GB,
      OxfordDictionariesLanguage.en_US,
      OxfordDictionariesLanguage.fr,
      OxfordDictionariesLanguage.gu,
      OxfordDictionariesLanguage.hi,
      OxfordDictionariesLanguage.lv,
      OxfordDictionariesLanguage.ro,
      OxfordDictionariesLanguage.es,
      OxfordDictionariesLanguage.sw,
      OxfordDictionariesLanguage.ta
    ],
    OxFordDictionariesEndpoint.inflections: [
      OxfordDictionariesLanguage.en_GB,
      OxfordDictionariesLanguage.en_US,
      OxfordDictionariesLanguage.hi,
      OxfordDictionariesLanguage.lv,
      OxfordDictionariesLanguage.ro,
      OxfordDictionariesLanguage.es,
      OxfordDictionariesLanguage.sw,
      OxfordDictionariesLanguage.ta
    ],
    OxFordDictionariesEndpoint.lemmas: [
      OxfordDictionariesLanguage.en,
      OxfordDictionariesLanguage.de,
      OxfordDictionariesLanguage.hi,
      OxfordDictionariesLanguage.it,
      OxfordDictionariesLanguage.lv,
      OxfordDictionariesLanguage.pt,
      OxfordDictionariesLanguage.ro,
      OxfordDictionariesLanguage.tn,
      OxfordDictionariesLanguage.es,
      OxfordDictionariesLanguage.sw,
      OxfordDictionariesLanguage.ta
    ],
    OxFordDictionariesEndpoint.search: [
      OxfordDictionariesLanguage.en_GB,
      OxfordDictionariesLanguage.en_US,
      OxfordDictionariesLanguage.fr,
      OxfordDictionariesLanguage.gu,
      OxfordDictionariesLanguage.hi,
      OxfordDictionariesLanguage.lv,
      OxfordDictionariesLanguage.ro,
      OxfordDictionariesLanguage.es,
      OxfordDictionariesLanguage.sw,
      OxfordDictionariesLanguage.ta
    ],
    OxFordDictionariesEndpoint.searchTranslations: [
      OxfordDictionariesLanguage.en,
      OxfordDictionariesLanguage.ar,
      OxfordDictionariesLanguage.zh,
      OxfordDictionariesLanguage.de,
      OxfordDictionariesLanguage.el,
      OxfordDictionariesLanguage.ha,
      OxfordDictionariesLanguage.hi,
      OxfordDictionariesLanguage.id,
      OxfordDictionariesLanguage.xh,
      OxfordDictionariesLanguage.zu,
      OxfordDictionariesLanguage.it,
      OxfordDictionariesLanguage.ms,
      OxfordDictionariesLanguage.mr,
      OxfordDictionariesLanguage.nso,
      OxfordDictionariesLanguage.pt,
      OxfordDictionariesLanguage.qu,
      OxfordDictionariesLanguage.ru,
      OxfordDictionariesLanguage.tn,
      OxfordDictionariesLanguage.es,
      OxfordDictionariesLanguage.tt,
      OxfordDictionariesLanguage.te,
      OxfordDictionariesLanguage.tpi,
      OxfordDictionariesLanguage.tk,
      OxfordDictionariesLanguage.ur
    ],
    OxFordDictionariesEndpoint.searchThesaurus: [OxfordDictionariesLanguage.en],
    OxFordDictionariesEndpoint.translations: [
      OxfordDictionariesLanguage.en,
      OxfordDictionariesLanguage.ar,
      OxfordDictionariesLanguage.zh,
      OxfordDictionariesLanguage.de,
      OxfordDictionariesLanguage.el,
      OxfordDictionariesLanguage.ha,
      OxfordDictionariesLanguage.hi,
      OxfordDictionariesLanguage.id,
      OxfordDictionariesLanguage.xh,
      OxfordDictionariesLanguage.zu,
      OxfordDictionariesLanguage.it,
      OxfordDictionariesLanguage.ms,
      OxfordDictionariesLanguage.mr,
      OxfordDictionariesLanguage.nso,
      OxfordDictionariesLanguage.pt,
      OxfordDictionariesLanguage.qu,
      OxfordDictionariesLanguage.ru,
      OxfordDictionariesLanguage.tn,
      OxfordDictionariesLanguage.es,
      OxfordDictionariesLanguage.tt,
      OxfordDictionariesLanguage.te,
      OxfordDictionariesLanguage.tpi,
      OxfordDictionariesLanguage.tk,
      OxfordDictionariesLanguage.ur
    ],
    OxFordDictionariesEndpoint.thesaurus: [OxfordDictionariesLanguage.en],
    OxFordDictionariesEndpoint.sentences: [
      OxfordDictionariesLanguage.en,
      OxfordDictionariesLanguage.es
    ],
  };
}
