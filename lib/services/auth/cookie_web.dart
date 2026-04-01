import 'dart:html' as html;

void setAuthCookie(String token) {
  final isHttps = html.window.location.protocol == 'https:';
  final secure = isHttps ? '; Secure' : '';
  html.document.cookie = 'auth-token=$token; path=/; SameSite=Lax$secure';
}
void clearAuthCookie() {
  html.document.cookie = 'auth-token=; path=/; Max-Age=0; SameSite=Lax';
}
