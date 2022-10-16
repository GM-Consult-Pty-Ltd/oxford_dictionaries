// Copyright ©2022, GM Consult (Pty) Ltd.
// BSD 3-Clause License
// All rights reserved

import 'package:gmconsult_dart_core/dart_core.dart';

/// An enumeration class for the languages available in the OxfordDictionaries
/// API
class OxfordDictionariesLanguage {
  /// Private generative constructor.

  /// Available languages in the API
  static const values = [
    OxfordDictionariesLanguage.en_GB,
    OxfordDictionariesLanguage.en_US,
    OxfordDictionariesLanguage.en,
    OxfordDictionariesLanguage.ar,
    OxfordDictionariesLanguage.zh,
    OxfordDictionariesLanguage.fa,
    OxfordDictionariesLanguage.fr,
    OxfordDictionariesLanguage.ka,
    OxfordDictionariesLanguage.de,
    OxfordDictionariesLanguage.el,
    OxfordDictionariesLanguage.gu,
    OxfordDictionariesLanguage.ha,
    OxfordDictionariesLanguage.hi,
    OxfordDictionariesLanguage.ig,
    OxfordDictionariesLanguage.id,
    OxfordDictionariesLanguage.xh,
    OxfordDictionariesLanguage.zu,
    OxfordDictionariesLanguage.it,
    OxfordDictionariesLanguage.lv,
    OxfordDictionariesLanguage.ms,
    OxfordDictionariesLanguage.mr,
    OxfordDictionariesLanguage.nso,
    OxfordDictionariesLanguage.pt,
    OxfordDictionariesLanguage.qu,
    OxfordDictionariesLanguage.ro,
    OxfordDictionariesLanguage.ru,
    OxfordDictionariesLanguage.tn,
    OxfordDictionariesLanguage.es,
    OxfordDictionariesLanguage.sw,
    OxfordDictionariesLanguage.tg,
    OxfordDictionariesLanguage.ta,
    OxfordDictionariesLanguage.tt,
    OxfordDictionariesLanguage.te,
    OxfordDictionariesLanguage.tpi,
    OxfordDictionariesLanguage.tk,
    OxfordDictionariesLanguage.ur,
    OxfordDictionariesLanguage.yo,
  ];

  /// A constant value for English, United Kingdom.
// ignore: constant_identifier_names
  static const en_GB = Language('en', 'GB');

  /// A constant value for English, United States.
// ignore: constant_identifier_names
  static const en_US = Language('en', 'US');

  /// A constant value for English.
// ignore: constant_identifier_names
  static const en = Language('en');

  /// A constant value for Arabic.
// ignore: constant_identifier_names
  static const ar = Language('ar');

  /// A constant value for Chinese.
// ignore: constant_identifier_names
  static const zh = Language('zh');

  /// A constant value for Persian.
// ignore: constant_identifier_names
  static const fa = Language('fa');

  /// A constant value for French.
// ignore: constant_identifier_names
  static const fr = Language('fr');

  /// A constant value for Georgian.
// ignore: constant_identifier_names
  static const ka = Language('ka');

  /// A constant value for German.
// ignore: constant_identifier_names
  static const de = Language('de');

  /// A constant value for Greek.
// ignore: constant_identifier_names
  static const el = Language('el');

  /// A constant value for Gujarati.
// ignore: constant_identifier_names
  static const gu = Language('gu');

  /// A constant value for Hausa.
// ignore: constant_identifier_names
  static const ha = Language('ha');

  /// A constant value for Hindi.
// ignore: constant_identifier_names
  static const hi = Language('hi');

  /// A constant value for Igbo.
// ignore: constant_identifier_names
  static const ig = Language('ig');

  /// A constant value for Indonesian.
// ignore: constant_identifier_names
  static const id = Language('id');

  /// A constant value for Xhosa.
// ignore: constant_identifier_names
  static const xh = Language('xh');

  /// A constant value for Zulu.
// ignore: constant_identifier_names
  static const zu = Language('zu');

  /// A constant value for Italian.
// ignore: constant_identifier_names
  static const it = Language('it');

  /// A constant value for Latvian.
// ignore: constant_identifier_names
  static const lv = Language('lv');

  /// A constant value for Malay.
// ignore: constant_identifier_names
  static const ms = Language('ms');

  /// A constant value for Marathi.
// ignore: constant_identifier_names
  static const mr = Language('mr');

  /// A constant value for Pedi.
// ignore: constant_identifier_names
  static const nso = Language('nso');

  /// A constant value for Portuguese.
// ignore: constant_identifier_names
  static const pt = Language('pt');

  /// A constant value for Quechua.
// ignore: constant_identifier_names
  static const qu = Language('qu');

  /// A constant value for Romanian.
// ignore: constant_identifier_names
  static const ro = Language('ro');

  /// A constant value for Russian.
// ignore: constant_identifier_names
  static const ru = Language('ru');

  /// A constant value for Tswana.
// ignore: constant_identifier_names
  static const tn = Language('tn');

  /// A constant value for Spanish.
// ignore: constant_identifier_names
  static const es = Language('es');

  /// A constant value for Swahili.
// ignore: constant_identifier_names
  static const sw = Language('sw');

  /// A constant value for Tajik.
// ignore: constant_identifier_names
  static const tg = Language('tg');

  /// A constant value for Tamil.
// ignore: constant_identifier_names
  static const ta = Language('ta');

  /// A constant value for Tatar.
// ignore: constant_identifier_names
  static const tt = Language('tt');

  /// A constant value for Telugu.
// ignore: constant_identifier_names
  static const te = Language('te');

  /// A constant value for Tok Pisin.
// ignore: constant_identifier_names
  static const tpi = Language('tpi');

  /// A constant value for Turkmen.
// ignore: constant_identifier_names
  static const tk = Language('tk');

  /// A constant value for Urdu.
// ignore: constant_identifier_names
  static const ur = Language('ur');

  /// A constant value for Yoruba.
// ignore: constant_identifier_names
  static const yo = Language('yo');

  /// A constant value for 'und'.
  /// - [languageCode] : 'und'.
  static const und = Language('und');

  /// A constant value for Spanish, Spain.
  /// - [languageCode] : 'es'.
  /// - [countryCode]  : 'ES'.
  // ignore: constant_identifier_names
  static const es_ES = Language('es', 'ES');
}
