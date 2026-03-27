import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_repository.dart';
import 'auth_token_provider.dart';
import '../products/product_list_page.dart';
import 'cookie.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository());

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});
  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _usernameCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();
  bool _loading = false;
  @override
  void dispose() {
    _usernameCtrl.dispose();
    _pwdCtrl.dispose();
    super.dispose();
  }
  Future<void> _login() async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      final repo = ref.read(authRepositoryProvider);
      final token = await repo.login(username: _usernameCtrl.text.trim(), password: _pwdCtrl.text);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      ref.read(authTokenProvider.notifier).state = token;
      setAuthCookie(token);
      if (mounted) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const ProductListPage()));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('登录')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _usernameCtrl, keyboardType: TextInputType.text, decoration: const InputDecoration(labelText: '用户名')),
            const SizedBox(height: 12),
            TextField(controller: _pwdCtrl, obscureText: true, decoration: const InputDecoration(labelText: '密码')),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _login,
                child: _loading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('登录'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
