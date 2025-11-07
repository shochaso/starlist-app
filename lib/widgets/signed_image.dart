import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../services/cdn_analytics.dart';
import '../services/signed_url_client.dart';

typedef SignedImagePlaceholderBuilder = Widget Function(BuildContext context);

/// Displays a Supabase Storage object that requires a signed URL. The widget
/// automatically refreshes the URL when it expires (HTTP 401/403) and caches
/// the most recent response in-memory for smoother UX.
class SignedImage extends StatefulWidget {
  const SignedImage({
    super.key,
    required this.objectPath,
    this.initialUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorPlaceholder,
    this.borderRadius,
  });

  final String objectPath;
  final String? initialUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final SignedImagePlaceholderBuilder? placeholder;
  final SignedImagePlaceholderBuilder? errorPlaceholder;
  final BorderRadius? borderRadius;

  @override
  State<SignedImage> createState() => _SignedImageState();
}

class _SignedImageState extends State<SignedImage> {
  late final SignedUrlClient _client;
  String? _currentUrl;
  bool _resolving = false;
  Object? _lastError;

  @override
  void initState() {
    super.initState();
    _client = SignedUrlClient();
    _currentUrl = widget.initialUrl;
    if (_currentUrl == null) {
      _refresh(force: true);
    } else {
      _refresh(force: false);
    }
  }

  @override
  void didUpdateWidget(covariant SignedImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.objectPath != widget.objectPath) {
      _currentUrl = widget.initialUrl;
      _refresh(force: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius;
    Widget child;
    if (_currentUrl == null) {
      child = _buildPlaceholder(context, isError: _lastError != null);
    } else {
      child = Image.network(
        _currentUrl!,
        key: ValueKey(_currentUrl),
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        errorBuilder: (context, error, stackTrace) {
          _handleLoadError(error);
          return _buildPlaceholder(context, isError: true);
        },
      );
    }
    if (radius != null) {
      child = ClipRRect(borderRadius: radius, child: child);
    }
    return child;
  }

  Widget _buildPlaceholder(BuildContext context, {required bool isError}) {
    final builder =
        isError ? widget.errorPlaceholder ?? widget.placeholder : widget.placeholder;
    if (builder != null) {
      return builder(context);
    }
    return Container(
      width: widget.width,
      height: widget.height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.18),
        borderRadius: widget.borderRadius,
      ),
      child: isError
          ? const Icon(Icons.image_not_supported_outlined, size: 24)
          : const CircularProgressIndicator(strokeWidth: 2),
    );
  }

  Future<void> _refresh({required bool force}) async {
    if (_resolving) {
      return;
    }
    _resolving = true;
    try {
      final nextUrl = _currentUrl == null || force
          ? await _client.getSignedUrl(widget.objectPath)
          : await _client.ensureFresh(widget.objectPath, _currentUrl!);
      if (!mounted) return;
      setState(() {
        _currentUrl = nextUrl;
        _lastError = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _lastError = error;
      });
      if (kDebugMode) {
        debugPrint('[SignedImage] failed to refresh ${widget.objectPath}: $error');
      }
    } finally {
      _resolving = false;
    }
  }

  void _handleLoadError(Object error) {
    if (error is NetworkImageLoadException) {
      if (error.statusCode == 401 || error.statusCode == 403) {
        CdnAnalytics.instance.recordError(bucket: 'private', error: error);
        _refresh(force: true);
        return;
      }
    }
    if (kDebugMode) {
      debugPrint('[SignedImage] load error for ${widget.objectPath}: $error');
    }
    setState(() => _lastError = error);
  }
}
