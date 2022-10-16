// Copyright ©2022, GM Consult (Pty) Ltd.
// BSD 3-Clause License
// All rights reserved

import 'package:dictosaurus/dictosaurus.dart';
import 'package:gmconsult_dart_core/dart_core.dart';
import 'package:oxford_dictionaries/src/_index.dart';
import 'package:porter_2_stemmer/porter_2_stemmer.dart';
import 'package:gmconsult_dart_core/type_definitions.dart';
import '../oxford_dictionaries_endpoint.dart';

/// An interface for Oxford Dictionaries API endpoints
abstract class Endpoint extends ApiEndpointBase<TermProperties> {
  //

  /// Uses the [Porter2Stemmer] to return the stem of [term].
  String get porter2stem => term.stemPorter2();

  /// Const default generative constructor.
  const Endpoint();

  /// The [OxFordDictionariesEndpoint] enumeration of the Endpoint.
  OxFordDictionariesEndpoint get endpoint;

  @override
  HttpProtocol get protocol => HttpProtocol.https;

  /// The ISO language code for the language of a term.
  Language get sourceLanguage;

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
        json['porter2stem'] = porter2stem;
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

///
extension EndpointStringExtension on String {
  //

  /// Normalizes text from the JSON.
  /// - Change all quote marks to single apostrophe +U0027.
  /// - Remove enclosing quote marks.
  /// - Change all dashes to single standard hyphen.
  String normalize() {
    return // change all quote marks to single apostrophe +U0027
        replaceAll(RegExp('[\'"“”„‟’‘‛]+'), "'")
            // remove enclosing quote marks
            .replaceAll(RegExp(r"(^'+)|('+(?=$))"), '')
            // change all dashes to single standard hyphen
            .replaceAll(RegExp(r'[\-—]+'), '-')
            .trim();
  }
}

/// Utiltiy extensions on String to extract data from JSON
extension EndPointExtensionOnJson on JSON {
//

  /// Returns a [Pronunciation]s collection by parsing the 'pronunciations'
  /// field of the JSON.
  Set<Pronunciation> pronunciations(String term) =>
      getJsonList('pronunciations')
          .map((pronunciation) => Pronunciation(
              term: term,
              audioLink: pronunciation['audioFile']?.toString(),
              phoneticSpelling: pronunciation['phoneticSpelling']?.toString(),
              languageCodes: pronunciation.getStringList('dialects')))
          .toSet();

  /// Returns a collection of etymologies by parsing the 'etymologies'
  /// field of the JSON.
  Set<String> get etymologies => getStringList('etymologies').toSet();

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
      final text = json[textFieldName];
      if (text is String) {
        retVal.add(text.normalize());
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
  Set<String> getStringList(String fieldName) => this[fieldName] is Iterable
      ? (this[fieldName] as Iterable)
          .cast<String>()
          .map((e) => e.normalize())
          .toSet()
      : {};
}
