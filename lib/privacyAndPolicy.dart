import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Privacyandpolicy extends StatefulWidget {
  const Privacyandpolicy({Key? key}) : super(key: key);

  @override
  State<Privacyandpolicy> createState() => _PrivacyandpolicyState();
}

class _PrivacyandpolicyState extends State<Privacyandpolicy> {
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

    await controller
        .loadRequest(Uri.parse('https://scavengertime.com/privacy-policy/'));

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
          "Privacy & Policy",
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

// import 'package:flutter/material.dart';
// import 'package:flutter_html/flutter_html.dart';

// class Privacyandpolicy extends StatefulWidget {
//   @override
//   _PrivacyandpolicyState createState() => _PrivacyandpolicyState();
// }

// class _PrivacyandpolicyState extends State<Privacyandpolicy> {
//   @override
//   void initState() {
//     super.initState();
//     // fetchTermsAndConditions();
//   }

//   // Corrected multi-line string syntax
//   String termsHtml = """
//        <h1>Privacy Policy</h1>
//     <p>Last Updated: March 19, 2025</p>

//     <h2>1. Introduction</h2>
//     <p>Welcome to our application. This Privacy Policy explains how we collect, use, and protect your information.</p>

//     <h2>2. Information We Collect</h2>
//     <ul>
//         <li>We collect personal data such as name, email, and usage information.</li>
//         <li>Information may be gathered through cookies and analytics tools.</li>
//         <li>We do not sell or share your personal data with third parties without consent.</li>
//     </ul>

//     <h2>3. How We Use Your Information</h2>
//     <p>We use your data to improve our service, personalize your experience, and ensure security.</p>

//     <h2>4. Data Security</h2>
//     <p>We take reasonable measures to protect your data from unauthorized access or misuse.</p>

//     <h2>5. Changes to This Policy</h2>
//     <p>We reserve the right to update this Privacy Policy. Continued use of our service implies acceptance of any changes.</p>

//     <h2>6. Contact Us</h2>
//     <p>If you have any questions, contact us at <a href="mailto:support@example.com">support@example.com</a>.</p>
//  """;
//   // Future<void> fetchTermsAndConditions() async {
//   //   final response = await http.get(Uri.parse("https://example.com/api/terms"));

//   //   if (response.statusCode == 200) {
//   //     setState(() {
//   //       termsHtml = json.decode(response.body)["terms"];
//   //     });
//   //   } else {
//   //     setState(() {
//   //       termsHtml = "<p>Failed to load terms. Please try again later.</p>";
//   //     });
//   //   }
//   // }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           "Privacy and Policy",
//           style: TextStyle(color: Color.fromRGBO(255, 255, 255, 1)),
//         ),
//         iconTheme: const IconThemeData(color: Colors.white),
//         backgroundColor: Color.fromRGBO(21, 55, 146, 1),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: termsHtml.isEmpty
//             ? const Center(child: CircularProgressIndicator())
//             : SingleChildScrollView(
//                 child: Html(
//                   data: termsHtml,
//                 ),
//               ),
//       ),
//     );
//   }
// }
