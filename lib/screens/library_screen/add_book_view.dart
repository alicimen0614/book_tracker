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
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leadingWidth: 50,
        leading: IconButton(
            tooltip: "Geri dön",
            splashRadius: 25,
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios_new,
              size: 30,
            )),
        actions: [
          IconButton(
            splashRadius: 25,
            onPressed: () async {
              if (titleFieldController.text == "") {
                ScaffoldMessenger.of(context).removeCurrentSnackBar();
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
                BookWorkEditionsModelEntries bookInfo =
                    BookWorkEditionsModelEntries(
                        covers: [1],
                        title: titleFieldController.text,
                        isbn_10: isbnFieldController.text != ""
                            ? [isbnFieldController.text]
                            : null,
                        numberOfPages: pageNumberFieldController.text != ""
                            ? int.parse(pageNumberFieldController.text)
                            : null,
                        publishers: publisherFieldController.text != ""
                            ? [publisherFieldController.text]
                            : null);
                Uint8List imageAsByte = Uint8List.fromList([]);
                if (pickedImage != null) {
                  final Uint8List imageAsByte =
                      await pickedImage!.readAsBytes();
                }

                //insert author
                if (authorFieldController.text != "") {
                  ref.read(sqlProvider).insertAuthors(
                      authorFieldController.text, uniqueIdCreater(bookInfo));
                }

                //insert book
                ref
                    .read(sqlProvider)
                    .insertBook(
                        bookInfo,
                        bookStatus == BookStatus.alreadyRead
                            ? "Okuduklarım"
                            : bookStatus == BookStatus.currentlyReading
                                ? "Şu an okuduklarım"
                                : "Okumak istediklerim",
                        pickedImage != null ? imageAsByte : null)
                    .whenComplete(() => Navigator.pop(context));

                if (ref.read(authProvider).currentUser != null) {
                  ref.read(firestoreProvider).setBookData(
                      collectionPath: "usersBooks",
                      bookAsMap: {
                        "title": titleFieldController.text,
                        "isbn_10": isbnFieldController.text != ""
                            ? [isbnFieldController.text]
                            : null,
                        "numberOfPages": pageNumberFieldController.text != ""
                            ? int.parse(pageNumberFieldController.text)
                            : null,
                        "publishers": publisherFieldController.text != ""
                            ? [publisherFieldController.text]
                            : null,
                        "covers": [1],
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
              }
            },
            icon: Icon(Icons.check_sharp, size: 30),
          )
        ],
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromRGBO(195, 129, 84, 1),
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Divider(
                thickness: 0,
                color: Colors.transparent,
              ),
              Text(
                "Kitap ekle",
                textAlign: TextAlign.left,
                style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54),
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
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5))),
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
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              Divider(
                thickness: 0,
                color: Colors.transparent,
              ),
              bookStatusSelectionSection(),
            ],
          ),
        ),
      ),
    );
  }

  Row bookStatusSelectionSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        ElevatedButton(
            onPressed: () {
              setState(() {
                bookStatus = BookStatus.wantToRead;
              });
            },
            child: Text("Okumak İstiyorum",
                style: TextStyle(
                    color: bookStatus == BookStatus.wantToRead
                        ? Colors.white
                        : Colors.black54)),
            style: ElevatedButton.styleFrom(
                foregroundColor: bookStatus == BookStatus.wantToRead
                    ? Colors.white
                    : Colors.teal,
                backgroundColor: bookStatus == BookStatus.wantToRead
                    ? Colors.teal
                    : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ))),
        ElevatedButton(
            onPressed: () {
              setState(() {
                bookStatus = BookStatus.currentlyReading;
              });
            },
            child: Text(
              "Şu an okuyorum",
              style: TextStyle(
                  color: bookStatus == BookStatus.currentlyReading
                      ? Colors.white
                      : Colors.black54),
            ),
            style: ElevatedButton.styleFrom(
                foregroundColor: bookStatus == BookStatus.currentlyReading
                    ? Colors.white
                    : Colors.teal,
                backgroundColor: bookStatus == BookStatus.currentlyReading
                    ? Colors.teal
                    : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ))),
        ElevatedButton(
            onPressed: () {
              setState(() {
                bookStatus = BookStatus.alreadyRead;
              });
            },
            child: Text("Okudum",
                style: TextStyle(
                    color: bookStatus == BookStatus.alreadyRead
                        ? Colors.white
                        : Colors.black54)),
            style: ElevatedButton.styleFrom(
                foregroundColor: bookStatus == BookStatus.alreadyRead
                    ? Colors.white
                    : Colors.teal,
                backgroundColor: bookStatus == BookStatus.alreadyRead
                    ? Colors.teal
                    : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                )))
      ],
    );
  }

  Row bookTypeSelectionSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
            onPressed: () {
              setState(() {
                bookFormat = BookFormat.paperBook;
              });
            },
            child: Text("Kağıt kitap",
                style: TextStyle(
                    color: bookFormat == BookFormat.paperBook
                        ? Colors.white
                        : Colors.black54)),
            style: ElevatedButton.styleFrom(
                foregroundColor: bookFormat == BookFormat.paperBook
                    ? Colors.white
                    : Colors.teal,
                backgroundColor: bookFormat == BookFormat.paperBook
                    ? Colors.teal
                    : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ))),
        VerticalDivider(),
        ElevatedButton(
            onPressed: () {
              setState(() {
                bookFormat = BookFormat.ebook;
              });
            },
            child: Text(
              "E-kitap",
              style: TextStyle(
                  color: bookFormat == BookFormat.ebook
                      ? Colors.white
                      : Colors.black54),
            ),
            style: ElevatedButton.styleFrom(
                foregroundColor:
                    bookFormat == BookFormat.ebook ? Colors.white : Colors.teal,
                backgroundColor:
                    bookFormat == BookFormat.ebook ? Colors.teal : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ))),
        VerticalDivider(),
        ElevatedButton(
            onPressed: () {
              setState(() {
                bookFormat = BookFormat.audioBook;
              });
            },
            child: Text("Sesli kitap",
                style: TextStyle(
                    color: bookFormat == BookFormat.audioBook
                        ? Colors.white
                        : Colors.black54)),
            style: ElevatedButton.styleFrom(
                foregroundColor: bookFormat == BookFormat.audioBook
                    ? Colors.white
                    : Colors.teal,
                backgroundColor: bookFormat == BookFormat.audioBook
                    ? Colors.teal
                    : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                )))
      ],
    );
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
