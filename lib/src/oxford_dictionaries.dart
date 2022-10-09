// Copyright ©2022, GM Consult (Pty) Ltd.
// BSD 3-Clause License
// All rights reserved

import 'package:dictosaurus/dictosaurus.dart';
import 'dart:async';
import 'package:gmconsult_dart_core/dart_core.dart';
import 'endpoints/_index.dart';
import 'oxford_dictionaries_endpoints.dart';

/// Implements [Dictionary] with the `Oxford Dictionaries` API as dictionary
/// provider.
///
/// See: https://developer.oxforddictionaries.com/.
class OxfordDictionaries
    with OxfordDictionariesApiMixin, DictionaryMixin, ThesaurusMixin
    implements DictoSaurus {
  //

  @override
  final String languageCode;

  /// Hydrates a [OxfordDictionaries] instance:
  /// - [appId] is the `OxfordDictionaries Application ID`;
  /// - [appKey] is the `OxfordDictionaries Application Key`;
  /// - [languageCode] is the ISO language code of the [Dictionary].
  const OxfordDictionaries(
      {required this.appId, required this.appKey, this.languageCode = 'en_US'});

  @override
  final String appId;

  @override
  final String appKey;

  @override
  Future<List<String>> expandTerm(String term, [int limit = 10]) async {
    // TODO: implement expandTerm using the search endpoint
    return [term];
  }

  @override
  Future<List<String>> startsWith(String chars, [int limit = 10]) async {
    // TODO: implement startsWith using the search endpoint
    return [];
  }

  @override
  Future<List<String>> suggestionsFor(String term, [int limit = 10]) async {
    // TODO: implement suggestionsFor using the search endpoint
    return [term];
  }
}

/// A mixin that returns [Map<String, dynamic>] responses from the Oxford Dictionaries API.
///
/// See: https://developer.oxforddictionaries.com/.
abstract class OxfordDictionariesApiMixin implements Dictionary {
  //

  @override
  Future<TermProperties?> getEntry(String term) async {
    return await EntriesEndpoint(languageCode, appId, appKey).getEntry(term);
  }

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

  /// Query the `Entries` endpoint:
  /// - [term] is the word to query.
  /// - [strictMatch] specifies whether diacritics must match exactly. If
  ///   "false", near-homographs for the given word_id will also be selected
  ///   (e.g., rose matches both rose and rosé; similarly rosé matches both);
  ///
  /// More information at:
  /// https://developer.oxforddictionaries.com/documentation#!/Words/get_words_source_lang
  Future<Map<String, dynamic>?> entriesEndPoint(String term,
      {bool strictMatch = false, String sourceLanguage = 'en-us'}) async {
    final languages =
        kLanguagesMap[OxFordDictionariesEndpoints.entries] as Set<String>;
    if (languages.contains(sourceLanguage) && term.isNotEmpty) {
      final path = 'api/v2/entries/$sourceLanguage/${term.toLowerCase()}';
      final queryParameters = {'strictMatch': strictMatch.toString()};
      final json = await JsonApi.instance.get(
          host: host,
          path: path,
          headers: headers,
          queryParameters: queryParameters,
          isHttps: true);

      final id = json['id'];
      if (id == term.toLowerCase()) {
        return json;
      }
    }
    return null;
  }
}
