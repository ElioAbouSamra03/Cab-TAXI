import 'package:cabtaxi/Controllers/HomePageController.dart';
import 'package:get/get.dart';

class Homepagebindings extends Bindings{
  @override
  void dependencies() {
    Get.lazyPut<Homepagecontroller>(() => Homepagecontroller());
  }
}