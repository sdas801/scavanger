import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TermsAndConditionsScreen extends StatefulWidget {
  const TermsAndConditionsScreen({Key? key}) : super(key: key);

  @override
  State<TermsAndConditionsScreen> createState() =>
      _TermsAndConditionsScreenState();
}

class _TermsAndConditionsScreenState extends State<TermsAndConditionsScreen> {
  WebViewController? _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  Future<void> _initializeWebView() async {
    final controller = WebViewController();
    await controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    await controller.setNavigationDelegate(
      NavigationDelegate(
        onPageStarted: (String url) {
          if (mounted) setState(() => _isLoading = true);
        },
        onPageFinished: (String url) {
          if (mounted) setState(() => _isLoading = false);
        },
        onWebResourceError: (WebResourceError error) {
          debugPrint('WebView error: ${error.description}');
        },
      ),
    );

    await controller.loadRequest(
        Uri.parse('https://scavengertime.com/terms-and-conditions/'));

    if (mounted) {
      setState(() {
        _controller = controller;
      });
    }
  }

  @override
  void dispose() {
    _controller?.clearCache(); // Properly dispose the WebView
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Terms & Conditions",
          style: TextStyle(color: Colors.white), // White text color
        ),
        backgroundColor:
            const Color.fromARGB(255, 35, 7, 138), // Blue background
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true, // White back arrow
      ),
      body: Stack(
        children: [
          if (_controller != null)
            WebViewWidget(controller: _controller!)
          else
            const Center(child: CircularProgressIndicator()),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
