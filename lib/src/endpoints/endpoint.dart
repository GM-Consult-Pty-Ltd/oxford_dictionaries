// Copyright ©2022, GM Consult (Pty) Ltd.
// BSD 3-Clause License
// All rights reserved

import 'package:dictosaurus/dictosaurus.dart';
import 'package:gmconsult_dart_core/dart_core.dart';
import 'package:gmconsult_dart_core/type_definitions.dart';
import '../_common/oxford_dictionaries_endpoint.dart';

/// An interface for Oxford Dictionaries API endpoints
abstract class Endpoint extends ApiEndpointBase<TermProperties> {
  //

  /// Const default generative constructor.
  const Endpoint();

  /// The [OxFordDictionariesEndpoint] enumeration of the Endpoint.
  OxFordDictionariesEndpoint get endpoint;

  @override
  HttpProtocol get protocol => HttpProtocol.https;

  /// The ISO language code for the language of a term.
  String get sourceLanguage;

  /// The term parameter requested from the endpoint.
  String get term;

  @override
  String get host => 'od-api.oxforddictionaries.com';

  /// Returns a [TermProperties] from [json] if it contains the required fields.
  TermProperties? fromJson(Map<String, dynamic> json);

  @override
  Future<TermProperties?> post(TermProperties? obj) =>
      throw UnimplementedError();

  @override
  Future<Map<String, dynamic>?> postJson(JSON? json) =>
      throw UnimplementedError();

  @override
  JsonSerializer<TermProperties> get serializer => throw UnimplementedError();

  /// Returns the JSON for the endpoint
  @override
  Future<Map<String, dynamic>?> getJson() async {
    if (endpoint.languageCodeExists(sourceLanguage) && term.isNotEmpty) {
      final json = await super.getJson();
      if (json != null &&
          json['id'] == term.toLowerCase() &&
          json['metadata'] is Map) {
        return json;
      }
    }
    return null;
  }
}

/// Parses the Iterable to a String in the correct format for the endpoint.
extension ToStringExtensionOnIterable on Iterable<String> {
  /// Parses the Iterable to a String in the correct format for the endpoint.
  String get toParameter => toString()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z,]+'), '')
      .replaceAll(',', '%2C');
}
