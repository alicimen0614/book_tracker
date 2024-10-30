import 'dart:async';

import 'package:book_tracker/const.dart';
import 'package:book_tracker/databases/firestore_database.dart';
import 'package:book_tracker/models/quote_model.dart';
import 'package:book_tracker/providers/quotes_state_provider.dart';
import 'package:book_tracker/screens/home_screen/detailed_quote_view.dart';
import 'package:book_tracker/screens/library_screen/books_list_view.dart';
import 'package:book_tracker/widgets/sign_up_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;

class QuotesScreen extends ConsumerStatefulWidget {
  const QuotesScreen({super.key});

  @override
  ConsumerState<QuotesScreen> createState() => _QuotesScreenState();
}

class _QuotesScreenState extends ConsumerState<QuotesScreen> {
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
    ref.read(quotesProvider.notifier).fetchTrendingQuotes();
    ref.read(quotesProvider.notifier).fetchRecentQuotes();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: 0,
      child: Scaffold(
        body: NestedScrollView(
            floatHeaderSlivers: true,
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  automaticallyImplyLeading: false,
                  leading: IconButton(
                    tooltip: "Yeni Alıntı Ekle",
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.arrow_back_sharp,
                      size: 30,
                    ),
                  ),
                  actions: [
                    IconButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const BooksListView(isNotes: false)));
                        },
                        icon: const Icon(
                          Icons.add,
                          size: 30,
                        ))
                  ],
                  expandedHeight: 150,
                  pinned: true,
                  floating: true,
                  title: const Text("Alıntılar"),
                  bottom: const TabBar(
                    tabAlignment: TabAlignment.fill,
                    unselectedLabelColor: Colors.white60,
                    indicatorColor: Colors.white,
                    labelColor: Colors.white,
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelStyle: TextStyle(
                      fontSize: 15,
                      fontFamily: "Nunito Sans",
                      fontWeight: FontWeight.bold,
                    ),
                    tabs: [
                      Tab(
                          text: "Trendler",
                          icon: Icon(Icons.trending_up_rounded)),
                      Tab(
                          text: "En Yeni",
                          icon: Icon(Icons.access_time_rounded))
                    ],
                    indicatorWeight: 5,
                  ),
                ),
              ];
            },
            body: TabBarView(
                children: [quotesBuilder(true), quotesBuilder(false)])),
      ),
    );
  }

  ListView quotesBuilder(bool isTrendingQuotes) {
    Map<String, Quote> readQuotesList = isTrendingQuotes
        ? ref.read(quotesProvider).trendingQuotes
        : ref.read(quotesProvider).recentQuotes;
    Map<String, Quote> watchQuotesList = isTrendingQuotes
        ? ref.watch(quotesProvider).trendingQuotes
        : ref.watch(quotesProvider).recentQuotes;
    bool isLoading = isTrendingQuotes
        ? ref.watch(quotesProvider).isTrendingLoading
        : ref.watch(quotesProvider).isRecentLoading;
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 10),
      separatorBuilder: (context, index) => Divider(
        color: Colors.grey.shade400,
        endIndent: 10,
        indent: 10,
        height: 20,
      ),
      itemCount: readQuotesList.length,
      itemBuilder: (context, index) {
        final quoteId = watchQuotesList.keys.toList()[index];
        int likeCount = watchQuotesList[quoteId]!.likes!.length;
        bool isUserLikedQuote = FirebaseAuth.instance.currentUser != null
            ? watchQuotesList[quoteId]!
                .likes!
                .contains(FirebaseAuth.instance.currentUser!.uid)
            : false;
        String text = readQuotesList[quoteId]!.quoteText!;
        var textHeight = calculateTextHeight(
            text,
            TextStyle(
              fontSize: MediaQuery.of(context).size.height / 55,
            ),
            Const.screenSize.width - 100);

        return isLoading == false
            ? GestureDetector(
                onDoubleTap: () {
                  likePost(quoteId, index, isTrendingQuotes);
                },
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailedQuoteView(
                          quote: readQuotesList[quoteId]!,
                          quoteId: quoteId,
                          isTrendingQuotes: isTrendingQuotes,
                        ),
                      ));
                },
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
                          readQuotesList[quoteId]!.userPicture != null
                              ? CircleAvatar(
                                  backgroundColor: Colors.grey,
                                  backgroundImage: NetworkImage(
                                      readQuotesList[quoteId]!.userPicture!),
                                )
                              : const Icon(
                                  Icons.account_circle_sharp,
                                  size: 45,
                                  color: Color(0xFF1B7695),
                                ),
                          SizedBox(
                            width: Const.minSize,
                          ),
                          Text(readQuotesList[quoteId]!.userName!,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize:
                                    MediaQuery.of(context).size.height / 50,
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
                                  fontSize:
                                      MediaQuery.of(context).size.height / 55,
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
                                  child: readQuotesList[quoteId]!.bookCover !=
                                          null
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          child: CachedNetworkImage(
                                            imageUrl:
                                                "https://covers.openlibrary.org/b/id/${readQuotesList[quoteId]!.bookCover}-M.jpg",
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
                                                        BorderRadius.circular(
                                                            15)),
                                                child: const Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    strokeAlign: -10,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        )
                                      : ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(15),
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
                                Text(readQuotesList[quoteId]!.bookName!),
                                if (readQuotesList[quoteId]!.bookAuthorName !=
                                    null)
                                  Text(readQuotesList[quoteId]!.bookAuthorName!)
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          IconButton(
                            padding: EdgeInsets.zero,
                            splashColor: Colors.black,
                            visualDensity: const VisualDensity(
                                horizontal: -4, vertical: -4),
                            icon: Icon(
                                isUserLikedQuote
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: isUserLikedQuote
                                    ? Colors.red
                                    : const Color.fromARGB(196, 0, 0, 0),
                                size: 30),
                            onPressed: () {
                              likePost(quoteId, index, isTrendingQuotes);
                            },
                          ),
                          const SizedBox(width: 8.0),
                          Text(isUserLikedQuote && likeCount != 1
                              ? "Siz ve ${likeCount - 1} diğer kişi bunu beğendi."
                              : isUserLikedQuote && likeCount == 1
                                  ? "$likeCount kişi beğendi."
                                  : isUserLikedQuote == false && likeCount == 0
                                      ? "Henüz kimse beğenmedi."
                                      : isUserLikedQuote == false &&
                                              likeCount != 0
                                          ? "$likeCount kişi bunu beğendi."
                                          : ""),
                          const Spacer(),
                          Text(
                            timeAgo(readQuotesList[quoteId]!.date),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            : const Align(
                alignment: Alignment.center,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
      },
    );
  }

  void likePost(String quoteId, int index, bool isTrendingQuotes) {
    if (FirebaseAuth.instance.currentUser != null) {
      // UI'yi anında güncelle
      updateUILikeStatus(quoteId, index, isTrendingQuotes);

      // Son beğeni durumu kaydet
      pendingLikeStatus[quoteId] = isTrendingQuotes
          ? ref
              .read(quotesProvider)
              .trendingQuotes[quoteId]!
              .likes!
              .contains(FirebaseAuth.instance.currentUser!.uid)
          : ref
              .read(quotesProvider)
              .recentQuotes[quoteId]!
              .likes!
              .contains(FirebaseAuth.instance.currentUser!.uid);

      // Eğer zaten bir zamanlayıcı varsa onu iptal et
      debounceTimers[quoteId]?.cancel();

      // Yeni bir zamanlayıcı başlat (örneğin 3 saniye sonra Firebase'e gönder)
      debounceTimers[quoteId] = Timer(const Duration(seconds: 3), () {
        FirestoreDatabase()
            .commitLikeToFirebase(quoteId, pendingLikeStatus[quoteId]);

        debounceTimers.remove(quoteId);
        pendingLikeStatus.remove(quoteId);
      });
    } else {
      showSignUpDialog();
    }
  }

  void updateUILikeStatus(String quoteId, index, bool isTrendingQuotes) {
    ref
        .read(quotesProvider.notifier)
        .updateLikedQuote(quoteId, isTrendingQuotes);
  }

  void showSignUpDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return const SignUpDialog();
      },
    );
  }
}
