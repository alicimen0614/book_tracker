import 'package:book_tracker/const.dart';
import 'package:book_tracker/l10n/app_localizations.dart';
import 'package:book_tracker/providers/quotes_provider.dart';
import 'package:book_tracker/providers/riverpod_management.dart';
import 'package:book_tracker/services/analytics_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReportingDialog extends ConsumerStatefulWidget {
  final QuoteEntry quoteEntry;
  
  const ReportingDialog({super.key,required this.quoteEntry});

  @override
  ConsumerState<ReportingDialog> createState() => _ReportingDialogState();
}

class _ReportingDialogState extends ConsumerState<ReportingDialog> {
  String selectedReason = ReportReason.inappropriate.value;
  TextEditingController noteController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return 
           AlertDialog(
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
  }
}