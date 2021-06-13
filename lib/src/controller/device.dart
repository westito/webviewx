import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webviewx/src/utils/html_utils.dart';

import 'dart:async' show Future, FutureOr;
import 'package:flutter/services.dart' show rootBundle;
import 'package:webviewx/src/utils/source_type.dart';
import 'package:webviewx/src/utils/utils.dart';
import 'package:webviewx/src/utils/view_content_model.dart';

/// Mobile implementation
abstract class DeviceWebViewXController
    extends ValueNotifier<ViewContentModel> {
  /// Boolean value notifier used to toggle ignoring gestures on the webview
  ValueNotifier<bool> ignoreAllGesturesNotifier;

  /// Constructor
  DeviceWebViewXController({
    required String initialContent,
    required SourceType initialSourceType,
    required bool ignoreAllGestures,
  })  : ignoreAllGesturesNotifier = ValueNotifier(ignoreAllGestures),
        super(
          ViewContentModel(
            content: initialContent,
            sourceType: initialSourceType,
          ),
        );

  void _setContent(ViewContentModel model) {
    value = model;
  }

  /// Returns true if the webview's current content is HTML
  bool get isCurrentContentHTML => value.sourceType == SourceType.HTML;

  /// Returns true if the webview's current content is URL
  bool get isCurrentContentURL => value.sourceType == SourceType.URL;

  /// Returns true if the webview's current content is URL, and if
  /// [SourceType] is [SourceType.URL_BYPASS], which means it should
  /// use the bypass to fetch the web page content.
  bool get isCurrentContentURLBypass =>
      value.sourceType == SourceType.URL_BYPASS;

  /// Set webview content to the specified URL.
  /// Example URL: https://flutter.dev
  ///
  /// If [fromAssets] param is set to true,
  /// [url] param must be a String path to an asset
  /// Example: 'assets/some_url.txt'
  void loadContent(
    String content,
    SourceType sourceType, {
    Map<String, String> headers = const {},
    bool fromAssets = false,
  }) async {
    if (fromAssets) {
      var _content = await rootBundle.loadString(content);
      _setContent(ViewContentModel(
        content: _content,
        headers: headers,
        sourceType: sourceType,
      ));
    } else {
      _setContent(ViewContentModel(
        content: content,
        headers: headers,
        sourceType: sourceType,
      ));
    }
  }

  /// Boolean getter which reveals if the gestures are ignored right now
  bool get ignoringAllGestures => ignoreAllGesturesNotifier.value;

  /// Function to set ignoring gestures
  void setIgnoreAllGestures(bool value) {
    ignoreAllGesturesNotifier.value = value;
  }

  /// This function allows you to call Javascript functions defined inside the webview.
  ///
  /// Suppose we have a defined a function (using [EmbeddedJsContent]) as follows:
  ///
  /// ```javascript
  /// function someFunction(param) {
  ///   return 'This is a ' + param;
  /// }
  /// ```
  /// Example call:
  ///
  /// ```dart
  /// var resultFromJs = await callJsMethod('someFunction', ['test'])
  /// print(resultFromJs); // prints "This is a test"
  /// ```
  //TODO This should return an error if the operation failed, but it doesn't
  Future<dynamic> callJsMethod(
    String name,
    List<dynamic> params,
  );

  /// This function allows you to evaluate 'raw' javascript (e.g: 2+2)
  /// If you need to call a function you should use the method above ([callJsMethod])
  ///
  /// The [inGlobalContext] param should be set to true if you wish to eval your code
  /// in the 'window' context, instead of doing it inside the corresponding iframe's 'window'
  ///
  /// For more info, check Mozilla documentation on 'window'
  Future<dynamic> evalRawJavascript(
    String rawJavascript, {
    bool inGlobalContext = false, // NO-OP HERE
  });

  /// Returns the current content
  Future<WebViewContent> getContent();

  /// Returns a Future that completes with the value true, if you can go
  /// back in the history stack.
  Future<bool> canGoBack();

  /// Go back in the history stack.
  Future<void> goBack();

  /// Returns a Future that completes with the value true, if you can go
  /// forward in the history stack.
  Future<bool> canGoForward();

  /// Go forward in the history stack.
  Future<void> goForward();

  /// Reload the current content.
  Future<void> reload();

  /// Dispose resources
  @override
  void dispose() {
    ignoreAllGesturesNotifier.dispose();
    super.dispose();
  }
}
