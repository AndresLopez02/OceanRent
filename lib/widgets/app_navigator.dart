import 'package:flutter/material.dart';
import 'package:ocean_rent/pages/login/login_page.dart';

class AppNavigator {
  static void goToLogin(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const LoginPage()));
  }
}

