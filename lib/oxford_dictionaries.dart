// Copyright ©2022, GM Consult (Pty) Ltd.
// BSD 3-Clause License
// All rights reserved

/// Dictionary class that uses the Oxford Dictionaries REST API.
///
/// Also exports the `dictosaurus` package.
library oxford_dictionaries;

export 'src/_index.dart'
    show
        OxfordDictionaries,
        OxfordDictionariesEndpoint,
        OxfordDictionariesLanguage;
export 'package:dictosaurus/dictosaurus.dart';
