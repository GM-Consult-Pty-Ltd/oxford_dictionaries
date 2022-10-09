// Copyright ©2022, GM Consult (Pty) Ltd.
// BSD 3-Clause License
// All rights reserved

import 'package:gmconsult_dart_core/dart_core.dart';
import 'package:oxford_dictionaries/src/oxford_dictionaries_endpoints.dart';

import 'endpoint.dart';
import 'package:dictosaurus/dictosaurus.dart';

/// Retrieve definitions, pronunciations, example sentences, grammatical
/// information and word origins.
class EntriesEndpoint extends Endpoint {
//

  /// Const default generative constructor.
  const EntriesEndpoint(this.languageCode, this.appId, this.appKey);

  @override
  final String languageCode;

  @override
  final String appId;

  @override
  final String appKey;

  /// Returns a [TermProperties] for [term].
  @override
  Future<TermProperties?> getEntry(String term) async {
    final sourceLanguage = languageCode.replaceAll('_', '-').toLowerCase();
    final json =
        await getJson(term, sourceLanguage: sourceLanguage, strictMatch: false);
    if (json != null) {
      final retVal = json.toTermProperties();
      return retVal;
    }
    return null;
  }

  @override
  Future<Map<String, dynamic>?> getJson(String term,
      {bool strictMatch = false, String sourceLanguage = 'en-us'}) async {
    final languages = Endpoint
        .kLanguagesMap[OxFordDictionariesEndpoints.entries] as Set<String>;
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

extension _OxfordDictionariesHashmapExtension on Map<String, dynamic> {
  //

  /// Maps the `lexicalCategory` field an element of `[lexicalEntries]`
  /// as [PartOfSpeech] if it exists.
  PartOfSpeech? get poS {
    final json = this['lexicalCategory'] is Map
        ? ((this['lexicalCategory']) as Map)
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

  /// Maps the `inflections` field an element of [lexicalEntryEntries] to a
  /// Set of [String] if the field exists.
  Set<String> get lexicalEntriesEntryInflections {
    final retVal = <String>{};
    final collection = getJsonList('inflections');
    for (final json in collection) {
      final value = json['inflectedForm'];
      if (value is String) {
        retVal.add(value);
      }
    }
    return retVal;
  }

  /// Maps the `lexicalCategory` field an element of [lexicalEntries]
  /// as [PartOfSpeech] if it exists.
  Set<String> getTextValues(String fieldName) {
    final retVal = <String>{};
    final phrases = getJsonList(fieldName);
    for (final json in phrases) {
      final phrase = json['text'];
      if (phrase is String) {
        retVal.add(phrase);
      }
    }
    return retVal;
  }

  /// Returns the `id` field of the Map<String, dynamic> response as `String?`.
  String? get term => this['id'] is String ? this['id'] as String : null;

  /// Returns the `language` field of the Map<String, dynamic> response as `String?`.
  String? get language =>
      (this['language'] is String ? this['language'] as String : null)
          ?.replaceAll('-', '_');

  /// Returns the first phonetic spelling found in the `pronunciations` field
  /// of an element of `"lexicalEntry" "entries"`.
  String? get lexicalEntriesEntryPhonetic {
    final collection = getJsonList('pronunciations');
    String? retVal;
    for (final json in collection) {
      final value = json['phoneticSpelling'];
      if (value is String) {
        retVal = retVal ?? value;
      }
      return retVal;
    }
    return null;
  }

  Iterable<Map<String, dynamic>> getJsonList(String fieldName) =>
      this[fieldName] is Iterable
          ? (this[fieldName] as Iterable).cast<Map<String, dynamic>>()
          : [];

  Iterable<String> getStringList(String fieldName) =>
      this[fieldName] is Iterable
          ? (this[fieldName] as Iterable).cast<String>()
          : [];

  TermProperties? toTermProperties() {
    final term = this.term;
    String languageCode = '';
    final Iterable<Map<String, dynamic>> results = getJsonList('results');
    if (results.isNotEmpty && term is String) {
      languageCode =
          languageCode.isEmpty ? results.first.language ?? '' : languageCode;
      final variants = <TermDefinition>{};
      String? stem;
      String? lemma;
      String? phonetic;
      for (final r in results) {
        final lexicalEntries = r.getJsonList('lexicalEntries');
        for (final le in lexicalEntries) {
          final partOfSpeech = le.poS;
          final phrases = <String>{};
          if (partOfSpeech != null) {
            final entries = le.getJsonList('entries');
            for (final e in entries) {
              final inflections = e.lexicalEntriesEntryInflections;
              phonetic = phonetic ?? e.lexicalEntriesEntryPhonetic;
              final senses = e.getJsonList('senses');
              for (final s in senses) {
                final synonyms = s.getTextValues('synonyms');
                final definitions = s.getStringList('definitions');
                for (final definition in definitions) {
                  phrases.addAll(s.getTextValues('examples'));
                  final variant = TermDefinition(
                      term: term,
                      partOfSpeech: partOfSpeech,
                      definition: definition,
                      phrases: phrases,
                      antonyms: {},
                      inflections: inflections,
                      synonyms: synonyms);
                  variants.add(variant);
                }
                final subsenses = s.getJsonList('subsenses');
                for (final ss in subsenses) {
                  final definitions = ss.getStringList('definitions');
                  for (final definition in definitions) {
                    phrases.addAll(s.getTextValues('examples'));
                    final variant = TermDefinition(
                        term: term,
                        partOfSpeech: partOfSpeech,
                        definition: definition,
                        phrases: phrases,
                        antonyms: {},
                        inflections: inflections,
                        synonyms: synonyms);
                    variants.add(variant);
                  }
                }
              }
            }
          }
        }
      }
      return TermProperties(
          term: term,
          stem: stem ?? term,
          lemma: lemma ?? term,
          phonetic: phonetic ?? term,
          languageCode: languageCode,
          variants: variants);
    }
    return null;
  }
}
