// Copyright ©2022, GM Consult (Pty) Ltd.
// BSD 3-Clause License
// All rights reserved

import 'package:dictosaurus/dictosaurus.dart';
import 'dart:async';
import 'package:gmconsult_dart_core/dart_core.dart';
import 'package:oxford_dictionaries/src/_index.dart';
import 'endpoints/_index.dart';
import '_common/oxford_dictionaries_endpoint.dart';

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

  /// Returns a [TermProperties] for [term].
  @override
  Future<TermProperties?> getEntry(String term,
      [Iterable<TermProperty>? fields]) async {
    TermProperties? retVal;
    if (fields == null) {
      retVal = await EntriesEndpoint.query(term, apiKeys);
    } else {
      if (fields.isEmpty) {
        retVal = await EntriesEndpoint.query(term, apiKeys);
      }
      if (fields.contains(TermProperty.synonyms)) {}
      if (fields.contains(TermProperty.antonyms)) {
        // query the Thesaurus
      }
      if (fields.contains(TermProperty.lemma)) {
        // query lemma, then check if it needs the other fields
      }
      if (fields.contains(TermProperty.stem)) {
        // query call stemmer function
      }
    }
    return retVal;
  }

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
  Map<String, String> get apiKeys => {'app_id': appId, 'app_key': appKey};
}
