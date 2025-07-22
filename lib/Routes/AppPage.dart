import 'package:cabtaxi/Bindings/LoginBindings.dart';
import 'package:cabtaxi/Bindings/RegistrationBinding.dart';
import 'package:cabtaxi/Routes/AppRoute.dart';
import 'package:cabtaxi/Views/Login.dart';
import 'package:cabtaxi/Views/Registration.dart';
import 'package:get/get_navigation/get_navigation.dart';

class AppPage{
static final List<GetPage> pages = [
GetPage(
  name: AppRoute.Register,
  page: () => Registration(),
  binding: Registrationbinding(),
),
GetPage(
  name: AppRoute.login,
  page: () => Login(),
  binding: Loginbindings(),
),
];

}