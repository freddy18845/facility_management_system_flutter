import 'package:flutter/material.dart';
import 'package:fms_app/widgets/btn.dart';
import 'package:fms_app/widgets/query_button.dart';
import 'package:fms_app/widgets/textform.dart';
import 'package:intl/intl.dart';
import '../utils/app_theme.dart';
import 'action_button.dart';
import 'empty_table.dart';

class CustomDataTable extends StatefulWidget {
  final String title;
  final String? action;
  final IconData? actionIcon;
  final List<String> headers;
  final List<String> mobileHeaders;
  final List<Map<String, dynamic>> data;
  final List<int> flexValues;
  final List<int> mobileFlexValues;
  final Function(Map<String, dynamic>)? onRowTap;
  final Function(List<Map<String, dynamic>>)? onSelectionChanged;
  final Function(List<Map<String, dynamic>>)? onBulkAction;
  final Function(List<Map<String, dynamic>>)? onBulkDelete;
  final Function(List<Map<String, dynamic>>)? onBulkExport;
  final VoidCallback? onQueryPressed;
  final VoidCallback? onRefreshPressed;
  final Function(Map<String, dynamic>)? onEditBtn;
  final bool showSearch;
  final bool showRefresh;
  final bool showFilter;
  final bool showDateRange;
  final bool showCheckbox;
  // 🔄 Loading / Skeleton
  final bool isLoading;
  final bool autoLoadWhenEmpty;
  final int shimmerRowCount;
  final bool showEditBtn;
  final List<String>? filterOptions;
  final String? filterLabel;
  final Color? priorityColorKey;
  final double? height;
  final bool showPagination;
  final int itemsPerPage;

  const CustomDataTable({
    super.key,
    required this.title,
    required this.headers,
    required this.mobileHeaders,
    required this.data,
    required this.flexValues,
    required this.mobileFlexValues,
    this.isLoading = false,
    this.autoLoadWhenEmpty = true,
    this.shimmerRowCount = 6,
    this.onEditBtn,
    this.onRowTap,
    this.onSelectionChanged,
    this.onBulkAction,
    this.onBulkDelete,
    this.showRefresh= false,
    this.showEditBtn = false,
    this.actionIcon = Icons.assignment,
    this.action = 'Assign',
    this.onBulkExport,
    this.onQueryPressed,
    this.onRefreshPressed,
    this.showSearch = true,
    this.showFilter = false,
    this.showDateRange = false,
    this.showCheckbox = false,
    this.showPagination = true,
    this.itemsPerPage = 10,
    this.filterOptions,
    this.filterLabel,
    this.priorityColorKey,
    this.height,
  });

  @override
  State<CustomDataTable> createState() => _CustomDataTableState();
}

class _CustomDataTableState extends State<CustomDataTable> {
  final TextEditingController _searchQuery = TextEditingController();
  String? _selectedFilter;
  DateTime? _startDate;
  DateTime? _endDate;
  List<Map<String, dynamic>> _filteredData = [];
  Set<int> _selectedIndices = {};
  bool _selectAll = false;
  int _currentPage = 1;
  int _totalPages = 1;

  @override
  void initState() {
    super.initState();
    _filteredData = widget.data;
    _updatePagination();
  }

  @override
  void dispose() {
    _searchQuery.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(CustomDataTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.data != oldWidget.data) {
      _applyFilters();
    }
  }

  void _updatePagination() {
    _totalPages = widget.showPagination
        ? (_filteredData.length / widget.itemsPerPage).ceil()
        : 1;
    if (_totalPages == 0) _totalPages = 1;
    if (_currentPage > _totalPages) _currentPage = _totalPages;
  }

  void _applyFilters() {
    setState(() {
      _filteredData = widget.data.where((item) {
        bool matchesSearch = true;
        if (_searchQuery.text.isNotEmpty) {
          matchesSearch = item.values.any(
            (value) => value.toString().toLowerCase().contains(
              _searchQuery.text.toLowerCase(),
            ),
          );
        }

        bool matchesFilter = true;
        if (_selectedFilter != null && widget.filterLabel != null) {
          matchesFilter = item[widget.filterLabel] == _selectedFilter;
        }

        bool matchesDateRange = true;
        if (_startDate != null &&
            _endDate != null &&
            item.containsKey('date')) {
          try {
            DateTime itemDate = DateTime.parse(item['date']);
            matchesDateRange =
                itemDate.isAfter(
                  _startDate!.subtract(const Duration(days: 1)),
                ) &&
                itemDate.isBefore(_endDate!.add(const Duration(days: 1)));
          } catch (e) {
            matchesDateRange = true;
          }
        }

        return matchesSearch && matchesFilter && matchesDateRange;
      }).toList();

      _updatePagination();
      _selectedIndices.removeWhere((index) => index >= _filteredData.length);
      _updateSelectAll();
    });
  }

