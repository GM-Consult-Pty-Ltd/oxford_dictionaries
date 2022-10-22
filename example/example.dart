// Copyright ©2022, GM Consult (Pty) Ltd.
// BSD 3-Clause License
// All rights reserved

// ignore_for_file: unused_import
import 'package:gmconsult_proprietary/gmconsult_proprietary.dart';
import 'package:oxford_dictionaries/oxford_dictionaries.dart';
import 'package:gmconsult_dev/gmconsult_dev.dart';

void main() async {
  //

  // [sign up for an account](https://developer.oxforddictionaries.com/#plans)
  // to obtain API keys.
  final appId = GMConsultKeys.oxfordDictionariesHeaders['app_id'] as String;
  final appKey = GMConsultKeys.oxfordDictionariesHeaders['app_key'] as String;

  // hydrate a `OxfordDictionaries` instance with api keys and a language
  // [sign up for an account](https://developer.oxforddictionaries.com/#plans)
  // to obtain API keys
  final dictionary = OxfordDictionaries(
      appId: appId, appKey: appKey, language: OxfordDictionariesLanguage.en_GB);

  // get the `DictionaryEntry` for "swimming" from the `words` endpoint
  final props =
      await dictionary.getEntry('swimming', OxfordDictionariesEndpoint.words);

  // print the defintions for "swinning"
  print(props?.definitionsMap());

  // prints
  // {
  //  PartOfSpeech.noun:
  //    {the sport or activity of propelling oneself through water using the limbs},
  //  PartOfSpeech.verb:
  //    {propel the body through water by using the limbs, or (in the case of a fish or other aquatic animal) by using fins, tail, or other bodily movement,
  //    cross (a particular stretch of water) by swimming,
  //    float on or at the surface of a liquid,
  //    cause to float or move across water, be immersed in or covered with liquid, appear to reel or whirl before one's eyes,
  //    experience a dizzily confusing sensation in one's head}
  // }
}
