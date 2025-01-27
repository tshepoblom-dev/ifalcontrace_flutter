import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

const String kNavigationExamplePage = '''
<!DOCTYPE html><html>
<head><title>Navigation Delegate Example</title></head>
<body>
<p>
The navigation delegate is set to block navigation to the youtube website.
</p>
<ul>
<ul><a href="https://www.youtube.com/">https://www.youtube.com/</a></ul>
<ul><a href="https://www.google.com/">https://www.google.com/</a></ul>
</ul>
</body>
</html>
''';

class WebViewScreen extends StatefulWidget {
  static const routeName = '/passArguments';
  final String title;
  final String url;


  const WebViewScreen({
    super.key,
    required this.title,
    required this.url,
  });

  @override
  _WebViewScreenState createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late String title;
  late String selectedUrl;
  late bool isLoading;
  late WebViewController _controller;
  late Timer _timer;

  @override
  void initState() {
    super.initState();

        // #docregion platform_features
        late final PlatformWebViewControllerCreationParams params;
        if (WebViewPlatform.instance is WebKitWebViewPlatform) {
          params = WebKitWebViewControllerCreationParams(
            allowsInlineMediaPlayback: true,
            mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
          );
        } else {
          params = const PlatformWebViewControllerCreationParams();
        }

        final WebViewController controller =
        WebViewController.fromPlatformCreationParams(params);
        // #enddocregion platform_features

        controller
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onProgress: (int progress) {
                debugPrint('WebView is loading (progress : $progress%)');
              },
              onPageStarted: (String url) {
                debugPrint('Page started loading: $url');
              },
              onPageFinished: (String url) {
                debugPrint('Page finished loading: $url');
              },
              onWebResourceError: (WebResourceError error) {
                debugPrint('''
Page resource error:
  code: ${error.errorCode}
  description: ${error.description}
  errorType: ${error.errorType}
  isForMainFrame: ${error.isForMainFrame}
          ''');
              },
              onNavigationRequest: (NavigationRequest request) {
                if (request.url.startsWith('https://www.youtube.com/')) {
                  debugPrint('blocking navigation to ${request.url}');
                  return NavigationDecision.prevent;
                }
                debugPrint('allowing navigation to ${request.url}');
                return NavigationDecision.navigate;
              },
            ),
          )
          ..addJavaScriptChannel(
            'Toaster',
            onMessageReceived: (JavaScriptMessage message) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(message.message)),
              );
            },
          )
          ..loadRequest(Uri.parse(widget.url));

        // #docregion platform_features
        if (controller.platform is AndroidWebViewController) {
          AndroidWebViewController.enableDebugging(true);
          (controller.platform as AndroidWebViewController)
              .setMediaPlaybackRequiresUserGesture(false);
        }
        // #enddocregion platform_features

        _controller = controller;
        setState(() {

        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        // This drop down menu demonstrates that Flutter widgets can be shown over the web view.
      ),
      body: WebViewWidget(controller: _controller),
      floatingActionButton: favoriteButton(),
    );
  }

  Widget favoriteButton() {
    return FloatingActionButton(
      onPressed: () async {
        final String? url = await _controller.currentUrl();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Favorited $url')),
        );
      },
      child: const Icon(Icons.favorite),
    );
  }
}