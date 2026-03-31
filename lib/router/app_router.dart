import 'package:flutter/material.dart';
import '../common/constants/route_names.dart';
import '../pages/auth/login_page.dart';
import '../pages/common/startup_gate.dart';
import '../pages/home/home_root_page.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.splash:
        return MaterialPageRoute(builder: (_) => const StartupGate());
      case RouteNames.login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case RouteNames.home:
        return MaterialPageRoute(builder: (_) => const HomeRootPage());
      default:
        return MaterialPageRoute(builder: (_) => const StartupGate());
    }
  }

  static void goLogin(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil(RouteNames.login, (route) => false);
  }

  static void goHome(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil(RouteNames.home, (route) => false);
  }

  static void goSplash(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil(RouteNames.splash, (route) => false);
  }
}
