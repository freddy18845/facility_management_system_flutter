import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaystackWebViewDialog extends StatefulWidget {
  final String url;
  final String reference;

  const PaystackWebViewDialog({super.key, required this.url, required this.reference});

  @override
  State<PaystackWebViewDialog> createState() => _PaystackWebViewDialogState();
}

class _PaystackWebViewDialogState extends State<PaystackWebViewDialog> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
    // Inside PaystackWebViewDialog
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            // Check only for the path, not the whole domain
            if (request.url.contains('payments/verify')) {
              Navigator.pop(context, true);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )

      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  // Inside your PaystackWebViewDialog build method
  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: SizedBox(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          children: [
            // Header
            ListTile(
              title: const Text("Payment Checkout", style: TextStyle(fontWeight: FontWeight.bold)),
              trailing: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context, false), // Return false for cancel
              ),
            ),

            // WebView
            Expanded(
              child: Stack(
                children: [
                  WebViewWidget(controller: _controller),
                  if (_isLoading) const Center(child: CircularProgressIndicator()),
                ],
              ),
            ),

            // --- MANUAL BUTTONS BAR ---
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(15)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text("Cancel", style: TextStyle(color: Colors.red)),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    onPressed: () => Navigator.pop(context, true), // Close and trigger verify
                    child: const Text("I Have Paid", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}