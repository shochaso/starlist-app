import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../src/providers/theme_provider_enhanced.dart';

/// Starlist データ整理・閲覧ページ（Flutter実装モック）
/// - ファン/スター視点切替
/// - プラン（無料/ライト/スタンダード/プレミアム）切替
/// - カテゴリフィルタ（複数選択 OR / ALL一致）
/// - YouTubeは常時フル開放、それ以外は課金者のみフル表示／未課金はチラ見せ(スター指定max20%)
/// - 非公開アイテムはガラス調モザイク + 情報テキストは表示しない
/// - 正方形サムネイル (AspectRatio 1:1)
/// - スター視点のアクション文言は「もっと見る」/ ファンは「詳細を見る」
class StarDataViewPage extends ConsumerStatefulWidget {
  const StarDataViewPage({super.key});

  @override
  ConsumerState<StarDataViewPage> createState() => _StarDataViewPageState();
}

class _StarDataViewPageState extends ConsumerState<StarDataViewPage> {
  String viewMode = 'fan'; // fan | star
  String fanTier = 'free'; // free | light | standard | premium

  // 検索・フィルタ
  String query = '';
  final Set<String> selectedCats = {};
  bool matchAllCats = false; // false = OR, true = ALL一致
  String dateRange = 'all'; // all | 7d | 30d

  final now = DateTime(2025, 10, 2);

  final categories = const [
    {'id': 'all', 'name': '全て', 'icon': Icons.trending_up, 'color': Colors.purple},
    {'id': 'youtube', 'name': 'YouTube', 'icon': Icons.ondemand_video, 'color': Colors.red},
    {'id': 'music', 'name': '音楽', 'icon': Icons.music_note, 'color': Colors.green},
    {'id': 'shopping', 'name': '買い物', 'icon': Icons.shopping_bag, 'color': Colors.blue},
    {'id': 'books', 'name': '書籍', 'icon': Icons.menu_book, 'color': Colors.orange},
    {'id': 'apps', 'name': 'アプリ', 'icon': Icons.smartphone, 'color': Colors.indigo},
    {'id': 'food', 'name': '食事', 'icon': Icons.restaurant, 'color': Colors.amber},
  ];

  // サンプルデータ（React版と同等）
  late List<Post> data;

  @override
  void initState() {
    super.initState();
    data = sampleData();
  }

  bool dateKeep(DateTime d) {
    if (dateRange == 'all') return true;
    final diff = now.difference(d).inDays;
    return dateRange == '7d' ? diff <= 7 : diff <= 30;
  }

  bool textIncludes(String hay, String needle) =>
      hay.toLowerCase().contains(needle.trim().toLowerCase());

  bool matchesQuery(Post p) {
    if (query.trim().isEmpty) return true;
    final inPost = textIncludes(p.postTitle, query) || textIncludes(p.category, query);
    final inItems = p.items.any((it) =>
        [it.title, it.channel, it.artist].whereType<String>().any((t) => textIncludes(t, query)));
    return inPost || inItems;
  }

  bool canViewContent(String itemVisibility) {
    const order = ['free', 'light', 'standard', 'premium'];
    return order.indexOf(fanTier) >= order.indexOf(itemVisibility);
  }

  int _gridCrossAxisCount(double width) {
    if (width > 1200) return 6;
    if (width > 900) return 5;
    if (width > 600) return 4;
    if (width > 400) return 3;
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProviderEnhanced);
    final isDark = themeState.isDarkMode;
    
    // 前段フィルタ（検索 + 日付）
    final pre = data.where((p) => matchesQuery(p) && dateKeep(p.date)).toList();

    // カテゴリ件数
    final counts = <String, int>{};
    for (final p in pre) {
      counts[p.category] = (counts[p.category] ?? 0) + 1;
    }

