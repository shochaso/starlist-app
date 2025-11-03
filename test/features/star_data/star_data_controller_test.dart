import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:starlist_app/core/telemetry/star_data_telemetry.dart';
import 'package:starlist_app/features/star_data/application/star_data_controller.dart';
import 'package:starlist_app/features/star_data/application/star_data_providers.dart';
import 'package:starlist_app/features/star_data/domain/category.dart';
import 'package:starlist_app/features/star_data/domain/star_data.dart';
import 'package:starlist_app/features/star_data/domain/visibility.dart';
import 'package:starlist_app/features/star_data/infrastructure/star_data_repository.dart';

class _MockStarDataRepository extends Mock implements StarDataRepository {}

class _MockStarDataTelemetry extends Mock implements StarDataTelemetry {}

void main() {
  setUpAll(() {
    registerFallbackValue(StarDataCategory.music);
    registerFallbackValue(StarDataCategory.youtube);
    registerFallbackValue(const StarDataControllerArgs(username: 'dummy'));
  });

  StarDataPage _buildPage({
    List<StarData>? items,
    bool isLoggedIn = true,
    bool canViewFollowers = false,
    bool isOwner = false,
    String? nextCursor,
  }) {
    final dataItems = items ??
        [
          StarData(
            id: '1',
            category: StarDataCategory.music,
            title: 'Sample track',
            description: 'Great song',
            serviceIcon: 'assets/service_icons/sample.png',
            url: null,
            imageUrl: null,
            createdAt: DateTime.now().subtract(const Duration(hours: 2)),
            visibility: StarDataVisibility.public,
            starComment: null,
            enrichedMetadata: null,
          ),
        ];

    return StarDataPage(
      profile: const StarProfile(
        username: 'aurora',
        displayName: 'Aurora',
        avatarUrl: null,
        bio: 'Synth artist',
        totalFollowers: 1200,
        snsLinks: StarSnsLinks(),
      ),
      viewerAccess: StarDataViewerAccess(
        isLoggedIn: isLoggedIn,
        canViewFollowersOnlyContent: canViewFollowers,
        isOwner: isOwner,
        canToggleActions: isLoggedIn,
        categoryDigest: {
          for (final category in StarDataCategory.values) category: 0,
        },
      ),
      items: dataItems,
      nextCursor: nextCursor,
    );
  }

  test('initial load uses repository with provided category', () async {
    final repo = _MockStarDataRepository();
    final telemetry = _MockStarDataTelemetry();
    final args = StarDataControllerArgs(
      username: 'aurora',
      initialCategory: StarDataCategory.music,
    );

    when(
      () => repo.fetchStarData(
        username: any(named: 'username'),
        category: any(named: 'category'),
        cursor: any(named: 'cursor'),
      ),
    ).thenAnswer((_) async => _buildPage());

    final container = ProviderContainer(
      overrides: [
        starDataRepositoryProvider.overrideWithValue(repo),
        starDataTelemetryProvider.overrideWithValue(telemetry),
      ],
    );
    addTearDown(container.dispose);

    await container.read(starDataControllerProvider(args).future);

    verify(
      () => repo.fetchStarData(
        username: 'aurora',
        category: StarDataCategory.music,
        cursor: null,
      ),
    ).called(1);

    verify(
      () => telemetry.recordView(
        username: 'aurora',
        category: StarDataCategory.music,
      ),
    ).called(1);
  });

  test('selectCategory fetches new data and records view', () async {
    final repo = _MockStarDataRepository();
    final telemetry = _MockStarDataTelemetry();
    final args = const StarDataControllerArgs(username: 'aurora');

    when(
      () => repo.fetchStarData(
        username: any(named: 'username'),
        category: any(named: 'category'),
        cursor: any(named: 'cursor'),
      ),
    ).thenAnswer((invocation) async {
      final category =
          invocation.namedArguments[#category] as StarDataCategory?;
      return _buildPage(
        items: [
          StarData(
            id: 'item-${category?.apiValue ?? 'all'}',
            category: category ?? StarDataCategory.other,
            title: 'Item',
            description: null,
            serviceIcon: 'assets/service_icons/sample.png',
            url: null,
            imageUrl: null,
            createdAt: DateTime.now(),
            visibility: StarDataVisibility.public,
            starComment: null,
            enrichedMetadata: null,
          ),
        ],
      );
    });

    final container = ProviderContainer(
      overrides: [
        starDataRepositoryProvider.overrideWithValue(repo),
        starDataTelemetryProvider.overrideWithValue(telemetry),
      ],
    );
    addTearDown(container.dispose);

    await container.read(starDataControllerProvider(args).future);

    clearInteractions(repo);
    clearInteractions(telemetry);

    await container
        .read(starDataControllerProvider(args).notifier)
        .selectCategory(StarDataCategory.youtube);

    verify(
      () => repo.fetchStarData(
        username: 'aurora',
        category: StarDataCategory.youtube,
        cursor: null,
      ),
    ).called(1);

    verify(
      () => telemetry.recordView(
        username: 'aurora',
        category: StarDataCategory.youtube,
      ),
    ).called(1);
  });

  test('viewer access toggles digest-only view for anonymous users', () async {
    final repo = _MockStarDataRepository();
    final telemetry = _MockStarDataTelemetry();
    final args = const StarDataControllerArgs(username: 'aurora');

    when(
      () => repo.fetchStarData(
        username: any(named: 'username'),
        category: any(named: 'category'),
        cursor: any(named: 'cursor'),
      ),
    ).thenAnswer(
      (_) async => _buildPage(isLoggedIn: false, items: const []),
    );

    final container = ProviderContainer(
      overrides: [
        starDataRepositoryProvider.overrideWithValue(repo),
        starDataTelemetryProvider.overrideWithValue(telemetry),
      ],
    );
    addTearDown(container.dispose);

    final state = await container.read(starDataControllerProvider(args).future);

    expect(state.showDigestOnly, isTrue);
    expect(state.items, isEmpty);
  });

  test(
      'fetchNext appends items using cursor and triggers paywall telemetry once',
      () async {
    final repo = _MockStarDataRepository();
    final telemetry = _MockStarDataTelemetry();
    final args = const StarDataControllerArgs(username: 'aurora');

    when(
      () => repo.fetchStarData(
        username: any(named: 'username'),
        category: any(named: 'category'),
        cursor: null,
      ),
    ).thenAnswer(
      (_) async => _buildPage(
        nextCursor: 'cursor-1',
        canViewFollowers: true,
        items: [
          StarData(
            id: '1',
            category: StarDataCategory.music,
            title: 'Followers only item',
            description: null,
            serviceIcon: 'assets/service_icons/sample.png',
            url: null,
            imageUrl: null,
            createdAt: DateTime.now(),
            visibility: StarDataVisibility.followers,
            starComment: null,
            enrichedMetadata: null,
          ),
        ],
      ),
    );

    when(
      () => repo.fetchStarData(
        username: any(named: 'username'),
        category: any(named: 'category'),
        cursor: 'cursor-1',
      ),
    ).thenAnswer(
      (_) async => _buildPage(
        items: [
          StarData(
            id: '2',
            category: StarDataCategory.music,
            title: 'Second page',
            description: null,
            serviceIcon: 'assets/service_icons/sample.png',
            url: null,
            imageUrl: null,
            createdAt: DateTime.now(),
            visibility: StarDataVisibility.public,
            starComment: null,
            enrichedMetadata: null,
          ),
        ],
      ),
    );

    final container = ProviderContainer(
      overrides: [
        starDataRepositoryProvider.overrideWithValue(repo),
        starDataTelemetryProvider.overrideWithValue(telemetry),
      ],
    );
    addTearDown(container.dispose);

    await container.read(starDataControllerProvider(args).future);

    verify(
      () => telemetry.recordPaywallUnlock(username: 'aurora'),
    ).called(1);
    clearInteractions(telemetry);

    await container.read(starDataControllerProvider(args).notifier).fetchNext();

    final state = container.read(starDataControllerProvider(args)).value;
    expect(state?.items.length, 2);

    verifyNever(
      () => telemetry.recordPaywallUnlock(username: 'aurora'),
    );
  });
}
