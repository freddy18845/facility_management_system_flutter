import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../components/issue_tab.dart';
import '../../components/tenant_and_artisan_navbar.dart';
import '../../providers/app_Manager.dart';
import '../../providers/constants.dart';
import '../../utils/api_service.dart';
import '../../widgets/btn.dart';
import '../../widgets/empty_table.dart';
import '../../widgets/loading.dart';
import '../../widgets/textform.dart';
import '../../utils/app_theme.dart';
import '../dailogs/issue_report_dailog.dart';
import '../login_screen.dart';

class TenantIssuesScreen extends StatefulWidget {
  const TenantIssuesScreen({super.key});

  @override
  State<TenantIssuesScreen> createState() => _TenantIssuesScreenState();
}

class _TenantIssuesScreenState extends State<TenantIssuesScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final _issueTypeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _searchQuery = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  List<XFile> _images = [];
  List<Map<String, dynamic>> myIssues = [];
  List<Map<String, dynamic>> _allIssues = [];
  String? _selectedStatus;

  String _selectedPriority = 'medium';

  bool _isSubmitting = false;
  bool _isLoadingIssues = false;
  double _uploadProgress = 0;
  String _loadingMessage = '';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final tenantId = AppManager().getTenantId();
  final companyId = AppManager().getCompanyId();
  final role = AppManager().getRole();
  Timer? _inactivityTimer;
