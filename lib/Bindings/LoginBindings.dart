import 'package:cabtaxi/Controllers/LoginController.dart';
import 'package:cabtaxi/Controllers/RegistrationController.dart';
import 'package:get/get.dart';

class Loginbindings extends Bindings{
  @override
  void dependencies() {
    Get.lazyPut<Logincontroller>(() => Logincontroller());
  }
}