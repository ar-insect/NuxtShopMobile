import 'package:web/web.dart' as web;

void setAuthCookie(String token) {
  final isHttps = web.window.location.protocol == 'https:';
  final secure = isHttps ? '; Secure' : '';
  web.document.cookie = 'auth-token=$token; path=/; SameSite=Lax$secure';
}
void clearAuthCookie() {
  web.document.cookie = 'auth-token=; path=/; Max-Age=0; SameSite=Lax';
}