    // 最終フィルタ（カテゴリ）
    final filtered = selectedCats.isEmpty
        ? pre
        : pre.where((p) {
            if (matchAllCats) {
              return selectedCats.every((id) => id == p.category);
            }
            return selectedCats.contains(p.category);
          }).toList();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        elevation: 0.5,
        title: Text(
          'スターの日常データ', 
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ToggleButtons(
              borderRadius: BorderRadius.circular(10),
              fillColor: const Color(0xFF4ECDC4),
              selectedColor: Colors.white,
              color: isDark ? Colors.white70 : Colors.black54,
              isSelected: [viewMode == 'fan', viewMode == 'star'],
              onPressed: (i) => setState(() => viewMode = i == 0 ? 'fan' : 'star'),
              children: const [
                Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text('ファン視点')),
                Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text('スター視点')),
              ],
            ),
          )
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 検索 + 期間
                  Row(children: [
                    Expanded(
                      child: TextField(
                        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.filter_alt_outlined,
                            color: isDark ? Colors.white54 : Colors.black54,
                          ),
                          hintText: '検索: タイトル / アイテム名 / チャンネル',
                          hintStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
                          filled: true,
                          fillColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDark ? const Color(0xFF333333) : const Color(0xFFE2E8F0),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDark ? const Color(0xFF333333) : const Color(0xFFE2E8F0),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF4ECDC4)),
                          ),
                        ),
                        onChanged: (v) => setState(() => query = v),
                      ),
                    ),
                    const SizedBox(width: 8),
                    DropdownButtonHideUnderline(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark ? const Color(0xFF333333) : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: DropdownButton<String>(
                          value: dateRange,
                          dropdownColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                          items: const [
                            DropdownMenuItem(value: 'all', child: Text('期間: すべて')),
                            DropdownMenuItem(value: '7d', child: Text('直近7日')),
                            DropdownMenuItem(value: '30d', child: Text('直近30日')),
                          ],
                          onChanged: (v) => setState(() => dateRange = v ?? 'all'),
                        ),
                      ),
                    ),
                  ]),

                  const SizedBox(height: 8),

                  // カテゴリフィルタ
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          label: Text('全て  ${pre.length}', style: const TextStyle(fontSize: 12)),
                          selected: selectedCats.isEmpty,
                          selectedColor: const Color(0xFF4ECDC4),
                          backgroundColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                          labelStyle: TextStyle(
                            color: selectedCats.isEmpty 
                              ? Colors.white 
                              : (isDark ? Colors.white70 : Colors.black87),
                          ),
                          onSelected: (_) => setState(() => selectedCats.clear()),
                        ),
                      ),
                      ...categories.where((c) => c['id'] != 'all').map((c) {
                        final id = c['id'] as String;
                        final selected = selectedCats.contains(id);
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: ChoiceChip(
                            label: Text('${c['name']}  ${(counts[id] ?? 0)}', style: const TextStyle(fontSize: 12)),
                            selected: selected,
                            selectedColor: const Color(0xFF4ECDC4),
                            backgroundColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                            labelStyle: TextStyle(
                              color: selected 
                                ? Colors.white 
                                : (isDark ? Colors.white70 : Colors.black87),
                            ),
                            onSelected: (_) => setState(() {
                              if (selected) {
                                selectedCats.remove(id);
                              } else {
                                selectedCats.add(id);
                              }
                            }),
                          ),
                        );
                      })
                    ]),
                  ),

                  const SizedBox(height: 8),

                  // プラン切替（ファン視点のみ）
                  if (viewMode == 'fan')
                    Row(children: [
                      Text(
                        'プラン:', 
                        style: TextStyle(
                          fontSize: 12, 
                          color: isDark ? Colors.white54 : Colors.black54,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Wrap(spacing: 6, children: [
                        _planBtn('無料', 'free'),
                        _planBtn('ライト', 'light'),
                        _planBtn('スタンダード', 'standard'),
                        _planBtn('プレミアム', 'premium'),
                      ]),
                      const Spacer(),
                      Text(
                        '${filtered.length} 件', 
                        style: TextStyle(
                          fontSize: 12, 
                          color: isDark ? Colors.white54 : Colors.black54,
                        ),
                      ),
                    ]),
                ],
              ),
            ),
          ),

          // 投稿リスト
          SliverList.builder(
            itemCount: filtered.length,
            itemBuilder: (context, idx) {
              final post = filtered[idx];
              final badge = visibilityBadge(post.visibility);
              final canView = viewMode == 'star' || canViewContent(post.visibility);
              final visibleCount = post.items.where((it) => it.visible).length;
              final hiddenCount = post.totalItems - visibleCount;
              final bestHidden = post.items.where((it) => !it.visible && it.isBest).length;

              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
                child: Card(
                  elevation: 0.5,
                  color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: Column(
                    children: [
                      // ヘッダー
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDark 
                              ? [const Color(0xFF2A2A2A), const Color(0xFF333333)]
                              : [const Color(0xFFF4EBFF), const Color(0xFFEAF2FF)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          border: Border(
                            bottom: BorderSide(
                              color: isDark ? const Color(0xFF333333) : const Color(0xFFE6E6E6),
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _categoryIcon(post.category), 
                              size: 16,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    post.postTitle, 
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    '${_dateStr(post.date)} ${post.time} • ${post.totalItems}件',
                                    style: TextStyle(
                                      fontSize: 11, 
                                      color: isDark ? Colors.white54 : Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: badge.color,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(badge.text, style: const TextStyle(color: Colors.white, fontSize: 11)),
                            ),
                            if (viewMode == 'star')
                              Padding(
                                padding: const EdgeInsets.only(left: 6),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: (isDark ? Colors.white : Colors.black).withOpacity(.05),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '👁 ${post.likes + 150}', 
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isDark ? Colors.white70 : Colors.black54,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      // アイテムグリッド
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: LayoutBuilder(
                          builder: (context, c) {
                            final cross = _gridCrossAxisCount(c.maxWidth);
                            return GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: cross,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                childAspectRatio: 0.78,
                              ),
                              itemCount: post.items.length,
                              itemBuilder: (context, i) {
                                final it = post.items[i];
                                final isVisible = viewMode == 'star' || it.visible || post.category == 'youtube' || (canView && it.visible);
                                return _ItemCard(item: it, isVisible: isVisible, isDark: isDark);
                              },
                            );
                          },
                        ),
                      ),

                      // チラ見せ案内
                      if (!canView && hiddenCount > 0)
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFFFFF3CD), Color(0xFFFFE8A1)]),
                            border: Border.all(color: const Color(0xFFF4C84D)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(color: const Color(0xFFF4C84D), borderRadius: BorderRadius.circular(999)),
                                child: const Icon(Icons.auto_awesome, color: Color(0xFF7A5200)),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('残り$hiddenCount件が非公開' + (bestHidden > 0 ? '（うち★ベスト $bestHidden件！）' : ''),
                                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF7A5200))),
                                    const SizedBox(height: 2),
                                    Text('${badge.text}にアップグレードで見ることができます', 
                                        style: const TextStyle(fontSize: 12, color: Color(0xFF7A5200))),
                                  ],
                                ),
                              ),
                              FilledButton.icon(
                                onPressed: () {},
                                style: FilledButton.styleFrom(
                                  backgroundColor: const Color(0xFF4ECDC4),
                                ),
                                icon: const Icon(Icons.lock, color: Colors.white),
                                label: const Text('アップグレード', style: TextStyle(color: Colors.white)),
                              )
                            ],
                          ),
                        ),

                      // コメント
                      if (canView && post.starComment.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF2D1B3D) : const Color(0xFFF5EDFF),
                            border: Border(
                              left: BorderSide(
                                color: isDark ? const Color(0xFF4ECDC4) : Colors.purple.shade400, 
                                width: 3,
                              ),
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '💬 スターのコメント', 
                                style: TextStyle(
                                  fontSize: 12, 
                                  color: isDark ? const Color(0xFF4ECDC4) : Colors.purple.shade700, 
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                post.starComment,
                                style: TextStyle(
                                  color: isDark ? Colors.white70 : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),

                      // アクションバー
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              color: isDark ? const Color(0xFF333333) : const Color(0xFFE9E9E9),
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            _iconText(Icons.favorite_border, '${post.likes}', isDark),
                            const SizedBox(width: 14),
                            _iconText(Icons.mode_comment_outlined, '${post.comments}', isDark),
                            const SizedBox(width: 14),
                            IconButton(
                              onPressed: () {}, 
                              icon: Icon(
                                Icons.share_outlined,
                                color: isDark ? Colors.white54 : Colors.black54,
                              ),
                            ),
                            const Spacer(),
                            if (canView)
                              FilledButton(
                                onPressed: () {},
                                style: FilledButton.styleFrom(
                                  backgroundColor: const Color(0xFF4ECDC4),
                                ),
                                child: Text(
                                  viewMode == 'star' ? 'もっと見る' : '詳細を見る',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ---- UI helpers ----
  Widget _planBtn(String label, String value) {
    final selected = fanTier == value;
    final isDark = ref.watch(themeProviderEnhanced).isDarkMode;
    
    return OutlinedButton(
      onPressed: () => setState(() => fanTier = value),
      style: OutlinedButton.styleFrom(
        backgroundColor: selected 
          ? const Color(0xFF4ECDC4)
          : (isDark ? const Color(0xFF2A2A2A) : Colors.white),
        foregroundColor: selected 
          ? Colors.white 
          : (isDark ? Colors.white70 : Colors.black87),
        side: BorderSide(
          color: selected 
            ? const Color(0xFF4ECDC4) 
            : (isDark ? const Color(0xFF333333) : Colors.black26),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        textStyle: const TextStyle(fontSize: 12),
      ),
      child: Text(label),
    );
  }

  IconData _categoryIcon(String cat) {
    switch (cat) {
      case 'youtube':
        return Icons.ondemand_video;
      case 'music':
        return Icons.music_note;
      case 'shopping':
        return Icons.shopping_bag;
      case 'books':
        return Icons.menu_book;
      case 'apps':
        return Icons.smartphone;
      case 'food':
        return Icons.restaurant;
      default:
        return Icons.trending_up;
    }
  }

  String _dateStr(DateTime d) => '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Widget _iconText(IconData icon, String text, bool isDark) => Row(
    children: [
      Icon(
        icon, 
        size: 18, 
        color: isDark ? Colors.white54 : Colors.black54,
      ), 
      const SizedBox(width: 4), 
      Text(
        text,
        style: TextStyle(
          color: isDark ? Colors.white70 : Colors.black87,
        ),
      ),
    ],
  );
}

// ---- モザイク & アイテムカード ----
class _ItemCard extends StatelessWidget {
  const _ItemCard({required this.item, required this.isVisible, required this.isDark});
  final Item item;
  final bool isVisible;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF333333) : Colors.black12,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : Colors.black12).withOpacity(0.08),
            blurRadius: 6, 
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 正方形サムネ
          AspectRatio(
            aspectRatio: 1,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // 画像
                ClipRRect(
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                  child: Image.network(item.thumbnail, fit: BoxFit.cover),
                ),
                if (!isVisible) ...[
                  // 強ブラー
                  Positioned.fill(
                    child: ImageFiltered(
                      imageFilter: ImageFilter.blur(sigmaX: 9, sigmaY: 9),
                      child: Container(color: Colors.transparent),
                    ),
                  ),
                  // ガラス+クロスハッチ
                  Positioned.fill(
                    child: CustomPaint(painter: _HatchPainter()),
                  ),
                  // ロック & ベスト
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lock_outline, color: Colors.white.withOpacity(.95), size: 28),
                        const SizedBox(height: 6),
                        if (item.isBest)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: const Color(0xFFFFD54F), borderRadius: BorderRadius.circular(999)),
                            child: const Text('★ベスト', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF5D4300), fontSize: 11)),
                          ),
                      ],
                    ),
                  ),
                ]
              ],
            ),
          ),

          // 情報欄（非公開時は名称やメタを出さない）
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              height: 48,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isVisible ? item.title : '非公開アイテム', 
                    maxLines: 2, 
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  if (isVisible && item.price != null)
                    Text(
                      item.price!, 
                      style: TextStyle(
                        fontSize: 12, 
                        color: isDark ? const Color(0xFF4ECDC4) : Colors.deepPurple, 
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  if (isVisible && item.channel != null)
                    Text(
                      item.channel!, 
                      style: TextStyle(
                        fontSize: 11, 
                        color: isDark ? Colors.white54 : Colors.black54,
                      ), 
                      maxLines: 1, 
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (isVisible && item.artist != null)
                    Text(
                      item.artist!, 
                      style: TextStyle(
                        fontSize: 11, 
                        color: isDark ? Colors.white54 : Colors.black54,
                      ), 
                      maxLines: 1, 
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (isVisible && item.duration != null)
                    Text(
                      item.duration!, 
                      style: TextStyle(
                        fontSize: 11, 
                        color: isDark ? Colors.white54 : Colors.black54,
                      ),
                    ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _HatchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 乳白色のガラス感 + 交差ストライプ
    final bg = Paint()
      ..color = const Color(0x80FFFFFF)
      ..blendMode = BlendMode.srcOver;
    canvas.drawRect(Offset.zero & size, bg);

    final p1 = Paint()
      ..color = const Color(0x66FFFFFF)
      ..strokeWidth = 1.2;
    final p2 = Paint()
      ..color = const Color(0x33FFFFFF)
      ..strokeWidth = 1.2;

    const step = 8.0;
    for (double x = -size.height; x < size.width; x += step) {
      // 斜め↘
      canvas.drawLine(Offset(x, 0), Offset(x + size.height, size.height), p1);
    }
    for (double x = -size.height; x < size.width; x += step) {
      // 斜め↙
      canvas.drawLine(Offset(x + size.height, 0), Offset(x, size.height), p2);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ---- データモデル ----
class Post {
  Post({
    required this.id,
    required this.category,
    required this.postTitle,
    required this.date,
    required this.time,
    required this.totalItems,
    required this.items,
    required this.visibility,
    required this.likes,
    required this.comments,
    required this.starComment,
  });

  final int id;
  final String category;
  final String postTitle;
  final DateTime date;
  final String time;
  final int totalItems;
  final List<Item> items;
  final String visibility; // free | light | standard | premium
  final int likes;
  final int comments;
  final String starComment;
}

class Item {
  Item({
    required this.id,
    required this.title,
    this.price,
    this.channel,
    this.artist,
    this.duration,
    required this.visible,
    required this.isBest,
    required this.thumbnail,
  });

  final int id;
  final String title;
  final String? price;
  final String? channel;
  final String? artist;
  final String? duration;
  final bool visible;
  final bool isBest;
  final String thumbnail;
}

// ---- サンプルデータ ----
List<Post> sampleData() => [
      Post(
        id: 1,
        category: 'food',
        postTitle: 'セブンイレブンで夜食購入',
        date: DateTime(2025, 10, 1),
        time: '22:30',
        totalItems: 5,
        items: [
          Item(id: 1, title: 'おにぎり ツナマヨ', price: '¥138', visible: true, isBest: false, thumbnail: 'https://img-afd.7api-01.dp1.sej.co.jp/item-image/047786/BC434201E3FE7C32240B5ABC20A6789A.jpg'),
          Item(id: 2, title: '金のハンバーグ', price: '¥598', visible: false, isBest: true, thumbnail: 'https://www.7andi.com/var/rev0/0000/3115/11948162553.jpg'),
          Item(id: 3, title: 'ななチキ', price: '¥238', visible: false, isBest: false, thumbnail: 'https://via.placeholder.com/80x80/ffcc00/ffffff?text=からあげ'),
          Item(id: 4, title: 'セブンカフェ アイスコーヒー L', price: '¥150', visible: false, isBest: true, thumbnail: 'https://img-afd.7api-01.dp1.sej.co.jp/item-image/140472/EB6F99982458E96014BBE654173C4A62.jpg'),
          Item(id: 5, title: 'ポテトチップス うすしお', price: '¥128', visible: false, isBest: false, thumbnail: 'https://www.calbee.co.jp/common/utility/binout.php?db=products&f=5221'),
        ],
        visibility: 'premium',
        likes: 432,
        comments: 78,
        starComment: '編集作業のお供に！金のハンバーグとアイスコーヒーの組み合わせが最高でした🔥',
      ),
      Post(
        id: 2,
        category: 'youtube',
        postTitle: '今日観たゲーム実況動画',
        date: DateTime(2025, 10, 1),
        time: '18:45',
        totalItems: 8,
        items: [
          Item(id: 1, title: '【マイクラ】最新アップデート解説', channel: 'GameChannel A', duration: '24:15', visible: true, isBest: false, thumbnail: 'https://img.youtube.com/vi/dQw4w9WgXcQ/hqdefault.jpg'),
          Item(id: 2, title: '【モンハン】神プレイ集', channel: 'HunterPro', duration: '15:42', visible: false, isBest: true, thumbnail: 'https://img.youtube.com/vi/6_b7RDuLwcI/hqdefault.jpg'),
          Item(id: 3, title: 'ポケモン対戦環境解説', channel: 'PokeMaster', duration: '18:30', visible: true, isBest: false, thumbnail: 'https://img.youtube.com/vi/kJQP7kiw5Fk/hqdefault.jpg'),
          Item(id: 4, title: 'FPS上達テクニック', channel: 'FPS_God', duration: '20:05', visible: false, isBest: true, thumbnail: 'https://img.youtube.com/vi/9bZkp7q19f0/hqdefault.jpg'),
          Item(id: 5, title: 'ホラーゲーム実況', channel: 'ScaryGamer', duration: '45:20', visible: false, isBest: false, thumbnail: 'https://img.youtube.com/vi/fJ9rUzIMcZQ/hqdefault.jpg'),
          Item(id: 6, title: 'レトロゲーム特集', channel: 'RetroGame', duration: '32:10', visible: false, isBest: true, thumbnail: 'https://img.youtube.com/vi/3JZ_D3ELwOQ/hqdefault.jpg'),
          Item(id: 7, title: '最新ゲームニュース', channel: 'GameNews', duration: '12:30', visible: false, isBest: false, thumbnail: 'https://img.youtube.com/vi/L_jWHffIx5E/hqdefault.jpg'),
          Item(id: 8, title: 'ゲーム音楽メドレー', channel: 'MusicGame', duration: '60:00', visible: false, isBest: false, thumbnail: 'https://img.youtube.com/vi/2Vv-BfVoq4g/hqdefault.jpg'),
        ],
        visibility: 'standard',
        likes: 567,
        comments: 123,
        starComment: 'モンハンとFPSの動画が特に参考になりました！',
      ),
      Post(
        id: 3,
        category: 'music',
        postTitle: '作業用BGMプレイリスト',
        date: DateTime(2025, 9, 30),
        time: '14:20',
        totalItems: 6,
        items: [
          Item(id: 1, title: 'YOASOBI - アイドル', artist: 'YOASOBI', visible: true, isBest: false, thumbnail: 'https://via.placeholder.com/80x80/1DB954/ffffff?text=YOASOBI'),
          Item(id: 2, title: 'Ado - 唱', artist: 'Ado', visible: false, isBest: true, thumbnail: 'https://via.placeholder.com/80x80/1DB954/ffffff?text=Ado'),
          Item(id: 3, title: 'ずとまよ - 秒針を噛む', artist: 'ずとまよ', visible: false, isBest: false, thumbnail: 'https://via.placeholder.com/80x80/1DB954/ffffff?text=ZTMY'),
          Item(id: 4, title: 'ヨルシカ - 夜行', artist: 'ヨルシカ', visible: false, isBest: true, thumbnail: 'https://via.placeholder.com/80x80/1DB954/ffffff?text=YRSK'),
          Item(id: 5, title: 'ヒゲダン - Subtitle', artist: 'ヒゲダン', visible: true, isBest: false, thumbnail: 'https://via.placeholder.com/80x80/1DB954/ffffff?text=Higedan'),
          Item(id: 6, title: 'ミセス - ダンスホール', artist: 'ミセス', visible: false, isBest: false, thumbnail: 'https://via.placeholder.com/80x80/1DB954/ffffff?text=Mrs'),
        ],
        visibility: 'light',
        likes: 289,
        comments: 45,
        starComment: 'Adoとヨルシカのこの曲、集中力が上がります',
      ),
      Post(
        id: 4,
        category: 'shopping',
        postTitle: 'Amazon購入品 - ガジェット編',
        date: DateTime(2025, 9, 29),
        time: '20:15',
        totalItems: 4,
        items: [
          Item(id: 1, title: 'Logicool MX Master 3', price: '¥14,800', visible: true, isBest: false, thumbnail: 'https://via.placeholder.com/80x80/0066cc/ffffff?text=Mouse'),
          Item(id: 2, title: 'メカニカルキーボード', price: '¥18,900', visible: false, isBest: true, thumbnail: 'https://via.placeholder.com/80x80/0066cc/ffffff?text=KB'),
          Item(id: 3, title: 'モニターアーム デュアル', price: '¥8,900', visible: false, isBest: true, thumbnail: 'https://via.placeholder.com/80x80/0066cc/ffffff?text=Arm'),
          Item(id: 4, title: 'USBハブ 10ポート', price: '¥3,200', visible: false, isBest: false, thumbnail: 'https://via.placeholder.com/80x80/0066cc/ffffff?text=USB'),
        ],
        visibility: 'premium',
        likes: 821,
        comments: 156,
        starComment: 'キーボードとモニターアームで作業環境が劇的に改善！おすすめです',
      ),
    ];

// 表示バッジ
class VisibilityBadge { 
  VisibilityBadge(this.text, this.color); 
  final String text; 
  final Color color; 
}

VisibilityBadge visibilityBadge(String v) {
  switch (v) {
    case 'light':
      return VisibilityBadge('ライト+', Colors.blue);
    case 'standard':
      return VisibilityBadge('スタンダード+', Colors.purple);
    case 'premium':
      return VisibilityBadge('プレミアム限定', const Color(0xFFFFC107));
    default:
      return VisibilityBadge('無料公開', Colors.grey);
  }
}