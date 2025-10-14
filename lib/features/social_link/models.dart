import 'package:flutter/material.dart';

enum SocialProvider { google, x, instagram }

enum SocialLinkStatus { connected, expired, disconnected }

enum SocialLinkAction { connected, disconnected, failed }

String providerFromJson(String value) => value.toLowerCase();

@immutable
class SocialAccount {
  const SocialAccount({
    required this.id,
    required this.provider,
    required this.status,
    this.displayName,
    this.expiresAt,
  });

  factory SocialAccount.fromJson(Map<String, dynamic> json) {
    final provider = _parseProvider(json['provider'] as String? ?? 'google');
    final expiresRaw = json['expires_at']?.toString();
    final expiresAt = expiresRaw != null ? DateTime.tryParse(expiresRaw) : null;
    final status = _parseStatus(
      json['status'] as String? ??
          (expiresAt != null && expiresAt.isBefore(DateTime.now())
              ? 'expired'
              : 'connected'),
    );
    return SocialAccount(
      id: json['id']?.toString() ?? '',
      provider: provider,
      status: status,
      displayName: json['display_name'] as String?,
      expiresAt: expiresAt,
    );
  }

  final String id;
  final SocialProvider provider;
  final SocialLinkStatus status;
  final String? displayName;
  final DateTime? expiresAt;

  static SocialProvider _parseProvider(String value) {
    switch (value.toLowerCase()) {
      case 'google':
        return SocialProvider.google;
      case 'instagram':
        return SocialProvider.instagram;
      case 'x':
      case 'twitter':
        return SocialProvider.x;
      default:
        return SocialProvider.google;
    }
  }

  static SocialLinkStatus _parseStatus(String value) {
    switch (value.toLowerCase()) {
      case 'connected':
        return SocialLinkStatus.connected;
      case 'expired':
        return SocialLinkStatus.expired;
      default:
        return SocialLinkStatus.disconnected;
    }
  }
}

@immutable
class SocialLinkLog {
  const SocialLinkLog({
    required this.provider,
    required this.action,
    required this.timestamp,
    this.message,
  });

  factory SocialLinkLog.fromJson(Map<String, dynamic> json) {
    final provider =
        SocialAccount._parseProvider(json['provider'] as String? ?? 'google');
    final action = _parseAction(json['action'] as String? ?? 'connected');
    return SocialLinkLog(
      provider: provider,
      action: action,
      timestamp: json['timestamp']?.toString() ?? '',
      message: json['message'] as String?,
    );
  }

  final SocialProvider provider;
  final SocialLinkAction action;
  final String timestamp;
  final String? message;

  static SocialLinkAction _parseAction(String value) {
    switch (value.toLowerCase()) {
      case 'disconnected':
        return SocialLinkAction.disconnected;
      case 'failed':
        return SocialLinkAction.failed;
      default:
        return SocialLinkAction.connected;
    }
  }
}

extension SocialLinkActionLabel on SocialLinkAction {
  String get label {
    switch (this) {
      case SocialLinkAction.connected:
        return '連携しました';
      case SocialLinkAction.disconnected:
        return '連携を解除しました';
      case SocialLinkAction.failed:
        return '連携に失敗しました';
    }
  }
}

extension SocialProviderMeta on SocialProvider {
  String get displayName {
    switch (this) {
      case SocialProvider.google:
        return 'Google';
      case SocialProvider.x:
        return 'X (Twitter)';
      case SocialProvider.instagram:
        return 'Instagram';
    }
  }

  IconData get icon {
    switch (this) {
      case SocialProvider.google:
        return Icons.account_circle;
      case SocialProvider.x:
        return Icons.alternate_email;
      case SocialProvider.instagram:
        return Icons.camera_alt_outlined;
    }
  }

  Color get brandColor {
    switch (this) {
      case SocialProvider.google:
        return const Color(0xFF4285F4);
      case SocialProvider.x:
        return Colors.black;
      case SocialProvider.instagram:
        return const Color(0xFFE1306C);
    }
  }

  String get connectLabel {
    switch (this) {
      case SocialProvider.google:
        return 'Googleと連携する';
      case SocialProvider.x:
        return 'Xと連携する';
      case SocialProvider.instagram:
        return 'Instagramと連携する';
    }
  }
}

class SocialLinkStatusStyle {
  const SocialLinkStatusStyle({
    required this.badge,
    this.borderColor,
    this.borderWidth = 1.0,
  });

  final Widget badge;
  final Color? borderColor;
  final double borderWidth;
}

extension SocialLinkStatusMeta on SocialLinkStatus {
  SocialLinkStatusStyle style(ColorScheme scheme) {
    switch (this) {
      case SocialLinkStatus.connected:
        return SocialLinkStatusStyle(
          badge: _StatusBadge('連携中', scheme.primary),
          borderColor: scheme.primary.withOpacity(0.4),
          borderWidth: 1.4,
        );
      case SocialLinkStatus.expired:
        return const SocialLinkStatusStyle(
          badge: _StatusBadge('再認証が必要', Colors.orange),
          borderColor: Colors.orange,
          borderWidth: 1.4,
        );
      case SocialLinkStatus.disconnected:
        return const SocialLinkStatusStyle(
          badge: _StatusBadge('未連携', Colors.grey),
        );
    }
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge(this.label, this.color);

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
