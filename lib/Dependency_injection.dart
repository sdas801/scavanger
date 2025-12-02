import 'package:get/get.dart';
import 'package:scavenger_app/networkcheck.dart';

class DependencyInjection {
  static void init() {
    Get.put<NetworkController>(NetworkController(), permanent: true);
  }
}