// Set timeout duration (e.g., 15 minutes)
  static final _timeoutDuration = Duration(minutes: ideaTimeDuration);

  @override
  void initState() {
    super.initState();
    getIssuesByTenantAndCompany();
    _syncOfflineIssues();
    _initializeAnimations();
  }

  @override
  void dispose() {
    _issueTypeController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _searchQuery.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
  }

  // ================= LOAD ISSUES =================
  Future<void> getIssuesByTenantAndCompany() async {
    try {
      setState(() {
        _isLoadingIssues = true;
        _loadingMessage = 'Loading your issues...';
      });
      await Future.delayed(const Duration(seconds: 2));
      final response = await ApiService().get(
        'issues/$companyId',
        context,
      );

      if (response?.statusCode == 200) {
        final responseData = jsonDecode(response!.body);

        if (responseData['success']) {
          setState(() {
            _allIssues = List<Map<String, dynamic>>.from(
              responseData['issues'] ?? [],
            );
            myIssues = List.from(_allIssues); // TOTAL = ALL
            _selectedStatus = null;
          });
        }
      }
    } catch (e) {
      showCustomSnackBar(context, 'Failed to load issues', color: Colors.red);
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingIssues = false;
          _loadingMessage = '';
        });
      }
    }
  }

  // ================= CONNECTIVITY =================
  Future<bool> _isOnline() async {
    if (kIsWeb) return true;
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }

  // ================= IMAGE PICKERS =================
  Future<void> _pickImages() async {
    final images = await _picker.pickMultiImage(imageQuality: 85);

    if (images.isNotEmpty) {
      setState(() {
        final remaining = 5 - _images.length;
        _images.addAll(images.take(remaining));
      });
    }
  }

  Future<void> _takePhoto() async {
    final photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );

    if (photo != null && _images.length < 5) {
      setState(() => _images.add(photo));
    }
  }

  void _removeImage(int index) {
    setState(() => _images.removeAt(index));
  }

  // ================= FILTER =================
  void filterIssues() {
    setState(() {
      myIssues = myIssues.where((issue) {
        return issue['Location'].toString().toLowerCase().contains(
          _searchQuery.text.toLowerCase(),
        ) ||
            issue['IssueType'].toString().toLowerCase().contains(
              _searchQuery.text.toLowerCase(),
            );
      }).toList();
    });
  }

  // ================= SUBMIT ISSUE =================
  Future<void> _submitIssue() async {
    if (!_formKey.currentState!.validate()) return;

    if (role != 'tenant') {
      showCustomSnackBar(
        context,
        'Only tenants can report issues',
        color: Colors.red,
      );
      return;
    }

    final payload = {
      'tenant_id': tenantId.toString(),
      'company_id': companyId.toString(),
      'issue_type': capitalizeFirst(_issueTypeController.text.trim()),
      'description': _descriptionController.text.trim(),
      'location': capitalizeFirst(_locationController.text.trim()),
      'priority': _selectedPriority,
    };

    final isOnline = await _isOnline();

    if (!isOnline) {
      await Hive.box(
        'offline_issues',
      ).add({'data': payload, 'images': _images.map((e) => e.path).toList()});

      Navigator.pop(context);
      showCustomSnackBar(
        context,
        'Offline: Issue saved & will sync later',
        color: Colors.orange,
      );
      _clearForm();
      return;
    }

    await _sendIssue(payload, _images);
  }

  // ================= SEND API =================
  Future<void> _sendIssue(Map<String, dynamic> data, List<XFile> images) async {
    try {
      setState(() {
        _isSubmitting = true;
        _loadingMessage = 'Submitting issue...';
      });
      if (!mounted) return;
      LoadingScreen.show(context, message: 'Processing, Please wait...');
      final response = await ApiService.multipartFilePost(
        endpoint: 'issues',
        data: data,
        images: images,
      );
      if (!mounted) return;
      LoadingScreen.hide(context);
      if (response.statusCode == 200 || response.statusCode == 201) {


        showCustomSnackBar(
          context,
          'Issue reported successfully',
          color: Colors.green,
        );
        Navigator.pop(context);
        _clearForm();
        getIssuesByTenantAndCompany();
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Submission failed');
      }
    } catch (e) {
      if (!mounted) return;
      LoadingScreen.hide(context);
      showCustomSnackBar(context, 'Error: ${e.toString()}', color: Colors.red);
    } finally {
      setState(() {
        _isSubmitting = false;
        _loadingMessage = '';
      });
    }
  }

  // ================= OFFLINE SYNC =================
  Future<void> _syncOfflineIssues() async {
    final box = Hive.box('offline_issues');
    if (box.isEmpty) return;

    if (!await _isOnline()) return;

    for (int i = box.length - 1; i >= 0; i--) {
      final item = box.getAt(i);
      await _sendIssue(
        Map<String, dynamic>.from(item['data']),
        (item['images'] as List).map((e) => XFile(e)).toList(),
      );
      await box.deleteAt(i);
    }
  }

  void _filterByStatus(String? status) {
    setState(() {
      _selectedStatus = status;

      if (status == null || status == 'total') {
        myIssues = List.from(_allIssues);
        return;
      }

      if (status == 'resolved') {
        myIssues = _allIssues.where((i) =>
        i['status'] == 'Completed' ||
            i['status'] == 'Cancelled').toList();
        return;
      }

      myIssues =
          _allIssues.where((i) => i['status'] == status).toList();
    });
  }


  void _clearForm() {
    _issueTypeController.clear();
    _descriptionController.clear();
    _locationController.clear();
    _images.clear();
    _selectedPriority = 'medium';
  }
  void _startInactivityTimer() {
    _inactivityTimer?.cancel(); // Cancel any existing timer
    _inactivityTimer = Timer(_timeoutDuration, _handleAutoLogout);
  }

  Future<void> _handleAutoLogout() async {
    if (!mounted) return;
    LoadingScreen.show(context, message: 'Logging out...');

    try {

      final response = await ApiService().post(
        'auth/logout',
        {},
        context,
        true,
      );

      if (mounted) LoadingScreen.hide(context);

      if (response?.statusCode == 200 || response?.statusCode == 201) {
        final responseData = jsonDecode(response!.body);
        debugPrint('📦 Logout response: $responseData');

        // Clear AppManager data
        await AppManager().clearLoginData();

        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
                (_) => false,
          );
        }
      } else {
        throw Exception('Logout failed');
      }
    } catch (e, stackTrace) {
      if (mounted) LoadingScreen.hide(context);
      debugPrint('❌ Logout error: $e');
      debugPrint('❌ Stack trace: $stackTrace');

      if (mounted) {
        showCustomSnackBar(
          context,
          'Logout failed. Please try again.',
          color: Colors.red,
        );
      }
    }
  }
  Map<String, int> _getIssueStats() {
    return {
      'total': myIssues.length,
      'pending': myIssues
          .where((i) => i['status'] == 'Pending')
          .length,
      'assigned': myIssues
          .where((i) => i['status'] == 'Assigned')
          .length,
      'in_progress': myIssues
          .where((i) => i['status'] == 'In_progress')
          .length,
      'resolved': myIssues
          .where((i) =>
      i['status'] == 'Completed' || i['Status'] == 'Cancelled')
          .length,
    };
  }

  // ================= LOADING OVERLAY =================
  Widget _loadingOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.transparent,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: Colors.blueAccent),
              const SizedBox(height: 16),
              Text(_loadingMessage, style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery
        .of(context)
        .size;
    final isMobile = size.width < 600;

    return Listener(
        onPointerDown: (_) => _startInactivityTimer(), // Reset timer on every touch
        child : Scaffold(
      backgroundColor: Colors.grey.shade200,
      floatingActionButton:FadeTransition(
        opacity: _fadeAnimation,
        child: CustomButton(
          icon: Icons.add,
          text: 'Report Issue',
          color: Colors.orange,
          onPressed: _showReportIssueDialog,
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Navbar(isMobile: isMobile,),
              if (!_isLoadingIssues)
                Container(
                  color: Colors.grey.shade50,
                  width: double.maxFinite,
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (!isMobile)
                        Spacer(),


                      if (!isMobile)
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Align(
                            alignment: Alignment.center,
                            child: _buildStatsSection(isMobile),
                          ),
                        ),

                      Spacer(),
                      Container(
                        height: 37,
                        margin: EdgeInsets.only(right: 8),
                        child:
                        CustomButton(
                          onPressed: (){
                            getIssuesByTenantAndCompany();
                          },
                          color: Colors.blueAccent,
                          text: '',
                          icon: Icons.sync,
                        ),),
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: SizedBox(
                          width: 250,
                          child: buildField(
                            controller: _searchQuery,
                            label: 'Search...',
                            icon: Icons.search,
                            onChangeAction: (_) => filterIssues(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              Expanded(
                child: _isSubmitting || _isLoadingIssues
                    ? _loadingOverlay()
                    : myIssues.isNotEmpty?buildMyIssuesTab(
                    isMobile:isMobile,context:context,myIssuesList:  myIssues,  onRefresh:  getIssuesByTenantAndCompany):EmptyTableView(message: 'No Compliant made yet'),
              ),
            ],
          ),
        ],
      ),
        ) );
  }

  void _showReportIssueDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          ReportIssueDialog(
            formKey: _formKey,
            issueTypeController: _issueTypeController,
            descriptionController: _descriptionController,
            locationController: _locationController,
            selectedPriority: _selectedPriority,
            images: _images,
            onPickImages: _pickImages,
            onTakePhoto: _takePhoto,
            onRemoveImage: _removeImage,
            onPriorityChanged: (p) => setState(() => _selectedPriority = p),
            onSubmit: _submitIssue,
            isSubmitting: _isSubmitting,
            uploadProgress: _uploadProgress,
          ),
    );
  }

  Widget _buildStatsSection(bool isMobile) {
    final stats = _getIssueStats();

    final statItems = [
      {'label': 'Total', 'value': stats['total'].toString(), 'status': 'total'},
      {
        'label': 'Pending',
        'value': stats['pending'].toString(),
        'status': 'pending'
      },
      {
        'label': 'Assigned',
        'value': stats['assigned'].toString(),
        'status': 'assigned'
      },
      {
        'label': 'In Progress',
        'value': stats['in_progress'].toString(),
        'status': 'in_progress'
      },
      {
        'label': 'Resolved',
        'value': stats['resolved'].toString(),
        'status': 'resolved'
      },
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(statItems.length * 2 - 1, (index) {
          if (index.isOdd) {
            // Divider
            return Container(
              height: 32,
              width: 1,
              margin: EdgeInsets.symmetric(horizontal: 16),
              color: Colors.grey.shade300,
            );
          } else {
            final stat = statItems[index ~/ 2];
            return _buildTextStat(
                stat['label']!, stat['value']!, stat['status']!);
          }
        }),
      ),
    );
  }

  Widget _buildTextStat(String label, String value, String status) {
    final isActive = _selectedStatus == status;

    return GestureDetector(
      onTap: () => _filterByStatus(status),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.blue : Colors.black87,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isActive ? Colors.blue : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
