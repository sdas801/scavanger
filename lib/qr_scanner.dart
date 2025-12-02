import 'package:flutter/material.dart';
import 'dart:developer';
import 'dart:io';
// import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_code_dart_scan/qr_code_dart_scan.dart';

class QRScanner extends StatefulWidget {
  const QRScanner({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRScannerState();
}

class _QRScannerState extends State<QRScanner> {
  // Barcode? result;
  var isLoading = false;
  // QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  BuildContext? sContext;

  void _vefiryToken(String token) {
    print('Token: $token');
    final nestedUri = Uri.parse(token);
    String? nestedQry = nestedUri.queryParameters['qry'];
    // Navigator.of(sContext as BuildContext).pop();
    Navigator.pop(sContext as BuildContext, nestedQry);
  }

  Future<void> _showErrorDialog() async {
    return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)), //this right here
            child: Container(
              height: 240,
              child: Padding(
                padding: const EdgeInsets.all(1.0),
                child: Column(
                  children: [
                    Container(
                        alignment: Alignment.topRight,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.pop(sContext as BuildContext, false);
                          },
                          style: ElevatedButton.styleFrom(
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(5),
                            backgroundColor: Colors.black, // <-- Button color
                            foregroundColor: Colors.red, // <-- Splash color
                          ),
                          child: const Icon(Icons.close, color: Colors.white),
                        )),
                    Container(
                      alignment: Alignment.center,
                      child: const Text('Error',
                          style: TextStyle(fontSize: 42, color: Colors.red)),
                    ),
                    Container(
                      alignment: Alignment.center,
                      child: const Text('Oops! Something went wrong',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black)),
                    ),
                    Container(
                      padding: const EdgeInsets.only(top: 20),
                      alignment: Alignment.center,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          reassemble();
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.only(left: 20, right: 20),
                          backgroundColor: Colors.red, // <-- Button color
                          foregroundColor: Colors.red, // <-- Splash color
                        ),
                        child: const Text('Try Again',
                            style:
                                TextStyle(fontSize: 20, color: Colors.white)),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  void verifyQRCode(String qrCode) async {
    // pauseCamera();
    setState(() {
      isLoading = true;
    });
    // await Future.delayed(const Duration(seconds: 2));
    _vefiryToken(qrCode);
  }

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  /* @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  void pauseCamera() {
    controller!.pauseCamera();
  } */

  @override
  Widget build(BuildContext context) {
    sContext = context;
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(flex: 4, child: _buildQrView(context)),
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 250.0
        : 400.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    /* return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    ); */
    return QRCodeDartScanView(
      scanInvertedQRCode: true,
      typeScan: TypeScan.live,
      onCapture: (Result result) {
        // do anything with result
        // result.text
        // result.rawBytes
        // result.resultPoints
        // result.format
        // result.numBits
        // result.resultMetadata
        // result.time
        verifyQRCode(result.text);
      },
    );
  }

  /* void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      verifyQRCode(scanData.code as String);
      setState(() {
        result = scanData;
      });
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  } */

  @override
  void dispose() {
    super.dispose();
  }
}
