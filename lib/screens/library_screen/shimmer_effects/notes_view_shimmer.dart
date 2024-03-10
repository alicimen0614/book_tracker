import 'package:book_tracker/widgets/shimmer_widget.dart';
import 'package:flutter/material.dart';

ListView notesViewShimmerEffect() {
  return ListView.separated(
    padding: const EdgeInsets.all(15),
    separatorBuilder: (context, index) => const SizedBox(
      height: 15,
    ),
    itemCount: 5,
    itemBuilder: (context, index) => ShimmerWidget.rounded(
      shapeBorder:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      width: MediaQuery.sizeOf(context).width - 30,
      height: MediaQuery.sizeOf(context).height / 6,
    ),
  );
}
