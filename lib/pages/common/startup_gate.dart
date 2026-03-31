import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/auth/auth_token_provider.dart';
import '../../services/auth/cookie.dart';
import '../home/home_root_page.dart';

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
    return const HomeRootPage();
  }
}
