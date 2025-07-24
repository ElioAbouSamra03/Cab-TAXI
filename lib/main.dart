import 'package:cabtaxi/Views/HomePage.dart';
import 'package:cabtaxi/Routes/AppRoute.dart';
import 'package:cabtaxi/Views/Login.dart';
import 'package:cabtaxi/Views/MapPage.dart';
import 'package:cabtaxi/Views/Registration.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  runApp(CabTaxiApp());
}

class CabTaxiApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoute.HomePage,
      getPages: [
        GetPage(name: AppRoute.HomePage, page: () => HomePage()),
        GetPage(name: AppRoute.Register, page: () => Registration()),
        GetPage(name: AppRoute.login, page: () => Login()),
        GetPage(name: AppRoute.MapPage, page: () => MapPage()),
      ],
    );
  }
}
