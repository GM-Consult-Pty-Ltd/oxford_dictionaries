// Copyright ©2022, GM Consult (Pty) Ltd.
// BSD 3-Clause License
// All rights reserved

import 'package:dictosaurus/dictosaurus.dart';
import 'package:dictosaurus/extensions.dart';
import 'data/english_kgrams.dart';
import 'package:oxford_dictionaries/src/_index.dart';
import 'dart:async';
import 'endpoints/_index.dart';

/// Implements [Dictionary] with the `Oxford Dictionaries` API as dictionary
/// provider.
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
      [OxFordDictionariesEndpoint? endpoint]) async {
    // DictionaryEntry? retVal;
    switch (endpoint) {
      case OxFordDictionariesEndpoint.lemmas:
        return await Lemmas.query(term, apiKeys);
      case OxFordDictionariesEndpoint.thesaurus:
        return await Thesaurus.query(term, apiKeys);
      case OxFordDictionariesEndpoint.words:
        return await Words.query(term, apiKeys);
      case OxFordDictionariesEndpoint.entries:
        return await Entries.query(term, apiKeys);
      default:
        return await Entries.query(term, apiKeys);
    }
  }

  @override
  Future<List<String>> expandTerm(String term, [int limit = 5]) async {
    final retVal = <String>{term};
    retVal.add(term);
    final synonyms =
        (await getEntry(term, OxFordDictionariesEndpoint.thesaurus))
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
      Search.query(chars, apiKeys, limit: limit, prefix: true);

  @override
  Future<List<String>> suggestionsFor(String term, [int limit = 10]) async {
    if (term.isEmpty) {
      return [];
    }
    final terms = await Search.query(term, apiKeys, limit: limit);
    if (language.languageCode == 'en') {
      terms.addAll(kGramIndexLoader(term));
    }
    return term.matches(terms, k: k, limit: limit);
  }

  @override
  Future<Set<TermVariant>> translate(String term, Language targetLanguage) =>
      Translations.translate(apiKeys,
          term: term, sourceLanguage: language, targetLanguage: targetLanguage);

  /// Returns the [appId] and [appKey] as headers for the HTTP request.
  Map<String, String> get apiKeys => {'app_id': appId, 'app_key': appKey};
}
