import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splash_navigator/feature_mixin.dart';
import 'package:splash_navigator/main.dart';
import 'package:splash_navigator/onboarding_screen.dart';
import 'package:webview_flutter/webview_flutter.dart';

// Import for iOS features.
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class FeatureView extends StatefulWidget {
  const FeatureView({super.key});

  @override
  State<FeatureView> createState() => _FeatureViewState();

  static Widget builder(BuildContext context) {
    return FeatureView();
  }
}

class _FeatureViewState extends State<FeatureView> with ConfigMixin {
  late final WebViewController _controller;

  bool _isAppInfoLoading = true;

  @override
  void initState() {
    super.initState();

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

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {},
          onPageStarted: (String url) {},
          onPageFinished: (String url) async {
            if (url == targetData) {
              //TODO ЛОГИКА ПРОВЕРКИ ПРОЙДЕН ЛИ ОНБОРДИНГ - ЕСЛИ НЕТ ТО В MAIN
              return;
            }
            setState(() => _isAppInfoLoading = false);
          },
          onWebResourceError: (WebResourceError error) {
            if (error.errorCode == -1009) {}
          },
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
          onUrlChange: (UrlChange change) {
            if (change.url != null) {
              saveLastVisitedUrl(change.url!);
            }
          },
        ),
      );

    if (controller.platform is WebKitWebViewController) {
      (controller.platform as WebKitWebViewController)
          .setAllowsBackForwardNavigationGestures(true);
    }

    _controller = controller;

    final urlToLoad = loadTargetUrl();
    _controller.loadRequest(Uri.parse(urlToLoad));
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor:
      _isAppInfoLoading ? null : CupertinoColors.darkBackgroundGray,
      child: _isAppInfoLoading
          ? const _AppInfoLoadingState()
          : SafeArea(child: _AppInfoLoadedState(controller: _controller)),
    );
  }
}

class _AppInfoLoadingState extends StatelessWidget {
  const _AppInfoLoadingState();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF900e52),
      width: double.infinity,
      height: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Image.asset(
              'assets/images/icon.png',
              width: 120,
              height: 120,
            ),
          ),
          const SizedBox(height: 25),
          const CupertinoActivityIndicator(
            color: CupertinoColors.white,
            radius: 16,
          ),
        ],
      ),
    );
  }
}

class _AppInfoLoadedState extends StatelessWidget {
  final WebViewController controller;

  const _AppInfoLoadedState({required this.controller});

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: controller);
  }
}