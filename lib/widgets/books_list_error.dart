import 'package:flutter/material.dart';

@override
Center booksListError(
  bool isNetworkError,
  BuildContext context,
  VoidCallback? onTryAgain, {
  String title = 'Bir şeyler yanlış gitti.',
  String? message = 'Uygulama bilinmeyen bir hatayla karşılaştı.\n'
      'Lütfen daha sonra tekrar deneyin.',
}) {
  if (isNetworkError == true) {
    title = "İnternete bağlanılamadı";
    message = "Lütfen internet bağlantınızı kontrol edip tekrar deneyiniz.";
  }

  return Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      child: Column(
        children: [
          isNetworkError == true
              ? Image.asset(
                  "lib/assets/images/no_internet_connection.png",
                  width: MediaQuery.of(context).size.width / 1.2,
                )
              : SizedBox.shrink(),
          isNetworkError == true
              ? SizedBox(
                  height: 15,
                )
              : SizedBox.shrink(),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          if (message != null)
            const SizedBox(
              height: 16,
            ),
          if (message != null)
            Text(
              message,
              textAlign: TextAlign.center,
            ),
          if (onTryAgain != null)
            const SizedBox(
              height: 48,
            ),
          if (onTryAgain != null)
            SizedBox(
              height: 50,
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white),
                onPressed: onTryAgain,
                icon: const Icon(
                  Icons.refresh,
                  color: Colors.white,
                ),
                label: const Text(
                  'Tekrar dene',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    ),
  );
}
