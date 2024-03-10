import 'package:book_tracker/widgets/shimmer_widget.dart';
import 'package:flutter/material.dart';

Expanded authorInfoBodyShimmerBuilder(BuildContext context) {
  return Expanded(
    child: Scrollbar(
      thickness: 2,
      radius: const Radius.circular(20),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        physics: const ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Yazar Adı",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Divider(color: Colors.transparent, thickness: 0),
            ShimmerWidget.rounded(
                width: MediaQuery.sizeOf(context).width / 2,
                height: 15,
                shapeBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15))),
            const Divider(color: Colors.transparent, thickness: 0),
            const Text(
              "Biyografi",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Divider(color: Colors.transparent, thickness: 0),
            SizedBox(
              height: MediaQuery.sizeOf(context).height / 5.5,
              child: ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                separatorBuilder: (context, index) => const SizedBox(
                  height: 5,
                ),
                itemCount: 5,
                itemBuilder: (context, index) => ShimmerWidget.rounded(
                    height: 15,
                    width: MediaQuery.sizeOf(context).width - 30,
                    shapeBorder: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15))),
              ),
            ),
            Align(
                alignment: Alignment.centerRight,
                child: ShimmerWidget.rounded(
                    width: 100,
                    height: 15,
                    shapeBorder: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)))),
            const Divider(color: Colors.transparent, thickness: 0),
            const Text(
              "Yazara Ait Kitaplar",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Divider(color: Colors.transparent, thickness: 0),
            SizedBox(
              height: 150,
              child: ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  itemBuilder: (context, index) => Column(
                        children: [
                          ShimmerWidget.rounded(
                              width: 70,
                              height: 100,
                              shapeBorder: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15))),
                          const SizedBox(
                            height: 5,
                          ),
                          ShimmerWidget.rounded(
                              width: 70,
                              height: 10,
                              shapeBorder: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15))),
                          const SizedBox(
                            height: 5,
                          ),
                          ShimmerWidget.rounded(
                              width: 50,
                              height: 10,
                              shapeBorder: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15))),
                        ],
                      ),
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 20),
                  itemCount: 4),
            ),
            const Divider(color: Colors.transparent, thickness: 0),
            Align(
              alignment: Alignment.centerRight,
              child: ShimmerWidget.rounded(
                  width: MediaQuery.sizeOf(context).width / 3,
                  height: 15,
                  shapeBorder: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15))),
            )
          ],
        ),
      ),
    ),
  );
}
