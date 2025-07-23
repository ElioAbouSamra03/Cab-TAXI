import 'package:cabtaxi/Controllers/DashboardController.dart';
import 'package:get/get.dart';

class Dashboardbindings extends Bindings{
  @override
  void dependencies() {
    Get.lazyPut<Dashboardcontroller>(() => Dashboardcontroller());
  }
}