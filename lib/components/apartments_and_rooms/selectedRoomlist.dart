import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import '../../widgets/custom_table.dart';
import '../../widgets/loading.dart';

class SelectedRoomTable extends StatefulWidget {
  final Function(Map<String, dynamic> data) onTap;
  final Function(Map<String, dynamic> data) onEdit;
  final Function(List<Map<String, dynamic>>) onDelete;
  final Function(List<Map<String, dynamic>>) onBulkEdit;
  final Function() onRefresh;

  final String title;
  final List<Map<String, dynamic>> data;
  const SelectedRoomTable({
    super.key,
    required this.data,
    required this.onTap,
    required this.title,
    required this.onEdit,
    required this.onDelete,
    required this.onRefresh,
    required this.onBulkEdit,
  });

  @override
  State<SelectedRoomTable> createState() => _SelectedRoomTableState();
}

class _SelectedRoomTableState extends State<SelectedRoomTable> {
  bool isLoading = false;
  void _handleBulkExport(List<Map<String, dynamic>> selectedItems) async {
    // Show loading immediately
    LoadingScreen.show(
      context,
      message:
          'Exporting ${selectedItems.length} Room${selectedItems.length > 1 ? 's' : ''}...',
    );

    // Simulate export delay
    await Future.delayed(const Duration(seconds: 2));

    // Hide loading
    if (mounted) {
      LoadingScreen.hide(context);

      // Show success message
      showCustomSnackBar(
        context,
        '${selectedItems.length} Room${selectedItems.length > 1 ? 's' : ''} exported successfully to CSV',
        color: Colors.orange,
      );

      // TODO: Add your actual export logic here
      print('Exporting ${selectedItems.length} items');
      for (var item in selectedItems) {
        print('Export: ${item['name']}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: CustomDataTable(
                  title: '${widget.title}',
                  height: constraints.maxHeight - 32,
                  isLoading: isLoading, // ✅ Add this
                  autoLoadWhenEmpty: false,
                  showPagination: true,
                  itemsPerPage: 10,
                  showCheckbox: true,
                  showRefresh: true,
                  showEditBtn: true,
                  onBulkAction: widget.onBulkEdit,
                  actionIcon: Icons.edit_outlined,
                  onBulkDelete: widget.onDelete,
                  onBulkExport: _handleBulkExport,

                  // Optional: Track selection changes
                  onSelectionChanged: (selectedItems) {
                    print('${selectedItems.length} items selected');
                  },

                  onRefreshPressed: ()  async {
                    setState(() {
                      isLoading = true;
                    });
                    await Future.delayed(const Duration(seconds: 1));
                    widget.onRefresh;
                    setState(() {
                      isLoading = false;
                    });
                  },
                  // Desktop headers
                  headers: const ['Room Number', 'Status'],

                  // Mobile headers
                  mobileHeaders: const ['Room Number', 'Status'],

                  // Desktop flex values
                  flexValues: const [1, 1],

                  // Mobile flex values
                  mobileFlexValues: const [1, 1],

                  // Data - use the local Rooms list
                  data: widget.data,

                  // Enable features
                  showSearch: true,
                  showFilter: true,

                  // Filter options
                  filterOptions: const ['name'],
                  filterLabel: 'Filter by Name',

                  // Row tap handler
                  onRowTap: (rowData) {
                    widget.onTap(rowData);
                  },
                  onEditBtn: (Map<String, dynamic> roomData) async {
                    await widget.onEdit(roomData);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
