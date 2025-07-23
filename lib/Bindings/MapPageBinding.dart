import 'package:cabtaxi/Controllers/LoginController.dart';
import 'package:cabtaxi/Controllers/MapPageController.dart';
import 'package:cabtaxi/Controllers/RegistrationController.dart';
import 'package:get/get.dart';

class MapPagebindings extends Bindings{
  @override
  void dependencies() {
    Get.lazyPut<Mappagecontroller>(() => Mappagecontroller());
  }
}