import 'package:cabtaxi/Controllers/MapPageController.dart';
import 'package:get/get.dart';

class MapPagebindings extends Bindings{
  @override
  void dependencies() {
    Get.lazyPut<Mappagecontroller>(() => Mappagecontroller());
  }
}