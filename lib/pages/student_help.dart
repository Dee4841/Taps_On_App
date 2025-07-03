import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class StudentHelpPage extends StatelessWidget {
  final Uri _url = Uri.parse('https://www.sadag.org/index.php?option=com_content&view=article&id=1904&Itemid=151');

  Future<void> _launchUrl() async {
    if (!await launchUrl(_url, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $_url';
    }
  }

  @override
  Widget build(BuildContext context) {
    _launchUrl(); // Launch the site when the page opens
    return Scaffold(
      appBar: AppBar(title: Text('Student Help')),
      body: Center(child: Text('Opening Student Help site...')),
    );
  }
}
