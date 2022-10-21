// Copyright ©2022, GM Consult (Pty) Ltd.
// BSD 3-Clause License
// All rights reserved

import 'package:gmconsult_dart_core/type_definitions.dart';
import 'package:oxford_dictionaries/src/_index.dart';
import 'endpoint.dart';
import 'package:dictosaurus/dictosaurus.dart';

/// Retrieve possible headword matches for a given string of text.
///
/// The results are calculated using headword matching, fuzzy matching, and
/// lemmatization

class Search extends Endpoint<List<String>> {
//

  /// Queries the [Search] for a [List<String>] for the [term] and
  /// optional parameters.
  static Future<List<String>> query(String term, Map<String, String> apiKeys,
      {Language language = Language.en_US,
      bool prefix = false,
      int? limit,
      int? offset,
      Iterable<String>? grammaticalFeatures,
      PartOfSpeech? lexicalCategory,
      Iterable<String>? domains}) async {
    assert(limit == null || (limit < 5001 && limit >= 0),
        '[limit] must be null or between 0 and 5,000 inclusive');
    assert(offset == null || (offset < 10001 && offset >= 0),
        '[offset] must be null or between 0 and 10,000 inclusive');
    assert(((limit ?? 0) + (offset ?? 0) <= 10000),
        'Sum of limit and offset must be less that 10,000');
    return await Search._(term, apiKeys, language, prefix, limit, offset)
            .get() ??
        [];
  }

  /// Const default generative constructor.
  Search._(this.term, this.headers, this.language, this.prefix, this.limit,
      this.offset);

  @override
  final String term;

  @override
  final Language language;

  @override
  String get path => 'api/v2/search/${language.toLanguageTag().toLowerCase()}';

  @override
  final Map<String, String> headers;

  /// Specifies whether to return only results that start with the term.
  final bool prefix;

  /// Restricts number of returned results. Default and maximum is 5000.
  final int? limit;

  /// Pagination - results offset. The sum of offset and limit must not
  /// exceed 10000.
  final int? offset;

  @override
  Map<String, String> get queryParameters {
    final qp = {'q': term};
    if (offset != null) {
      qp['offset'] = offset.toString();
    }
    if (prefix) {
      qp['prefix'] = 'true';
    }
    if (limit != null) {
      qp['limit'] = limit.toString();
    }
    return qp;
  }

  @override
  OxFordDictionariesEndpoint get endpoint => OxFordDictionariesEndpoint.entries;

  @override
  JsonDeserializer<List<String>> get deserializer => (json) {
        final results = json.toResults(language).map((e) {
          if (term.isNotEmpty && !term.contains(RegExp(r'[^a-zA-Z]+'))) {
            final terms = e.split(RegExp(r'[^a-zA-Z]+')).where((element) =>
                element.toLowerCase().contains(term.toLowerCase()));
            return (terms.isNotEmpty ? terms.first : e).toLowerCase();
          }
          return e;
        }).toList();
        results.sort(((a, b) => a.length.compareTo(b.length)));
        return results.toSet().toList();
      };
}

extension _OxfordDictionariesHashmapExtension on Map<String, dynamic> {
  //

  List<String> toResults(Language language) {
    final Iterable<Map<String, dynamic>> results = getJsonList('results');
    return results.map((e) => e['word'] as String).toList();
  }
}

// ignore: unused_element
final _sampleRequest =
    'https://od-api.oxforddictionaries.com/api/v2/search/en-gb?q=appl&limit=10';

// ignore: unused_element
final _sampleBody = {
  {
    'metadata': {
      'limit': '10',
      'offset': '0',
      'operation': 'search',
      'provider': 'Oxford University Press',
      'schema': 'WordList',
      'sourceLanguage': 'en-gb',
      'total': '146'
    },
    'results': [
      {
        'id': 'apple',
        'label': 'apple',
        'matchString': 'appl',
        'matchType': 'normalised',
        'region': 'gb',
        'score': 9.353748,
        'word': 'apple'
      },
      {
        'id': 'apples_to_apples',
        'label': 'apples to apples',
        'matchString': 'appl',
        'matchType': 'normalised',
        'region': 'gb',
        'score': 8.658035,
        'word': 'apples to apples'
      },
      {
        'id': 'appled',
        'label': 'appled',
        'matchString': 'appl',
        'matchType': 'normalised',
        'score': 8.152414,
        'word': 'appled'
      },
      {
        'id': 'Adam%27s_apple',
        'label': "Adam's apple",
        'matchString': 'appl',
        'matchType': 'normalised',
        'region': 'gb',
        'score': 7.0965137,
        'word': "Adam's apple"
      },
      {
        'id': 'she%27s_apples',
        'label': "she's apples",
        'matchString': 'appl',
        'matchType': 'normalised',
        'region': 'gb',
        'score': 7.0965137,
        'word': "she's apples"
      },
      {
        'id': 'apple_butter',
        'label': 'apple butter',
        'matchString': 'appl',
        'matchType': 'normalised',
        'region': 'gb',
        'score': 7.0965137,
        'word': 'apple butter'
      },
      {
        'id': 'apple_core',
        'label': 'apple core',
        'matchString': 'appl',
        'matchType': 'normalised',
        'region': 'gb',
        'score': 7.0965137,
        'word': 'apple core'
      },
      {
        'id': 'apple_green',
        'label': 'apple green',
        'matchString': 'appl',
        'matchType': 'normalised',
        'region': 'gb',
        'score': 7.0965137,
        'word': 'apple green'
      },
      {
        'id': 'Apple_Islander',
        'label': 'Apple Islander',
        'matchString': 'appl',
        'matchType': 'normalised',
        'region': 'gb',
        'score': 7.0965137,
        'word': 'Apple Islander'
      },
      {
        'id': 'Apple_Isle',
        'label': 'Apple Isle',
        'matchString': 'appl',
        'matchType': 'normalised',
        'region': 'gb',
        'score': 7.0965137,
        'word': 'Apple Isle'
      }
    ]
  }
};
