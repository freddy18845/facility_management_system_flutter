import 'package:flutter/material.dart';
import '../widgets/account_card.dart';
import '../widgets/btn.dart';
import '../widgets/textform.dart';
import '../widgets/login_card.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    final horizontalPadding = isMobile ? 16.0 : size.width * 0.05;
    final verticalPadding = isMobile ? 16.0 : size.height * 0.04;

    return Scaffold(
      //backgroundColor: Colors.grey.shade50,
      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
        ),
        child: Center(child: LoginCard(
        ),

        // SingleChildScrollView(
        //   child: Padding(
        //     padding: EdgeInsets.symmetric(
        //       horizontal: horizontalPadding,
        //       vertical: verticalPadding,
        //     ),
        //     child: Column(
        //       mainAxisAlignment: MainAxisAlignment.center,
        //       crossAxisAlignment: CrossAxisAlignment.center,
        //       children: [
        //         SizedBox(height: isMobile ? 40 : 80),
        //
        //         if (!showLoginCard) ...[
        //           Text(
        //             'Select Account Type',
        //             textAlign: TextAlign.center,
        //             style: TextStyle(
        //               fontSize: isMobile ? 16 : 20,
        //               fontWeight: FontWeight.bold,
        //             ),
        //           ),
        //           Text(
        //             'What kind of account do you need to proceed',
        //             overflow: TextOverflow.clip,
        //             textAlign: TextAlign.center,
        //             style: TextStyle(
        //               fontSize: isMobile ? 10 : 12,
        //               fontStyle: FontStyle.italic,
        //             ),
        //           ),
        //           SizedBox(height: verticalPadding),
        //           Center(
        //             child: Wrap(
        //               spacing: isMobile ? 12 : 24,
        //               runSpacing: isMobile ? 12 : 24,
        //               alignment: WrapAlignment.center,
        //               children: [
        //                 SizedBox(
        //                   width: isMobile ? size.width * 0.8 : 220,
        //                   child: GestureDetector(
        //                     onTap: () {
        //                       setState(() {
        //                         selectedAccount = 'Tenant';
        //                         selectedAccountIcon = 'tenant.png';
        //                       });
        //                     },
        //                     onTapDown: (_) {
        //                       setState(() {
        //                         selectedAccount = 'Tenant';
        //                         selectedAccountIcon = 'tenant.png';
        //                       });
        //                     },
        //                     child: AccountCard(
        //                       title: 'Tenant',
        //                       icon: 'tenant.png',
        //                       description: 'tenant portal for reporting and tracking faulty facility',
        //                       isSelected: selectedAccount == 'Tenant',
        //                     ),
        //                   ),
        //                 ),
        //                 SizedBox(
        //                   width: isMobile ? size.width * 0.8 : 220,
        //                   child: GestureDetector(
        //                     onTap: () {
        //                       setState(() {
        //                         selectedAccount = 'Administrator';
        //                         selectedAccountIcon = 'admin.png';
        //                       });
        //                     },
        //                     onTapDown: (_) {
        //                       setState(() {
        //                         selectedAccount = 'Administrator';
        //                         selectedAccountIcon = 'admin.png';
        //                       });
        //                     },
        //                     child: AccountCard(
        //                       title: 'Administrator',
        //                       icon: 'admin.png',
        //                       description: 'Admin portal for addressing tenant compliant',
        //                       isSelected: selectedAccount == 'Administrator',
        //                     ),
        //                   ),
        //                 ),
        //                 SizedBox(
        //                   width: isMobile ? size.width * 0.8 : 220,
        //                   child: GestureDetector(
        //                     onTap: () {
        //                       setState(() {
        //                         selectedAccount = 'Artisan';
        //                         selectedAccountIcon = 'artisan.png';
        //                       });
        //                     },
        //                     onTapDown: (_) {
        //                       setState(() {
        //                         selectedAccount = 'Artisan';
        //                         selectedAccountIcon = 'artisan.png';
        //                       });
        //                     },
        //                     child: AccountCard(
        //                       title: 'Artisan',
        //                       icon: 'artisan.png',
        //                       description: 'Artisan portal for addressing assigned tacks',
        //                       isSelected: selectedAccount == 'Artisan',
        //                     ),
        //                   ),
        //                 ),
        //               ],
        //             ),
        //           ),
        //           SizedBox(height: verticalPadding * 2),
        //          Align(
        //            alignment: Alignment.center,
        //            child:
        //
        //            CustomButton(
        //              icon: Icons.arrow_forward,
        //              text: 'Proceed to Login',
        //              color: Colors.green.shade700,
        //              onPressed:selectedAccount != null
        //                  ? () {
        //                setState(() {
        //                  showLoginCard = true;
        //                });
        //              }
        //                  : null,
        //            isShowIcon: false,)
        //
        //
        //          ),
        //         ],
        //
        //         if (showLoginCard)
        //           Center(child: LoginCard(
        //             accountType: selectedAccount!,
        //             accountIcon: selectedAccountIcon!,
        //             onBack: () {
        //               setState(() {
        //                 showLoginCard = false;
        //               });
        //             },
        //           ),)
        //         ],
        //
        //     ),
        //   ),
        // ),
      ),
      ) );
  }
}

