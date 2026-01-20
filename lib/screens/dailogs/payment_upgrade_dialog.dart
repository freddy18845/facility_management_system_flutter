
import 'package:flutter/material.dart';
import 'package:fms_app/components/dailog_widgets/bottom_bar.dart';
import 'package:fms_app/components/dailog_widgets/header.dart';
import 'package:fms_app/screens/dailogs/room.dart';
import '../../Models/payData.dart';
import '../../utils/api_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/btn.dart';
import '../../widgets/loading.dart';

class PaymentUpgradeDialog extends StatefulWidget {
  const PaymentUpgradeDialog({super.key});

  @override
  State<PaymentUpgradeDialog> createState() => _PaymentUpgradeDialogState();

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const PaymentUpgradeDialog(),
    );
  }
}

class _PaymentUpgradeDialogState extends State<PaymentUpgradeDialog>
    with SingleTickerProviderStateMixin {
  final _pageController = PageController();
  int _currentPage = 0;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }



  void _switchPage(int page) {
    _animationController.reset();
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  void _handlePayment({
    required double amount,
    required int qty,
    required String type,
  }) async {
    String? activeReference;

    if (mounted) Navigator.pop(context);

    await RoomDialog.show(
      context,
      title: 'Payment Guidelines',
      isOnlyCancel: true,
      child: StatefulBuilder(
        builder: (context, setDialogState) {
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStep('1', 'Click "Proceed to payment" to open the checkout.'),
                    const SizedBox(height: 12),
                    _buildStep('2', 'Complete the process in the new browser tab.'),
                    const SizedBox(height: 12),
                    _buildStep('3', 'Come back here and tap "Verify payment" to finish.'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              CustomButton(
                text: 'Proceed to payment',
                color: Colors.green,
                isShowIcon: false,
                icon: Icons.payment,
                onPressed: () async {
                  final ref = await ApiService().processPayment(
                    context: context,
                    amount: amount,
                    type: type,
                    quantity: qty,
                  );

                  if (ref != null) {
                    setDialogState(() => activeReference = ref);
                  }
                },
              ),
              const SizedBox(height: 12),

              CustomButton(
                text: 'Verify payment',
                color: activeReference == null ? Colors.grey : Colors.orange,
                isShowIcon: false,
                onPressed: activeReference == null
                    ? null
                    : () async {
                  // 1. Run the server verification
                  await ApiService().verifyOnServer(context, activeReference!);
                  // 2. CHECK MOUNTED before proceeding to refresh
                  if (!mounted) Navigator.pop(context);

                

                  // 3. Trigger the data refresh
                 
                },
                icon: Icons.verified,
              )
            ],
          );
        },
      ),
    );
  }

  Widget _buildStep(String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.blue,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, height: 1.5),
          ),
        ),
      ],
    );
  }

  void onNotificationTap(String? reference) async {
    if (reference != null) {
      LoadingScreen.show(context);
      await ApiService().verifyOnServer(context, reference);
      LoadingScreen.hide(context);
      showCustomSnackBar(context, "Account Upgraded Successfully!");
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 680),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const DialogHeader(title: 'Upgrade Account'),

            // Elegant Tab Selector
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: _buildTabSelector(),
            ),

            // Pages
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: [
                  _buildPaymentGrid(
                    title: "SMS Packages",
                    subtitle: "Boost your messaging credits",
                    gradient: [Colors.purple.shade400, Colors.blue.shade400],
                    options: [
                      payData("100 SMS", "GHS 20", 20.0, 100, 'sms_topup',
                          Icons.message_outlined, Colors.purple.shade100),
                      payData("500 SMS", "GHS 90", 90.0, 500, 'sms_topup',
                          Icons.forum_outlined, Colors.blue.shade100),
                      payData("1000 SMS", "GHS 170", 170.0, 1000, 'sms_topup',
                          Icons.textsms_outlined, Colors.indigo.shade100),
                    ],
                  ),
                  _buildPaymentGrid(
                    title: "Subscription Plans",
                    subtitle: "Keep your business running smoothly",
                    gradient: [Colors.orange.shade400, Colors.red.shade400],
                    options: [
                      payData("1 Month", "GHS 150", 150.0, 1, 'subscription',
                          Icons.calendar_today_outlined, Colors.orange.shade100),
                      payData("3 Months", "GHS 400", 400.0, 3, 'subscription',
                          Icons.calendar_view_month_outlined, Colors.red.shade100),
                    ],
                  ),
                ],
              ),
            ),

            // Bottom Navigation
            DialogBottomNavigator(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomButton(
                    text: 'Cancel',
                    icon: Icons.close,
                    color: Colors.red.shade400,
                    onPressed: () => Navigator.pop(context),
                  ),
                  CustomButton(
                    text: _currentPage == 0 ? 'Subscriptions' : 'SMS Credits',
                    icon: _currentPage == 0 ? Icons.arrow_forward : Icons.arrow_back,
                    color: Colors.blue.shade600,
                    onPressed: () => _switchPage(_currentPage == 0 ? 1 : 0),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTab(
              label: 'SMS Packages',
              icon: Icons.message_outlined,
              isActive: _currentPage == 0,
              onTap: () => _switchPage(0),
            ),
          ),
          Expanded(
            child: _buildTab(
              label: 'Subscriptions',
              icon: Icons.card_membership_outlined,
              isActive: _currentPage == 1,
              onTap: () => _switchPage(1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab({
    required String label,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isActive
              ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isActive ? Colors.blue.shade700 : Colors.grey.shade600,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive ? Colors.blue.shade700 : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentGrid({
    required String title,
    required String subtitle,
    required List<Color> gradient,
    required List<Map<String, dynamic>> options,
  }) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ...options.map(
                    (opt) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [
                        Colors.white,
                        opt['bgColor'].withOpacity(0.3),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: opt['bgColor'].withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => _handlePayment(
                        amount: opt['amt'],
                        qty: opt['qty'],
                        type: opt['type'],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: opt['bgColor'],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                opt['icon'],
                                color: Colors.blue.shade700,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    opt['label'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    'One-time purchase',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  opt['price'],
                                  style: TextStyle(
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'Best Value',
                                    style: TextStyle(
                                      color: Colors.green.shade700,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


}