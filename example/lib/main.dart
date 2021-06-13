import 'package:flutter/material.dart';
import 'package:webview_windows/webview_windows.dart';

import 'webview_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WebViewX Example App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WebViewXPage(),
    );
  }
}