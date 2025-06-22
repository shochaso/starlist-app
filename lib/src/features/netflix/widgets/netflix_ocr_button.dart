import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/netflix_providers.dart';
import '../../../data/models/netflix_models.dart';

/// Netflix OCRボタンウィジェット
class NetflixOcrButton extends ConsumerStatefulWidget {
  final Function(List<NetflixViewingHistory>)? onOcrComplete;

  const NetflixOcrButton({
    Key? key,
    this.onOcrComplete,
  }) : super(key: key);

  @override
  ConsumerState<NetflixOcrButton> createState() => _NetflixOcrButtonState();
}

class _NetflixOcrButtonState extends ConsumerState<NetflixOcrButton> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(netflixViewingLoadingProvider);
    final ocrProgress = ref.watch(netflixOcrProgressProvider);
    
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFE50914),
                Color(0xFFB00710),
              ],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE50914).withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isLoading ? null : () => _showOcrOptions(),
              onTapDown: (_) => _animationController.forward(),
              onTapUp: (_) => _animationController.reverse(),
              onTapCancel: () => _animationController.reverse(),
              customBorder: const CircleBorder(),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (ocrProgress > 0 && ocrProgress < 1)
                    // 進捗インジケーター
                    CircularProgressIndicator(
                      value: ocrProgress,
                      strokeWidth: 3,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      backgroundColor: Colors.white.withOpacity(0.3),
                    )
                  else if (isLoading)
                    // 読み込み中
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  else
                    // OCRアイコン
                    const Icon(
                      Icons.document_scanner,
                      color: Colors.white,
                      size: 28,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// OCRオプションを表示
  void _showOcrOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.only(top: 12),
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ハンドル
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              
              // タイトル
              const Text(
                'Netflix視聴履歴を読み込む',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '読み込み方法を選択してください',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              
              // オプションリスト
              _buildOcrOption(
                icon: Icons.screenshot,
                title: '視聴履歴画面',
                subtitle: 'Netflixアプリの視聴履歴をスクリーンショット',
                sourceType: 'screenshot',
              ),
              _buildOcrOption(
                icon: Icons.email,
                title: '通知メール',
                subtitle: 'Netflixからの新作通知メールをスキャン',
                sourceType: 'email',
              ),
              _buildOcrOption(
                icon: Icons.history,
                title: '履歴ページ',
                subtitle: 'Webブラウザの視聴履歴ページをスクリーンショット',
                sourceType: 'history_page',
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  /// OCRオプション項目
  Widget _buildOcrOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required String sourceType,
  }) {
    return ListTile(
      onTap: () {
        Navigator.pop(context);
        _startOcr(sourceType);
      },
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFFE50914).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: const Color(0xFFE50914),
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 12,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        color: Colors.grey,
        size: 16,
      ),
    );
  }

  /// OCR処理を開始
  Future<void> _startOcr(String sourceType) async {
    try {
      await ref.read(netflixViewingActionProvider).analyzeImageFromGallery(
        sourceType: sourceType,
      );
      
      // OCR結果を確認
      final ocrResult = ref.read(netflixOcrResultProvider);
      if (ocrResult != null && ocrResult.isNotEmpty) {
        widget.onOcrComplete?.call(ocrResult);
        
        // 成功ダイアログを表示
        if (mounted) {
          _showSuccessDialog(ocrResult);
        }
      } else {
        // 検出されなかった場合
        if (mounted) {
          _showNoResultDialog();
        }
      }
    } catch (e) {
      // エラーハンドリングはprovidersで行われているため、ここでは何もしない
    }
  }

  /// 成功ダイアログ
  void _showSuccessDialog(List<NetflixViewingHistory> viewingHistory) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFE50914).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: Color(0xFFE50914),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              '読み込み完了',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${viewingHistory.length}件の視聴履歴を検出しました',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF333333),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: viewingHistory.take(3).map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check,
                        color: Color(0xFFE50914),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.fullTitle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                )).toList(),
              ),
            ),
            if (viewingHistory.length > 3) ...[
              const SizedBox(height: 8),
              Text(
                '他${viewingHistory.length - 3}件',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(netflixViewingActionProvider).clearOcrResult();
            },
            child: const Text(
              '閉じる',
              style: TextStyle(color: Color(0xFFE50914)),
            ),
          ),
        ],
      ),
    );
  }

  /// 検出なしダイアログ
  void _showNoResultDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(
              Icons.info_outline,
              color: Colors.orange,
              size: 24,
            ),
            SizedBox(width: 12),
            Text(
              '視聴履歴が見つかりません',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '画像から視聴履歴を検出できませんでした。',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
            SizedBox(height: 12),
            Text(
              '以下をご確認ください：',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '• 画像が鮮明に撮影されているか\n'
              '• Netflix関連の画像であるか\n'
              '• 文字が読み取れる状態か\n'
              '• 視聴履歴が表示されているか',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'もう一度試す',
              style: TextStyle(color: Color(0xFFE50914)),
            ),
          ),
        ],
      ),
    );
  }
}