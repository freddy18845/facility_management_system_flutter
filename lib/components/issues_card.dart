import 'package:flutter/material.dart';
import '../screens/dailogs/comment_dailog.dart';
import '../utils/api_service.dart';
import '../utils/app_theme.dart';
import '../widgets/loading.dart';
import '../widgets/textform.dart';

class IssueCard extends StatefulWidget {
  final Map<String, dynamic> issue;
  final VoidCallback onTap;
  final VoidCallback onRefresh;
  final bool isArtisan;
  final bool isTablet;

  const IssueCard({
    super.key,
    required this.issue,
    required this.onTap,
    this.isArtisan = false,
    required this.isTablet,
    required this.onRefresh,
  });

  @override
  State<IssueCard> createState() => _IssueCardState();
}

class _IssueCardState extends State<IssueCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  TextEditingController _messageController = TextEditingController();
  bool isShowButton = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    setState(() {
      if (!widget.isArtisan) {
        isShowButton =
            widget.issue['status'] == "Cancelled" ||
            widget.issue['status'] == "Completed" ||
            widget.issue['status'] == "Pending";
      } else {
        isShowButton =
            widget.issue['status'] == "Cancelled" ||
            widget.issue['status'] == "Completed";
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getPriorityColor() {
    return getPriorityColor(widget.issue['priority']);
  }

  Color _getStatusColor() {
    return getStatusColor(widget.issue['status']);
  }

  IconData _getPriorityIcon() {
    switch (widget.issue['priority']?.toLowerCase()) {
      case 'high':
        return Icons.priority_high_rounded;
      case 'medium':
        return Icons.remove_circle_outline_rounded;
      case 'low':
        return Icons.arrow_downward_rounded;
      default:
        return Icons.flag_rounded;
    }
  }

  IconData _getStatusIcon() {
    switch (widget.issue['status']?.toLowerCase()) {
      case 'Pending':
        return Icons.schedule_rounded;
      case 'In_progress':
        return Icons.autorenew_rounded;
      case 'Completed':
        return Icons.check_circle_rounded;
      case 'Cancelled':
        return Icons.cancel_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  Future<void> submit() async {
    try {
      // Show loading if your ApiService doesn't do it automatically
      if (!mounted) return;
      LoadingScreen.show(context);

      final response = await ApiService().post(
        'issues/${widget.issue['id']}/update',
        {
          "update_message": _messageController.text.trim(),
          "progress": widget.isArtisan ? 70 : 100,
          "status": widget.isArtisan ? "in_progress" : "completed",
        },
        context,
        true,
      );
      if (!mounted) return;
      LoadingScreen.hide(context);
      // 1. Check if response is valid
      if (response != null &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        if (mounted) {
          showCustomSnackBar(
            context,
            'Updated successfully',
            color: Colors.green,
          );
          widget.onRefresh();

          // 3. SAFE POP: Only pop if there is actually a route to pop back to
          if (Navigator.of(context).canPop()) {
            // This returns 'true' to the parent screen so it can refresh the list
            Navigator.of(context).pop(true);
          }
        }
      }
    } catch (e) {
      if (!mounted) return;
      LoadingScreen.hide(context);
      debugPrint("Submit Error: $e");
      // Handle error...
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _getPriorityColor().withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: widget.onTap,
            onTapDown: (_) => _controller.forward(),
            onTapUp: (_) => _controller.reverse(),
            onTapCancel: () => _controller.reverse(),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _getPriorityColor().withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header with gradient
                  _buildHeader(),

                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Issue Type
                        _buildIssueType(),

                        const SizedBox(height: 8),

                        // Description
                        if (!widget.isTablet)
                          SizedBox(height: 50, child: _buildDescription()),

                        const SizedBox(height: 8),

                        // Status & Progress
                        if (!widget.isArtisan)
                          isShowButton
                              ? Row(
                                  children: [
                                    Expanded(child: _buildStatusProgress()),
                                  ],
                                )
                              : Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: _buildStatusProgress(),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      flex: 1,
                                      child: InkWell(
                                        onTap: () async {
                                          bool?
                                          confirmed = await CommentDialog.show(
                                            context,
                                            title: 'Confirmation Completion',
                                            message:
                                                'Are you sure the job completed?',
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 16,
                                              ),
                                              child: buildField(
                                                controller: _messageController,
                                                label: 'Comment',
                                                icon: Icons.chat_outlined,
                                                keyboardType:
                                                    TextInputType.text,
                                              ),
                                            ),
                                          );
                                          if (confirmed!) {
                                            if (_messageController
                                                .text
                                                .isEmpty) {
                                              _messageController.text =
                                                  "Status approved by tenant";
                                            }
                                            submit();
                                          }
                                        },
                                        child: _buildActionButton(),
                                      ),
                                    ),
                                  ],
                                ),
                        if (widget.isArtisan)
                          // Action Button
                          InkWell(
                            onTap: () async {
                              bool? confirmed = await CommentDialog.show(
                                context,
                                title: 'Confirmation',
                                message:
                                    'Kindly tap yes to confirm the progress, if your have started working on the issues.',
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  child: buildField(
                                    controller: _messageController,
                                    label: 'Comment',
                                    icon: Icons.chat_outlined,
                                    keyboardType: TextInputType.text,
                                  ),
                                ),
                              );
                              if (confirmed!) {
                                if (_messageController.text.isEmpty) {
                                  _messageController.text =
                                      "Technician arrived on site";
                                }
                                submit();
                              }
                            },
                            child: _buildActionButton(),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
      ),
      child: Row(
        children: [
          // Priority Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getPriorityColor(),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: _getPriorityColor().withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_getPriorityIcon(), color: Colors.white, size: 14),
                const SizedBox(width: 6),
                Text(
                  widget.issue['priority'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Time Indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.access_time_rounded,
                  size: 12,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  _getTimeAgo(widget.issue['reportedDate']),
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Chevron
          Icon(
            Icons.chevron_right_rounded,
            color: Colors.grey.shade800,
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildIssueType() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.build_rounded,
            size: 18,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            widget.issue['issuetype'],
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.description_rounded,
            size: 16,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.issue['description'] ?? "No description recorded yet.",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.clip,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusProgress() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.4)),
      ),
      child: Column(
        children: [
          // Status Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _getStatusColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  _getStatusIcon(),
                  size: 16,
                  color: _getStatusColor(),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.issue['status'],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${widget.issue['progress']}%',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeOutCubic,
              tween: Tween<double>(
                begin: 0,
                end: (widget.issue['progress'] ?? 0) / 100,
              ),
              builder: (context, value, _) => LinearProgressIndicator(
                value: value,
                backgroundColor: _getStatusColor().withOpacity(0.05),
                valueColor: AlwaysStoppedAnimation(_getStatusColor()),
                minHeight: 8,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    final buttonColor = widget.isArtisan
        ? Colors.blue
        : widget.issue['status'] == 'In Progress' ||
              widget.issue['status'] == "Pending"
        ? Colors.blue
        : Colors.grey;

    final buttonText = widget.isArtisan
        ? 'In Progress'
        : widget.issue['status'] == 'In Progress' ||
              widget.issue['status'] == "Pending"
        ? 'In Progress'
        : "Is Completed";

    return Container(
      width: double.infinity,
      height: widget.isTablet ? 70 : 55,
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: buttonColor),

        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon(buttonIcon, color: buttonColor, size: 30),
              Text(
                overflow: TextOverflow.clip,
                buttonText,
                style: TextStyle(color: buttonColor, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTimeAgo(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'Recently';

    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 7) {
        return '${(difference.inDays / 7).floor()}w ago';
      } else if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Recently';
    }
  }
}
