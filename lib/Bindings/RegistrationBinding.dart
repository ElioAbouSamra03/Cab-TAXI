import 'package:cabtaxi/Controllers/RegistrationController.dart';
import 'package:get/get.dart';

class Registrationbinding extends Bindings{
  @override
  void dependencies() {
    Get.lazyPut<RegistrationController>(() => RegistrationController());
  }
}