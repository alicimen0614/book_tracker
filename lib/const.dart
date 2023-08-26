import 'package:book_tracker/models/bookswork_editions_model.dart';

final List mainCategories = [
  "Klasikler",
  "Fantasy",
  "Macera",
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

int uniqueIdCreater(BookWorkEditionsModelEntries bookEditionInfo) {
  int uniqueId;
  if (bookEditionInfo.isbn_10 != null &&
      int.tryParse(bookEditionInfo.isbn_10!.first!) != null) {
    uniqueId = int.parse(bookEditionInfo.isbn_10!.first!);
  } else if (bookEditionInfo.isbn_13 != null &&
      int.tryParse(bookEditionInfo.isbn_13!.first!) != null) {
    uniqueId = int.parse(bookEditionInfo.isbn_13!.first!);
  } else if (bookEditionInfo.publishers != null) {
    uniqueId = int.parse(
        "${bookEditionInfo.title.hashCode}${bookEditionInfo.publishers!.first.hashCode}");
  } else {
    uniqueId = int.parse("${bookEditionInfo.title.hashCode}");
  }
  return uniqueId;
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
