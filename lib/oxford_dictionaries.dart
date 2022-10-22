// Copyright ©2022, GM Consult (Pty) Ltd.
// BSD 3-Clause License
// All rights reserved

/// Dictionary class that uses the Oxford Dictionaries REST API.
///
/// *Oxford Dictionaries, the Oxford Dictionaries logo, Oxford University Press,
/// OUP, Oxford and/or any other names of products or services provided by
/// Oxford University Press and referred to in this package are either
/// trademarks or registered trademarks of Oxford University Press.*
///
/// The `oxford_dictionaries` library uses endpoints of the
/// [Oxford Dictionaries API](https://developer.oxforddictionaries.com/) to
/// return lexical data. To use this library you need to
/// [sign up for an account](https://developer.oxforddictionaries.com/#plans)
/// to obtain API keys.
///
/// The [OxfordDictionaries] class implements the [DictoSaurus] interface that includes includes *dictionary*, *thesaurus* and *term expansion* utilities.
///
/// The implementation in this library uses six (out of nine)
/// [Oxford Dictionaries API endpoints](https://developer.oxforddictionaries.com/documentation)
/// to populate a [DictionaryEntry] object and provide some
/// [translation services to/from English](https://developer.oxforddictionaries.com/documentation/languages).
///
/// The endpoint classes are available in a separate `endpoints` mini-library.
/// More information on the endpoints are available from the
/// [Oxford Dictionaries API Documentation](https://developer.oxforddictionaries.com/documentation).
///
/// This library Also exports the [DictoSaurus] interface, and [PartOfSpeech]
/// enumeration from the `dictosaurus` package.
library oxford_dictionaries;

import 'package:dictosaurus/dictosaurus.dart';

export 'src/_index.dart'
    show
        OxfordDictionaries,
        OxfordDictionariesEndpoint,
        OxfordDictionariesLanguage;
export 'package:dictosaurus/dictosaurus.dart'
    show DictoSaurus, PartOfSpeech, DictionaryEntry, TermVariant;
