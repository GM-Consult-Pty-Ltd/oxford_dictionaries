// Copyright ©2022, GM Consult (Pty) Ltd.
// BSD 3-Clause License
// All rights reserved

import 'package:dictosaurus/dictosaurus.dart';
import 'package:gmconsult_dart_core/dart_core.dart';
import 'package:gmconsult_dart_core/type_definitions.dart';
import '../_common/oxford_dictionaries_endpoint.dart';

/// An interface for Oxford Dictionaries API endpoints
abstract class Endpoint extends ApiEndpointBase<TermProperties> {
  //

  /// Const default generative constructor.
  const Endpoint();

  /// The [OxFordDictionariesEndpoint] enumeration of the Endpoint.
  OxFordDictionariesEndpoint get endpoint;

  @override
  HttpProtocol get protocol => HttpProtocol.https;

  /// The ISO language code for the language of a term.
  String get sourceLanguage;

  /// The term parameter requested from the endpoint.
  String get term;

  @override
  String get host => 'od-api.oxforddictionaries.com';

  // /// Returns a [TermProperties] from [json] if it contains the required fields.
  // TermProperties? fromJson(Map<String, dynamic> json);

  @override
  Future<TermProperties?> post(TermProperties? obj) =>
      throw UnimplementedError();

  @override
  Future<Map<String, dynamic>?> postJson(JSON? json) =>
      throw UnimplementedError();

  @override
  JsonSerializer<TermProperties> get serializer => throw UnimplementedError();

  /// Returns the JSON for the endpoint
  @override
  Future<Map<String, dynamic>?> getJson() async {
    if (endpoint.languageCodeExists(sourceLanguage) && term.isNotEmpty) {
      final json = await super.getJson();
      if (json != null &&
          // json['query'].to == term.toLowerCase() &&
          json['metadata'] is Map) {
        return json;
      }
    }
    return null;
  }
}

/// Parses the Iterable to a String in the correct format for the endpoint.
extension ToStringExtensionOnIterable on Iterable<String> {
  //

  /// Parses the Iterable to a String in the correct format for the endpoint.
  String get toParameter => toString()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z,]+'), '')
      .replaceAll(',', '%2C');
}

/// Utiltiy extensions on String to extract data from JSON
extension EndPointExtensionOnJson on JSON {
//

  /// Maps the `lexicalCategory` field an element of `[lexicalEntries]`
  /// as [PartOfSpeech] if it exists.
  PartOfSpeech? getPoS(String fieldName) {
    final json = this[fieldName] is Map
        ? ((this[fieldName]) as Map)
            .map((key, value) => MapEntry(key.toString(), value))
        : null;
    if (json != null) {
      final value = json['id'];
      switch (value) {
        case 'noun':
          return PartOfSpeech.noun;
        case 'pronoun':
          return PartOfSpeech.pronoun;
        case 'adjective':
          return PartOfSpeech.adjective;
        case 'verb':
          return PartOfSpeech.verb;
        case 'adverb':
          return PartOfSpeech.adverb;
        case 'preposition':
          return PartOfSpeech.noun;
        case 'conjunction':
          return PartOfSpeech.conjunction;
        case 'interjection':
          return PartOfSpeech.interjection;
        case 'article':
          return PartOfSpeech.article;
        default:
          return null;
      }
    }
    return null;
  }

  /// Maps the [textFieldName] elements of [listFieldName] if the field with
  /// [listFieldName] exists, is an Iterable of Map and the elements have
  /// a String field with name [textFieldName].
  Set<String> getTextValues(String listFieldName, String textFieldName) {
    final retVal = <String>{};
    final phrases = getJsonList(listFieldName);
    for (final json in phrases) {
      final phrase = json[textFieldName];
      if (phrase is String) {
        retVal.add(phrase);
      }
    }
    return retVal;
  }

  /// Returns the `language` field of the Map<String, dynamic> response as `String?`.
  String? get language =>
      (this['language'] is String ? this['language'] as String : null)
          ?.replaceAll('-', '_');

  /// Return a collection of JSON objects if the field at [fieldName] is an
  /// iterable of Map.
  Iterable<Map<String, dynamic>> getJsonList(String fieldName) =>
      this[fieldName] is Iterable
          ? (this[fieldName] as Iterable).cast<Map<String, dynamic>>()
          : [];

  /// Return a collection of Strings if the field at [fieldName] is an
  /// iterable of String.
  Iterable<String> getStringList(String fieldName) =>
      this[fieldName] is Iterable
          ? (this[fieldName] as Iterable).cast<String>()
          : [];
}
