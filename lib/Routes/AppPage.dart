import 'package:cabtaxi/Bindings/DashboardBindings.dart';
import 'package:cabtaxi/Bindings/HomePageBindings.dart';
import 'package:cabtaxi/Bindings/LoginBindings.dart';
import 'package:cabtaxi/Bindings/MapPageBinding.dart';
import 'package:cabtaxi/Bindings/RegistrationBinding.dart';
import 'package:cabtaxi/Routes/AppRoute.dart';
import 'package:cabtaxi/Views/DashboardPage.dart';
import 'package:cabtaxi/Views/HomePage.dart';
import 'package:cabtaxi/Views/Login.dart';
import 'package:cabtaxi/Views/Registration.dart';
import 'package:cabtaxi/Views/MapPage.dart';
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
GetPage(
  name: AppRoute.MapPage,
  page: () => MapPage(),
  binding: MapPagebindings(),
),
GetPage(
  name: AppRoute.HomePage,
  page: () => HomePage(),
  binding: Homepagebindings(),
),
GetPage(
  name: AppRoute.DashboardPage,
  page: () => DashboardPage(),
  binding: Dashboardbindings(),
),
];

}