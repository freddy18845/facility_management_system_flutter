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
import '../login_screen.dart';


class ArtisanScreen extends StatefulWidget {
  const ArtisanScreen({super.key});

  @override
  State<ArtisanScreen> createState() => _ArtisanScreenState();
}

class _ArtisanScreenState extends State<ArtisanScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final _issueTypeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _searchQuery = TextEditingController();
  List<XFile> _images = [];
  List<Map<String, dynamic>> myTasks = [];
  List<Map<String, dynamic>> _allIssues = [];
  String _selectedPriority = 'medium';

  bool _isSubmitting = false;
  bool _isLoadingIssues = false;
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
    getTasks();
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
  Future<void> getTasks() async {
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
            myTasks = List.from(_allIssues); // TOTAL = ALL
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




  // ================= FILTER =================
  void filterIssues() {
    setState(() {
      myTasks = myTasks.where((issue) {
        return issue['Location'].toString().toLowerCase().contains(
          _searchQuery.text.toLowerCase(),
        ) ||
            issue['IssueType'].toString().toLowerCase().contains(
              _searchQuery.text.toLowerCase(),
            );
      }).toList();
    });
  }


  // ================= SEND API =================
  Future<void> _sendIssue(Map<String, dynamic> data, List<XFile> images) async {
    try {
      setState(() {
        _isSubmitting = true;
        _loadingMessage = 'Submitting issue...';
      });

      final response = await ApiService.multipartFilePost(
        endpoint: 'issues',
        data: data,
        images: images,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.pop(context);

        showCustomSnackBar(
          context,
          'Issue reported successfully',
          color: Colors.green,
        );

        _clearForm();
        getTasks();
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Submission failed');
      }
    } catch (e) {
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
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;

    return  Listener(
        onPointerDown: (_) => _startInactivityTimer(), // Reset timer on every touch
        child :Scaffold(
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [

                      Container(
                        height: 37,
                        margin: EdgeInsets.only(right: 8),
                        child:
                        CustomButton(
                          onPressed: (){
                            getTasks();
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
                    :myTasks.isNotEmpty? buildMyIssuesTab(isMobile:isMobile,context:context,myIssuesList:  myTasks,  onRefresh:  getTasks):EmptyTableView(message: 'No Compliant assigned to you'),
              ),
            ],
          ),
        ],
      ),
        ));
  }

}



