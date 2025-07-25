import 'dart:async';
import 'dart:convert';

import 'package:book_tracker/const.dart';
import 'package:book_tracker/databases/firestore_database.dart';
import 'package:book_tracker/models/bookswork_editions_model.dart';
import 'package:book_tracker/providers/locale_provider.dart';
import 'package:book_tracker/providers/quotes_provider.dart';
import 'package:book_tracker/providers/riverpod_management.dart';
import 'package:book_tracker/screens/auth_screen/auth_view.dart';
import 'package:book_tracker/screens/home_screen/add_quote_screen.dart';
import 'package:book_tracker/services/analytics_service.dart';
import 'package:book_tracker/widgets/custom_alert_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:book_tracker/l10n/app_localizations.dart';

import 'package:timeago/timeago.dart' as timeago;

class DetailedQuoteView extends ConsumerStatefulWidget {
  final QuoteEntry quoteEntry;
  final bool? isTrendingQuotes;

  const DetailedQuoteView(
      {super.key, required this.quoteEntry, this.isTrendingQuotes});

  @override
  ConsumerState<DetailedQuoteView> createState() => _DetailedQuoteViewState();
}

class _DetailedQuoteViewState extends ConsumerState<DetailedQuoteView> {
  bool hasUserLikedQuote = false;
  int likeCount = 0;
  BannerAd? _banner;
  Map<String, Timer?> debounceTimers = {}; // Her post için bir zamanlayıcı
  Map<String, bool> pendingLikeStatus = {}; // Son beğeni durumu (beğeni/yok)
  String timeAgo(String? dateString) {
    if (dateString == null) return '';
    final dateTime = DateTime.parse(dateString);
    final difference = DateTime.now().difference(dateTime);
    return timeago.format(DateTime.now().subtract(difference),
        locale: ref.read(localeProvider).languageCode);
  }

  @override
  void initState() {
    _createBannerAd();
    super.initState();
  }

