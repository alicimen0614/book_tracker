import 'dart:convert';
import 'dart:io';
import 'package:book_tracker/const.dart';
import 'package:book_tracker/models/bookswork_editions_model.dart';
import 'package:book_tracker/providers/riverpod_management.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum BookFormat { paperBook, ebook, audioBook }

enum BookStatus { wantToRead, currentlyReading, alreadyRead }

class AddBookView extends ConsumerStatefulWidget {
  const AddBookView(
      {super.key,
      this.title,
      this.authorName,
      this.publisher,
      this.bookStatus = "",
      this.isbn10,
      this.pageNumber,
      this.publishDate,
      this.bookId,
      this.covers,
      this.physical_format,
      this.bookImage,
      this.indexOfEdition = 0,
      this.toUpdate = false});

  final String? title;
  final String? authorName;
  final String? publisher;
  final String? isbn10;
  final int? pageNumber;
  final String bookStatus;
  final String? publishDate;
  final int? bookId;
  final List<int?>? covers;
  final String? physical_format;
  final Image? bookImage;
  final int indexOfEdition;
  final bool toUpdate;

  @override
  ConsumerState<AddBookView> createState() => _AddBookViewState();
}

class _AddBookViewState extends ConsumerState<AddBookView> {
  bool isImageSizeSuitable = false;
  @override
  void initState() {
    if (widget.title != "") {
      if (widget.physical_format == "paperback" ||
          widget.physical_format == "Paperback") {
        bookFormat = BookFormat.paperBook;
      } else if (widget.physical_format == "E-book" ||
          widget.physical_format == "Ebook" ||
          widget.physical_format == "E-Book") {
        bookFormat = BookFormat.ebook;
      } else if (widget.physical_format == "CD" ||
          widget.physical_format == "audio cd" ||
          widget.physical_format == "Audio cassette") {
        bookFormat = BookFormat.audioBook;
      } else {
        bookFormat = BookFormat.paperBook;
      }
      titleFieldController.text = widget.title ?? "";
      authorFieldController.text = widget.authorName ?? "";
      publisherFieldController.text = widget.publisher ?? "";
      isbnFieldController.text = widget.isbn10 ?? "";
      publishDateFieldController.text = widget.publishDate ?? "";
      widget.pageNumber != null
          ? pageNumberFieldController.text = widget.pageNumber.toString()
          : "";

      bookStatus = widget.bookStatus == "Okuduklarım"
          ? BookStatus.alreadyRead
          : widget.bookStatus == "Şu an okuduklarım"
              ? BookStatus.currentlyReading
              : BookStatus.wantToRead;
    }

    super.initState();
  }

  bool isSaved = false;
  File? pickedImage;
  BookFormat bookFormat = BookFormat.paperBook;
  BookStatus bookStatus = BookStatus.wantToRead;

  final titleFieldController = TextEditingController();
  final authorFieldController = TextEditingController();
  final publisherFieldController = TextEditingController();
  final isbnFieldController = TextEditingController();
  final pageNumberFieldController = TextEditingController();
  final publishDateFieldController = TextEditingController();

