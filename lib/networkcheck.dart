import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NetworkController extends GetxController {
  final Connectivity _connectivity = Connectivity();

  @override
  void onInit() {
    super.onInit();
    // _checkInitialConnection();
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  // // Check network status when the controller is initialized
  // Future<void> _checkInitialConnection() async {
  //   final connectivityResult = await _connectivity.checkConnectivity();
  //   _updateConnectionStatus(connectivityResult); // Show dialog if no connection
  // }

  void _updateConnectionStatus(ConnectivityResult connectivityResult) {
    if (connectivityResult == ConnectivityResult.none) {
      if (Get.isDialogOpen != true) {
        Get.dialog(
          WillPopScope(
            onWillPop: () async => false, // Disable back button
            child: Dialog(
              backgroundColor: const Color.fromARGB(255, 255, 255, 255),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.wifi_off,
                      color: Color.fromRGBO(11, 0, 171, 1),
                      size: 50,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'PLEASE CONNECT TO THE INTERNET',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(11, 0, 171, 1),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
          barrierDismissible: false,
        );
      }
    } else {
      if (Get.isDialogOpen == true) {
        Get.back(); // Close the dialog when the network is restored
      }
    }
  }
}
