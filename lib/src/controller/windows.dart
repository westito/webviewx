import 'package:webview_windows/webview_windows.dart';
import 'package:webviewx/src/utils/view_content_model.dart';

import '../../webviewx.dart';
import 'device.dart';

/// Windows implementation
class WindowsWebViewXController extends DeviceWebViewXController {
  /// Webview controller connector
  late WebviewController connector;

  /// Constructor
  WindowsWebViewXController({
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
    return Future.value();
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
    return connector.executeScript(rawJavascript);
  }

  /// Returns the current content
  @override
  Future<WebViewContent> getContent() async {
    var currentContent = await connector.url.first;

    //TODO clicking new urls should update (at least) the current sourcetype, and maybe the content
    var parsedContent = Uri.tryParse(currentContent);
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
    return Future.value(false);
  }

  /// Go back in the history stack.
  @override
  Future<void> goBack() {
    return Future.value();
  }

  /// Returns a Future that completes with the value true, if you can go
  /// forward in the history stack.
  @override
  Future<bool> canGoForward() {
    return Future.value(false);
  }

  /// Go forward in the history stack.
  @override
  Future<void> goForward() {
    return Future.value();
  }

  /// Reload the current content.
  @override
  Future<void> reload() {
    return connector.reload();
  }
}