  List<Map<String, dynamic>> _getPaginatedData() {
    if (!widget.showPagination) return _filteredData;

    final startIndex = (_currentPage - 1) * widget.itemsPerPage;
    final endIndex = (startIndex + widget.itemsPerPage).clamp(
      0,
      _filteredData.length,
    );

    if (startIndex >= _filteredData.length) return [];
    return _filteredData.sublist(startIndex, endIndex);
  }

  void _goToPage(int page) {
    setState(() {
      _currentPage = page.clamp(1, _totalPages);
    });
  }

  void _previousPage() {
    if (_currentPage > 1) _goToPage(_currentPage - 1);
  }

  void _nextPage() {
    if (_currentPage < _totalPages) _goToPage(_currentPage + 1);
  }

  void _toggleSelectAll(bool? value) {
    setState(() {
      if (value == true) {
        _selectedIndices = Set.from(
          List.generate(_filteredData.length, (index) => index),
        );
        _selectAll = true;
      } else {
        _selectedIndices.clear();
        _selectAll = false;
      }
      _notifySelectionChanged();
    });
  }

  void _toggleRowSelection(int index) {
    setState(() {
      if (_selectedIndices.contains(index)) {
        _selectedIndices.remove(index);
      } else {
        _selectedIndices.add(index);
      }
      _updateSelectAll();
      _notifySelectionChanged();
    });
  }

  void _updateSelectAll() {
    _selectAll =
        _filteredData.isNotEmpty &&
        _selectedIndices.length == _filteredData.length;
  }

  void _notifySelectionChanged() {
    if (widget.onSelectionChanged != null) {
      final selectedData = _selectedIndices
          .map((index) => _filteredData[index])
          .toList();
      widget.onSelectionChanged!(selectedData);
    }
  }

  List<Map<String, dynamic>> getSelectedItems() {
    return _selectedIndices.map((index) => _filteredData[index]).toList();
  }

