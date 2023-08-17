import 'dart:convert';
import 'dart:developer';

import 'package:book_tracker/models/books_model.dart';
import 'package:book_tracker/models/bookswork_editions_model.dart';
import 'package:book_tracker/models/bookswork_model.dart';
import 'package:book_tracker/models/categorybooks_model.dart';
import 'package:book_tracker/models/trendingbooks_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class BooksService extends ChangeNotifier {
  Future<BooksModel> bookSearch(String searchItem, int page) async {
    print("booksearch api girdi");
    var response = await http.get(Uri.parse(
        'https://openlibrary.org/search.json?mode=everything&q=$searchItem&limit=10&page=$page'));
    log('https://openlibrary.org/search.json?mode=everything&q=$searchItem&limit=10&page=$page');
    if (response.statusCode == 200) {
      var result = BooksModel.fromJson(jsonDecode(response.body));
      log("${result.numFound.toString()}-1");
      log("${result.start.toString()}-2");

      return result;
    } else {
      throw ("Bir sorun oluştu ${response.statusCode}");
    }
  }

  Future<CategoryBooks> categoryBooks(String categoryName, int offset) async {
    print("categorybooks api girdi");
    var response = await http.get(Uri.parse(
        "https://openlibrary.org/subjects/${categoryName.toLowerCase()}.json?limit=20&offset=$offset&published_in=2000-2023"));
    log("https://openlibrary.org/subjects/$categoryName.json?limit=20&offset=$offset");
    if (response.statusCode == 200) {
      var result = CategoryBooks.fromJson(jsonDecode(response.body));
      log(result.workCount.toString());

      print(result);
      return result;
    } else {
      throw ("Bir sorun oluştu ${response.statusCode}");
    }
  }

  Future<List<BooksModelDocs?>?> bookSearchDocsList(
      String searchItem, int page) async {
    print("booksmodeldocslist çalıştı");

    var _searchBooks = await bookSearch(searchItem, page);
    log(_searchBooks.docs.toString());
    return _searchBooks.docs;
  }

  Future<List<CategoryBooksWorks?>?> categoryBookWorksList(
      String categoryName, int pageKey) async {
    var _categoryBooks = await categoryBooks(categoryName, pageKey);
    return _categoryBooks.works;
  }

  Future<TrendingBooks> trendingBooks(String date, int pageKey) async {
    print("categorybooks api girdi");
    var response = await http.get(Uri.parse(
        "https://openlibrary.org/trending/${date.toLowerCase()}.json?limit=10&page=$pageKey"));
    log("https://openlibrary.org/trending/${date.toLowerCase()}.json?limit=10&page=$pageKey");
    if (response.statusCode == 200) {
      var result = TrendingBooks.fromJson(jsonDecode(response.body));
      log(result.works.toString());

      print(result);
      return result;
    } else {
      throw ("Bir sorun oluştu ${response.statusCode}");
    }
  }

  Future<List<TrendingBooksWorks?>?> trendingBookDocsList(
      String date, int pageKey) async {
    var _trendingBooks = await trendingBooks(date, pageKey);
    return _trendingBooks.works;
  }

  Future<BookWorkModel> getBooksWorkModel(String key) async {
    var response =
        await http.get(Uri.parse("https://openlibrary.org$key.json"));
    if (response.statusCode == 200) {
      var result = BookWorkModel.fromJson(jsonDecode(response.body));

      print(result);
      return result;
    } else {
      throw ("Bir sorun oluştu ${response.statusCode}");
    }
  }

  Future<BookWorkEditionsModel> getBookWorkEditions(String key) async {
    print("https://openlibrary.org$key/editions.json");
    var response =
        await http.get(Uri.parse("https://openlibrary.org$key/editions.json"));
    if (response.statusCode == 200) {
      var result = BookWorkEditionsModel.fromJson(jsonDecode(response.body));

      print(result);
      return result;
    } else {
      throw ("Bir sorun oluştu ${response.statusCode}");
    }
  }

  Future<List<BookWorkEditionsModelEntries?>?> bookEditionsEntriesList(
      String key) async {
    var _bookEditions = await getBookWorkEditions(key);
    return _bookEditions.entries;
  }
}
