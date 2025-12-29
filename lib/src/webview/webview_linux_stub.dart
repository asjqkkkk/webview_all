import 'package:flutter/widgets.dart';

/// Placeholder used when the Linux WebView implementation is not available.
class WebviewLinux extends StatelessWidget {
  final String url;

  const WebviewLinux({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    throw UnsupportedError(
      'WebviewLinux is unavailable on this platform. '
      'This stub should never be built.',
    );
  }
}
