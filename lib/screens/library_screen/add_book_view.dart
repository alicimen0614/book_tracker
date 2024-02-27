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

enum BookFormat { paperBook, ebook, audioBook }

enum BookStatus { wantToRead, currentlyReading, alreadyRead }

class AddBookView extends ConsumerStatefulWidget {
  const AddBookView({super.key});

  @override
  ConsumerState<AddBookView> createState() => _AddBookViewState();
}

class _AddBookViewState extends ConsumerState<AddBookView> {
  bool isSaved = false;
  File? pickedImage;
  BookFormat bookFormat = BookFormat.paperBook;
  BookStatus bookStatus = BookStatus.wantToRead;

  final titleFieldController = TextEditingController();
  final authorFieldController = TextEditingController();
  final publisherFieldController = TextEditingController();
  final isbnFieldController = TextEditingController();
  final pageNumberFieldController = TextEditingController();

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
            "Kitap ekle",
            textAlign: TextAlign.left,
            style: TextStyle(
                fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          centerTitle: true,
          leadingWidth: 50,
          leading: IconButton(
              tooltip: "Geri dön",
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
                    duration: Duration(seconds: 2),
                    content: const Text('Lütfen bir başlık girin'),
                    action: SnackBarAction(
                      label: 'Tamam',
                      onPressed: () {},
                    ),
                    behavior: SnackBarBehavior.floating,
                  ));
                } else {
                  isSaved = true;
                  BookWorkEditionsModelEntries bookInfo =
                      BookWorkEditionsModelEntries(
                          covers: null,
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

                  //insert author
                  if (authorFieldController.text != "") {
                    ref.read(sqlProvider).insertAuthors(
                        authorFieldController.text,
                        uniqueIdCreater(bookInfo),
                        context);
                  }

                  //insert book
                  ref.read(sqlProvider).insertBook(
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
                          "covers": null,
                          "imageAsByte": pickedImage != null
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
                    Navigator.pop(context, isSaved);
                  }

                  ScaffoldMessenger.of(context).clearSnackBars;
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: const Text('Kitap başarıyla eklendi!'),
                    action: SnackBarAction(label: 'Tamam', onPressed: () {}),
                    behavior: SnackBarBehavior.floating,
                  ));
                }
              },
              icon: Icon(Icons.check_sharp, size: 30),
            )
          ],
          automaticallyImplyLeading: false,
          elevation: 0,
        ),
        body: Scrollbar(
          thickness: 3,
          radius: Radius.circular(20),
          child: Padding(
            padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: SingleChildScrollView(
              physics: ClampingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(
                    thickness: 0,
                    color: Colors.transparent,
                  ),
                  Center(
                    child: Container(
                      height: 220,
                      width: 140,
                      child: Stack(
                        alignment: Alignment.center,
                        clipBehavior: Clip.none,
                        children: [
                          pickedImage == null
                              ? Center(
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.grey.shade400,
                                        border: Border.all(color: Colors.white),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5))),
                                    height: 200,
                                    width: 120,
                                  ),
                                )
                              : Image.file(
                                  pickedImage!,
                                  fit: BoxFit.cover,
                                  height: 200,
                                  width: 120,
                                  filterQuality: FilterQuality.medium,
                                ),
                          pickedImage == null
                              ? Icon(
                                  Icons.photo,
                                  color: Colors.grey,
                                )
                              : SizedBox.shrink(),
                          Positioned(
                              bottom: 0,
                              right: 0,
                              child: Material(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    side: BorderSide(color: Colors.white)),
                                child: ClipOval(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade400,
                                    ),
                                    padding: EdgeInsets.all(0),
                                    height: 40,
                                    width: 40,
                                    child: IconButton(
                                        padding: EdgeInsets.all(0),
                                        splashRadius: 25,
                                        onPressed: () {
                                          modalBottomSheetBuilderForPopUpMenu(
                                              context);
                                        },
                                        icon: Icon(
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
                  SizedBox(
                    height: 16,
                  ),
                  TextFormField(
                    controller: titleFieldController,
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(10),
                        hintText: "Başlık",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30))),
                  ),
                  Divider(
                    thickness: 0,
                    color: Colors.transparent,
                  ),
                  TextFormField(
                    controller: authorFieldController,
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(10),
                        hintText: "Yazar",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30))),
                  ),
                  Divider(
                    thickness: 0,
                    color: Colors.transparent,
                  ),
                  TextFormField(
                    controller: publisherFieldController,
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(10),
                        hintText: "Yayıncı",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30))),
                  ),
                  Divider(
                    thickness: 0,
                    color: Colors.transparent,
                  ),
                  Text(
                    "Kitap türü",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  Divider(
                    thickness: 0,
                    color: Colors.transparent,
                  ),
                  bookTypeSelectionSection(),
                  Divider(
                    thickness: 0,
                    color: Colors.transparent,
                  ),
                  TextFormField(
                    controller: isbnFieldController,
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(10),
                        hintText: "ISBN",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30))),
                  ),
                  Divider(
                    thickness: 0,
                    color: Colors.transparent,
                  ),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    controller: pageNumberFieldController,
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(10),
                        hintText: "Sayfa sayısı",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30))),
                  ),
                  Divider(
                    thickness: 0,
                    color: Colors.transparent,
                  ),
                  Text("Kitap durumu",
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                  Divider(
                    thickness: 0,
                    color: Colors.transparent,
                  ),
                  bookStatusSelectionSection(),
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
        Spacer(),
        Expanded(
          flex: 4,
          child: bookStatusCustomElevatedButton(
              text: "Okumak İstiyorum", bookStatusName: BookStatus.wantToRead),
        ),
        Spacer(),
        Expanded(
          flex: 4,
          child: bookStatusCustomElevatedButton(
              text: "Şu an okuyorum",
              bookStatusName: BookStatus.currentlyReading),
        ),
        Spacer(),
        Expanded(
          flex: 4,
          child: bookStatusCustomElevatedButton(
              text: "Okudum", bookStatusName: BookStatus.alreadyRead),
        ),
        Spacer()
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
        child: Text(text,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: bookStatus == bookStatusName
                    ? Colors.white
                    : Colors.black54),
            maxLines: 2),
        style: ElevatedButton.styleFrom(
            padding: EdgeInsets.zero,
            foregroundColor:
                bookStatus == bookStatusName ? Colors.white : Color(0xFF1B7695),
            backgroundColor:
                bookStatus == bookStatusName ? Color(0xFF1B7695) : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            )));
  }

  Row bookTypeSelectionSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Spacer(),
        Expanded(
          flex: 4,
          child: bookTypeCustomElevatedButton(
              text: "Kağıt kitap", bookFormatName: BookFormat.paperBook),
        ),
        Spacer(),
        Expanded(
          flex: 4,
          child: bookTypeCustomElevatedButton(
              text: "E-kitap", bookFormatName: BookFormat.ebook),
        ),
        Spacer(),
        Expanded(
          flex: 4,
          child: bookTypeCustomElevatedButton(
              text: "Sesli kitap", bookFormatName: BookFormat.audioBook),
        ),
        Spacer()
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
        child: Text(text,
            style: TextStyle(
                color: bookFormat == bookFormatName
                    ? Colors.white
                    : Colors.black54),
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis),
        style: ElevatedButton.styleFrom(
            padding: EdgeInsets.zero,
            foregroundColor:
                bookFormat == bookFormatName ? Colors.white : Color(0xFF1B7695),
            backgroundColor:
                bookFormat == bookFormatName ? Color(0xFF1B7695) : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            )));
  }

  void modalBottomSheetBuilderForPopUpMenu(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Colors.grey.shade300,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30), topRight: Radius.circular(30))),
      context: context,
      builder: (context) {
        return Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            onTap: () {
              pickImage(ImageSource.camera);
            },
            leading: Icon(
              color: Colors.black,
              Icons.photo_camera_outlined,
              size: 30,
            ),
            title: Text("Kamera", style: TextStyle(fontSize: 20)),
          ),
          Divider(),
          ListTile(
            onTap: () => pickImage(ImageSource.gallery),
            leading: Icon(
              Icons.image_outlined,
              color: Colors.black,
              size: 30,
            ),
            title: Text("Galeri", style: TextStyle(fontSize: 20)),
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
          imageQuality: 70);
      if (image == null) {
        return;
      } else {
        final CroppedFile? croppedFile =
            await cropImage(file: image).whenComplete(() {
          Navigator.pop(context);
        });

        if (croppedFile != null) {
          if (checkImageSize(File(croppedFile.path)) < 2.0) {
            setState(() {
              pickedImage = File(croppedFile.path);
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              duration: Duration(seconds: 2),
              content: const Text("Seçtiğiniz resim 2 MB'dan küçük olmalıdır."),
              action: SnackBarAction(label: 'Tamam', onPressed: () {}),
              behavior: SnackBarBehavior.floating,
            ));
          }
        }
      }
    } on PlatformException catch (e) {
      print("Failed to pick image: $e");
    }
  }

  Future<CroppedFile?> cropImage({required XFile file}) async {
    return await ImageCropper().cropImage(
      sourcePath: file.path,
      uiSettings: [AndroidUiSettings(lockAspectRatio: false)],
    );
  }

  double checkImageSize(File image) {
    var imageSize = image.readAsBytesSync().lengthInBytes;
    print("$imageSize imageSize");
    double byte = imageSize.floorToDouble();
    print("$byte byte");

    double kilobyte = (byte / 1024.0);
    print("$kilobyte kilobyte");

    double megabyte = (kilobyte / 1024.0);
    print("$megabyte megabyte");

    return megabyte;
  }
}
