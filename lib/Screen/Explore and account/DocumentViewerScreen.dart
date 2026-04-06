import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class DocumentViewerScreen extends StatefulWidget {
  final String url;
  final String title;

  const DocumentViewerScreen({
    super.key,
    required this.url,
    required this.title,
  });

  @override
  State<DocumentViewerScreen> createState() => _DocumentViewerScreenState();
}

class _DocumentViewerScreenState extends State<DocumentViewerScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;
  int _loadingProgress = 0;

  // Professional solid color palette (matching other screens)
  static const _primaryColor = Color(0xFF1E88E5);
  static const _surfaceColor = Colors.white;
  static const _backgroundLight = Color(0xFFF8FAFF);
  static const _textPrimary = Color(0xFF1F2937);
  static const _textSecondary = Color(0xFF6B7280);
  static const _errorColor = Color(0xFFEF4444);
  static const _borderColor = Color(0xFFE5E7EB);

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    final viewerUrl = _getViewerUrl(widget.url);

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(_surfaceColor)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) {
              setState(() {
                _isLoading = true;
                _hasError = false;
              });
            }
          },
          onProgress: (progress) {
            if (mounted) {
              setState(() => _loadingProgress = progress);
            }
          },
          onPageFinished: (_) {
            if (mounted) {
              setState(() => _isLoading = false);
            }
          },
          onWebResourceError: (error) {
            if (mounted) {
              setState(() {
                _isLoading = false;
                _hasError = true;
              });
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(viewerUrl));
  }

  String _getViewerUrl(String url) {
    final lower = url.toLowerCase();
    if (lower.endsWith('.pdf') || lower.contains('.pdf')) {
      return 'https://docs.google.com/gview?embedded=true&url=${Uri.encodeComponent(url)}';
    }
    return url;
  }

  Future<void> _openInBrowser() async {
    try {
      final uri = Uri.parse(widget.url);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Could not open in browser.'),
          backgroundColor: _errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundLight,
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: _primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () => _controller.reload(),
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Reload',
          ),
          IconButton(
            onPressed: _openInBrowser,
            icon: const Icon(Icons.open_in_browser, color: Colors.white),
            tooltip: 'Open in Browser',
          ),
        ],
      ),
      body: Stack(
        children: [
          // WebView (solid background)
          if (!_hasError)
            Container(
              color: _surfaceColor,
              child: WebViewWidget(controller: _controller),
            ),

          // Loading indicator (flat, solid colors)
          if (_isLoading && !_hasError)
            Container(
              color: _surfaceColor,
              child: Column(
                children: [
                  LinearProgressIndicator(
                    value: _loadingProgress / 100,
                    backgroundColor: _borderColor,
                    valueColor: const AlwaysStoppedAnimation<Color>(_primaryColor),
                    minHeight: 3,
                  ),
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(
                            color: _primaryColor,
                            strokeWidth: 3,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Loading document...',
                            style: TextStyle(
                              color: _textSecondary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (_loadingProgress > 0 && _loadingProgress < 100)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                '$_loadingProgress%',
                                style: TextStyle(
                                  color: _textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Error state (modern, helpful)
          if (_hasError)
            Container(
              color: _surfaceColor,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 72,
                        color: _errorColor,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Unable to Load Document',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: _textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'The document could not be displayed.\nTry opening it in your browser instead.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: _textSecondary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 28),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () {
                              setState(() {
                                _isLoading = true;
                                _hasError = false;
                              });
                              _controller.reload();
                            },
                            icon: const Icon(Icons.refresh, size: 18),
                            label: const Text('Retry'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _primaryColor,
                              side: const BorderSide(color: _primaryColor, width: 1.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton.icon(
                            onPressed: _openInBrowser,
                            icon: const Icon(Icons.open_in_browser, size: 18),
                            label: const Text('Open in Browser'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}