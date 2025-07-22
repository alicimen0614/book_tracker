import 'dart:convert';
import 'dart:developer';

import 'package:book_tracker/models/authors_model.dart';
import 'package:book_tracker/models/authors_works_model.dart';
import 'package:book_tracker/models/books_model.dart';
import 'package:book_tracker/models/bookswork_editions_model.dart';
import 'package:book_tracker/models/bookswork_model.dart';
import 'package:book_tracker/widgets/error_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class BooksService {
  String baseUrl = "https://openlibrary.org";
  String fields =
      "fields=key,title,edition_count,first_publish_year,cover_i,first_sentence,language,author_key,author_name,subject";
  Future<dynamic> getBooksFromApi(
      String item, int page, String apiName, BuildContext context) async {
        log( "$baseUrl/search.json?$apiName=${item.toLowerCase()}&$fields&limit=10&page=$page&sort=trending");
    var response = await http.get(Uri.parse(
        "$baseUrl/search.json?$apiName=${item.toLowerCase()}&$fields&limit=10&page=$page&sort=trending"));

    return jsonDecode(response.body);
  }

  Future<dynamic> getTrendingBooks(
      int pageKey, BuildContext context) async {
        String fields =
      "fields=key,title,edition_count,first_publish_year,cover_i,first_sentence,language,author_key,author_name,subject";
    log("$baseUrl/search.json?q=trending_score_hourly_sum:[1%20TO%20*]&$fields&mode=everything&sort=readinglog&lang=tr&limit=10&page=$pageKey");
    try {
      var response = await http.get(Uri.parse(
          "$baseUrl/search.json?q=trending_score_hourly_sum:[1%20TO%20*]&$fields&mode=everything&sort=readinglog&lang=tr&limit=10&page=$pageKey"));
      var result=jsonDecode(response.body);
      return result;
    } catch (e) {
      errorSnackBar(context, e.toString());
    }
  }

  Future<dynamic> getWorkDetail(String key, BuildContext context) async {
    try {
      var response = await http.get(Uri.parse("$baseUrl$key.json"));
      var result = BookWorkModel.fromJson(jsonDecode(response.body));

      return result;
    } catch (e) {
      errorSnackBar(context, e.toString());
    }
  }

  Future<dynamic> getBookWorkEditions(
      String key, int offset, BuildContext context, int limit) async {
    try {
      log("$baseUrl$key/editions.json?offset=$offset&limit=$limit");
      var response = await http.get(
          Uri.parse("$baseUrl$key/editions.json?offset=$offset&limit=$limit"));

      var result = BookWorkEditionsModel.fromJson(jsonDecode(response.body));

      return result;
    } catch (e) {
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
      errorSnackBar(context, e.toString());
    }
  }
}