  @override
  void dispose() {
    titleFieldController.dispose();
    authorFieldController.dispose();
    publisherFieldController.dispose();
    isbnFieldController.dispose();
    pageNumberFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context)!.addBook,
            textAlign: TextAlign.left,
            style: TextStyle(
                fontSize: MediaQuery.of(context).size.height / 40,
                fontWeight: FontWeight.bold,
                color: Colors.white),
          ),
          centerTitle: true,
          leadingWidth: 50,
          leading: IconButton(
              tooltip: AppLocalizations.of(context)!.goBack,
              splashRadius: 25,
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_back_sharp,
                size: 30,
              )),
          actions: [
            IconButton(
              splashRadius: 25,
              onPressed: () async {
                if (titleFieldController.text == "") {
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    duration: const Duration(seconds: 2),
                    content: Text(AppLocalizations.of(context)!.enterTitle),
                    action: SnackBarAction(
                      label: AppLocalizations.of(context)!.okay,
                      onPressed: () {},
                    ),
                    behavior: SnackBarBehavior.floating,
                  ));
                } else {
                  isSaved = true;
                  List<String?>? authorsNames = authorFieldController.text != ""
                      ? [authorFieldController.text]
                      : null;

                  BookWorkEditionsModelEntries bookInfo =
                      BookWorkEditionsModelEntries(
                          physical_format: bookFormat.name == "ebook"
                              ? AppLocalizations.of(context)!.ebook
                              : bookFormat.name == "audioBook"
                                  ? AppLocalizations.of(context)!.audioBook
                                  : AppLocalizations.of(context)!.paperBook,
                          publish_date: publishDateFieldController.text != ""
                              ? publishDateFieldController.text
                              : null,
                          covers: widget.covers,
                          authorsNames: authorsNames,
                          title: titleFieldController.text,
                          isbn_10: isbnFieldController.text != ""
                              ? [isbnFieldController.text]
                              : null,
                          number_of_pages: pageNumberFieldController.text != ""
                              ? int.parse(pageNumberFieldController.text)
                              : null,
                          publishers: publisherFieldController.text != ""
                              ? [publisherFieldController.text]
                              : null);
                  Uint8List imageAsByte = Uint8List.fromList([]);
                  if (pickedImage != null) {
                    imageAsByte = await pickedImage!.readAsBytes();
                  }
                  if (uniqueIdCreater(bookInfo) != widget.bookId) {
                    //handle notes in sql while editing
                    if (widget.bookId != null) {
                      //delete book in sql
                      await ref.read(sqlProvider).deleteBook(
                            widget.bookId!,
                          );
                      var notes = await ref
                          .read(sqlProvider)
                          .getNotes(context, bookId: widget.bookId);
                      if (notes != []) {
                        for (var element in notes!) {
                          await ref.read(sqlProvider).insertNoteToBook(
                                element["note"],
                                uniqueIdCreater(bookInfo),
                                context,
                                element["noteDate"],
                                noteId: element["id"].runtimeType == String
                                    ? int.parse(element["id"])
                                    : element["id"],
                              );
                        }
                      }
                    }
                    //handle notes in firebase
                    if (widget.bookId != null &&
                        ref.read(authProvider).currentUser != null) {
                      //delete book on firebase
                      ref.read(firestoreProvider).deleteBook(context,
                          referencePath: "usersBooks",
                          userId: ref.read(authProvider).currentUser!.uid,
                          bookId: widget.bookId.toString());
                      var notes;
                      ref
                          .read(firestoreProvider)
                          .getNotes("usersBooks",
                              ref.read(authProvider).currentUser!.uid, context)
                          .then((value) {
                        if (value != null) {
                          notes = value.docs
                              .map(
                                (e) => e.data(),
                              )
                              .toList();
                        }
                      });

                      if (notes != null) {
                        var wantedNotes = notes
                            .where((e) => e["bookId"] == widget.bookId)
                            .toList();
                        if (wantedNotes != []) {
                          for (var element in wantedNotes) {
                            await ref.read(firestoreProvider).setNoteData(
                                context,
                                noteId: element["id"].runtimeType == int
                                    ? element["id"]
                                    : int.tryParse(element["id"]),
                                collectionPath: "usersBooks",
                                note: element["note"],
                                userId: ref.read(authProvider).currentUser!.uid,
                                uniqueBookId: uniqueIdCreater(bookInfo),
                                noteDate: element["noteDate"]);
                          }
                        }
                      }
                    }
                  }

                  //insert author
                  if (authorFieldController.text != "") {
                    await ref.read(sqlProvider).insertAuthors(
                        authorFieldController.text,
                        uniqueIdCreater(bookInfo),
                        context);
                  }

                  //insert book
                  await ref.read(sqlProvider).insertBook(
                      bookInfo,
                      bookStatus == BookStatus.alreadyRead
                          ? "Okuduklarım"
                          : bookStatus == BookStatus.currentlyReading
                              ? "Şu an okuduklarım"
                              : "Okumak istediklerim",
                      pickedImage != null ? imageAsByte : null,
                      context);

                  if (ref.read(authProvider).currentUser != null) {
                    ref.read(firestoreProvider).setBookData(context,
                        collectionPath: "usersBooks",
                        bookAsMap: {
                          "authorsNames": authorFieldController.text != ""
                              ? [authorFieldController.text]
                              : null,
                          "physical_format": bookFormat.name == "ebook"
                              ? AppLocalizations.of(context)!.ebook
                              : bookFormat.name == "audioBook"
                                  ? AppLocalizations.of(context)!.audioBook
                                  : AppLocalizations.of(context)!.paperBook,
                          "publish_date": publishDateFieldController.text != ""
                              ? publishDateFieldController.text
                              : null,
                          "title": titleFieldController.text,
                          "isbn_10": isbnFieldController.text != ""
                              ? [isbnFieldController.text]
                              : null,
                          "number_of_pages":
                              pageNumberFieldController.text != ""
                                  ? int.parse(pageNumberFieldController.text)
                                  : null,
                          "publishers": publisherFieldController.text != ""
                              ? [publisherFieldController.text]
                              : null,
                          "covers": widget.covers,
                          "imageAsByte":
                              pickedImage != null && isImageSizeSuitable == true
                                  ? base64Encode(imageAsByte)
                                  : null,
                          "bookStatus": bookStatus == BookStatus.alreadyRead
                              ? "Okuduklarım"
                              : bookStatus == BookStatus.currentlyReading
                                  ? "Şu an okuduklarım"
                                  : "Okumak istediklerim",
                        },
                        userId: ref.read(authProvider).currentUser!.uid);
                  }
                  if (ref.read(indexBottomNavbarProvider) == 0) {
                    Navigator.pop(context, isSaved);
                    Navigator.pop(context);
                  } else {
                    if (widget.toUpdate) {
                      Navigator.pop(context, isSaved);
                      Navigator.pop(context);
                    } else {
                      Navigator.pop(context, isSaved);
                      Navigator.pop(context, isSaved);
                    }
                  }

                  ScaffoldMessenger.of(context).clearSnackBars;
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(!widget.toUpdate
                        ? AppLocalizations.of(context)!
                            .bookSuccessfullyAddedToLibrary
                        : AppLocalizations.of(context)!
                            .bookStatusUpdatedSuccessfully),
                    action: SnackBarAction(
                        label: AppLocalizations.of(context)!.okay,
                        onPressed: () {}),
                    behavior: SnackBarBehavior.floating,
                  ));
                }
              },
              icon: const Icon(Icons.check_sharp, size: 30),
            )
          ],
          automaticallyImplyLeading: false,
          elevation: 0,
        ),
        body: Scrollbar(
          thumbVisibility: true,
          thickness: 3,
          radius: const Radius.circular(20),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(
                    thickness: 0,
                    color: Colors.transparent,
                  ),
                  Center(
                    child: SizedBox(
                      height: 220,
                      width: 140,
                      child: Stack(
                        alignment: Alignment.center,
                        clipBehavior: Clip.none,
                        children: [
                          pickedImage == null && widget.bookImage == null
                              ? Center(
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.grey.shade400,
                                        border: Border.all(color: Colors.white),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(5))),
                                    height: 200,
                                    width: 120,
                                  ),
                                )
                              : (pickedImage != null &&
                                          widget.bookImage == null) ||
                                      (pickedImage != null &&
                                          widget.bookImage != null)
                                  ? Image.file(
                                      pickedImage!,
                                      fit: BoxFit.cover,
                                      height: 200,
                                      width: 120,
                                      filterQuality: FilterQuality.medium,
                                    )
                                  : Hero(
                                      tag: widget.bookId! +
                                          widget.indexOfEdition,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(15),
                                        child: Image(
                                          fit: BoxFit.fill,
                                          image: widget.bookImage!.image,
                                          width: 120,
                                          height: 200,
                                        ),
                                      ),
                                    ),
                          pickedImage == null && widget.bookImage == null
                              ? const Icon(
                                  Icons.photo,
                                  color: Colors.grey,
                                )
                              : const SizedBox.shrink(),
                          Positioned(
                              bottom: 0,
                              right: 0,
                              child: Material(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    side:
                                        const BorderSide(color: Colors.white)),
                                child: ClipOval(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade400,
                                    ),
                                    padding: const EdgeInsets.all(0),
                                    height: 40,
                                    width: 40,
                                    child: IconButton(
                                        padding: const EdgeInsets.all(0),
                                        splashRadius: 25,
                                        onPressed: () {
                                          modalBottomSheetBuilderForPopUpMenu(
                                              context);
                                        },
                                        icon: const Icon(
                                          Icons.add_a_photo_rounded,
                                          size: 23,
                                        )),
                                  ),
                                ),
                              ))
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  TextFormField(
                    controller: titleFieldController,
                    decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(10),
                        hintText: AppLocalizations.of(context)!.title,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30))),
                  ),
                  const Divider(
                    thickness: 0,
                    color: Colors.transparent,
                  ),
                  TextFormField(
                    controller: authorFieldController,
                    decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(10),
                        hintText: AppLocalizations.of(context)!.authorName,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30))),
                  ),
                  const Divider(
                    thickness: 0,
                    color: Colors.transparent,
                  ),
                  TextFormField(
                    controller: publisherFieldController,
                    decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(10),
                        hintText: AppLocalizations.of(context)!.publisher,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30))),
                  ),
                  const Divider(
                    thickness: 0,
                    color: Colors.transparent,
                  ),
                  Text(
                    AppLocalizations.of(context)!.bookStatus,
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  const Divider(
                    thickness: 0,
                    color: Colors.transparent,
                  ),
                  bookStatusSelectionSection(),
                  const Divider(
                    thickness: 0,
                    color: Colors.transparent,
                  ),
                  TextFormField(
                    controller: publishDateFieldController,
                    decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(10),
                        hintText: AppLocalizations.of(context)!.publishDate,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30))),
                  ),
                  const Divider(
                    thickness: 0,
                    color: Colors.transparent,
                  ),
                  TextFormField(
                    enabled: widget.isbn10 != null ? false : true,
                    controller: isbnFieldController,
                    decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(10),
                        hintText: "ISBN",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30))),
                  ),
                  const Divider(
                    thickness: 0,
                    color: Colors.transparent,
                  ),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    controller: pageNumberFieldController,
                    decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(10),
                        hintText: AppLocalizations.of(context)!.pageCount,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30))),
                  ),
                  const Divider(
                    thickness: 0,
                    color: Colors.transparent,
                  ),
                  Text(AppLocalizations.of(context)!.bookFormat,
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.bold)),
                  const Divider(
                    thickness: 0,
                    color: Colors.transparent,
                  ),
                  bookTypeSelectionSection(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Row bookStatusSelectionSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(),
        Expanded(
          flex: 4,
          child: bookStatusCustomElevatedButton(
              text: AppLocalizations.of(context)!.wantToRead,
              bookStatusName: BookStatus.wantToRead),
        ),
        const Spacer(),
        Expanded(
          flex: 4,
          child: bookStatusCustomElevatedButton(
              text: AppLocalizations.of(context)!.currentlyReading,
              bookStatusName: BookStatus.currentlyReading),
        ),
        const Spacer(),
        Expanded(
          flex: 4,
          child: bookStatusCustomElevatedButton(
              text: AppLocalizations.of(context)!.alreadyRead,
              bookStatusName: BookStatus.alreadyRead),
        ),
        const Spacer()
      ],
    );
  }

  ElevatedButton bookStatusCustomElevatedButton(
      {required String text, required BookStatus bookStatusName}) {
    return ElevatedButton(
        onPressed: () {
          setState(() {
            bookStatus = bookStatusName;
          });
        },
        style: ElevatedButton.styleFrom(
            fixedSize: const Size(30, 45),
            padding: EdgeInsets.zero,
            foregroundColor: bookStatus == bookStatusName
                ? Colors.white
                : const Color(0xFF1B7695),
            backgroundColor: bookStatus == bookStatusName
                ? const Color(0xFF1B7695)
                : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            )),
        child: Text(text,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: bookStatus == bookStatusName
                    ? Colors.white
                    : Colors.black54,
                fontSize: MediaQuery.of(context).size.height / 60),
            maxLines: 2));
  }

  Row bookTypeSelectionSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(),
        Expanded(
          flex: 4,
          child: bookTypeCustomElevatedButton(
              text: AppLocalizations.of(context)!.paperBook,
              bookFormatName: BookFormat.paperBook),
        ),
        const Spacer(),
        Expanded(
          flex: 4,
          child: bookTypeCustomElevatedButton(
              text: AppLocalizations.of(context)!.ebook,
              bookFormatName: BookFormat.ebook),
        ),
        const Spacer(),
        Expanded(
          flex: 4,
          child: bookTypeCustomElevatedButton(
              text: AppLocalizations.of(context)!.audioBook,
              bookFormatName: BookFormat.audioBook),
        ),
        const Spacer()
      ],
    );
  }

  ElevatedButton bookTypeCustomElevatedButton(
      {required String text, required BookFormat bookFormatName}) {
    return ElevatedButton(
        onPressed: () {
          setState(() {
            bookFormat = bookFormatName;
          });
        },
        style: ElevatedButton.styleFrom(
            padding: EdgeInsets.zero,
            foregroundColor: bookFormat == bookFormatName
                ? Colors.white
                : const Color(0xFF1B7695),
            backgroundColor: bookFormat == bookFormatName
                ? const Color(0xFF1B7695)
                : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            )),
        child: Text(text,
            style: TextStyle(
                color: bookFormat == bookFormatName
                    ? Colors.white
                    : Colors.black54),
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis));
  }

  void modalBottomSheetBuilderForPopUpMenu(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Colors.grey.shade300,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30), topRight: Radius.circular(30))),
      context: context,
      builder: (context) {
        return Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            visualDensity: const VisualDensity(vertical: 3),
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30))),
            onTap: () {
              pickImage(ImageSource.camera);
            },
            leading: const Icon(
              color: Colors.black,
              Icons.photo_camera_outlined,
              size: 30,
            ),
            title: Text(AppLocalizations.of(context)!.camera,
                style: const TextStyle(fontSize: 20)),
          ),
          const Divider(
            height: 0,
          ),
          ListTile(
            visualDensity: const VisualDensity(vertical: 3),
            onTap: () => pickImage(ImageSource.gallery),
            leading: const Icon(
              Icons.image_outlined,
              color: Colors.black,
              size: 30,
            ),
            title: Text(AppLocalizations.of(context)!.gallery,
                style: const TextStyle(fontSize: 20)),
          ),
        ]);
      },
    );
  }

  Future pickImage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(
          source: source,
          preferredCameraDevice: CameraDevice.rear,
          maxHeight: 800,
          maxWidth: 480,
          imageQuality: 70);
      if (image == null) {
        return;
      } else {
        final CroppedFile? croppedFile =
            await cropImage(file: image).whenComplete(() {
          Navigator.pop(context);
        });

        if (croppedFile != null) {
          if (await checkImageSize(File(croppedFile.path)) < 1048487) {
            isImageSizeSuitable = true;
          } else {
            isImageSizeSuitable = false;
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              duration: const Duration(seconds: 4),
              content: Text(AppLocalizations.of(context)!.imageSizeWarning),
              action: SnackBarAction(
                  label: AppLocalizations.of(context)!.okay, onPressed: () {}),
              behavior: SnackBarBehavior.floating,
            ));
          }
          setState(() {
            pickedImage = File(croppedFile.path);
          });
        }
      }
    } on PlatformException {}
  }

  Future<CroppedFile?> cropImage({required XFile file}) async {
    return await ImageCropper().cropImage(
      sourcePath: file.path,
      uiSettings: [AndroidUiSettings(lockAspectRatio: false)],
    );
  }

  Future<int> checkImageSize(File image) async {
    Uint8List imageAsByte = await image.readAsBytes();
    String base64Data = base64Encode(imageAsByte);
    int base64Size = base64Data.length;

    return base64Size;
  }
}
