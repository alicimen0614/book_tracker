import 'package:book_tracker/models/bookswork_editions_model.dart';
import 'package:flutter/material.dart';
import 'package:sealed_languages/sealed_languages.dart';

import 'l10n/app_localizations.dart';

List<String> getMainCategoriesNames(BuildContext context) {
  return [
    AppLocalizations.of(context)!.classics,
    AppLocalizations.of(context)!.fantasy,
    AppLocalizations.of(context)!.adventure,
    AppLocalizations.of(context)!.contemporary,
    AppLocalizations.of(context)!.romance,
    AppLocalizations.of(context)!.dystopian,
    AppLocalizations.of(context)!.horror,
    AppLocalizations.of(context)!.paranormal,
    AppLocalizations.of(context)!.historicalFiction,
    AppLocalizations.of(context)!.scienceFiction,
    AppLocalizations.of(context)!.childrens,
    AppLocalizations.of(context)!.academic,
    AppLocalizations.of(context)!.mystery,
    AppLocalizations.of(context)!.thrillers,
    AppLocalizations.of(context)!.memoir,
    AppLocalizations.of(context)!.selfHelp,
    AppLocalizations.of(context)!.cookbook,
    AppLocalizations.of(context)!.art_Photography,
    AppLocalizations.of(context)!.youngAdult,
    AppLocalizations.of(context)!.personalDevelopment,
    AppLocalizations.of(context)!.motivational,
    AppLocalizations.of(context)!.health,
    AppLocalizations.of(context)!.history,
    AppLocalizations.of(context)!.travel,
    AppLocalizations.of(context)!.guide,
    AppLocalizations.of(context)!.families_Relationships,
    AppLocalizations.of(context)!.humor,
    AppLocalizations.of(context)!.graphicNovel,
    AppLocalizations.of(context)!.shortStory,
    AppLocalizations.of(context)!.biographyAndAutobiography,
    AppLocalizations.of(context)!.poetry,
    AppLocalizations.of(context)!.religion_Spirituality
  ];
}

class Const {
  static late Size screenSize;
  static late double minSize;

  static void init(BuildContext context) {
    screenSize = MediaQuery.of(context).size;
    minSize = screenSize.width * 0.03;
  }

  static const List mainCategories = [
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

  static const List mainCategoriesImages = [
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

  static const Map<int, String> monthsInYearInTurkish = {
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
}

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

double calculateTextHeight(String text, TextStyle style, double maxWidth) {
  final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: style,
      ),
      textDirection: TextDirection.ltr);

  textPainter.layout(minWidth: 0, maxWidth: maxWidth);

  return textPainter.size.height;
}

enum ReportReason {
  inappropriate,
  spam,
  copyright,
  misleading,
  other;


  String get value {
    switch (this) {
      case ReportReason.inappropriate:
        return 'inappropriate';
      case ReportReason.spam:
        return 'spam';
      case ReportReason.copyright:
        return 'copyright';
      case ReportReason.misleading:
        return 'misleading';
      case ReportReason.other:
        return 'other';
    }
  }


  String getDisplayText(BuildContext context) {
    switch (this) {
      case ReportReason.inappropriate:
        return AppLocalizations.of(context)!.inappropriate;
      case ReportReason.spam:
        return AppLocalizations.of(context)!.spam;
      case ReportReason.copyright:
        return AppLocalizations.of(context)!.copyright;
      case ReportReason.misleading:
        return AppLocalizations.of(context)!.misleading;
      case ReportReason.other:
        return AppLocalizations.of(context)!.other;
    }
  }


  static ReportReason fromString(String value) {
    switch (value) {
      case 'inappropriate':
        return ReportReason.inappropriate;
      case 'spam':
        return ReportReason.spam;
      case 'copyright':
        return ReportReason.copyright;
      case 'misleading':
        return ReportReason.misleading;
      case 'other':
        return ReportReason.other;
      default:
        return ReportReason.inappropriate;
    }
  }
}
