import 'package:http/http.dart' as http;
import 'package:http/browser_client.dart' as http_browser;

http.Client createHttpClient() {
  final client = http_browser.BrowserClient()..withCredentials = true;
  return client;
}
