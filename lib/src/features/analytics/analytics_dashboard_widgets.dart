import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/analytics_models.dart';
import '../services/analytics_service.dart';

/// ファン分析ダッシュボード画面
class FanAnalyticsDashboardScreen extends ConsumerStatefulWidget {
  final String starId;

  const FanAnalyticsDashboardScreen({
    super.key,
    required this.starId,
  });

  @override
  ConsumerState<FanAnalyticsDashboardScreen> createState() => _FanAnalyticsDashboardScreenState();
}

class _FanAnalyticsDashboardScreenState extends ConsumerState<FanAnalyticsDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  final DateTime _endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final params = {
      'starId': widget.starId,
      'startDate': _startDate,
      'endDate': _endDate,
    };

    final fanAnalyticsAsync = ref.watch(fanAnalyticsProvider(params));

    return Scaffold(
      appBar: AppBar(
        title: const Text('ファン分析ダッシュボード'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '概要'),
            Tab(text: 'ファン属性'),
            Tab(text: 'エンゲージメント'),
            Tab(text: 'トップファン'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: _showDateRangePicker,
          ),
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: () => _exportReport(context),
          ),
        ],
      ),
      body: fanAnalyticsAsync.when(
        data: (analytics) => TabBarView(
          controller: _tabController,
          children: [
            _buildOverviewTab(analytics),
            _buildFanAttributesTab(analytics),
            _buildEngagementTab(analytics),
            _buildTopFansTab(analytics),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text('エラーが発生しました: $error'),
        ),
      ),
    );
  }

  /// 概要タブを構築するメソッド
  Widget _buildOverviewTab(FanAnalyticsData analytics) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDateRangeHeader(),
          const SizedBox(height: 16.0),
          
          // ファン数の概要カード
          _buildSummaryCard(
            title: 'ファン数の概要',
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  label: '総ファン数',
                  value: '${analytics.totalFans}',
                  icon: Icons.people,
                  color: Colors.blue,
                ),
                _buildStatItem(
                  label: 'アクティブファン',
                  value: '${analytics.activeFans}',
                  icon: Icons.person_add,
                  color: Colors.green,
                ),
                _buildStatItem(
                  label: '新規ファン',
                  value: '${analytics.newFans}',
                  icon: Icons.new_releases,
                  color: Colors.orange,
                ),
                _buildStatItem(
                  label: 'ロイヤルファン',
                  value: '${analytics.loyalFans}',
                  icon: Icons.star,
                  color: Colors.purple,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16.0),
          
          // 会員ティア分布カード
          _buildSummaryCard(
            title: '会員ティア分布',
            child: SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: _buildPieChartSections(analytics.fansByTier),
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          
          // 継続率カード
          _buildSummaryCard(
            title: '継続率',
            child: SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 1.0,
                  barGroups: _buildRetentionBarGroups(analytics.retentionRates),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          return Text('${(value * 100).toInt()}%');
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final keys = analytics.retentionRates.keys.toList();
                          if (value.toInt() >= 0 && value.toInt() < keys.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(keys[value.toInt()]),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ファン属性タブを構築するメソッド
  Widget _buildFanAttributesTab(FanAnalyticsData analytics) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDateRangeHeader(),
          const SizedBox(height: 16.0),
          
          // 地域分布カード
          _buildSummaryCard(
            title: '地域分布',
            child: SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: _buildPieChartSections(analytics.fansByRegion),
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          
          // 年齢分布カード
          _buildSummaryCard(
            title: '年齢分布',
            child: SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: analytics.fansByAge.values.reduce((a, b) => a > b ? a : b) * 1.2,
                  barGroups: _buildAgeBarGroups(analytics.fansByAge),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          return Text('${value.toInt()}');
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final keys = analytics.fansByAge.keys.toList();
                          if (value.toInt() >= 0 && value.toInt() < keys.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(keys[value.toInt()]),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          
          // 性別分布カード
          _buildSummaryCard(
            title: '性別分布',
            child: SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: _buildPieChartSections(analytics.fansByGender),
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// エンゲージメントタブを構築するメソッド
  Widget _buildEngagementTab(FanAnalyticsData analytics) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDateRangeHeader(),
          const SizedBox(height: 16.0),
          
          // エンゲージメント率カード
          _buildSummaryCard(
            title: 'エンゲージメント率',
            child: SizedBox(
              height: 200,
              child: RadarChart(
                RadarChartData(
                  radarShape: RadarShape.polygon,
                  dataSets: [
                    RadarDataSet(
                      dataEntries: _buildEngagementRadarEntries(analytics.engagementRates),
                      color: Colors.blue.withOpacity(0.4),
                      fillColor: Colors.blue.withOpacity(0.2),
                      borderColor: Colors.blue,
                      borderWidth: 2,
                    ),
                  ],
                  radarBorderData: BorderSide(color: Colors.grey.shade300),
                  tickBorderData: BorderSide(color: Colors.grey.shade300, width: 1),
                  gridBorderData: BorderSide(color: Colors.grey.shade200, width: 1),
                  ticksTextStyle: const TextStyle(color: Colors.black, fontSize: 10),
                  titleTextStyle: const TextStyle(color: Colors.black, fontSize: 12),
                  getTitle: (index) {
                    final keys = analytics.engagementRates.keys.toList();
                    if (index >= 0 && index < keys.length) {
                      return keys[index];
                    }
                    return '';
                  },
                  tickCount: 5,
                  titlePositionPercentageOffset: 0.2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          
          // エンゲージメント指標カード
          _buildSummaryCard(
            title: 'エンゲージメント指標',
            child: Column(
              children: analytics.engagementRates.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Text(
                        entry.key,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: LinearProgressIndicator(
                          value: entry.value,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getColorForEngagementRate(entry.key, entry.value),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Text('${(entry.value * 100).toStringAsFixed(1)}%'),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  /// トップファンタブを構築するメソッド
  Widget _buildTopFansTab(FanAnalyticsData analytics) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDateRangeHeader(),
          const SizedBox(height: 16.0),
          
          // トップファンリストカード
          _buildSummaryCard(
            title: 'トップファン',
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: analytics.topFans.length,
              itemBuilder: (context, index) {
                final fan = analytics.topFans[index];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text('${index + 1}'),
                  ),
                  title: Text(fan['username']),
                  subtitle: Text('${fan['monthsSupporting']}ヶ月間サポート中'),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '¥${_formatCurrency(fan['totalSpent'])}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'ポイント: ${fan['loyaltyPoints']}',
                        style: TextStyle(
                          fontSize: 12.0,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  onTap: () => _showFanDetails(context, fan),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 日付範囲ヘッダーを構築するメソッド
  Widget _buildDateRangeHeader() {
    return Row(
      children: [
        const Icon(Icons.date_range, size: 16.0),
        const SizedBox(width: 8.0),
        Text(
          '${_formatDate(_startDate)} 〜 ${_formatDate(_endDate)}',
          style: TextStyle(
            fontSize: 14.0,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  /// 概要カードを構築するメソッド
  Widget _buildSummaryCard({
    required String title,
    required Widget child,
  }) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            child,
          ],
        ),
      ),
    );
  }

  /// 統計項目を構築するメソッド
  Widget _buildStatItem({
    required String label,
    required Stri<response clipped><NOTE>To save on context only part of this file has been shown to you. You should retry this tool after you have searched inside the file with `grep -n` in order to find the line numbers of what you are looking for.</NOTE>