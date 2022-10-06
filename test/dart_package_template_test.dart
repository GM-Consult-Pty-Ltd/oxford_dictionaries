// Copyright ©2022, GM Consult (Pty) Ltd.
// BSD 3-Clause License
// All rights reserved

// ignore: unused_import
import 'package:dart_package_template/dart_package_template.dart';
import 'package:test/test.dart';
import 'package:gmconsult_dev/gmconsult_dev.dart';

void main() {
  group('A group of tests', () {
    setUp(() {
      // Additional setup goes here.
    });

    test('JsonDataService.securities', (() async {
//   //

      final results = <Map<String, dynamic>>[];

      final service = await JsonDataService.securities;

      results.addAll((await service
              .batchRead(['AAPL:XNGS', 'TSLA:XNGS', 'INTC:XNGS', 'F:XNYS']))
          .values);

      Echo(
          title: 'SECURITIES',
          results: results,
          fields: ['ticker', 'hashTag', 'name', 'timestamp']).printResults();

      await service.close();
    }));

    //TODO: tests
    test('First Test', () {
      // test goes here
    });
  });
}
