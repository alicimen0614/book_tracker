import 'package:flutter/material.dart';

class AlertForDataSource extends StatelessWidget {
  const AlertForDataSource({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            centerTitle: true,
            title: const FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                "Uygulama Veri Kaynağı Hakkında",
              ),
            )),
        body: const SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(15),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("Uygulama Veri Kaynağı ve Sorumluluk Bildirimi:"),
              SizedBox(
                height: 20,
              ),
              Text(
                  "Bu uygulama, kitap bilgilerini OpenLibrary API'sini kullanarak almakta olup, bu veriler OpenLibrary topluluğu tarafından sağlanmaktadır. OpenLibrary, geniş bir kullanıcı kitlesi tarafından desteklenen bir platformdur ve herkesin kitap bilgilerini düzenleme yeteneğine sahiptir."),
              SizedBox(
                height: 20,
              ),
              Text("Kullanıcı Sorumluluğu:"),
              SizedBox(
                height: 20,
              ),
              Text(
                  "Uygulamamızdaki kitap bilgilerinin doğruluğu ve güncelliği Open Library kullanıcıları tarafından sağlanmaktadır. Lütfen unutmayın ki uygulamamızın geliştiricileri, kitap bilgilerini değiştirme veya güncelleme yetkisine sahip değillerdir. Herhangi bir hata, eksik bilgi, uygunsuz görüntü veya yanlışlık durumunda, ilgili kitap bilgisini Open Library platformunda düzeltebilir veya güncelleyebilirsiniz. Bu uyarı, uygulamamızdaki kitap bilgilerinin sorumluluğunun Open Library ve kullanıcıları arasında paylaşıldığını göstermektedir. Teşekkür ederiz.")
            ]),
          ),
        ));
  }
}