  @override
  void dispose() {
    if (_banner != null) {
      _banner!.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    hasUserLikedQuote = FirebaseAuth.instance.currentUser != null
        ? widget.quoteEntry.quote.likes!
                .contains(FirebaseAuth.instance.currentUser!.uid)
            ? true
            : false
        : false;
    likeCount = widget.quoteEntry.quote.likes!.length;
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.quoteDetails),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                widget.quoteEntry.quote.userPicture != null
                    ? CircleAvatar(
                        backgroundImage: NetworkImage(
                          widget.quoteEntry.quote.userPicture!,
                        ),
                        radius: 25,
                      )
                    : const Icon(
                        Icons.account_circle_sharp,
                        size: 50,
                        color: Color(0xFF1B7695),
                      ),
                const SizedBox(
                  width: 16,
                ),
                Text(
                  "${widget.quoteEntry.quote.userName}",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),const Spacer(),
                  
                    IconButton(
                        onPressed: () =>
                            modalBottomSheetBuilderForPopUpMenu(context, ref),
                        icon: const Icon(
                          Icons.more_vert_sharp,
                          color: Color(0xFF1B7695),
                        ))
              ],
            ),
            const SizedBox(height: 16.0),
            Card(
              margin: const EdgeInsets.all(0),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  widget.quoteEntry.quote.quoteText ?? '',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                widget.quoteEntry.quote.imageAsByte != null
                    ? Expanded(
                        flex: 3,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.memory(
                            height: Const.screenSize.height * 0.2,
                            fit: BoxFit.fill,
                            base64Decode(widget.quoteEntry.quote.imageAsByte!),
                            errorBuilder: (context, error, stackTrace) =>
                                Image.asset(
                              "lib/assets/images/error.png",
                            ),
                          ),
                        ),
                      )
                    : widget.quoteEntry.quote.bookCover != null
                        ? Expanded(
                            flex: 3,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: CachedNetworkImage(
                                height: Const.screenSize.height * 0.2,
                                imageUrl:
                                    "https://covers.openlibrary.org/b/id/${widget.quoteEntry.quote.bookCover!}-M.jpg",
                                fit: BoxFit.fill,
                                errorWidget: (context, error, stackTrace) {
                                  return Image.asset(
                                    "lib/assets/images/error.png",
                                    height: 120,
                                  );
                                },
                                placeholder: (context, url) {
                                  return Expanded(
                                    flex: 3,
                                    child: Container(
                                      height: Const.screenSize.height * 0.2,
                                      decoration: BoxDecoration(
                                          color: Colors.grey.shade400,
                                          borderRadius:
                                              BorderRadius.circular(15)),
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          strokeAlign: -5,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          )
                        : Expanded(
                            flex: 3,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.asset(
                                height: Const.screenSize.height * 0.2,
                                "lib/assets/images/nocover.jpg",
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                const Spacer(),
                Expanded(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        widget.quoteEntry.quote.bookName!,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      SizedBox(
                        height: Const.minSize,
                      ),
                      if (widget.quoteEntry.quote.bookAuthorName != null)
                        Text(
                          widget.quoteEntry.quote.bookAuthorName!,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        )
                    ],
                  ),
                ),
                const Spacer(),
              ],
            ),
            SizedBox(
              height: Const.minSize,
            ),
            Row(
              children: [
                IconButton(
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    switchInCurve: Curves.bounceOut,
                    switchOutCurve: Curves.easeIn,
                    transitionBuilder: (child, animation) {
                      return ScaleTransition(
                        scale: animation,
                        child: RotationTransition(
                          turns: animation,
                          child: child,
                        ),
                      );
                    },
                    child: Icon(
                        key: ValueKey<bool>(hasUserLikedQuote),
                        hasUserLikedQuote
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: hasUserLikedQuote
                            ? Colors.red
                            : const Color.fromARGB(196, 0, 0, 0),
                        size: 30),
                  ),
                  onPressed: () async {
                    await likePost(widget.quoteEntry);
                    setState(() {
                      hasUserLikedQuote;
                    });
                  },
                ),
                Text(hasUserLikedQuote && likeCount != 1
                    ? AppLocalizations.of(context)!
                        .likedByYouAndOneOther(likeCount - 1)
                    : hasUserLikedQuote && likeCount == 1
                        ? AppLocalizations.of(context)!.peopleLiked(likeCount)
                        : hasUserLikedQuote == false && likeCount == 0
                            ? AppLocalizations.of(context)!.noOneLikedYet
                            : hasUserLikedQuote == false && likeCount != 0
                                ? AppLocalizations.of(context)!
                                    .peopleLiked(likeCount)
                                : ""),
                const Spacer(),
                Text(
                  timeAgo(widget.quoteEntry.quote.date), 
                ),
              ],
            ),
            const SizedBox(
              height: 15,
            ),
            if (_banner != null)
              Center(
                child: SizedBox(
                    width: Const.screenSize.width,
                    height: Const.screenSize.height * 0.3,
                    child: Center(child: AdWidget(ad: _banner!))),
              )
          ],
        ),
      ),
    );
  }

  Future<void> likePost(QuoteEntry quoteEntry) async {
    if (FirebaseAuth.instance.currentUser != null) {
      // UI'yi anında güncelle
      updateUILikeStatus(quoteEntry.id);

      // Son beğeni durumu kaydet
      pendingLikeStatus[quoteEntry.id] = quoteEntry.quote.likes!
          .contains(FirebaseAuth.instance.currentUser!.uid);

      // Eğer zaten bir zamanlayıcı varsa onu iptal et
      debounceTimers[quoteEntry.id]?.cancel();

      // Yeni bir zamanlayıcı başlat (örneğin 3 saniye sonra Firebase'e gönder)
      debounceTimers[quoteEntry.id] =
          Timer(const Duration(seconds: 3), () {
             _commitLikeSafely(quoteEntry.id);
        pendingLikeStatus.remove(quoteEntry.id);
      });
    } else {
      showSignUpDialog();
    }
  }

  void showSignUpDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return CustomAlertDialog(
          title:  Const.appName,
          description: AppLocalizations.of(context)!.loginToLikePost,
          secondButtonOnPressed: () {
            Navigator.pop(context);
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const AuthView(formStatusData: FormStatus.register),
                ));
          },
          secondButtonText: AppLocalizations.of(context)!.signUp,
          thirdButtonOnPressed: () {
            Navigator.pop(context);
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const AuthView(formStatusData: FormStatus.signIn),
                )).then(
              (value) {
                setState(() {});
              },
            );
          },
          thirdButtonText: AppLocalizations.of(context)!.signIn,
          firstButtonOnPressed: () {
            Navigator.pop(context);
          },
          firstButtonText: AppLocalizations.of(context)!.close,
        );
      },
    );
  }

  void updateUILikeStatus(String quoteId) {
    ref
        .read(quotesProvider.notifier)
        .updateLikedQuote(quoteId, widget.isTrendingQuotes);
  }

  void _createBannerAd() {
    _banner = BannerAd(
        size: AdSize.getInlineAdaptiveBannerAdSize(
            (Const.screenSize.width*0.9).floor(),
            (Const.screenSize.height * 0.3).floor()),
        adUnitId: 'ca-app-pub-1939809254312142/9271243251',
        listener: bannerAdListener,
        request: const AdRequest())
      ..load();
  }

  final BannerAdListener bannerAdListener = BannerAdListener(
    onAdLoaded: (ad) => debugPrint("adloaded"),
    onAdFailedToLoad: (ad, error) {
      ad.dispose();
      print(error);
      debugPrint("adfailed to load");
    },
    onAdOpened: (ad) => debugPrint("ad opened"),
  );
  
   Future<void> _commitLikeSafely(String quoteId) async {
  await FirestoreDatabase().commitLikeToFirebase(
      quoteId, pendingLikeStatus[quoteId]);



  debounceTimers.remove(quoteId);
  pendingLikeStatus.remove(quoteId);
}

 void modalBottomSheetBuilderForPopUpMenu(
      BuildContext pageContext, WidgetRef ref) {
    showModalBottomSheet(
      backgroundColor: Colors.grey.shade300,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30), topRight: Radius.circular(30))),
      context: pageContext,
      builder: (context) {
        return Column(mainAxisSize: MainAxisSize.min, children: [
          if (FirebaseAuth.instance.currentUser != null && 
                      widget.quoteEntry.quote.userId == FirebaseAuth.instance.currentUser!.uid) ListTile(
            visualDensity: const VisualDensity(vertical: 3),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddQuoteScreen(
                        isNavigatingFromDetailedEdition: false,
                        quoteId: widget.quoteEntry.id,
                        quoteDate: widget.quoteEntry.quote.date ?? "",
                        initialQuoteValue: widget.quoteEntry.quote.quoteText ?? "",
                        bookImage: widget.quoteEntry.quote.imageAsByte != null
                            ? Image.memory(
                                fit: BoxFit.fill,
                                base64Decode(widget.quoteEntry.quote.imageAsByte!),
                                errorBuilder: (context, error, stackTrace) =>
                                    Image.asset(
                                  "lib/assets/images/error.png",
                                ),
                              )
                            : widget.quoteEntry.quote.bookCover != null
                                ? Image.network(
                                    "https://covers.openlibrary.org/b/id/${widget.quoteEntry.quote.bookCover}-M.jpg")
                                : null,
                        showDeleteIcon: true,
                        bookInfo: BookWorkEditionsModelEntries(
                            title: widget.quoteEntry.quote.bookName,
                            covers: widget.quoteEntry.quote.bookCover == null
                                ? null
                                : [int.tryParse(widget.quoteEntry.quote.bookCover!)],
                            authorsNames: widget.quoteEntry.quote.bookAuthorName != null
                                ? [widget.quoteEntry.quote.bookAuthorName]
                                : null)),
                  ));
            },
            leading: const Icon(
              Icons.keyboard,
              size: 30,
            ),
            title: Text(AppLocalizations.of(context)!.editQuote,
                style: const TextStyle(fontSize: 20)),
          ),
          const Divider(height: 0),
          if (FirebaseAuth.instance.currentUser != null &&
                      widget.quoteEntry.quote.userId == FirebaseAuth.instance.currentUser!.uid) ListTile(
            visualDensity: const VisualDensity(vertical: 3),
            onTap: () async {
              alertDialogBuilderForDeleting(context, ref);
            },
            leading: const Icon(
              Icons.delete,
              size: 30,
            ),
            title: Text(AppLocalizations.of(context)!.deleteQuote,
                style: const TextStyle(fontSize: 20)),
          ),
          const Divider(height: 0),
          ListTile(
            visualDensity: const VisualDensity(vertical: 3),
            onTap: () async {
              alertDialogForReporting(context, ref);
            },
            leading: const Icon(
              Icons.report_sharp,
              size: 30,
            ),
            title: Text(AppLocalizations.of(context)!.reportQuote,
                style: const TextStyle(fontSize: 20)),
          )
        ]);
      },
    );
  }

  
  Future<dynamic> alertDialogBuilderForDeleting(BuildContext context, WidgetRef ref) {
    return showDialog(
      context: context,
      builder: (context) {
        return CustomAlertDialog(
          title:  Const.appName,
          description: AppLocalizations.of(context)!.confirmDeleteQuote,
          thirdButtonOnPressed: () async {
            var result =
                await ref.read(quotesProvider.notifier).deleteQuote(widget.quoteEntry.id);
            if (result == true) {
              AnalyticsService()
                  .logEvent("delete_quote", {"quote_id": widget.quoteEntry.id});
              Navigator.pop(context);
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(
                      AppLocalizations.of(context)!.quoteSuccessfullyDeleted)));
            } else {
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content:
                      Text(AppLocalizations.of(context)!.errorDeletingQuote)));
            }
          },
          thirdButtonText: AppLocalizations.of(context)!.delete,
          firstButtonOnPressed: () {
            Navigator.pop(context);
          },
          firstButtonText: AppLocalizations.of(context)!.cancel,
        );
      },
    );
  }

