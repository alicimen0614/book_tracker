import 'package:book_tracker/models/bookswork_editions_model.dart';
import 'package:flutter/material.dart';
import 'package:sealed_languages/sealed_languages.dart';

final List mainCategories = [
  "Classics",
  "Fantasy",
  "Adventure",
  "Contemporary",
  "Romance",
  "Dystopian",
  "Horror",
  "Paranormal",
  "Historical Fiction",
  "Science Fiction",
  "Children's",
  "Academic",
  "Mystery",
  "Thrillers",
  "Memoir",
  "Self-help",
  "Cookbook",
  "Art & Photography",
  "Young Adult",
  "Personal Development",
  "Motivational",
  "Health",
  "History",
  "Travel",
  "Guide",
  "Families & Relationships",
  "Humor",
  "Graphic Novel",
  "Short Story",
  "Biography and Autobiography",
  "Poetry",
  "Religion & Spirituality"
];

final List mainCategoriesNames = [
  "Klasikler",
  "Fantastik",
  "Macera",
  "Modern",
  "Romantik",
  "Distopik",
  "Korku",
  "Paranormal",
  "Tarihsel kurgu",
  "Bilim kurgu",
  "Çocuk",
  "Akademik",
  "Gizem",
  "Gerilim",
  "Anı",
  "Kendine yardım",
  "Yemek kitabı",
  "Sanat ve Fotoğrafçılık",
  "Genç Yetişkin",
  "Kişisel Gelişim",
  "Motivasyonel",
  "Sağlık",
  "Tarih",
  "Seyahat",
  "Rehber",
  "Aileler ve İlişkiler",
  "Mizah",
  "Çizgi roman",
  "Kısa hikaye",
  "Biyografi ve Otobiyografi",
  "Şiir",
  "Din ve Maneviyat"
];

int uniqueIdCreater(BookWorkEditionsModelEntries? bookEditionInfo) {
  int uniqueId;
  if (bookEditionInfo!.isbn_10 != null &&
      int.tryParse(bookEditionInfo.isbn_10!.first!) != null) {
    uniqueId = int.parse(bookEditionInfo.isbn_10!.first!);
  } else if (bookEditionInfo.isbn_13 != null &&
      int.tryParse(bookEditionInfo.isbn_13!.first!) != null) {
    uniqueId = int.parse(bookEditionInfo.isbn_13!.first!);
  } else if (bookEditionInfo.publishers != null) {
    uniqueId = int.parse(
        "${bookEditionInfo.title.hashCode.toString().substring(1, 6)}${bookEditionInfo.publishers!.first.hashCode.toString().substring(1, 6)}");
  } else {
    uniqueId = int.parse("${bookEditionInfo.title.hashCode}").floor();
  }
  return uniqueId;
}

/* Some of the language codes coming from the api didn't match with the codes in the package but they matched with the bibliographiccode
                      so ı've searched within the list of languages that matches the language code coming from api and the package's bibliographiccode */
String countryNameCreater(BookWorkEditionsModelEntries bookEdition) {
  int indexOfBibliographicCode = NaturalLanguage.list.indexWhere((element) =>
      bookEdition.languages!.first!.key!.characters
          .getRange(11, 14)
          .toUpperCase()
          .toString() ==
      element.bibliographicCode);

  if (NaturalLanguage.maybeFromValue(bookEdition
          .languages!.first!.key!.characters
          .getRange(11, 14)
          .toUpperCase()
          .toString()) !=
      null) {
    String country = NaturalLanguage.maybeFromValue(bookEdition
            .languages!.first!.key!.characters
            .getRange(11, 14)
            .toUpperCase()
            .toString())!
        .name;
    return country;
  } else if (indexOfBibliographicCode != -1) {
    return NaturalLanguage.list[indexOfBibliographicCode].name;
  } else {
    return bookEdition.languages!.first!.key!.characters
        .getRange(11, 14)
        .toUpperCase()
        .toString();
  }
}

String getImageAsByte(List<BookWorkEditionsModelEntries>? listOfBooksFromSql,
    BookWorkEditionsModelEntries book) {
  return listOfBooksFromSql!
      .elementAt(listOfBooksFromSql.indexWhere(
          (element) => uniqueIdCreater(element) == uniqueIdCreater(book)))
      .imageAsByte!;
}

final List mainCategoriesImages = [
  "classical.png",
  "fantasy.png",
  "adventure.png",
  "contemporary.png",
  "romance.png",
  "dystopia.png",
  "horror.png",
  "paranormal.png",
  "historicalfiction.png",
  "science-fiction.png",
  "children.png",
  "academic.png",
  "mystery.png",
  "thriller.png",
  "memoirs.png",
  "self-help.png",
  "cooking.png",
  "art.png",
  "youngadult.png",
  "personaldevelopment.png",
  "praying.png",
  "health.png",
  "history.png",
  "travel.png",
  "guide.png",
  "family.png",
  "humor.png",
  "graphicnovel.png",
  "shortstory.png",
  "biography.png",
  "poetry.png",
  "religion.png"
];

const Map<int, String> monthsInYearInTurkish = {
  1: "Ocak",
  2: "Şubat",
  3: "Mart",
  4: "Nisan",
  5: "Mayıs",
  6: "Haziran",
  7: "Temmuz",
  8: "Ağustos",
  9: "Eylül",
  10: "Ekim",
  11: "Kasım",
  12: "Aralık"
};
