// Copyright ©2022, GM Consult (Pty) Ltd.
// BSD 3-Clause License
// All rights reserved

//TODO: edit README.md

/// Dictionary class that uses the Oxford Dictionaries RESTful API.
///
/// Also exports the `dictosaurus` package.
library oxford_dictionaries;

export 'src/_index.dart'
    show
        OxfordDictionaries,
        OxfordDictionariesApiMixin,
        OxFordDictionariesEndpoint;
export 'package:dictosaurus/dictosaurus.dart';
