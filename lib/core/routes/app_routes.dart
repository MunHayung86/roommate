import 'package:flutter/material.dart';
import 'package:roommate/features/auth/login_page.dart';
import 'package:roommate/features/navigation.dart';


class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    '/login': (context) => LoginPage(),
    '/' : (context) => Navigation(),
  };
}