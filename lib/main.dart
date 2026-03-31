import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'common/constants/route_names.dart';
import 'common/constants/text_constants.dart';
import 'common/constants/theme_constants.dart';
import 'router/app_router.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: TextConstants.appTitle,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: ThemeColors.primarySeed),
        useMaterial3: true,
      ),
      initialRoute: RouteNames.splash,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
