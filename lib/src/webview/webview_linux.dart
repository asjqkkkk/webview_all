/*
 * Copyright (C) 2023-2025 moluopro. All rights reserved.
 * Github: https://github.com/moluopro
 */

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webview_gtk_embed/webview_gtk_embed.dart';

class WebviewLinux extends StatefulWidget {
  final String url;

  const WebviewLinux({super.key, required this.url});

  @override
  State<WebviewLinux> createState() => _WebviewLinuxState();
}

class _WebviewLinuxState extends State<WebviewLinux> {
  WebviewGtkEmbedController? _controller;

  @override
  void dispose() {
    unawaited(_controller?.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GtkWebView(
      initialUrl: widget.url,
      onWebViewCreated: (controller) {
        _controller = controller;
      },
    );
  }
}
