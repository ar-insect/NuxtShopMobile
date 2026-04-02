import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../repositories/auth_repository.dart';
import '../../services/auth/auth_token_provider.dart';
import '../../services/auth/auth_token_store.dart';
import '../../services/auth/cookie.dart';
import '../../common/constants/text_constants.dart';
import '../../router/app_router.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository());

class LoginPage extends ConsumerStatefulWidget {
  final bool fromLogout;
  const LoginPage({super.key, this.fromLogout = false});
  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _usernameCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();
  bool _loading = false;
  @override
  void initState() {
    super.initState();
    if (widget.fromLogout) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已退出登录')));
      });
    }
  }
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
      await AuthTokenStore.save(token);
      ref.read(authTokenProvider.notifier).state = token;
      setAuthCookie(token);
      if (mounted) {
        AppRouter.goHome(context);
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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => AppRouter.goHome(context),
        ),
        title: const Text(TextConstants.loginTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _usernameCtrl, keyboardType: TextInputType.text, decoration: const InputDecoration(labelText: TextConstants.usernameLabel)),
            const SizedBox(height: 12),
            TextField(controller: _pwdCtrl, obscureText: true, decoration: const InputDecoration(labelText: TextConstants.passwordLabel)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _login,
                child: _loading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text(TextConstants.loginButton),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
