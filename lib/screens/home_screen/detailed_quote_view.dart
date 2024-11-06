import 'dart:async';
import 'dart:convert';

import 'package:book_tracker/const.dart';
import 'package:book_tracker/databases/firestore_database.dart';
import 'package:book_tracker/providers/quotes_state_provider.dart';
import 'package:book_tracker/widgets/sign_up_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:timeago/timeago.dart' as timeago;
import '../../models/quote_model.dart';

class DetailedQuoteView extends ConsumerStatefulWidget {
  final Quote quote;
  final String quoteId;
  final bool? isTrendingQuotes;

  const DetailedQuoteView(
      {super.key,
      required this.quote,
      required this.quoteId,
      this.isTrendingQuotes});

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
    timeago.setLocaleMessages('tr', timeago.TrMessages());
    if (dateString == null) return '';
    final dateTime = DateTime.parse(dateString);
    final difference = DateTime.now().difference(dateTime);
    return timeago.format(DateTime.now().subtract(difference), locale: 'tr');
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
        ? widget.isTrendingQuotes != null
            ? widget.isTrendingQuotes!
                ? ref
                    .watch(quotesProvider)
                    .trendingQuotes[widget.quoteId]!
                    .likes!
                    .contains(FirebaseAuth.instance.currentUser!.uid)
                : ref
                    .watch(quotesProvider)
                    .recentQuotes[widget.quoteId]!
                    .likes!
                    .contains(FirebaseAuth.instance.currentUser!.uid)
            : ref
                    .watch(quotesProvider)
                    .currentUsersQuotes[widget.quoteId]!
                    .likes!
                    .contains(FirebaseAuth.instance.currentUser!.uid)
                ? true
                : false
        : false;
    likeCount = widget.quote.likes!.length;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alıntı Detayı'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                widget.quote.userPicture != null
                    ? CircleAvatar(
                        backgroundImage: NetworkImage(
                          widget.quote.userPicture!,
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
                  "${widget.quote.userName}",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                )
              ],
            ),
            const SizedBox(height: 16.0),
            Card(
              margin: const EdgeInsets.all(0),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  widget.quote.quoteText ?? '',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  flex: 4,
                  child: widget.quote.imageAsByte != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.memory(
                            fit: BoxFit.fill,
                            base64Decode(widget.quote.imageAsByte!),
                            errorBuilder: (context, error, stackTrace) =>
                                Image.asset(
                              "lib/assets/images/error.png",
                            ),
                          ),
                        )
                      : widget.quote.bookCover != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: CachedNetworkImage(
                                imageUrl:
                                    "https://covers.openlibrary.org/b/id/${widget.quote.bookCover!}-M.jpg",
                                fit: BoxFit.fill,
                                errorWidget: (context, error, stackTrace) {
                                  return Image.asset(
                                    "lib/assets/images/error.png",
                                    height: 120,
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
                                        strokeAlign: -5,
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
                            ),
                ),
                const Spacer(),
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      Text(
                        widget.quote.bookName!,
                        style: const TextStyle(fontSize: 16),
                      ),
                      if (widget.quote.bookAuthorName != null)
                        Text(
                          widget.quote.bookAuthorName!,
                          style: const TextStyle(fontSize: 16),
                        )
                    ],
                  ),
                ),
                const Spacer(
                  flex: 10,
                )
              ],
            ),
            SizedBox(
              height: Const.minSize,
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(
                      hasUserLikedQuote
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: hasUserLikedQuote
                          ? Colors.red
                          : const Color.fromARGB(196, 0, 0, 0),
                      size: 30),
                  onPressed: () async {
                    await likePost(widget.quoteId);
                  },
                ),
                Spacer(),
                Text(hasUserLikedQuote && likeCount != 1
                    ? "Siz ve ${(likeCount - 1)} diğer kişi bunu beğendi."
                    : hasUserLikedQuote && likeCount == 1
                        ? "$likeCount kişi beğendi."
                        : hasUserLikedQuote == false && likeCount == 0
                            ? "Henüz kimse beğenmedi."
                            : hasUserLikedQuote == false && likeCount != 0
                                ? "$likeCount kişi bunu beğendi."
                                : ""),
                const Spacer(
                  flex: 5,
                ),
                Text(
                  timeAgo(widget.quote.date),
                ),
              ],
            ),
            const SizedBox(
              height: 15,
            ),
            if (_banner != null)
              Center(
                child: Container(
                    width: Const.screenSize.width,
                    height: Const.screenSize.height.floor() * 0.4,
                    child: AdWidget(ad: _banner!)),
              )
          ],
        ),
      ),
    );
  }

  Future<void> likePost(String quoteId) async {
    if (FirebaseAuth.instance.currentUser != null) {
      // UI'yi anında güncelle
      updateUILikeStatus(quoteId);

      // Son beğeni durumu kaydet
      pendingLikeStatus[quoteId] = widget.isTrendingQuotes != null
          ? widget.isTrendingQuotes == true
              ? ref
                  .read(quotesProvider)
                  .trendingQuotes[quoteId]!
                  .likes!
                  .contains(FirebaseAuth.instance.currentUser!.uid)
              : ref
                  .read(quotesProvider)
                  .recentQuotes[quoteId]!
                  .likes!
                  .contains(FirebaseAuth.instance.currentUser!.uid)
          : ref
              .read(quotesProvider)
              .currentUsersQuotes[quoteId]!
              .likes!
              .contains(FirebaseAuth.instance.currentUser!.uid);

      // Eğer zaten bir zamanlayıcı varsa onu iptal et
      debounceTimers[quoteId]?.cancel();

      // Yeni bir zamanlayıcı başlat (örneğin 3 saniye sonra Firebase'e gönder)
      debounceTimers[quoteId] = Timer(const Duration(seconds: 3), () async {
        await FirestoreDatabase()
            .commitLikeToFirebase(quoteId, pendingLikeStatus[quoteId], context);

        debounceTimers.remove(quoteId);
        pendingLikeStatus.remove(quoteId);
      });
    } else {
      showSignUpDialog();
    }
  }

  void showSignUpDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return const SignUpDialog();
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
            Const.screenSize.width.floor() - 50,
            Const.screenSize.height.floor() * 0.3.ceil()),
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
}
