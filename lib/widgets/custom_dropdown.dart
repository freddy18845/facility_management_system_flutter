import 'package:flutter/material.dart';

class CustomDropdown extends StatefulWidget {
  final String label;
  final Map<String, dynamic>? value;
  final List<Map<String, dynamic>> items;
  final String Function(Map<String, dynamic>) displayText;
  final void Function(Map<String, dynamic>) onSelected;
  final IconData icon;

  const CustomDropdown({
    super.key,
    required this.label,
    required this.items,
    required this.displayText,
    required this.onSelected,
    required this.icon,
    this.value,
  });

  @override
  State<CustomDropdown> createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool isOpen = false;

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _toggleDropdown() {
    if (isOpen) {
      _removeOverlay();
    } else {
      _showOverlay();
    }
  }

  void _showOverlay() {
    _overlayEntry = _createOverlay();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() => isOpen = true);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) setState(() => isOpen = false);
  }

  OverlayEntry _createOverlay() {
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    return OverlayEntry(
      builder: (_) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _removeOverlay,
        child: Stack(
          children: [
            Positioned(
              width: size.width,
              child: CompositedTransformFollower(
                link: _layerLink,
                offset: Offset(0, size.height + 4),
                showWhenUnlinked: false,
                child: Material(
                  elevation: 5,
                  borderRadius: BorderRadius.circular(8),
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: widget.items.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, index) {
                      final item = widget.items[index];
                      return ListTile(
                        dense: true,
                        title: Text(
                          widget.displayText(item),
                          style: const TextStyle(fontSize: 12),
                        ),
                        onTap: () {
                          widget.onSelected(item);
                          _removeOverlay();
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: InkWell(
        onTap: _toggleDropdown,
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
                  Icon(widget.icon, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 6),
                  Text(
                    widget.label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    isOpen
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 18,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                widget.value == null
                    ? 'Select ${widget.label}'
                    : widget.displayText(widget.value!),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: widget.value == null
                      ? Colors.grey.shade400
                      : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
