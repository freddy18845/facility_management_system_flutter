// Issue Details Dialog
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fms_app/components/dailog_widgets/header.dart';
import '../../components/dailog_widgets/issues_dailog_summary_data.dart';
import '../../components/time_line.dart';
import '../../providers/app_Manager.dart';
import '../../utils/app_theme.dart';
class IssueDetailsDialog extends StatelessWidget {
  final Map<String, dynamic> issue;
  final bool isArtisan;

  const IssueDetailsDialog({
    required this.issue,
    this.isArtisan = false,
  });

  String _s(dynamic v, [String fallback = '—']) {
    if (v == null) return fallback;
    return v.toString();
  }

  @override
  Widget build(BuildContext context) {
    final updates = (issue['updates'] as List?) ?? [];
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    final horizontalPadding = isMobile ? 16.0 : 24.0;
    final verticalPadding = isMobile ? 12.0 : 16.0;
    final role = AppManager().getRole();
    final images = issue['images'] as List? ?? [];
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 600,
          maxHeight: isMobile ? size.height * 0.85 : size.height * 0.65,
        ),
        decoration: BoxDecoration(
          color:Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          children: [
            // HEADER

            DialogHeader(title: 'Issue #${(issue['issueID'])}'),

            // BODY
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildDetailCard(  isMobile:isMobile, verticalPadding:verticalPadding,context:context,issue : issue),
                    SizedBox(height: verticalPadding),

                    buildDetailRow('Assign To:', issue['assignedTo'] ?? 'N/A',
                        Icons.engineering),
                    Divider(thickness: 1,color: Colors.grey.shade200,),
                    if (images.isNotEmpty) ...[
                      SizedBox(height: verticalPadding),
                      buildSectionTitle('Attached Images', Icons.photo_library),
                      SizedBox(height: verticalPadding),
                      buildImagesGrid(images,context),
                    ],
                    SizedBox(height: verticalPadding),
                    Divider(thickness: 1,color: Colors.grey.shade200,),
                    SizedBox(height: verticalPadding),
                    const Text(
                      'Progress Timeline',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    if (updates.isEmpty)
                      const Text('No updates yet'),

                    ...updates.map((update) {
                      return TimelineItem(
                        date: _s(update['date']),
                        message: _s(update['message']),
                        status: _s(update['Status'] ?? update['status']),
                        isLast: updates.last == update,
                        color: getStatusColor(
                          _s(update['Status'] ?? update['status']),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}

