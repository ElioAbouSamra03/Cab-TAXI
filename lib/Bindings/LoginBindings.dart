import 'package:cabtaxi/Controllers/LoginController.dart';
import 'package:get/get.dart';

class Loginbindings extends Bindings{
  @override
  void dependencies() {
    Get.lazyPut<Logincontroller>(() => Logincontroller());
  }
}