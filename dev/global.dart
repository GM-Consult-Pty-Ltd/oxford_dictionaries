// // Copyright ©2022, GM Consult (Pty) Ltd.
// // BSD 3-Clause License
// // All rights reserved

// import 'package:gmconsult_dev/test_data.dart';
// import 'package:text_indexing/text_indexing.dart';

// const k = 2;

// Future<InvertedIndex> getIndex() async {
//   final index = InMemoryIndex(
//       tokenizer: TextTokenizer.english,
//       zones: {'name': 1, 'descriptions': 0.5},
//       k: k);
//   final indexer = TextIndexer(index: index);
//   await indexer.indexCollection(TestData.stockNews);
//   return index;
// }

// Future<Iterable<Token>> tokenizer(String term, [String? zone]) async =>
//     [Token(term, 0)];
