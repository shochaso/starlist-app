import "package:flutter_test/flutter_test.dart";
import "package:mockito/mockito.dart";
import "package:starlist_app/src/features/privacy/models/privacy_settings.dart";
import "package:starlist_app/src/features/privacy/providers/privacy_provider.dart";
import "package:starlist_app/src/features/privacy/services/privacy_service.dart";

class MockPrivacyService extends Mock implements PrivacyService {}

void main() {
  late PrivacyProvider provider;
  late MockPrivacyService mockService;

  setUp(() {
    mockService = MockPrivacyService();
    provider = PrivacyProvider(mockService);
  });

  test("initial state", () {
    expect(provider.settings, null);
    expect(provider.isLoading, false);
    expect(provider.error, null);
  });

  test("load user privacy settings", () async {
    final settings = PrivacySettings(
      isProfilePublic: true,
      showEmail: false,
      showPhone: false,
      showLocation: false,
      allowFriendRequests: true,
      allowMessages: true,
      allowComments: true,
      allowNotifications: true,
      blockedUsers: [],
    );

    when(mockService.getUserPrivacySettings("user-id")).thenAnswer((_) async => settings);

    await provider.loadUserPrivacySettings("user-id");

    expect(provider.settings, settings);
    expect(provider.isLoading, false);
    expect(provider.error, null);
  });

  test("update privacy settings", () async {
    final settings = PrivacySettings(
      isProfilePublic: false,
      showEmail: true,
      showPhone: true,
      showLocation: true,
      allowFriendRequests: false,
      allowMessages: false,
      allowComments: false,
      allowNotifications: false,
      blockedUsers: [],
    );

    when(mockService.updatePrivacySettings("user-id", settings)).thenAnswer((_) async {});

    await provider.updatePrivacySettings("user-id", settings);

    expect(provider.settings, settings);
    expect(provider.isLoading, false);
    expect(provider.error, null);
  });

  test("block user", () async {
    final settings = PrivacySettings(
      isProfilePublic: true,
      showEmail: false,
      showPhone: false,
      showLocation: false,
      allowFriendRequests: true,
      allowMessages: true,
      allowComments: true,
      allowNotifications: true,
      blockedUsers: [],
    );

    when(mockService.blockUser("user-id", "blocked-user-id")).thenAnswer((_) async {
      return null;
    });

    provider._settings = settings;
    await provider.blockUser("user-id", "blocked-user-id");

    expect(provider.settings?.blockedUsers.contains("blocked-user-id"), true);
    expect(provider.isLoading, false);
    expect(provider.error, null);
  });

  test("unblock user", () async {
    final settings = PrivacySettings(
      isProfilePublic: true,
      showEmail: false,
      showPhone: false,
      showLocation: false,
      allowFriendRequests: true,
      allowMessages: true,
      allowComments: true,
      allowNotifications: true,
      blockedUsers: ["blocked-user-id"],
    );

    when(mockService.unblockUser("user-id", "blocked-user-id")).thenAnswer((_) async {
      return null;
    });

    provider._settings = settings;
    await provider.unblockUser("user-id", "blocked-user-id");

    expect(provider.settings?.blockedUsers.contains("blocked-user-id"), false);
    expect(provider.isLoading, false);
    expect(provider.error, null);
  });

  test("is user blocked", () async {
    when(mockService.isUserBlocked("user-id", "target-user-id")).thenAnswer((_) async => true);

    final isBlocked = await provider.isUserBlocked("user-id", "target-user-id");

    expect(isBlocked, true);
    expect(provider.error, null);
  });
}
