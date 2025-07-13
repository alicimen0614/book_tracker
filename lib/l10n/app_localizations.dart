import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('tr')
  ];

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome :)'**
  String get welcome;

  /// No description provided for @areYouReadingABook.
  ///
  /// In en, this message translates to:
  /// **'Are you reading a book?'**
  String get areYouReadingABook;

  /// No description provided for @addBook.
  ///
  /// In en, this message translates to:
  /// **'Add book'**
  String get addBook;

  /// No description provided for @quoteCorner.
  ///
  /// In en, this message translates to:
  /// **'Quote Corner'**
  String get quoteCorner;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get all;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @noCurrentReads.
  ///
  /// In en, this message translates to:
  /// **'You are not reading any book right now.'**
  String get noCurrentReads;

  /// No description provided for @noWantedReads.
  ///
  /// In en, this message translates to:
  /// **'You don’t have any books you want to read right now.'**
  String get noWantedReads;

  /// No description provided for @noFinishedReads.
  ///
  /// In en, this message translates to:
  /// **'You don’t have any finished books right now.'**
  String get noFinishedReads;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @explore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get explore;

  /// No description provided for @myLibrary.
  ///
  /// In en, this message translates to:
  /// **'My Library'**
  String get myLibrary;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @trendings.
  ///
  /// In en, this message translates to:
  /// **'Trendings'**
  String get trendings;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @classics.
  ///
  /// In en, this message translates to:
  /// **'Classics'**
  String get classics;

  /// No description provided for @fantasy.
  ///
  /// In en, this message translates to:
  /// **'Fantasy'**
  String get fantasy;

  /// No description provided for @adventure.
  ///
  /// In en, this message translates to:
  /// **'Adventure'**
  String get adventure;

  /// No description provided for @contemporary.
  ///
  /// In en, this message translates to:
  /// **'Contemporary'**
  String get contemporary;

  /// No description provided for @romance.
  ///
  /// In en, this message translates to:
  /// **'Romance'**
  String get romance;

  /// No description provided for @dystopian.
  ///
  /// In en, this message translates to:
  /// **'Dystopian'**
  String get dystopian;

  /// No description provided for @horror.
  ///
  /// In en, this message translates to:
  /// **'Horror'**
  String get horror;

  /// No description provided for @paranormal.
  ///
  /// In en, this message translates to:
  /// **'Paranormal'**
  String get paranormal;

  /// No description provided for @historicalFiction.
  ///
  /// In en, this message translates to:
  /// **'Historical Fiction'**
  String get historicalFiction;

  /// No description provided for @scienceFiction.
  ///
  /// In en, this message translates to:
  /// **'Science Fiction'**
  String get scienceFiction;

  /// No description provided for @childrens.
  ///
  /// In en, this message translates to:
  /// **'Children\'s'**
  String get childrens;

  /// No description provided for @academic.
  ///
  /// In en, this message translates to:
  /// **'Academic'**
  String get academic;

  /// No description provided for @mystery.
  ///
  /// In en, this message translates to:
  /// **'Mystery'**
  String get mystery;

  /// No description provided for @thrillers.
  ///
  /// In en, this message translates to:
  /// **'Thrillers'**
  String get thrillers;

  /// No description provided for @memoir.
  ///
  /// In en, this message translates to:
  /// **'Memoir'**
  String get memoir;

  /// No description provided for @selfHelp.
  ///
  /// In en, this message translates to:
  /// **'Self-help'**
  String get selfHelp;

  /// No description provided for @cookbook.
  ///
  /// In en, this message translates to:
  /// **'Cookbook'**
  String get cookbook;

  /// No description provided for @art_Photography.
  ///
  /// In en, this message translates to:
  /// **'Art & Photography'**
  String get art_Photography;

  /// No description provided for @youngAdult.
  ///
  /// In en, this message translates to:
  /// **'Young Adult'**
  String get youngAdult;

  /// No description provided for @personalDevelopment.
  ///
  /// In en, this message translates to:
  /// **'Personal Development'**
  String get personalDevelopment;

  /// No description provided for @motivational.
  ///
  /// In en, this message translates to:
  /// **'Motivational'**
  String get motivational;

  /// No description provided for @health.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get health;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @travel.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get travel;

  /// No description provided for @guide.
  ///
  /// In en, this message translates to:
  /// **'Guide'**
  String get guide;

  /// No description provided for @families_Relationships.
  ///
  /// In en, this message translates to:
  /// **'Families & Relationships'**
  String get families_Relationships;

  /// No description provided for @humor.
  ///
  /// In en, this message translates to:
  /// **'Humor'**
  String get humor;

  /// No description provided for @graphicNovel.
  ///
  /// In en, this message translates to:
  /// **'Graphic Novel'**
  String get graphicNovel;

  /// No description provided for @shortStory.
  ///
  /// In en, this message translates to:
  /// **'Short Story'**
  String get shortStory;

  /// No description provided for @biographyAndAutobiography.
  ///
  /// In en, this message translates to:
  /// **'Biography and Autobiography'**
  String get biographyAndAutobiography;

  /// No description provided for @poetry.
  ///
  /// In en, this message translates to:
  /// **'Poetry'**
  String get poetry;

  /// No description provided for @religion_Spirituality.
  ///
  /// In en, this message translates to:
  /// **'Religion & Spirituality'**
  String get religion_Spirituality;

  /// No description provided for @myQuotes.
  ///
  /// In en, this message translates to:
  /// **'My Quotes'**
  String get myQuotes;

  /// No description provided for @myNotes.
  ///
  /// In en, this message translates to:
  /// **'My Notes'**
  String get myNotes;

  /// No description provided for @currentlyReading.
  ///
  /// In en, this message translates to:
  /// **'Currently Reading'**
  String get currentlyReading;

  /// No description provided for @wantToRead.
  ///
  /// In en, this message translates to:
  /// **'Want to Read'**
  String get wantToRead;

  /// No description provided for @alreadyRead.
  ///
  /// In en, this message translates to:
  /// **'Already Read'**
  String get alreadyRead;

  /// No description provided for @visitor.
  ///
  /// In en, this message translates to:
  /// **'Visitor'**
  String get visitor;

  /// No description provided for @backupSyncBooks.
  ///
  /// In en, this message translates to:
  /// **'Backup or synchronize books'**
  String get backupSyncBooks;

  /// No description provided for @supportWithAds.
  ///
  /// In en, this message translates to:
  /// **'Support by watching ads'**
  String get supportWithAds;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact us'**
  String get contactUs;

  /// No description provided for @dataSourceDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'App data source and responsibility disclaimer'**
  String get dataSourceDisclaimer;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @refreshBooks.
  ///
  /// In en, this message translates to:
  /// **'Refresh books'**
  String get refreshBooks;

  /// No description provided for @emptyLibraryMessage.
  ///
  /// In en, this message translates to:
  /// **'Your library is currently empty.'**
  String get emptyLibraryMessage;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @loginToAddQuote.
  ///
  /// In en, this message translates to:
  /// **'You need to log in first to add a quote.'**
  String get loginToAddQuote;

  /// No description provided for @noQuoteAdded.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t added any quotes yet.'**
  String get noQuoteAdded;

  /// No description provided for @emptyNotes.
  ///
  /// In en, this message translates to:
  /// **'Your notes are empty.'**
  String get emptyNotes;

  /// No description provided for @addQuoteToBook.
  ///
  /// In en, this message translates to:
  /// **'Add a quote to your book'**
  String get addQuoteToBook;

  /// No description provided for @addYourBook.
  ///
  /// In en, this message translates to:
  /// **'Add your own book'**
  String get addYourBook;

  /// No description provided for @addNoteToBook.
  ///
  /// In en, this message translates to:
  /// **'Add a note to your book'**
  String get addNoteToBook;

  /// No description provided for @quotes.
  ///
  /// In en, this message translates to:
  /// **'Quotes'**
  String get quotes;

  /// No description provided for @newest.
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get newest;

  /// No description provided for @quoteDetails.
  ///
  /// In en, this message translates to:
  /// **'Quote Details'**
  String get quoteDetails;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'E-mail'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @notAMemberYet.
  ///
  /// In en, this message translates to:
  /// **'Not a member?'**
  String get notAMemberYet;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @alreadyAMember.
  ///
  /// In en, this message translates to:
  /// **'Already a member?'**
  String get alreadyAMember;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @noInternetConnection.
  ///
  /// In en, this message translates to:
  /// **'Unable to connect to the internet.'**
  String get noInternetConnection;

  /// No description provided for @checkInternetConnection.
  ///
  /// In en, this message translates to:
  /// **'Please check your internet connection and try again.'**
  String get checkInternetConnection;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @monthlyTrendingBooks.
  ///
  /// In en, this message translates to:
  /// **'Monthly Trending Books'**
  String get monthlyTrendingBooks;

  /// No description provided for @bookDetail.
  ///
  /// In en, this message translates to:
  /// **'Book Detail'**
  String get bookDetail;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @showMore.
  ///
  /// In en, this message translates to:
  /// **'Show More'**
  String get showMore;

  /// No description provided for @showLess.
  ///
  /// In en, this message translates to:
  /// **'Show Less'**
  String get showLess;

  /// No description provided for @availableLanguages.
  ///
  /// In en, this message translates to:
  /// **'Available Languages'**
  String get availableLanguages;

  /// No description provided for @limitedLanguagesDisplayed.
  ///
  /// In en, this message translates to:
  /// **'The languages here may not display all available languages.'**
  String get limitedLanguagesDisplayed;

  /// No description provided for @editions.
  ///
  /// In en, this message translates to:
  /// **'Editions'**
  String get editions;

  /// No description provided for @publishDate.
  ///
  /// In en, this message translates to:
  /// **'Publish Date'**
  String get publishDate;

  /// No description provided for @pageCount.
  ///
  /// In en, this message translates to:
  /// **'Page Count'**
  String get pageCount;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @publisher.
  ///
  /// In en, this message translates to:
  /// **'Publisher'**
  String get publisher;

  /// No description provided for @bookFormat.
  ///
  /// In en, this message translates to:
  /// **'Book format'**
  String get bookFormat;

  /// No description provided for @authors.
  ///
  /// In en, this message translates to:
  /// **'Authors'**
  String get authors;

  /// No description provided for @authorName.
  ///
  /// In en, this message translates to:
  /// **'Author Name'**
  String get authorName;

  /// No description provided for @biography.
  ///
  /// In en, this message translates to:
  /// **'Biography'**
  String get biography;

  /// No description provided for @booksByAuthor.
  ///
  /// In en, this message translates to:
  /// **'Books by the author'**
  String get booksByAuthor;

  /// No description provided for @birthDate.
  ///
  /// In en, this message translates to:
  /// **'Date of birth'**
  String get birthDate;

  /// No description provided for @deathDate.
  ///
  /// In en, this message translates to:
  /// **'Date of death'**
  String get deathDate;

  /// No description provided for @bookStatus.
  ///
  /// In en, this message translates to:
  /// **'Book status'**
  String get bookStatus;

  /// No description provided for @reviewOnGoodReads.
  ///
  /// In en, this message translates to:
  /// **'Review on GoodReads'**
  String get reviewOnGoodReads;

  /// No description provided for @reviewOnOpenLibrary.
  ///
  /// In en, this message translates to:
  /// **'Review on OpenLibrary'**
  String get reviewOnOpenLibrary;

  /// No description provided for @addQuote.
  ///
  /// In en, this message translates to:
  /// **'Add a quote'**
  String get addQuote;

  /// No description provided for @addNote.
  ///
  /// In en, this message translates to:
  /// **'Add a note'**
  String get addNote;

  /// No description provided for @changeBookStatus.
  ///
  /// In en, this message translates to:
  /// **'Change book status'**
  String get changeBookStatus;

  /// No description provided for @editBook.
  ///
  /// In en, this message translates to:
  /// **'Edit book'**
  String get editBook;

  /// No description provided for @information.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get information;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @selectNewBookStatus.
  ///
  /// In en, this message translates to:
  /// **'Select new book status'**
  String get selectNewBookStatus;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @firstSentence.
  ///
  /// In en, this message translates to:
  /// **'First Sentence'**
  String get firstSentence;

  /// No description provided for @enterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address.'**
  String get enterValidEmail;

  /// No description provided for @passwordLength.
  ///
  /// In en, this message translates to:
  /// **'Your password must be between 6 and 16 characters.'**
  String get passwordLength;

  /// No description provided for @enterLongerName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a longer name.'**
  String get enterLongerName;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get passwordsDoNotMatch;

  /// No description provided for @passwordNoSpaces.
  ///
  /// In en, this message translates to:
  /// **'Password cannot contain spaces.'**
  String get passwordNoSpaces;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong.'**
  String get somethingWentWrong;

  /// No description provided for @appEncounteredError.
  ///
  /// In en, this message translates to:
  /// **'The app encountered an unknown error.'**
  String get appEncounteredError;

  /// No description provided for @tryAgainLater.
  ///
  /// In en, this message translates to:
  /// **'Please try again later.'**
  String get tryAgainLater;

  /// No description provided for @removeFromShelf.
  ///
  /// In en, this message translates to:
  /// **'Remove from shelf'**
  String get removeFromShelf;

  /// No description provided for @addToShelf.
  ///
  /// In en, this message translates to:
  /// **'Add to shelf'**
  String get addToShelf;

  /// No description provided for @bookSuccessfullyDeleted.
  ///
  /// In en, this message translates to:
  /// **'The book has been successfully deleted.'**
  String get bookSuccessfullyDeleted;

  /// No description provided for @okay.
  ///
  /// In en, this message translates to:
  /// **'Okay'**
  String get okay;

  /// No description provided for @bookStatusUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'The book status has been successfully updated.'**
  String get bookStatusUpdatedSuccessfully;

  /// No description provided for @bookSuccessfullyAddedToLibrary.
  ///
  /// In en, this message translates to:
  /// **'The book has been successfully added to your library.'**
  String get bookSuccessfullyAddedToLibrary;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @paperback.
  ///
  /// In en, this message translates to:
  /// **'Paperback'**
  String get paperback;

  /// No description provided for @hardcover.
  ///
  /// In en, this message translates to:
  /// **'Hardcover'**
  String get hardcover;

  /// No description provided for @ebook.
  ///
  /// In en, this message translates to:
  /// **'E-book'**
  String get ebook;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @confirmDeleteBook.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this book from your library?'**
  String get confirmDeleteBook;

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Go back'**
  String get goBack;

  /// No description provided for @enterTitle.
  ///
  /// In en, this message translates to:
  /// **'Please enter a title.'**
  String get enterTitle;

  /// No description provided for @audioBook.
  ///
  /// In en, this message translates to:
  /// **'Audiobook'**
  String get audioBook;

  /// No description provided for @paperBook.
  ///
  /// In en, this message translates to:
  /// **'Paper book'**
  String get paperBook;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @imageSizeWarning.
  ///
  /// In en, this message translates to:
  /// **'The size of the selected image is high, so you may lose it during backup.'**
  String get imageSizeWarning;

  /// No description provided for @addBookWithSearch.
  ///
  /// In en, this message translates to:
  /// **'Add book with search'**
  String get addBookWithSearch;

  /// No description provided for @editQuote.
  ///
  /// In en, this message translates to:
  /// **'Edit quote'**
  String get editQuote;

  /// No description provided for @deleteQuote.
  ///
  /// In en, this message translates to:
  /// **'Delete quote'**
  String get deleteQuote;

  /// No description provided for @confirmDeleteQuote.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this quote?'**
  String get confirmDeleteQuote;

  /// No description provided for @quoteSuccessfullyDeleted.
  ///
  /// In en, this message translates to:
  /// **'The quote has been successfully deleted.'**
  String get quoteSuccessfullyDeleted;

  /// No description provided for @errorDeletingQuote.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while deleting the quote.'**
  String get errorDeletingQuote;

  /// No description provided for @booksSyncing.
  ///
  /// In en, this message translates to:
  /// **'Books are being synchronized.'**
  String get booksSyncing;

  /// No description provided for @pleaseWait.
  ///
  /// In en, this message translates to:
  /// **'Please wait.'**
  String get pleaseWait;

  /// No description provided for @noResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No results found.'**
  String get noResultsFound;

  /// No description provided for @clickToRetry.
  ///
  /// In en, this message translates to:
  /// **'Click to retry.'**
  String get clickToRetry;

  /// No description provided for @pressAgainToExit.
  ///
  /// In en, this message translates to:
  /// **'Press again to exit the app.'**
  String get pressAgainToExit;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @errorWhileLoggingOut.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while logging out.'**
  String get errorWhileLoggingOut;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters long.'**
  String get passwordMinLength;

  /// No description provided for @emailAlreadyInUse.
  ///
  /// In en, this message translates to:
  /// **'The email address is already in use by another account.'**
  String get emailAlreadyInUse;

  /// No description provided for @invalidEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'The email address is invalid.'**
  String get invalidEmailAddress;

  /// No description provided for @errorCreatingAccount.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while creating the account.'**
  String get errorCreatingAccount;

  /// No description provided for @invalidEmailOrPassword.
  ///
  /// In en, this message translates to:
  /// **'The email or password is invalid.'**
  String get invalidEmailOrPassword;

  /// No description provided for @userDisabled.
  ///
  /// In en, this message translates to:
  /// **'The user with this email address has been disabled.'**
  String get userDisabled;

  /// No description provided for @errorDuringLogin.
  ///
  /// In en, this message translates to:
  /// **'An error occurred during login.'**
  String get errorDuringLogin;

  /// No description provided for @loginToBackupBooks.
  ///
  /// In en, this message translates to:
  /// **'You must log in to back up your books.'**
  String get loginToBackupBooks;

  /// No description provided for @upToDate.
  ///
  /// In en, this message translates to:
  /// **'You are up to date!'**
  String get upToDate;

  /// No description provided for @emailCopied.
  ///
  /// In en, this message translates to:
  /// **'E-mail address copied.'**
  String get emailCopied;

  /// No description provided for @confirmLogout.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get confirmLogout;

  /// No description provided for @aboutAppDataSource.
  ///
  /// In en, this message translates to:
  /// **'About App Data Source'**
  String get aboutAppDataSource;

  /// No description provided for @appDataSourceAndDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'App Data Source and Responsibility Disclaimer:'**
  String get appDataSourceAndDisclaimer;

  /// No description provided for @appDataSourceInfo.
  ///
  /// In en, this message translates to:
  /// **'This app retrieves book information using the OpenLibrary API, and the data is provided by the OpenLibrary community. OpenLibrary is a platform supported by a large user base, and anyone has the ability to edit book information.'**
  String get appDataSourceInfo;

  /// No description provided for @userResponsibility.
  ///
  /// In en, this message translates to:
  /// **'User Responsibility:'**
  String get userResponsibility;

  /// No description provided for @userResponsibilityInfo.
  ///
  /// In en, this message translates to:
  /// **'The accuracy and currency of the book information in our app are provided by Open Library users. Please note that the developers of our app do not have the authority to change or update book information. In case of any errors, missing information, inappropriate images, or inaccuracies, you can correct or update the relevant book information on the Open Library platform. This disclaimer indicates that the responsibility for the book information in our app is shared between Open Library and its users. Thank you.'**
  String get userResponsibilityInfo;

  /// No description provided for @selectBookToAddNote.
  ///
  /// In en, this message translates to:
  /// **'Select the book to add a note'**
  String get selectBookToAddNote;

  /// No description provided for @selectBookToAddQuote.
  ///
  /// In en, this message translates to:
  /// **'Select the book to add a quote'**
  String get selectBookToAddQuote;

  /// No description provided for @addBookBeforeNote.
  ///
  /// In en, this message translates to:
  /// **'You must add a book before adding a note.'**
  String get addBookBeforeNote;

  /// No description provided for @addBookBeforeQuote.
  ///
  /// In en, this message translates to:
  /// **'You must add a book before adding a quote.'**
  String get addBookBeforeQuote;

  /// No description provided for @deleteNote.
  ///
  /// In en, this message translates to:
  /// **'Delete note'**
  String get deleteNote;

  /// No description provided for @noteSuccessfullyUpdated.
  ///
  /// In en, this message translates to:
  /// **'The note has been successfully updated.'**
  String get noteSuccessfullyUpdated;

  /// No description provided for @noteSuccessfullyAdded.
  ///
  /// In en, this message translates to:
  /// **'The note has been successfully added.'**
  String get noteSuccessfullyAdded;

  /// No description provided for @pleaseAddNoteFirst.
  ///
  /// In en, this message translates to:
  /// **'Please add a note first.'**
  String get pleaseAddNoteFirst;

  /// No description provided for @pleaseAddOrDeleteNoteFirst.
  ///
  /// In en, this message translates to:
  /// **'Please add a note first or delete the existing note.'**
  String get pleaseAddOrDeleteNoteFirst;

  /// No description provided for @enterYourNote.
  ///
  /// In en, this message translates to:
  /// **'Enter your note.'**
  String get enterYourNote;

  /// No description provided for @confirmDeleteNote.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this note?'**
  String get confirmDeleteNote;

  /// No description provided for @loginToLikePost.
  ///
  /// In en, this message translates to:
  /// **'You must be logged in to like a post.'**
  String get loginToLikePost;

  /// No description provided for @currentlyReadingBooks.
  ///
  /// In en, this message translates to:
  /// **'You are currently reading {currentlyReadingCount} books.'**
  String currentlyReadingBooks(int currentlyReadingCount);

  /// No description provided for @totalBooksToRead.
  ///
  /// In en, this message translates to:
  /// **'You have {wantToReadCount} books to read in total.'**
  String totalBooksToRead(int wantToReadCount);

  /// No description provided for @congratulationsTotalBooksRead.
  ///
  /// In en, this message translates to:
  /// **'Congratulations, you have read a total of {alreadyReadCount} books.'**
  String congratulationsTotalBooksRead(int alreadyReadCount);

  /// No description provided for @likedByYouAndOneOther.
  ///
  /// In en, this message translates to:
  /// **'You and {likeCount1} other liked this.'**
  String likedByYouAndOneOther(int likeCount1);

  /// No description provided for @peopleLiked.
  ///
  /// In en, this message translates to:
  /// **'Liked by {likeCount2}'**
  String peopleLiked(int likeCount2);

  /// No description provided for @noOneLikedYet.
  ///
  /// In en, this message translates to:
  /// **'No one has liked it yet.'**
  String get noOneLikedYet;

  /// No description provided for @quotesFailedToLoad.
  ///
  /// In en, this message translates to:
  /// **'Quotes could not be loaded.'**
  String get quotesFailedToLoad;

  /// No description provided for @clickToRefresh.
  ///
  /// In en, this message translates to:
  /// **'Please click to refresh.'**
  String get clickToRefresh;

  /// No description provided for @pleaseEnterQuote.
  ///
  /// In en, this message translates to:
  /// **'Please enter a quote.'**
  String get pleaseEnterQuote;

  /// No description provided for @quoteSuccessfullyAdded.
  ///
  /// In en, this message translates to:
  /// **'The quote has been successfully added.'**
  String get quoteSuccessfullyAdded;

  /// No description provided for @enterQuote.
  ///
  /// In en, this message translates to:
  /// **'Enter a quote.'**
  String get enterQuote;

  /// No description provided for @confirmSaveQuote.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to save this quote?'**
  String get confirmSaveQuote;

  /// No description provided for @quoteSuccessfullyUpdated.
  ///
  /// In en, this message translates to:
  /// **'The quote has been successfully updated.'**
  String get quoteSuccessfullyUpdated;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @anErrorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred.'**
  String get anErrorOccurred;

  /// No description provided for @viewAllEditions.
  ///
  /// In en, this message translates to:
  /// **'View All {editionCount} Editions.'**
  String viewAllEditions(int editionCount);

  /// No description provided for @bookEditions.
  ///
  /// In en, this message translates to:
  /// **'{bookName} Editions'**
  String bookEditions(String bookName);

  /// No description provided for @authorsBooks.
  ///
  /// In en, this message translates to:
  /// **'{authorName}\'s Books'**
  String authorsBooks(String authorName);

  /// No description provided for @viewAllBooks.
  ///
  /// In en, this message translates to:
  /// **'View All {bookCount} Books'**
  String viewAllBooks(int bookCount);

  /// No description provided for @errorFetchingNotes.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while fetching the notes'**
  String get errorFetchingNotes;

  /// No description provided for @errorDeletingBook.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while deleting the book'**
  String get errorDeletingBook;

  /// No description provided for @errorDeletingNote.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while deleting the note'**
  String get errorDeletingNote;

  /// No description provided for @errorDeletingNotes.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while deleting the notes'**
  String get errorDeletingNotes;

  /// No description provided for @errorAddingBook.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while adding the book'**
  String get errorAddingBook;

  /// No description provided for @errorAddingQuote.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while adding the quote'**
  String get errorAddingQuote;

  /// No description provided for @errorUpdatingBookStatus.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while updating the book status'**
  String get errorUpdatingBookStatus;

  /// No description provided for @errorAddingNote.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while adding the note.'**
  String get errorAddingNote;

  /// No description provided for @errorFetchingBooks.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while fetching the books.'**
  String get errorFetchingBooks;

  /// No description provided for @searchResults.
  ///
  /// In en, this message translates to:
  /// **'Search results:'**
  String get searchResults;

  /// No description provided for @selectAnEdition.
  ///
  /// In en, this message translates to:
  /// **'Choose an edition to add to your shelf'**
  String get selectAnEdition;

  /// No description provided for @selectStatusForBook.
  ///
  /// In en, this message translates to:
  /// **'Select the status for the book you want to add.'**
  String get selectStatusForBook;

  /// No description provided for @adFailedToLoad.
  ///
  /// In en, this message translates to:
  /// **'Ad failed to load.'**
  String get adFailedToLoad;

  /// No description provided for @loginSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Successfully logged in.'**
  String get loginSuccessful;

  /// No description provided for @createAccountSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Account successfully created.'**
  String get createAccountSuccessful;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
