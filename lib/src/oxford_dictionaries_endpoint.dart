// Copyright ©2022, GM Consult (Pty) Ltd.
// BSD 3-Clause License
// All rights reserved

import 'package:gmconsult_dart_core/dart_core.dart';
import 'package:oxford_dictionaries/src/_index.dart';

/// Enumeration of the `Oxford Dictionaries` API endpoints.
///
/// See: https://developer.oxforddictionaries.com/.
enum OxFordDictionariesEndpoint {
  /// Retrieve definitions, pronunciations, example sentences, grammatical
  /// information and word origins.
  entries,

  /// Retrieve the the possible lemmas for a given inflected word.
  lemmas,

  /// Search for headword matches, translations or synonyms for a word.
  search,

  /// Search for headword matches, translations or synonyms for a word.
  searchTranslations,

  /// Search for headword matches, translations or synonyms for a word.
  searchThesaurus,

  /// Return translations for a given word.
  translations,

  ///  Retrieve words that are similar/opposite in meaning to the input word
  /// (synonym/antonym).
  thesaurus,

  /// Retrieve sentences extracted from a corpus of real-world language,
  /// including news and blog content.
  sentences,

  /// A collection of utility endpoints.
  ///
  /// See https://developer.oxforddictionaries.com/documentation#/ for
  /// available paths.
  utility,

  /// Retrieve definitions, examples and other information for a given
  /// dictionary word or an inflection.
  words,

  /// Retrieve all the inflections of a given word.
  inflections
}

///
extension OxfordLanguagesEndpointExtension on OxFordDictionariesEndpoint {
  ///
  bool languageCodeExists(Language sourceLanguage) =>
      Constants.sourceLanguages[this]?.contains(sourceLanguage) ?? false;
}