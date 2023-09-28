import 'dart:convert';
import 'dart:developer';

import 'package:book_tracker/models/authors_model.dart';
import 'package:book_tracker/models/authors_works_model.dart';
import 'package:book_tracker/models/books_model.dart';
import 'package:book_tracker/models/bookswork_editions_model.dart';
import 'package:book_tracker/models/bookswork_model.dart';
import 'package:book_tracker/models/trendingbooks_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class BooksService extends ChangeNotifier {
  Future<BooksModel> bookSearch(String searchItem, int page) async {
    print("booksearch api girdi");
    var response = await http.get(Uri.parse(
        "https://openlibrary.org/search.json?q=$searchItem&fields=key,title,edition_count,first_publish_year,cover_i,first_sentence,language,author_key,author_name,subject&limit=10&page=$page"));
    log('https://openlibrary.org/search.json?q=$searchItem&fields=key,title,edition_count,first_publish_year,cover_i,first_sentence,language,author_key,author_name,subject&limit=10&page=$page');
    if (response.statusCode == 200) {
      var result = BooksModel.fromJson(jsonDecode(response.body));
      log("${result.numFound.toString()}-1");
      log("${result.start.toString()}-2");

      return result;
    } else {
      throw ("Bir sorun oluştu ${response.statusCode}");
    }
  }

  Future<BooksModel> getCategoryBooks(String categoryName, int pageKey) async {
    print("categorybooks api girdi");
    var response = await http.get(Uri.parse(
        "https://openlibrary.org/search.json?subject=${categoryName.toLowerCase()}&fields=key,title,edition_count,first_publish_year,cover_i,first_sentence,language,author_key,author_name,subject&limit=10&page=$pageKey"));
    log("https://openlibrary.org/search.json?subject=${categoryName.toLowerCase()}&fields=key,title,edition_count,first_publish_year,cover_i,first_sentence,language,author_key,author_name,subject&limit=10&page=$pageKey");
    if (response.statusCode == 200) {
      var result = BooksModel.fromJson(jsonDecode(response.body));

      return result;
    } else {
      throw ("Bir sorun oluştu ${response.statusCode}");
    }
  }

  Future<TrendingBooks> trendingBooks(String date, int pageKey) async {
    print("categorybooks api girdi");
    var response = await http.get(Uri.parse(
        "https://openlibrary.org/trending/${date.toLowerCase()}.json?limit=10&page=$pageKey"));
    log("https://openlibrary.org/trending/${date.toLowerCase()}.json?limit=10&page=$pageKey");
    if (response.statusCode == 200) {
      var result = TrendingBooks.fromJson(jsonDecode(response.body));
      log(result.works.toString());

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
    log("https://openlibrary.org$key.json");
    var response =
        await http.get(Uri.parse("https://openlibrary.org$key.json"));
    if (response.statusCode == 200) {
      var result = BookWorkModel.fromJson(jsonDecode(response.body));

      return result;
    } else {
      throw ("Bir sorun oluştu ${response.statusCode}");
    }
  }

  Future<BookWorkEditionsModel> getBookWorkEditions(
      String key, int offset) async {
    log("https://openlibrary.org$key/editions.json?offset=$offset");
    var response = await http.get(
        Uri.parse("https://openlibrary.org$key/editions.json?offset=$offset"));
    if (response.statusCode == 200) {
      var result = BookWorkEditionsModel.fromJson(jsonDecode(response.body));

      return result;
    } else {
      throw ("Bir sorun oluştu ${response.statusCode}");
    }
  }

  Future<AuthorsModel> getAuthorInfo(String key, bool doesContainTag) async {
    doesContainTag == true
        ? log("https://openlibrary.org$key.json")
        : log("https://openlibrary.org/authors/$key.json");

    var response = await http.get(doesContainTag == true
        ? Uri.parse("https://openlibrary.org$key.json")
        : Uri.parse("https://openlibrary.org/authors/$key.json"));
    if (response.statusCode == 200) {
      var result = AuthorsModel.fromJson(jsonDecode(response.body));

      return result;
    } else {
      throw ("Bir sorun oluştu ${response.statusCode}");
    }
  }

  Future<AuthorsWorksModel> getAuthorsWorks(
      String authorKey, int? limit, int offsetKey) async {
    log("https://openlibrary.org/authors/$authorKey/works.json?limit=$limit&offset=$offsetKey");
    var response = await http.get(Uri.parse(
        "https://openlibrary.org/authors/$authorKey/works.json?limit=$limit&offset=$offsetKey"));
    if (response.statusCode == 200) {
      var result = AuthorsWorksModel.fromJson(jsonDecode(response.body));

      return result;
    } else {
      throw ("Bir sorun oluştu ${response.statusCode}");
    }
  }
}
