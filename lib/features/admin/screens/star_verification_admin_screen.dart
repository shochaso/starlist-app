import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../services/sns_verification_service.dart';
import '../../../services/parental_consent_service.dart';
import '../../../services/ekyc_service.dart';
import '../../../models/sns_verification.dart';
import '../../../models/parental_consent.dart';
import '../../../widgets/loading_overlay.dart';

/// スター認証管理画面（管理者用）
class StarVerificationAdminScreen extends ConsumerStatefulWidget {
  const StarVerificationAdminScreen({super.key});

  @override
  ConsumerState<StarVerificationAdminScreen> createState() => _StarVerificationAdminScreenState();
}

class _StarVerificationAdminScreenState extends ConsumerState<StarVerificationAdminScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  
  // データ
  List<Map<String, dynamic>> _pendingApplications = [];
  List<SNSVerification> _snsVerifications = [];
  List<ParentalConsent> _parentalConsents = [];
  
  // フィルター
  String _selectedStatus = 'all';
  SNSPlatform? _selectedPlatform;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAllData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('スター認証管理'),
        backgroundColor: Colors.indigo[600],
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: '申請一覧', icon: Icon(Icons.assignment)),
            Tab(text: 'SNS認証', icon: Icon(Icons.verified)),
            Tab(text: '親権者同意', icon: Icon(Icons.family_restroom)),
          ],
        ),
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: Column(
          children: [
            _buildFilterSection(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildApplicationsTab(),
                  _buildSNSVerificationsTab(),
                  _buildParentalConsentsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadAllData,
        backgroundColor: Colors.indigo[600],
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }

  /// フィルターセクション
  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        children: [
          // 検索バー
          TextFormField(
            decoration: const InputDecoration(
              labelText: '検索',
              hintText: 'ユーザー名、メールアドレス等',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          const SizedBox(height: 12),
          
          // フィルターボタン
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'ステータス',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('全て')),
                    DropdownMenuItem(value: 'pending', child: Text('申請中')),
                    DropdownMenuItem(value: 'under_review', child: Text('審査中')),
                    DropdownMenuItem(value: 'awaiting_parental_consent', child: Text('親権者同意待ち')),
                    DropdownMenuItem(value: 'approved', child: Text('承認済み')),
                    DropdownMenuItem(value: 'rejected', child: Text('拒否')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value!;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<SNSPlatform?>(
                  value: _selectedPlatform,
                  decoration: const InputDecoration(
                    labelText: 'SNSプラットフォーム',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('全て')),
                    ...SNSPlatform.values.map((platform) => 
                      DropdownMenuItem(
                        value: platform,
                        child: Text(platform.displayName),
                      )
                    ).toList(),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedPlatform = value;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 申請一覧タブ
  Widget _buildApplicationsTab() {
    final filteredApplications = _filterApplications();
    
    if (filteredApplications.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('申請がありません', style: TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredApplications.length,
      itemBuilder: (context, index) {
        final application = filteredApplications[index];
        return _buildApplicationCard(application);
      },
    );
  }

  /// SNS認証タブ
  Widget _buildSNSVerificationsTab() {
    final filteredVerifications = _filterSNSVerifications();
    
    if (filteredVerifications.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.verified, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('SNS認証がありません', style: TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredVerifications.length,
      itemBuilder: (context, index) {
        final verification = filteredVerifications[index];
        return _buildSNSVerificationCard(verification);
      },
    );
  }

  /// 親権者同意タブ
  Widget _buildParentalConsentsTab() {
    final filteredConsents = _filterParentalConsents();
    
    if (filteredConsents.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.family_restroom, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('親権者同意がありません', style: TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredConsents.length,
      itemBuilder: (context, index) {
        final consent = filteredConsents[index];
        return _buildParentalConsentCard(consent);
      },
    );
  }

  /// 申請カード
  Widget _buildApplicationCard(Map<String, dynamic> application) {
    final isMinor = application['is_minor'] ?? false;
    final status = application['verification_status'];
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ヘッダー
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: _getStatusColor(status).withOpacity(0.2),
                  child: Icon(
                    isMinor ? Icons.child_care : Icons.person,
                    color: _getStatusColor(status),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        application['name'] ?? 'Unknown',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        application['email'] ?? '',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(status),
              ],
            ),
            const SizedBox(height: 16),
            
            // 詳細情報
            _buildInfoRow('法的氏名', application['legal_name'] ?? 'N/A'),
            if (isMinor) _buildInfoRow('年齢', '18歳未満'),
            _buildInfoRow('申請日', _formatDate(application['created_at'])),
            
            const SizedBox(height: 16),
            
            // アクションボタン
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showApplicationDetails(application),
                    icon: const Icon(Icons.info_outline),
                    label: const Text('詳細'),
                  ),
                ),
                const SizedBox(width: 12),
                if (status == 'under_review') ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _approveApplication(application['id']),
                      icon: const Icon(Icons.check),
                      label: const Text('承認'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _rejectApplication(application['id']),
                      icon: const Icon(Icons.close),
                      label: const Text('拒否'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// SNS認証カード
  Widget _buildSNSVerificationCard(SNSVerification verification) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ヘッダー
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Color(verification.platform.primaryColor),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        verification.platform.displayName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        verification.accountHandle,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(verification.verificationStatus),
              ],
            ),
            const SizedBox(height: 16),
            
            // 詳細情報
            _buildInfoRow('アカウントURL', verification.accountUrl),
            if (verification.followerCount != null)
              _buildInfoRow(verification.platform.followerLabel, _formatNumber(verification.followerCount!)),
            _buildInfoRow('認証コード', verification.verificationCode),
            _buildInfoRow('申請日', _formatDate(verification.createdAt.toString())),
            
            const SizedBox(height: 16),
            
            // アクションボタン
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _openURL(verification.accountUrl),
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('アカウントを開く'),
                  ),
                ),
                if (!verification.ownershipVerified) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _verifyOwnership(verification.id),
                      icon: const Icon(Icons.verified),
                      label: const Text('所有権確認'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 親権者同意カード
  Widget _buildParentalConsentCard(ParentalConsent consent) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ヘッダー
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.purple.withOpacity(0.2),
                  child: const Icon(
                    Icons.family_restroom,
                    color: Colors.purple,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        consent.parentFullName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${consent.relationshipToMinor} (${consent.parentEmail})',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(consent.verificationStatus),
              ],
            ),
            const SizedBox(height: 16),
            
            // 詳細情報
            _buildInfoRow('住所', consent.parentAddress),
            if (consent.consentDocumentUrl != null)
              _buildInfoRow('同意書', '提出済み'),
            _buildInfoRow('提出日', _formatDate(consent.consentSubmittedAt.toString())),
            
            const SizedBox(height: 16),
            
            // アクションボタン
            Row(
              children: [
                if (consent.consentDocumentUrl != null) ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _openURL(consent.consentDocumentUrl!),
                      icon: const Icon(Icons.description),
                      label: const Text('同意書確認'),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                if (consent.verificationStatus == 'parental_consent_submitted') ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _approveParentalConsent(consent.id),
                      icon: const Icon(Icons.check),
                      label: const Text('承認'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _rejectParentalConsent(consent.id),
                      icon: const Icon(Icons.close),
                      label: const Text('拒否'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 情報行
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  /// ステータスチップ
  Widget _buildStatusChip(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getStatusColor(status).withOpacity(0.3)),
      ),
      child: Text(
        _getStatusDisplayName(status),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: _getStatusColor(status),
        ),
      ),
    );
  }

  /// ステータス色取得
  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved':
      case 'verified':
        return Colors.green;
      case 'rejected':
      case 'failed':
        return Colors.red;
      case 'under_review':
        return Colors.blue;
      case 'awaiting_parental_consent':
      case 'parental_consent_submitted':
        return Colors.purple;
      case 'pending':
      default:
        return Colors.orange;
    }
  }

  /// ステータス表示名取得
  String _getStatusDisplayName(String status) {
    switch (status) {
      case 'pending':
        return '申請中';
      case 'under_review':
        return '審査中';
      case 'awaiting_parental_consent':
        return '親権者同意待ち';
      case 'parental_consent_submitted':
        return '同意書提出済み';
      case 'approved':
        return '承認済み';
      case 'rejected':
        return '拒否';
      case 'verified':
        return '認証済み';
      case 'failed':
        return '認証失敗';
      default:
        return status;
    }
  }

  /// 数値フォーマット
  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  /// 日付フォーマット
  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }

  /// データフィルタリング

  List<Map<String, dynamic>> _filterApplications() {
    var filtered = _pendingApplications.where((app) {
      // ステータスフィルター
      if (_selectedStatus != 'all' && app['verification_status'] != _selectedStatus) {
        return false;
      }
      
      // 検索フィルター
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final name = (app['name'] ?? '').toLowerCase();
        final email = (app['email'] ?? '').toLowerCase();
        final legalName = (app['legal_name'] ?? '').toLowerCase();
        
        if (!name.contains(query) && !email.contains(query) && !legalName.contains(query)) {
          return false;
        }
      }
      
      return true;
    }).toList();
    
    return filtered;
  }

  List<SNSVerification> _filterSNSVerifications() {
    var filtered = _snsVerifications.where((verification) {
      // プラットフォームフィルター
      if (_selectedPlatform != null && verification.platform != _selectedPlatform) {
        return false;
      }
      
      // 検索フィルター
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final handle = verification.accountHandle.toLowerCase();
        final url = verification.accountUrl.toLowerCase();
        
        if (!handle.contains(query) && !url.contains(query)) {
          return false;
        }
      }
      
      return true;
    }).toList();
    
    return filtered;
  }

  List<ParentalConsent> _filterParentalConsents() {
    var filtered = _parentalConsents.where((consent) {
      // 検索フィルター
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final parentName = consent.parentFullName.toLowerCase();
        final email = consent.parentEmail.toLowerCase();
        
        if (!parentName.contains(query) && !email.contains(query)) {
          return false;
        }
      }
      
      return true;
    }).toList();
    
    return filtered;
  }

  /// データ読み込み

  Future<void> _loadAllData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 並列でデータを取得
      final futures = [
        _loadPendingApplications(),
        SNSVerificationService.getSNSVerificationsForAdmin(),
        ParentalConsentService.getParentalConsentsForAdmin(),
      ];

      final results = await Future.wait(futures);
      
      setState(() {
        _pendingApplications = results[0] as List<Map<String, dynamic>>;
        _snsVerifications = results[1] as List<SNSVerification>;
        _parentalConsents = results[2] as List<ParentalConsent>;
      });
    } catch (e) {
      _showErrorSnackBar('データの読み込みに失敗しました: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 申請一覧を読み込み（ダミー実装）
  Future<List<Map<String, dynamic>>> _loadPendingApplications() async {
    // 実際の実装ではSupabaseから取得
    return [
      {
        'id': '1',
        'name': 'テストユーザー1',
        'email': 'test1@example.com',
        'legal_name': '田中太郎',
        'is_minor': false,
        'verification_status': 'under_review',
        'created_at': '2024-01-15T10:00:00Z',
      },
      {
        'id': '2',
        'name': 'テストユーザー2（未成年）',
        'email': 'test2@example.com',
        'legal_name': '佐藤花子',
        'is_minor': true,
        'verification_status': 'awaiting_parental_consent',
        'created_at': '2024-01-16T14:30:00Z',
      },
    ];
  }

  /// アクション処理

  Future<void> _approveApplication(String applicationId) async {
    // TODO: 実装
    _showSuccessSnackBar('申請を承認しました');
  }

  Future<void> _rejectApplication(String applicationId) async {
    // TODO: 実装
    _showErrorSnackBar('申請を拒否しました');
  }

  Future<void> _verifyOwnership(String verificationId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await SNSVerificationService.verifyOwnership(verificationId);
      if (result.success) {
        _showSuccessSnackBar('所有権確認が完了しました');
        await _loadAllData();
      } else {
        _showErrorSnackBar(result.error ?? '所有権確認に失敗しました');
      }
    } catch (e) {
      _showErrorSnackBar('エラーが発生しました: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _approveParentalConsent(String consentId) async {
    // TODO: 実装
    _showSuccessSnackBar('親権者同意を承認しました');
  }

  Future<void> _rejectParentalConsent(String consentId) async {
    // TODO: 実装
    _showErrorSnackBar('親権者同意を拒否しました');
  }

  Future<void> _openURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  void _showApplicationDetails(Map<String, dynamic> application) {
    // TODO: 詳細ダイアログを表示
  }

  /// ユーティリティ

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
} 