Future<dynamic> alertDialogForReporting(BuildContext context, WidgetRef ref) {
  String selectedReason = ReportReason.inappropriate.value;
  TextEditingController noteController = TextEditingController();
  
  return showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: Text(AppLocalizations.of(context)!.reportQuote),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppLocalizations.of(context)!.reportQuoteDescription),
                  const SizedBox(height: 16),
                   Text(
                    AppLocalizations.of(context)!.reportReason,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  RadioListTile<String>(
                    title:  Text(ReportReason.inappropriate.getDisplayText(context)),
                    value: ReportReason.inappropriate.value,
                    groupValue: selectedReason,
                    onChanged: (value) {
                      setState(() {
                        selectedReason = value!;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: Text(ReportReason.spam.getDisplayText(context)),
                    value: ReportReason.spam.value,
                    groupValue: selectedReason,
                    onChanged: (value) {
                      setState(() {
                        selectedReason = value!;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: Text(ReportReason.copyright.getDisplayText(context)),
                    value: ReportReason.copyright.value,
                    groupValue: selectedReason,
                    onChanged: (value) {
                      setState(() {
                        selectedReason = value!;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: Text(ReportReason.misleading.getDisplayText(context)),
                    value: ReportReason.misleading.value,
                    groupValue: selectedReason,
                    onChanged: (value) {
                      setState(() {
                        selectedReason = value!;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: Text(ReportReason.other.getDisplayText(context)),
                    value: ReportReason.other.value,
                    groupValue: selectedReason,
                    onChanged: (value) {
                      setState(() {
                        selectedReason = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                   Text(
                    AppLocalizations.of(context)!.reportingNote,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: noteController,
                    decoration:  InputDecoration(
                      border: const OutlineInputBorder(),
                      hintText:  AppLocalizations.of(context)!.annotation,
                    ),
                    maxLines: 3,
                    maxLength: 200,
                  ),
                ],
              ),
            ),
            actionsAlignment: MainAxisAlignment.end,
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(AppLocalizations.of(context)!.cancel),
              ),
              TextButton(
                onPressed: () async {
                  var result = await ref.read(firestoreProvider).insertReport(
                    context,
                    reason: selectedReason,
                    note: noteController.text.trim(),
                    reporterUserId: FirebaseAuth.instance.currentUser?.uid ?? "Visitor",
                    ownerUserId: widget.quoteEntry.quote.userId ?? "",
                    quoteText: widget.quoteEntry.quote.quoteText ?? "",
                    reporterEmail: FirebaseAuth.instance.currentUser?.email ?? "Visitor",
                    quoteId: widget.quoteEntry.id,
                  );

                  if (result == true) {
                    AnalyticsService().logEvent("report_quote", {"quote_id": widget.quoteEntry.id});
                    Navigator.pop(context);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(AppLocalizations.of(context)!.quoteSuccessfullyReported),
                    ));
                  } else {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(AppLocalizations.of(context)!.errorReportingQuote),
                    ));
                  }
                },
                child: Text(AppLocalizations.of(context)!.submit),
              ),
            ],
          );
        },
      );
    },
  );
}
}
