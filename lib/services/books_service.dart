import 'dart:convert';
import 'dart:developer';

import 'package:book_tracker/models/authors_model.dart';
import 'package:book_tracker/models/authors_works_model.dart';
import 'package:book_tracker/models/bookswork_editions_model.dart';
import 'package:book_tracker/models/bookswork_model.dart';
import 'package:book_tracker/models/trendingbooks_model.dart';
import 'package:book_tracker/widgets/error_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class BooksService {
  String baseUrl = "https://openlibrary.org";
  String fields =
      "fields=key,title,edition_count,first_publish_year,cover_i,first_sentence,language,author_key,author_name,subject";
  Future<dynamic> getBooksFromApi(
      String item, int page, String apiName, BuildContext context) async {
    var response = await http.get(Uri.parse(
        "$baseUrl/search.json?$apiName=${item.toLowerCase()}&$fields&limit=10&page=$page"));

    return jsonDecode(response.body);
  }

  Future<dynamic> getTrendingBooks(
      String date, int pageKey, BuildContext context) async {
    log("$baseUrl/trending/${date.toLowerCase()}.json?limit=10&page=$pageKey");
    try {
      var response = await http.get(Uri.parse(
          "$baseUrl/trending/${date.toLowerCase()}.json?limit=10&page=$pageKey"));
      var result = TrendingBooks.fromJson(jsonDecode(response.body));
      return result.works;
    } catch (e) {
      print("hata yakalandı gettrendingbooks $e");
      errorSnackBar(context, e.toString());
    }
  }

  Future<dynamic> getWorkDetail(String key, BuildContext context) async {
    try {
      var response = await http.get(Uri.parse("$baseUrl$key.json"));
      var result = BookWorkModel.fromJson(jsonDecode(response.body));

      return result;
    } catch (e) {
      print("hata yakalandı getworkdetail $e");
      errorSnackBar(context, e.toString());
    }
  }

  Future<dynamic> getBookWorkEditions(
      String key, int offset, BuildContext context) async {
    try {
      var response = await http
          .get(Uri.parse("$baseUrl$key/editions.json?offset=$offset"));

      var result = BookWorkEditionsModel.fromJson(jsonDecode(response.body));

      return result;
    } catch (e) {
      print("hata yakalandı getbookworkeditions $e");
      errorSnackBar(context, e.toString());
    }
  }

  Future<dynamic> getAuthorInfo(
      String key, bool doesContainTag, BuildContext context) async {
    try {
      var response = await http.get(doesContainTag == true
          ? Uri.parse("$baseUrl$key.json")
          : Uri.parse("$baseUrl/authors/$key.json"));

      var result = AuthorsModel.fromJson(jsonDecode(response.body));

      return result;
    } catch (e) {
      print("hata yakalandı authorinfo $e");
      errorSnackBar(context, e.toString());
    }
  }

  Future<dynamic> getAuthorsWorks(
      String authorKey, int? limit, int offsetKey, BuildContext context) async {
    try {
      var response = await http.get(Uri.parse(
          "$baseUrl/authors/$authorKey/works.json?limit=$limit&offset=$offsetKey"));

      var result = AuthorsWorksModel.fromJson(jsonDecode(response.body));

      return result;
    } catch (e) {
      print("hata yakalandı authors work $e");
      errorSnackBar(context, e.toString());
    }
  }
}
