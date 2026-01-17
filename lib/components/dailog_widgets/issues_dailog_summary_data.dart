import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../screens/dailogs/image_viewer_dailog.dart';
import '../../utils/app_theme.dart';

Widget buildDetailCard({required bool isMobile, required double verticalPadding,context,required  Map<String, dynamic> issue} ) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade300),
    ),
    child: Column(
      children: [
        buildDetailRow('Tenant Name', issue['tenant'] ?? 'N/A',
            Icons.person),
        const Divider(),
        buildDetailRow('Contact', issue['contact'] ?? 'N/A',
            Icons.phone),
        const Divider(),
        buildDetailRow('Apartment', issue['apartment'] ?? 'N/A',
            Icons.apartment),
        const Divider(),
        buildDetailRow('Room Number', issue['room'] ?? 'N/A',
            Icons.meeting_room),
        const Divider(),
        buildDetailRow('Issue Type', issue['issuetype'] ?? 'N/A',
            Icons.warning_amber),
        const Divider(),
        buildDetailRow('Priority', issue['priority'] ?? 'N/A',
            Icons.priority_high,
            valueColor: getPriorityColor(issue['priority'])),
        const Divider(),
        buildDetailRow('Reported Date',
            issue['reportedDate'] ?? 'N/A', Icons.calendar_today),
        const Divider(),
        _buildDescriptionRow('Description',
            issue['Description'] ?? 'No description record yet'),
      ],
    ),
  );
}

Widget buildDetailRow(String label, String value, IconData icon,
    {Color? valueColor}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: valueColor ?? Colors.grey.shade700,
              fontWeight:
              valueColor != null ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ],
    ),
  );
}
Widget _buildDescriptionRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(top: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.description, size: 18, color: Colors.grey.shade600),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade900,
          ),
        ),
      ],
    ),
  );
}


Widget buildSectionTitle(String title, IconData icon) {
  return Row(
    children: [
      Icon(icon, size: 20, color: Colors.grey.shade700),
      const SizedBox(width: 8),
      Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade700,
        ),
      ),
    ],
  );
}

String _formatDate(DateTime? date) {
  if (date == null) return 'Not selected';
  return '${date.day}/${date.month}/${date.year}';
}
Widget buildDateSelector({
  required String label,
  required DateTime? date,
  required VoidCallback onTap,
  required IconData icon,
}) {
  return InkWell(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _formatDate(date),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: date != null ? Colors.black87 : Colors.grey.shade400,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget buildImagesGrid(List images, BuildContext context) {
  return Wrap(
    spacing: 8,
    runSpacing: 8,
    children: images.asMap().entries.map((entry) {
      final index = entry.key;
      final image = entry.value;
      final imageUrl = image['url']?.toString() ?? '';

      debugPrint('🖼️ Loading image: $imageUrl');

      return GestureDetector(
        onTap: () => showImageViewer(images, index,context),
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300, width: 2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Stack(
              children: [
                Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  width: 100,
                  height: 100,
                  headers: const {
                    'Accept': 'image/*',
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: SizedBox(
                        width: 30,
                        height: 30,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    debugPrint('❌ Image load error: $error');
                    debugPrint('❌ URL: $imageUrl');
                    return Container(
                      color: Colors.grey.shade200,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.broken_image,
                              color: Colors.grey.shade400, size: 32),
                          const SizedBox(height: 4),
                          Text(
                            'Failed',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                // Image type badge
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      image['type']?.toString().toUpperCase() ?? 'IMAGE',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }).toList(),
  );
}
void showError(String message,BuildContext context) {
  showCustomSnackBar(context, message, color: Colors.red);
}

void showImageViewer(List images, int initialIndex, BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => ImageViewerDialog(
      images: images,
      initialIndex: initialIndex,
    ),
  );
}