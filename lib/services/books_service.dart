import 'dart:convert';
import 'dart:developer';

import 'package:book_tracker/models/books_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class BooksService extends ChangeNotifier {
  Future<BooksModel> booksModel(String searchItem, int page) async {
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

  Future getBookCover(List isbn) async {
    for (var element in isbn) {
      print("http request");
      var response = await http.get(
        Uri.parse("https://covers.openlibrary.org/b/isbn/$element-M.jpg"),
      );

      if (response.body.startsWith("GIF")) {
      } else {
        return "https://covers.openlibrary.org/b/isbn/$element-M.jpg";
      }
    }
    return;
  }

  Future bookSearchNumber(String searchItem, int page) async {
    var _booksModel = await booksModel(searchItem, page);
    return _booksModel.numFound;
  }

  Future<List<BooksModelDocs?>?> booksModelDocsList(
      String searchItem, int page) async {
    print("booksmodeldocslist çalıştı");
    List<BooksModelDocs?>? bookItemsList = [];
    var _booksModel = await booksModel(searchItem, page);
    log(_booksModel.docs.toString());
    return _booksModel.docs;
  }
}
