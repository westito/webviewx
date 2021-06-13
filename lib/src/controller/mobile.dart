import 'package:webview_flutter/webview_flutter.dart';
import 'package:webviewx/src/controller/device.dart';
import 'package:webviewx/src/utils/html_utils.dart';

import 'dart:async' show Future;
import 'package:webviewx/src/utils/source_type.dart';
import 'package:webviewx/src/utils/utils.dart';
import 'package:webviewx/src/utils/view_content_model.dart';

/// Mobile implementation
class MobileWebViewXController extends DeviceWebViewXController {
  /// Webview controller connector
  late WebViewController connector;

  /// Constructor
  MobileWebViewXController({
    required String initialContent,
    required SourceType initialSourceType,
    required bool ignoreAllGestures,
  }) : super(
          initialContent: initialContent,
          initialSourceType: initialSourceType,
          ignoreAllGestures: ignoreAllGestures,
        );

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
  @override
  Future<dynamic> callJsMethod(
    String name,
    List<dynamic> params,
  ) async {
    // This basically will transform a "raw" call (evaluateJavascript)
    // into a little bit more "typed" call, that is - calling a method.
    var result = await connector.evaluateJavascript(
      HtmlUtils.buildJsFunction(name, params),
    );

    // (MOBILE ONLY) Unquotes response if necessary
    //
    // In the mobile version responses from Js to Dart come wrapped in single quotes (')
    // The web works fine because it is already into it's native environment
    return HtmlUtils.unQuoteJsResponseIfNeeded(result);
  }

  /// This function allows you to evaluate 'raw' javascript (e.g: 2+2)
  /// If you need to call a function you should use the method above ([callJsMethod])
  ///
  /// The [inGlobalContext] param should be set to true if you wish to eval your code
  /// in the 'window' context, instead of doing it inside the corresponding iframe's 'window'
  ///
  /// For more info, check Mozilla documentation on 'window'
  @override
  Future<dynamic> evalRawJavascript(
    String rawJavascript, {
    bool inGlobalContext = false, // NO-OP HERE
  }) {
    return connector.evaluateJavascript(rawJavascript);
  }

  /// Returns the current content
  @override
  Future<WebViewContent> getContent() async {
    var currentContent = await connector.currentUrl();

    //TODO clicking new urls should update (at least) the current sourcetype, and maybe the content
    var parsedContent = Uri.tryParse(currentContent!);
    if (parsedContent != null && parsedContent.data != null) {
      currentContent = Uri.decodeFull(currentContent);
    }

    return WebViewContent(
      source: currentContent,
      sourceType: value.sourceType,
    );
  }

  /// Returns a Future that completes with the value true, if you can go
  /// back in the history stack.
  @override
  Future<bool> canGoBack() {
    return connector.canGoBack();
  }

  /// Go back in the history stack.
  @override
  Future<void> goBack() {
    return connector.goBack();
  }

  /// Returns a Future that completes with the value true, if you can go
  /// forward in the history stack.
  @override
  Future<bool> canGoForward() {
    return connector.canGoForward();
  }

  /// Go forward in the history stack.
  @override
  Future<void> goForward() {
    return connector.goForward();
  }

  /// Reload the current content.
  @override
  Future<void> reload() {
    return connector.reload();
  }
}
