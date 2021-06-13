part of 'device.dart';

class _WindowsWebViewXWidgetState extends State<WebViewXWidget> {
  late WebviewController originalWebViewController;
  late WindowsWebViewXController webViewXController;

  late bool _ignoreAllGestures;

  @override
  void initState() {
    super.initState();

    _ignoreAllGestures = widget.ignoreAllGestures;
    webViewXController = _createWindowsWebViewXController();
  }

  Future<WebviewController> initPlatformState() async {
    await originalWebViewController.initialize();

    originalWebViewController = WebviewController();
    webViewXController.connector = originalWebViewController;

    if (widget.onWebViewCreated != null) {
      widget.onWebViewCreated!(webViewXController);
    }

    return originalWebViewController;

    //if (!mounted) return;

    //setState(() {});
  }

  WindowsWebViewXController _createWindowsWebViewXController() {
    return WindowsWebViewXController(
      initialContent: widget.initialContent,
      initialSourceType: widget.initialSourceType,
      ignoreAllGestures: _ignoreAllGestures,
    )
      ..addListener(_handleChange)
      ..ignoreAllGesturesNotifier.addListener(
        _handleIgnoreGesturesChange,
      );
  }

  // Called when WebViewXController updates it's value
  Future<void> _handleChange() async {
    final newContentModel = webViewXController.value;

    if (newContentModel.sourceType == SourceType.HTML) {
      await originalWebViewController
          .loadStringContent(_prepareContent(newContentModel));
    } else {
      await originalWebViewController.loadUrl(newContentModel.content);
    }
  }

  // Called when the ValueNotifier inside WebViewXController updates it's value
  void _handleIgnoreGesturesChange() {
    setState(() {
      _ignoreAllGestures = webViewXController.ignoringAllGestures;
    });
  }

  // Prepares the source depending if it is HTML or URL
  String _prepareContent(ViewContentModel model) {
    return HtmlUtils.preprocessSource(
      model.content,
      jsContent: widget.jsContent,

      // Needed for mobile webview in order to URI-encode the HTML
      encodeHtml: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget webview = SizedBox(
        width: widget.width,
        height: widget.height,
        child: FutureBuilder<WebviewController>(
          future: initPlatformState(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Webview(snapshot.data!);
            } else {
              return Container();
            }
          },
        ));

    return IgnorePointer(
      ignoring: widget.ignoreAllGestures,
      child: webview,
    );
  }
}
