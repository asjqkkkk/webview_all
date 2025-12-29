/*
 * Copyright (C) 2023-2025 moluopro. All rights reserved.
 * Github: https://github.com/moluopro
 */

import 'package:desktop_webview_linux/desktop_webview_linux.dart';
import 'package:flutter/material.dart';

class WebviewLinux extends StatefulWidget {
  final String url;

  const WebviewLinux({super.key, required this.url});

  @override
  State<WebviewLinux> createState() => _WebviewLinuxState();
}

class _WebviewLinuxState extends State<WebviewLinux> {
  Webview? _webview;
  Object? _error;
  bool _isCreating = false;
  bool _windowClosed = false;
  int _creationRequestId = 0;

  @override
  void initState() {
    super.initState();
    _createWebview();
  }

  @override
  void didUpdateWidget(covariant WebviewLinux oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url && _webview != null) {
      _webview!.launch(widget.url);
    }
  }

  Future<void> _createWebview() async {
    final requestId = ++_creationRequestId;
    setState(() {
      _isCreating = true;
      _error = null;
      _windowClosed = false;
    });

    try {
      final webview = await WebviewWindow.create(
        configuration: CreateConfiguration(
          title: widget.url,
          openMaximized: true,
        ),
      );

      if (!mounted || requestId != _creationRequestId) {
        webview.close();
        return;
      }

      webview.launch(widget.url);
      webview.onClose.then((_) {
        if (!mounted || requestId != _creationRequestId) {
          return;
        }
        setState(() {
          _webview = null;
          _windowClosed = true;
        });
      });

      setState(() {
        _webview = webview;
      });
    } catch (error, stackTrace) {
      debugPrint('Failed to create Linux WebView: $error\n$stackTrace');
      if (!mounted || requestId != _creationRequestId) {
        return;
      }
      setState(() {
        _error = error;
      });
    } finally {
      if (!mounted || requestId != _creationRequestId) {
      } else {
        setState(() {
          _isCreating = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _webview?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return _LinuxWebviewStatusMessage(
        message: 'Failed to open the Linux WebView.',
        actionLabel: 'Retry',
        onActionPressed: () {
          _createWebview();
        },
      );
    }

    if (_isCreating) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_webview == null) {
      return _LinuxWebviewStatusMessage(
        message: _windowClosed
            ? 'The Linux WebView window was closed.'
            : 'The Linux WebView runs in a separate window.',
        actionLabel: _windowClosed ? 'Reopen WebView' : 'Open WebView',
        onActionPressed: () {
          _createWebview();
        },
      );
    }

    return _LinuxWebviewStatusMessage(
      message: 'The Linux WebView is open in a separate window.',
      secondaryActionLabel: 'Bring to front',
      onSecondaryActionPressed: () {
        _webview?.bringToForeground(maximized: true);
      },
    );
  }
}

class _LinuxWebviewStatusMessage extends StatelessWidget {
  final String message;
  final String? actionLabel;
  final VoidCallback? onActionPressed;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryActionPressed;

  const _LinuxWebviewStatusMessage({
    required this.message,
    this.actionLabel,
    this.onActionPressed,
    this.secondaryActionLabel,
    this.onSecondaryActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message,
                style: textTheme.bodyMedium, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            if (actionLabel != null && onActionPressed != null)
              ElevatedButton(
                onPressed: onActionPressed,
                child: Text(actionLabel!),
              ),
            if (secondaryActionLabel != null &&
                onSecondaryActionPressed != null)
              TextButton(
                onPressed: onSecondaryActionPressed,
                child: Text(secondaryActionLabel!),
              ),
          ],
        ),
      ),
    );
  }
}
