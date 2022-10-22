// Copyright ©2022, GM Consult (Pty) Ltd.
// BSD 3-Clause License
// All rights reserved

/// Mini-library that exports all the endpoints for the OxfordDictionaries API.
library endpoints;

export 'src/endpoints/_index.dart'
    show
        EntriesEndpoint,
        LemmasEndpoint,
        SearchEndpoint,
        ThesaurusEndpoint,
        TranslationsEndpoint,
        WordsEndpoint,
        OdApiEndpoint;
