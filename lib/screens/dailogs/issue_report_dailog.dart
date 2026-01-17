import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fms_app/components/dailog_widgets/bottom_bar.dart';
import 'package:image_picker/image_picker.dart';
import '../../components/dailog_widgets/header.dart';
import '../../widgets/btn.dart';
import '../../widgets/textform.dart';

class ReportIssueDialog extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController issueTypeController;
  final TextEditingController descriptionController;
  final TextEditingController locationController;
  final String selectedPriority;
  final List<XFile> images;
  final Future<void> Function() onPickImages;
  final Future<void> Function() onTakePhoto;
  final Function(int) onRemoveImage;
  final Function(String) onPriorityChanged;
  final VoidCallback onSubmit;
  final bool isSubmitting;
  final double uploadProgress;

  const ReportIssueDialog({
    super.key,
    required this.formKey,
    required this.issueTypeController,
    required this.descriptionController,
    required this.locationController,
    required this.selectedPriority,
    required this.onPriorityChanged,
    required this.onSubmit,
    required this.images,
    required this.onTakePhoto,
    required this.onRemoveImage,
    required this.onPickImages,
    required this.isSubmitting,
    required this.uploadProgress,
  });

  @override
  State<ReportIssueDialog> createState() => ReportIssueDialogState();
}

class ReportIssueDialogState extends State<ReportIssueDialog> {
  late String _localPriority;

  @override
  void initState() {
    super.initState();
    _localPriority = widget.selectedPriority;
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Choose from Gallery'),
            onTap: () async {
              Navigator.pop(context);
              await widget.onPickImages();
              setState(() {}); // Force rebuild
            },
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Take Photo'),
            onTap: () async {
              Navigator.pop(context);
              await widget.onTakePhoto();
              setState(() {}); // Force rebuild
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 40,
        vertical: isMobile ? 24 : 40,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 600,
          maxHeight: isMobile ? size.height * 0.85 : size.height * 0.75,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
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
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            DialogHeader(title: 'Report New Issue'),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: widget.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fill in the details below to report an issue',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 24),

                      buildField(
                        controller: widget.issueTypeController,
                        label: 'Issue Type',
                        icon: Icons.category_outlined,
                        onChangeAction: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter issue type';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      buildField(
                        controller: widget.locationController,
                        label: 'Location (e.g., Kitchen, Bathroom)',
                        icon: Icons.location_on_outlined,
                        onChangeAction: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter location';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      const Text(
                        'Priority Level',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          PriorityChip(
                            label: 'LOW',
                            color: Colors.green,
                            isSelected: _localPriority == 'low',
                            onTap: widget.isSubmitting
                                ? () {}
                                : () {
                              setState(() {
                                _localPriority = 'low';
                              });
                              widget.onPriorityChanged('low');
                            },
                          ),
                          const SizedBox(width: 8),
                          PriorityChip(
                            label: 'MEDIUM',
                            color: Colors.orange,
                            isSelected: _localPriority == 'medium',
                            onTap: widget.isSubmitting
                                ? () {}
                                : () {
                              setState(() {
                                _localPriority = 'medium';
                              });
                              widget.onPriorityChanged('medium');
                            },
                          ),
                          const SizedBox(width: 8),
                          PriorityChip(
                            label: 'HIGH',
                            color: Colors.red,
                            isSelected: _localPriority == 'high',
                            onTap: widget.isSubmitting
                                ? () {}
                                : () {
                              setState(() {
                                _localPriority = 'high';
                              });
                              widget.onPriorityChanged('high');
                            },
                          ),

                        ],
                      ),
                      const SizedBox(height: 16),

                      buildField(
                        controller: widget.descriptionController,
                        label: 'Description',
                        icon: Icons.description_outlined,
                        newMaxLines: 5,
                        onChangeAction: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter description';
                          }
                          if (value.trim().length < 10) {
                            return 'Description must be at least 10 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Image Upload Section
                      const Text(
                        'Add Photos (Optional)',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add up to 5 photos to help us understand the issue better',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Images Grid
                      if (widget.images.isNotEmpty)
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            ...widget.images.asMap().entries.map((entry) {
                              return ImagePreview(
                                image: entry.value,
                                onRemove: widget.isSubmitting
                                    ? () {}
                                    : () {
                                  widget.onRemoveImage(entry.key);
                                  setState(() {}); // Rebuild after delete
                                },
                              );
                            }),
                            if (widget.images.length < 5)
                              _AddImageButton(
                                onTap: widget.isSubmitting
                                    ? () {}
                                    : _showImageOptions,
                              ),
                          ],
                        )
                      else
                        _AddImageButton(
                          onTap: widget.isSubmitting
                              ? () {}
                              : _showImageOptions,
                        ),

                      const SizedBox(height: 16),

                      // Progress Indicator
                      if (widget.isSubmitting)
                        Column(
                          children: [
                            LinearProgressIndicator(
                              value: widget.uploadProgress > 0
                                  ? widget.uploadProgress
                                  : null,
                              backgroundColor: Colors.grey.shade200,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.blue,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.uploadProgress > 0
                                  ? 'Uploading... ${(widget.uploadProgress * 100).toStringAsFixed(0)}%'
                                  : 'Submitting issue...',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // Footer Buttons
            DialogBottomNavigator(child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomButton(
                  text: 'Cancel',
                  icon: Icons.close,
                  color: Colors.red,
                  onPressed: widget.isSubmitting
                      ? null
                      : () => Navigator.pop(context),
                ),
                CustomButton(
                  text: widget.isSubmitting ? 'Submitting...' : 'Submit Report',
                  icon: Icons.send,
                  isShowIcon: !widget.isSubmitting,
                  color: Colors.blue,
                  onPressed: widget.isSubmitting ? null : widget.onSubmit,
                ),
              ],
            ))

          ],
        ),
      ),
    );
  }
}

// Image Preview Widget
class ImagePreview extends StatelessWidget {
  final XFile image;
  final VoidCallback onRemove;

  const ImagePreview({
    super.key,
    required this.image,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
            image: DecorationImage(
              image: FileImage(File(image.path)),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: -8,
          right: -8,
          child: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 16,
              ),
            ),
            onPressed: onRemove,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ),
      ],
    );
  }
}

// Add Image Button Widget
class _AddImageButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddImageButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.grey.shade300,
            style: BorderStyle.solid,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate,
              color: Colors.grey.shade600,
              size: 32,
            ),
            const SizedBox(height: 4),
            Text(
              'Add Photo',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Priority Chip Widget
class PriorityChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const PriorityChip({
    super.key,
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          border: Border.all(color: color, width: 2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : color,
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}