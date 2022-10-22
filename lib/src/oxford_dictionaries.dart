// Copyright ©2022, GM Consult (Pty) Ltd.
// BSD 3-Clause License
// All rights reserved

import 'package:dictosaurus/dictosaurus.dart';
import 'package:dictosaurus/extensions.dart';
import 'data/english_kgrams.dart';
import 'package:oxford_dictionaries/src/_index.dart';
import 'dart:async';
import 'endpoints/_index.dart';

/// Implements [DictoSaurus] with the `Oxford Dictionaries` API as dictionary
/// provider.
///
/// To use this library you need to sign up for an account at
/// (https://developer.oxforddictionaries.com/#plans) to get an [appKey] and
/// [appId].
///
/// See: https://developer.oxforddictionaries.com/.
class OxfordDictionaries implements DictoSaurus {
  //

  @override
  final Language language;

  /// Hydrates a [OxfordDictionaries] instance:
  /// - [appId] is the `OxfordDictionaries Application ID`;
  /// - [appKey] is the `OxfordDictionaries Application Key`;
  /// - [language] is the ISO language code of the [Dictionary].
  const OxfordDictionaries(
      {required this.appId,
      required this.appKey,
      this.language = Language.en_US});

  /// The `OxfordDictionaries Application Key`.
  ///
  /// Get an Application Key at
  /// `https://developer.oxforddictionaries.com/documentation/getting_started`
  final String appKey;

  /// The `OxfordDictionaries Application ID`.
  ///
  /// Get an Application ID at
  /// `https://developer.oxforddictionaries.com/documentation/getting_started`
  final String appId;

  //

  /// The k-Gram index [k] value.
  int get k => 2;

  ///
  Set<String> kGramIndexLoader(String term) {
    final termGrams = term.kGrams(k);
    final retVal = <String>{};
    final similarityLimit = term.length <= 4 ? 1 : 4 / term.length;
    for (final kGram in termGrams) {
      final values = (englishKGrams[kGram] ?? {}).toList().where(
          (element) => term.lengthSimilarity(element) >= similarityLimit);
      retVal.addAll(values);
    }
    return retVal;
  }

  /// Returns a [DictionaryEntry] for [term].
  @override
  Future<DictionaryEntry?> getEntry(String term,
      [OxfordDictionariesEndpoint? endpoint]) async {
    // DictionaryEntry? retVal;
    switch (endpoint) {
      case OxfordDictionariesEndpoint.lemmas:
        return await LemmasEndpoint.query(term, apiKeys);
      case OxfordDictionariesEndpoint.thesaurus:
        return await ThesaurusEndpoint.query(term, apiKeys);
      case OxfordDictionariesEndpoint.words:
        return await WordsEndpoint.query(term, apiKeys);
      case OxfordDictionariesEndpoint.entries:
        return await EntriesEndpoint.query(term, apiKeys);
      default:
        return await EntriesEndpoint.query(term, apiKeys);
    }
  }

  @override
  Future<List<String>> expandTerm(String term, [int limit = 5]) async {
    final retVal = <String>{term};
    retVal.add(term);
    final synonyms =
        (await getEntry(term, OxfordDictionariesEndpoint.thesaurus))
            ?.allSynonyms()
            .where((element) => !element.contains(' '));
    if (synonyms != null) {
      retVal.addAll(synonyms);
    }

    if (retVal.length < limit) {
      final suggestions = await suggestionsFor(term, limit);
      retVal.addAll(suggestions);
    }
    final list = retVal.toList();
    return (list.length > limit) ? list.sublist(0, limit) : list;
  }

  @override
  Future<List<String>> startsWith(String chars, [int limit = 10]) =>
      SearchEndpoint.query(chars, apiKeys, limit: limit, prefix: true);

  @override
  Future<List<String>> suggestionsFor(String term, [int limit = 10]) async {
    if (term.isEmpty) {
      return [];
    }
    final terms = await SearchEndpoint.query(term, apiKeys, limit: limit);
    if (language.languageCode == 'en') {
      terms.addAll(kGramIndexLoader(term));
    }
    return term.matches(terms, k: k, limit: limit);
  }

  @override
  Future<Set<TermVariant>> translate(String term, Language targetLanguage) =>
      TranslationsEndpoint.translate(apiKeys,
          term: term, sourceLanguage: language, targetLanguage: targetLanguage);

  /// Returns the [appId] and [appKey] as headers for the HTTP request.
  Map<String, String> get apiKeys => {'app_id': appId, 'app_key': appKey};
}
