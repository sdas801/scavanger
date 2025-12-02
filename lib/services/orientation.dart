import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';

class OrientationService {
  StreamSubscription? _subscription;

  void startListening(Function(String) onOrientationChanged) {
    _subscription = accelerometerEvents.listen((AccelerometerEvent event) {
      double x = event.x, y = event.y;

      String orientation = "Portrait"; // Default

      if (y.abs() > x.abs()) {
        if (y > 0) {
          orientation = "Portrait Upside Down";
        } else {
          orientation = "Portrait";
        }
      } else {
        if (x > 0) {
          orientation = "Landscape Left";
        } else {
          orientation = "Landscape Right";
        }
      }

      onOrientationChanged(orientation);
    });
  }

  void stopListening() {
    _subscription?.cancel();
  }
}
