import 'package:url_launcher/url_launcher.dart';

class UrlLauncherFunc {
  Future<void> launchUrlWidget(String url) async {
    final Uri uri = Uri.parse(url);

    if (!await launchUrl(uri, webOnlyWindowName: '_blank')) {
      throw Exception('Could not launch $url');
    }
  }
}