  void clearSelection() {
    setState(() {
      _selectedIndices.clear();
      _selectAll = false;
      _notifySelectionChanged();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    final tableHeight = widget.height ?? size.height * 0.6;
    final bool showLoading =
        widget.isLoading ||
            (widget.autoLoadWhenEmpty && widget.data.isEmpty);
    return Container(
      height: tableHeight,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          width: 0.8,
          color: Theme.of(context).cardColor == Colors.white
              ? Colors.grey.shade200
              : Colors.transparent,
        ),
      ),
      child:
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and Search Row
          Row(
            children: [
              Text(
                widget.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isMobile ? 12 : 14,
                ),
              ),
              const Spacer(),
              if (widget.showRefresh && widget.onRefreshPressed != null)
               Container(
                 height: 37,
                 margin: EdgeInsets.only(right: 8),
                 child:
               CustomButton(
                 isMobile: isMobile,
                 onPressed: widget.onRefreshPressed!,
                 color: Colors.blueAccent,
                 text: '',
                 icon: Icons.sync,
               ),),
              if (widget.showSearch)
                SizedBox(
                  width: isMobile ? size.width * 0.4 : 250,
                  child: buildField(
                    controller: _searchQuery,
                    label: 'Search...',
                    icon: Icons.search,
                    onChangeAction: (value) => _applyFilters(),
                  ),
                ),
              if (widget.showSearch && widget.showDateRange)
                SizedBox(width: isMobile ? 5 : 10),
              if (widget.showDateRange && widget.onQueryPressed != null)
                QueryButton(
                  isMobile: isMobile,
                  onPressed: widget.onQueryPressed!,
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Action Row
          if (widget.showCheckbox && _selectedIndices.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).focusColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).focusColor == Colors.blue.shade50
                      ? Colors.blue.shade200
                      : Colors.amber.shade50,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 18,
                    color: Colors.blue.shade700,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${_selectedIndices.length} item${_selectedIndices.length > 1 ? 's' : ''} selected',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  const SizedBox(width: 16),
                  if (widget.onBulkAction != null)
                    ActionButton(
                      icon: widget.actionIcon!,
                      label: widget.action!,
                      color: Colors.green,
                      onPressed: () => widget.onBulkAction!(getSelectedItems()),
                    ),
                  const SizedBox(width: 8),
                  if (widget.onBulkDelete != null)
                    ActionButton(
                      icon: Icons.delete,
                      label: 'Delete',
                      color: Colors.red,
                      onPressed: () => widget.onBulkDelete!(getSelectedItems()),
                    ),
                  const SizedBox(width: 8),
                  if (widget.onBulkExport != null)
                    ActionButton(
                      icon: Icons.download,
                      label: 'Export',
                      color: Colors.orange,
                      onPressed: () => widget.onBulkExport!(getSelectedItems()),
                    ),
                  const Spacer(),
                  InkWell(
                    onTap: clearSelection,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.blue.shade300),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Clear',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.blue.shade700,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.close,
                            size: 14,
                            color: Colors.blue.shade700,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Table
          Expanded(
            child: Stack(
              children: [
                // ───────── REAL TABLE (FADED) ─────────
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 250),
                  opacity: showLoading ? 0.3 : 1,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final tableWidth = isMobile
                          ? constraints.maxWidth
                          : constraints.maxWidth
                          .clamp(600, double.infinity)
                          .toDouble();

                      final paginatedData = _getPaginatedData();

                      if (_filteredData.isEmpty && !showLoading) {
                        return const EmptyTableView(message: 'No data available');
                      }

                      return SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: SizedBox(
                          width: tableWidth,
                          child: Column(
                            children: [
                              // HEADER
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 2,
                                  horizontal: 4,
                                ),
                                color: Theme.of(context).secondaryHeaderColor,
                                child: Row(
                                  children: [
                                    if (widget.showCheckbox)
                                      SizedBox(
                                        width: 40,
                                        child: Checkbox(
                                          value: _selectAll,
                                          activeColor: Colors.blue,
                                          onChanged: _toggleSelectAll,
                                          materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                          visualDensity: VisualDensity.compact,
                                        ),
                                      ),
                                    ...List.generate(
                                      isMobile
                                          ? widget.mobileHeaders.length
                                          : widget.headers.length,
                                          (index) {
                                        final headers = isMobile
                                            ? widget.mobileHeaders
                                            : widget.headers;
                                        final flex = isMobile
                                            ? widget.mobileFlexValues
                                            : widget.flexValues;

                                        return Expanded(
                                          flex: flex[index],
                                          child: Text(
                                            formatHeader(headers[index]),
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: isMobile ? 10 : 12,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    if (widget.showEditBtn)
                                      Expanded(
                                        flex: 1,
                                        child: Center(
                                          child: Text(
                                            'Edit',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: isMobile ? 10 : 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const Divider(height: 0),

                              // ROWS
                              ...paginatedData.asMap().entries.map((entry) {
                                final actualIndex = widget.showPagination
                                    ? ((_currentPage - 1) * widget.itemsPerPage) +
                                    entry.key
                                    : entry.key;
                                return _buildRow(
                                  actualIndex,
                                  entry.value,
                                  isMobile,
                                );
                              }),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // ───────── SHIMMER OVERLAY ─────────
                if (showLoading)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 250),
                        opacity: showLoading ? 1 : 0,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final tableWidth = isMobile
                                ? constraints.maxWidth
                                : constraints.maxWidth
                                .clamp(600, double.infinity)
                                .toDouble();

                            return SingleChildScrollView(
                              child: SizedBox(
                                width: tableWidth,
                                child: Column(
                                  children: [
                                    // SHIMMER HEADER
                                    _SkeletonHeader(
                                      showCheckbox: widget.showCheckbox,
                                      showEditBtn: widget.showEditBtn,
                                      headers: isMobile
                                          ? widget.mobileHeaders
                                          : widget.headers,
                                      flexValues: isMobile
                                          ? widget.mobileFlexValues
                                          : widget.flexValues,
                                    ),
                                    const Divider(height: 0),

                                    // SHIMMER ROWS
                                    ...List.generate(
                                      widget.shimmerRowCount,
                                          (_) => _SkeletonRow(
                                        showCheckbox: widget.showCheckbox,
                                        showEditBtn: widget.showEditBtn,
                                        headers: isMobile
                                            ? widget.mobileHeaders
                                            : widget.headers,
                                        flexValues: isMobile
                                            ? widget.mobileFlexValues
                                            : widget.flexValues,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Results count and Pagination
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Pagination Controls
              if (widget.showPagination && _totalPages > 1)
                Row(
                  children: [
                    IconButton(
                      onPressed: _currentPage > 1 ? _previousPage : null,
                      icon: const Icon(Icons.chevron_left),
                      iconSize: 18,
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(),
                      color: _currentPage > 1
                          ? Colors.blue.shade700
                          : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    ..._buildPageNumbers(isMobile),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _currentPage < _totalPages ? _nextPage : null,
                      icon: const Icon(Icons.chevron_right),
                      iconSize: 18,
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(),
                      color: _currentPage < _totalPages
                          ? Colors.blue.shade700
                          : Colors.grey,
                    ),
                  ],
                ),

              const Spacer(),

              // Results count
              Text(
                'Showing ${_filteredData.length} of ${widget.data.length} results',
                style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPageNumbers(bool isMobile) {
    List<Widget> pageButtons = [];
    int maxButtons = isMobile ? 3 : 5;

    int start = (_currentPage - (maxButtons ~/ 2)).clamp(1, _totalPages);
    int end = (start + maxButtons - 1).clamp(1, _totalPages);

    if (end - start < maxButtons - 1) {
      start = (end - maxButtons + 1).clamp(1, _totalPages);
    }

    for (int i = start; i <= end; i++) {
      pageButtons.add(_buildPageButton(i));
    }

    return pageButtons;
  }

  Widget _buildPageButton(int page) {
    final isActive = page == _currentPage;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: InkWell(
        onTap: () => _goToPage(page),
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isActive ? Colors.blue.shade700 : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(6),
          ),
          alignment: Alignment.center,
          child: Text(
            '$page',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRow(int index, Map<String, dynamic> rowData, bool isMobile) {
    final headers = isMobile ? widget.mobileHeaders : widget.headers;
    final flexValues = isMobile ? widget.mobileFlexValues : widget.flexValues;
    final isSelected = _selectedIndices.contains(index);

    return Column(
      children: [
        InkWell(
          onTap: widget.onRowTap != null
              ? () => widget.onRowTap!(rowData)
              : null,
          child: Container(
            color: isSelected ? Theme.of(context).focusColor : null,
            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
            child: Row(
              children: [
                if (widget.showCheckbox)
                  SizedBox(
                    width: 40,
                    child: Checkbox(
                      value: isSelected,
                      activeColor: Colors.blue,
                      onChanged: (_) => _toggleRowSelection(index),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),

                ...List.generate(headers.length, (colIndex) {
                  final key = headers[colIndex].toLowerCase().replaceAll(
                    ' ',
                    '_',
                  );

                  dynamic value = rowData[key] ?? '';

                  // ✅ STATUS MAPPING
                  if (key == 'is_active') {
                    value = value == 1 ? 'Active' : 'Inactive';
                  }
                  if ((key == 'created_at'|| key=='lease_end_date'|| key=='move_in_date' || key=="reportedDate") && value.toString().isNotEmpty) {
                    try {
                      final date = DateTime.parse(value.toString());
                      value = DateFormat('dd MMM yyyy').format(date);
                    } catch (_) {}
                  }

                  bool isPriorityColumn = key.contains('priority');
                  Color? textColor = isPriorityColumn
                      ? getPriorityColor(value.toString())
                      : null;

                  return Expanded(
                    flex: flexValues[colIndex],
                    child: Text(
                      capitalizeFirst(value.toString()),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: isMobile ? 10 : 12,
                        color: textColor,
                        fontWeight: textColor != null
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  );
                }),
                if (widget.showEditBtn)
                  Expanded(
                    flex: 1,
                    child: InkWell(
                      onTap: () {
                        widget.onEditBtn!(rowData);
                      },
                      child: Icon(Icons.edit, size: 18, color: Colors.grey,),
                    ),
                  ),
              ],
            ),
          ),
        ),
        Divider(height: 0, color: Colors.grey.shade200),
      ],
    );
  }


}

/* ──────────────────── SKELETONS ──────────────────── */

class _SkeletonHeader extends StatelessWidget {
  final List<String> headers;
  final List<int> flexValues;
  final bool showCheckbox;
  final bool showEditBtn;

  const _SkeletonHeader({
    required this.headers,
    required this.flexValues,
    required this.showCheckbox,
    required this.showEditBtn,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      color: Theme.of(context).secondaryHeaderColor,
      child: Row(
        children: [
          if (showCheckbox)
            const SizedBox(width: 40, child: _ShimmerBox(height: 14)),
          ...List.generate(
            headers.length,
                (i) => Expanded(
              flex: flexValues[i],
              child: const _ShimmerBox(height: 14),
            ),
          ),
          if (showEditBtn)
            const Expanded(flex: 1, child: _ShimmerBox(height: 14)),
        ],
      ),
    );
  }
}

class _SkeletonRow extends StatelessWidget {
  final List<String> headers;
  final List<int> flexValues;
  final bool showCheckbox;
  final bool showEditBtn;

  const _SkeletonRow({
    required this.headers,
    required this.flexValues,
    required this.showCheckbox,
    required this.showEditBtn,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          child: Row(
            children: [
              if (showCheckbox)
                const SizedBox(width: 40, child: _ShimmerBox()),
              ...List.generate(
                headers.length,
                    (i) => Expanded(
                  flex: flexValues[i],
                  child: const _ShimmerBox(),
                ),
              ),
              if (showEditBtn)
                const Expanded(flex: 1, child: _ShimmerBox()),
            ],
          ),
        ),
        Divider(height: 0, color: Colors.grey.shade200),
      ],
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  final double height;
  const _ShimmerBox({this.height = 12});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.25, end: 0.6),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeInOut,
      builder: (_, value, __) => Container(
        height: height,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.3),
          borderRadius: BorderRadius.circular(6),
        ),
      ),
      onEnd: () {},
    );
  }
}



