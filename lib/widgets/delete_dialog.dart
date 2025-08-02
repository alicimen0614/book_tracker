import 'package:book_tracker/const.dart';
import 'package:book_tracker/l10n/app_localizations.dart';
import 'package:book_tracker/providers/quotes_provider.dart';
import 'package:book_tracker/services/analytics_service.dart';
import 'package:book_tracker/widgets/custom_alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeleteDialog extends ConsumerStatefulWidget {
  final String quoteId;
  const DeleteDialog({super.key,required this.quoteId});

  @override
  ConsumerState<DeleteDialog> createState() => _DeleteDialogState();
}

class _DeleteDialogState extends ConsumerState<DeleteDialog> {
  @override
  Widget build(BuildContext context) {
    return CustomAlertDialog(
          title:  Const.appName,
          description: AppLocalizations.of(context)!.confirmDeleteQuote,
          thirdButtonOnPressed: () async {
            var result =
                await ref.read(quotesProvider.notifier).deleteQuote(widget.quoteId);
            if (result == true) {
              AnalyticsService()
                  .logEvent("delete_quote", {"quote_id": widget.quoteId});
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
  }
}