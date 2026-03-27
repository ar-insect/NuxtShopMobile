import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/products/product_list_page.dart';
import 'features/auth/login_page.dart';
import 'features/auth/auth_token_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/auth/cookie.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const StartupGate(),
    );
  }
}

class StartupGate extends ConsumerStatefulWidget {
  const StartupGate({super.key});
  @override
  ConsumerState<StartupGate> createState() => _StartupGateState();
}

class _StartupGateState extends ConsumerState<StartupGate> {
  bool _ready = false;
  @override
  void initState() {
    super.initState();
    _init();
  }
  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    ref.read(authTokenProvider.notifier).state = token;
    if (token != null && token.isNotEmpty) {
      setAuthCookie(token);
    }
    if (mounted) setState(() => _ready = true);
  }
  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final token = ref.watch(authTokenProvider);
    if (token != null && token.isNotEmpty) {
      return const ProductListPage();
    }
    return const LoginPage();
  }
}
