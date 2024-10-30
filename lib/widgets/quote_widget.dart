import 'package:book_tracker/const.dart';
import 'package:book_tracker/models/quote_model.dart';
import 'package:book_tracker/providers/quotes_state_provider.dart';
import 'package:book_tracker/screens/home_screen/detailed_quote_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;

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
    int likeCount = FirebaseAuth.instance.currentUser != null &&
            isTrendingQuotes != null
        ? isTrendingQuotes!
            ? ref.watch(quotesProvider).trendingQuotes[quoteId]!.likes!.length
            : ref.watch(quotesProvider).recentQuotes[quoteId]!.likes!.length
        : ref.watch(quotesProvider).currentUsersQuotes[quoteId]!.likes!.length;
    bool isUserLikedQuote =
        FirebaseAuth.instance.currentUser != null && isTrendingQuotes != null
            ? isTrendingQuotes!
                ? ref
                    .watch(quotesProvider)
                    .trendingQuotes[quoteId]!
                    .likes!
                    .contains(FirebaseAuth.instance.currentUser!.uid)
                : ref
                    .watch(quotesProvider)
                    .recentQuotes[quoteId]!
                    .likes!
                    .contains(FirebaseAuth.instance.currentUser!.uid)
            : ref
                    .watch(quotesProvider)
                    .currentUsersQuotes[quoteId]!
                    .likes!
                    .contains(FirebaseAuth.instance.currentUser!.uid)
                ? true
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
                quote: quote,
                quoteId: quoteId,
                isTrendingQuotes: isTrendingQuotes,
              ),
            ));
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
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 15,
                      ),
                      child: Text(
                        "Daha fazla",
                        style: TextStyle(
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
                    flex: 8,
                    child: SizedBox(
                      height: Const.screenSize.height * 0.15,
                      child: Container(
                          child: quote.bookCover != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: CachedNetworkImage(
                                    imageUrl:
                                        "https://covers.openlibrary.org/b/id/${quote.bookCover}-M.jpg",
                                    fit: BoxFit.fill,
                                    errorWidget: (context, error, stackTrace) {
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
                    flex: 10,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(quote.bookName!),
                        if (quote.bookAuthorName != null)
                          Text(quote.bookAuthorName!)
                      ],
                    ),
                  ),
                  const Spacer(
                    flex: 20,
                  )
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
                    icon: Icon(
                        isUserLikedQuote
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: isUserLikedQuote
                            ? Colors.red
                            : const Color.fromARGB(196, 0, 0, 0),
                        size: 30),
                    onPressed: onPressedLikeButton,
                  ),
                  const SizedBox(width: 8.0),
                  Text(isUserLikedQuote && likeCount != 1
                      ? "Siz ve ${likeCount - 1} diğer kişi bunu beğendi."
                      : isUserLikedQuote && likeCount == 1
                          ? "$likeCount kişi beğendi."
                          : isUserLikedQuote == false && likeCount == 0
                              ? "Henüz kimse beğenmedi."
                              : isUserLikedQuote == false && likeCount != 0
                                  ? "$likeCount kişi bunu beğendi."
                                  : ""),
                  const Spacer(),
                  Text(
                    timeAgo(quote.date),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String timeAgo(String? dateString) {
    timeago.setLocaleMessages('tr', timeago.TrMessages());
    if (dateString == null) return '';
    final dateTime = DateTime.parse(dateString);
    final difference = DateTime.now().difference(dateTime);
    return timeago.format(DateTime.now().subtract(difference), locale: 'tr');
  }
}
