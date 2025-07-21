import 'dart:convert';

import 'package:book_tracker/const.dart';
import 'package:book_tracker/models/bookswork_editions_model.dart';
import 'package:book_tracker/models/quote_model.dart';
import 'package:book_tracker/providers/locale_provider.dart';
import 'package:book_tracker/providers/quotes_provider.dart';
import 'package:book_tracker/providers/riverpod_management.dart';
import 'package:book_tracker/screens/home_screen/add_quote_screen.dart';
import 'package:book_tracker/screens/home_screen/detailed_quote_view.dart';
import 'package:book_tracker/services/analytics_service.dart';
import 'package:book_tracker/widgets/custom_alert_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:book_tracker/l10n/app_localizations.dart';

class QuoteWidget extends ConsumerWidget {
  final Function()? onDoubleTap;
  final Function()? onPressedLikeButton;
  final Quote quote;
  final String quoteId;
  final bool? isTrendingQuotes;
  const QuoteWidget(
      {super.key,
      this.isTrendingQuotes,
      required this.onDoubleTap,
      required this.quote,
      required this.quoteId,
      required this.onPressedLikeButton});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    int likeCount = isTrendingQuotes != null
        ? isTrendingQuotes!
            ? quote.likes!.length
            : quote.likes!.length
        : FirebaseAuth.instance.currentUser != null
            ? quote.likes!.length
            : 0;
    bool isUserLikedQuote = FirebaseAuth.instance.currentUser != null
        ? isTrendingQuotes != null
            ? isTrendingQuotes!
                ? quote.likes!.contains(FirebaseAuth.instance.currentUser!.uid)
                : quote.likes!.contains(FirebaseAuth.instance.currentUser!.uid)
            : quote.likes!.contains(FirebaseAuth.instance.currentUser!.uid)
                ? true
                : false
        : false;
    String text = quote.quoteText!;
    var textHeight = calculateTextHeight(
        text,
        TextStyle(
          fontSize: MediaQuery.of(context).size.height / 55,
        ),
        Const.screenSize.width - 100);
    return GestureDetector(
      onDoubleTap: onDoubleTap,
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailedQuoteView(
                quoteEntry: QuoteEntry(id: quoteId, quote: quote),
                isTrendingQuotes: isTrendingQuotes,
              ),
            ));
        AnalyticsService().logEvent("click_quote", {"quote_id": quoteId});
      },
      child: Container(
        color: Colors.transparent,
        child: Column(
          children: [
            SizedBox(
              height: Const.minSize,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
              ),
              child: Row(
                children: [
                  quote.userPicture != null
                      ? CircleAvatar(
                          backgroundColor: Colors.grey,
                          backgroundImage: NetworkImage(quote.userPicture!),
                        )
                      : const Icon(
                          Icons.account_circle_sharp,
                          size: 45,
                          color: Color(0xFF1B7695),
                        ),
                  SizedBox(
                    width: Const.minSize,
                  ),
                  Text(quote.userName!,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: MediaQuery.of(context).size.height / 50,
                      )),
                  const Spacer(),
                  
                    IconButton(
                        onPressed: () =>
                            modalBottomSheetBuilderForPopUpMenu(context, ref),
                        icon: const Icon(
                          Icons.more_vert_sharp,
                          color: Color(0xFF1B7695),
                        ))
                ],
              ),
            ),
            SizedBox(
              height: Const.minSize,
            ),
            Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 10),
                    child: Text(
                      text,
                      style: TextStyle(
                          fontSize: MediaQuery.of(context).size.height / 55,
                          fontWeight: FontWeight.w700),
                      maxLines: 7,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (textHeight > 85)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.more,
                        style: const TextStyle(
                            color: Color(0xFF1B7695),
                            fontWeight: FontWeight.w700),
                        textAlign: TextAlign.end,
                      ),
                    )
                ],
              ),
            ),
            SizedBox(
              height: Const.minSize,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: Const.screenSize.height * 0.15,
                      child: Container(
                          child: quote.imageAsByte != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.memory(
                                    fit: BoxFit.fill,
                                    base64Decode(quote.imageAsByte!),
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Image.asset(
                                      "lib/assets/images/error.png",
                                    ),
                                  ),
                                )
                              : quote.bookCover != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(15),
                                      child: CachedNetworkImage(
                                        imageUrl:
                                            "https://covers.openlibrary.org/b/id/${quote.bookCover}-M.jpg",
                                        fit: BoxFit.fill,
                                        errorWidget:
                                            (context, error, stackTrace) {
                                          return Image.asset(
                                            "lib/assets/images/error.png",
                                            height: 80,
                                            width: 50,
                                          );
                                        },
                                        placeholder: (context, url) {
                                          return Container(
                                            decoration: BoxDecoration(
                                                color: Colors.grey.shade400,
                                                borderRadius:
                                                    BorderRadius.circular(15)),
                                            child: const Center(
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                strokeAlign: -10,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    )
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(15),
                                      child: Image.asset(
                                        "lib/assets/images/nocover.jpg",
                                        fit: BoxFit.fill,
                                      ),
                                    )),
                    ),
                  ),
                  const Spacer(),
                  Expanded(
                    flex: 4,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(quote.bookName!,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500)),
                        SizedBox(
                          height: Const.minSize,
                        ),
                        if (quote.bookAuthorName != null)
                          Text(quote.bookAuthorName!,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold))
                      ],
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
            SizedBox(
              height: Const.minSize,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    splashColor: Colors.black,
                    visualDensity:
                        const VisualDensity(horizontal: -4, vertical: -4),
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
                          key: ValueKey<bool>(isUserLikedQuote),
                          isUserLikedQuote
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: isUserLikedQuote
                              ? Colors.red
                              : const Color.fromARGB(196, 0, 0, 0),
                          size: 30),
                    ),
                    onPressed: onPressedLikeButton,
                  ),
                  const SizedBox(width: 8.0),
                  Text(isUserLikedQuote && likeCount != 1
                      ? AppLocalizations.of(context)!
                          .likedByYouAndOneOther(likeCount - 1)
                      : isUserLikedQuote && likeCount == 1
                          ? AppLocalizations.of(context)!.peopleLiked(likeCount)
                          : isUserLikedQuote == false && likeCount == 0
                              ? AppLocalizations.of(context)!.noOneLikedYet
                              : isUserLikedQuote == false && likeCount != 0
                                  ? AppLocalizations.of(context)!
                                      .peopleLiked(likeCount)
                                  : ""),
                  const Spacer(),
                  Text(
                    timeAgo(quote.date, ref),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String timeAgo(String? dateString, WidgetRef ref) {
    /* timeago.setLocaleMessages('tr', timeago.TrMessages()); */
    if (dateString == null) return '';
    final dateTime = DateTime.parse(dateString);
    final difference = DateTime.now().difference(dateTime);
    return timeago.format(DateTime.now().subtract(difference),
        locale: ref.read(localeProvider).languageCode);
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
                      quote.userId == FirebaseAuth.instance.currentUser!.uid) ListTile(
            visualDensity: const VisualDensity(vertical: 3),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddQuoteScreen(
                        isNavigatingFromDetailedEdition: false,
                        quoteId: quoteId,
                        quoteDate: quote.date ?? "",
                        initialQuoteValue: quote.quoteText ?? "",
                        bookImage: quote.imageAsByte != null
                            ? Image.memory(
                                fit: BoxFit.fill,
                                base64Decode(quote.imageAsByte!),
                                errorBuilder: (context, error, stackTrace) =>
                                    Image.asset(
                                  "lib/assets/images/error.png",
                                ),
                              )
                            : quote.bookCover != null
                                ? Image.network(
                                    "https://covers.openlibrary.org/b/id/${quote.bookCover}-M.jpg")
                                : null,
                        showDeleteIcon: true,
                        bookInfo: BookWorkEditionsModelEntries(
                            title: quote.bookName,
                            covers: quote.bookCover == null
                                ? null
                                : [int.tryParse(quote.bookCover!)],
                            authorsNames: quote.bookAuthorName != null
                                ? [quote.bookAuthorName]
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
                      quote.userId == FirebaseAuth.instance.currentUser!.uid) ListTile(
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
          title: "VastReads",
          description: AppLocalizations.of(context)!.confirmDeleteQuote,
          thirdButtonOnPressed: () async {
            var result =
                await ref.read(quotesProvider.notifier).deleteQuote(quoteId);
            if (result == true) {
              AnalyticsService()
                  .logEvent("delete_quote", {"quote_id": quoteId});
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
                    ownerUserId: quote.userId ?? "",
                    quoteText: quote.quoteText ?? "",
                    reporterEmail: FirebaseAuth.instance.currentUser?.email ?? "Visitor",
                    quoteId: quoteId,
                  );

                  if (result == true) {
                    AnalyticsService().logEvent("report_quote", {"quote_id": quoteId});
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
