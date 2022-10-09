// Copyright ©2022, GM Consult (Pty) Ltd.
// BSD 3-Clause License
// All rights reserved

import 'package:dictosaurus/dictosaurus.dart';
import '../oxford_dictionaries_endpoints.dart';

/// An interface for Oxford Dictionaries API endpoints
abstract class Endpoint {
  //

  /// Const default generative constructor.
  const Endpoint();

  /// The ISO language code for the language of a term.
  String get languageCode;

  /// The host part of the API request.
  String get host => 'od-api.oxforddictionaries.com';

  /// The `OxfordDictionaries Application ID`.
  ///
  /// Get an Application ID at
  /// `https://developer.oxforddictionaries.com/documentation/getting_started`
  String get appId;

  /// The `OxfordDictionaries Application Key`.
  ///
  /// Get an Application Key at
  /// `https://developer.oxforddictionaries.com/documentation/getting_started`
  String get appKey;

  /// Returns the [appId] and [appKey] as headers for the HTTP request.
  Map<String, String> get headers => {'app_id': appId, 'app_key': appKey};

  /// Hashmap of endpoint to valid language codes.
  static const kLanguagesMap = {
    OxFordDictionariesEndpoints.entries: {
      'en-gb',
      'en-us',
      'de',
      'es',
      'fr',
      'gu',
      'hi',
      'lv',
      'ro',
      'sw',
      'ta'
    }
  };

  /// Query the endpoint:
  /// - [term] is the word to query.
  /// - [strictMatch] specifies whether diacritics must match exactly. If
  ///   "false", near-homographs for the given word_id will also be selected
  ///   (e.g., rose matches both rose and rosé; similarly rosé matches both);
  ///
  /// More information at:
  /// https://developer.oxforddictionaries.com/documentation#!/Words/get_words_source_lang
  Future<Map<String, dynamic>?> getJson(String term,
      {bool strictMatch = false, String sourceLanguage = 'en-us'});

  /// Returns a [TermProperties] for [term].
  Future<TermProperties?> getEntry(String term);
}
