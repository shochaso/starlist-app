import 'package:flutter/material.dart';

void main() {
  runApp(const StarDashboardModernMockApp());
}

class StarDashboardModernMockApp extends StatelessWidget {
  const StarDashboardModernMockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Starlist Dashboard Mock',
      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'Inter',
        colorScheme: const ColorScheme.dark(
          background: _background,
          surface: _surface,
          primary: _accentYellow,
          secondary: _accentBlue,
        ),
        useMaterial3: true,
      ),
      home: const StarDashboardModernScreen(),
    );
  }
}

class StarDashboardModernScreen extends StatelessWidget {
  const StarDashboardModernScreen({super.key});

  static const _navItems = [
    _NavItem('Dashboard', true),
    _NavItem('My Content', false),
    _NavItem('Fans', false),
    _NavItem('Earnings', false),
    _NavItem('Reports', false),
    _NavItem('Settings', false),
  ];

  static final _recentActivities = [
    _Activity('Fan Name 1', '最新の投稿', 'Premium', _accentGreen, _accentGreenSoft, _accentYellow),
    _Activity('Fan Name 2', '100 S-Points', 'Standard', _accentYellow, _accentYellowSoft, _accentYellow),
    _Activity('Fan Name 3', 'Standard Fan', 'Standard', _accentBlue, _accentYellowSoft, _accentYellow),
    _Activity('Fan Name 4', 'チケット購入', 'Light', _accentYellow, _accentBlueSoft, _accentBlue),
    _Activity('Fan Name 5', '有料提案', 'Premium', _accentGreen, _accentGreenSoft, _accentGreen),
  ];

  static final _tableRows = [
    const _TableRowData('Behind The Scene #12', 'Video', 'Premium', '18,420', '¥72,800', '+12.8%'),
    const _TableRowData('Birthday Live', 'Live Stream', 'Premium', '12,230', '¥55,400', '+9.3%'),
    const _TableRowData('Morning Routine', 'Shorts', 'Standard', '42,500', '¥18,200', '+5.4%'),
    const _TableRowData('Merch Drop Vol.3', 'Shop', 'Premium', '4,980', '¥102,000', '+28.1%'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildNavRail(context),
                  const SizedBox(width: 1),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildKpiRow(context),
                          const SizedBox(height: 24),
                          _buildChartsAndActivity(context),
                          const SizedBox(height: 24),
                          _buildTableCard(context),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: _surfaceDark,
        border: Border(
          bottom: BorderSide(color: _divider, width: 1),
        ),
      ),
      child: Row(
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _accentYellow.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.star, color: _accentYellow),
              ),
              const SizedBox(width: 8),
              const Text(
                'Starlist',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: _textPrimary,
                ),
              ),
            ],
          ),
          const Spacer(),
          _buildIconButton(context, Icons.notifications_outlined),
          const SizedBox(width: 16),
          _buildIconButton(context, Icons.settings_outlined),
          const SizedBox(width: 16),
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: _accentYellow,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Text(
              'JD',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _background,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(BuildContext context, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(8),
      ),
      width: 40,
      height: 40,
      child: IconButton(
        visualDensity: VisualDensity.compact,
        onPressed: () {},
        icon: Icon(icon, color: _textPrimary),
      ),
    );
  }

  Widget _buildNavRail(BuildContext context) {
    return Container(
      width: 220,
      decoration: const BoxDecoration(
        color: _surfaceDark,
        border: Border(
          right: BorderSide(color: _divider, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          for (final item in _navItems) _NavLink(item: item),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, color: _accentYellow),
              label: const Text(
                'Create New',
                style: TextStyle(color: _accentYellow),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: _accentYellow, width: 1.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiRow(BuildContext context) {
    final cards = [
      _KpiData('Total Fans', '12,345', _accentYellow, _sparklineOne),
      _KpiData('Monthly Revenue', '¥ 250,000', _accentGreen, _sparklineTwo),
      _KpiData('Engagement Rate', '7.8%', _accentBlue, _sparklineThree),
    ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < cards.length; i++) ...[
          Expanded(child: _KpiCard(data: cards[i])),
          if (i < cards.length - 1) const SizedBox(width: 24),
        ],
      ],
    );
  }

  Widget _buildChartsAndActivity(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildAreaChartPlaceholder(context)),
        const SizedBox(width: 24),
        SizedBox(
          width: 320,
          child: _buildRecentActivityCard(context),
        ),
      ],
    );
  }

  Widget _buildAreaChartPlaceholder(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration,
      height: 340,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Fan Growth Over Time',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: _accentYellowSoft,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: const Text(
                '[Area Chart Placeholder]',
                style: TextStyle(
                  fontSize: 14,
                  color: _textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivityCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Activity',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          for (final activity in _recentActivities) ...[
            _ActivityTile(activity: activity),
            if (activity != _recentActivities.last) const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  Widget _buildTableCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top Performing Content',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: _divider.withOpacity(0.4), width: 1),
                color: _surfaceDark,
              ),
              child: Column(
                children: [
                  _buildTableHeader(),
                  const Divider(height: 1, color: _divider),
                  for (final row in _tableRows)
                    _ContentDataRow(row: row),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: const [
          Expanded(flex: 3, child: _TableHeaderLabel('Title')),
          Expanded(flex: 2, child: _TableHeaderLabel('Type')),
          Expanded(flex: 2, child: _TableHeaderLabel('Plan')), 
          Expanded(flex: 2, child: _TableHeaderLabel('Views')),
          Expanded(flex: 2, child: _TableHeaderLabel('Revenue')),
          Expanded(flex: 2, child: _TableHeaderLabel('Growth')),
        ],
      ),
    );
  }
}

class _NavItem {
  const _NavItem(this.label, this.selected);
  final String label;
  final bool selected;
}

class _NavLink extends StatelessWidget {
  const _NavLink({required this.item});

  final _NavItem item;

  @override
  Widget build(BuildContext context) {
    final color = item.selected ? _accentYellow : _textSecondary;
    return InkWell(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: item.selected ? _accentYellowSoft : Colors.transparent,
          border: Border(
            left: BorderSide(
              color: item.selected ? _accentYellow : Colors.transparent,
              width: 4,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              _iconForLabel(item.label),
              color: color,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: item.selected ? FontWeight.w600 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static IconData _iconForLabel(String label) {
    switch (label) {
      case 'Dashboard':
        return Icons.space_dashboard_outlined;
      case 'My Content':
        return Icons.tune;
      case 'Fans':
        return Icons.people_alt_outlined;
      case 'Earnings':
        return Icons.account_balance_wallet_outlined;
      case 'Reports':
        return Icons.insert_drive_file_outlined;
      case 'Settings':
        return Icons.settings_outlined;
      default:
        return Icons.circle_outlined;
    }
  }
}

class _KpiData {
  const _KpiData(this.title, this.value, this.accent, this.sparkline);
  final String title;
  final String value;
  final Color accent;
  final Gradient sparkline;
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({required this.data});

  final _KpiData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 104,
      decoration: _cardDecoration.copyWith(boxShadow: const [
        BoxShadow(
          color: Colors.black45,
          blurRadius: 8,
          offset: Offset(0, 4),
        ),
      ]),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Stack(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    data.title,
                    style: const TextStyle(
                      fontSize: 14,
                      color: _textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    data.value,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: data.accent,
                    ),
                  ),
                ],
              ),
              Icon(Icons.trending_up, color: data.accent.withOpacity(0.9)),
            ],
          ),
          Positioned(
            right: -10,
            bottom: -10,
            child: Container(
              width: 140,
              height: 110,
              decoration: BoxDecoration(
                gradient: data.sparkline,
                borderRadius: BorderRadius.circular(80),
                opacity: 0.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Activity {
  const _Activity(
    this.name,
    this.action,
    this.tier,
    this.avatarColor,
    this.badgeColor,
    this.badgeTextColor,
  );

  final String name;
  final String action;
  final String tier;
  final Color avatarColor;
  final Color badgeColor;
  final Color badgeTextColor;
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.activity});

  final _Activity activity;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: activity.avatarColor,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            activity.name.substring(0, 2).toUpperCase(),
            style: const TextStyle(
              color: _background,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(color: _textPrimary, fontSize: 14),
              children: [
                TextSpan(
                  text: activity.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const TextSpan(text: ' が '),
                TextSpan(
                  text: activity.action,
                  style: const TextStyle(color: _accentBlue),
                ),
                const TextSpan(text: ' を行いました。'),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: activity.badgeColor,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            activity.tier,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: activity.badgeTextColor,
            ),
          ),
        ),
      ],
    );
  }
}

class _TableRowData {
  const _TableRowData(this.title, this.type, this.plan, this.views, this.revenue, this.growth);

  final String title;
  final String type;
  final String plan;
  final String views;
  final String revenue;
  final String growth;
}

class _ContentDataRow extends StatelessWidget {
  const _ContentDataRow({required this.row});

  final _TableRowData row;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: _divider, width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              row.title,
              style: const TextStyle(
                color: _textPrimary,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              row.type,
              style: const TextStyle(color: _textSecondary),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              row.plan,
              style: const TextStyle(color: _textSecondary),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              row.views,
              style: const TextStyle(color: _textPrimary),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              row.revenue,
              style: const TextStyle(color: _textPrimary),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              row.growth,
              style: const TextStyle(
                color: _accentGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TableHeaderLabel extends StatelessWidget {
  const _TableHeaderLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: _textSecondary,
        letterSpacing: 0.8,
      ),
    );
  }
}

const _background = Color(0xFF0E1217);
const _surface = Color(0xFF161B22);
const _surfaceDark = Color(0xFF161C24);
const _divider = Color(0x26FFD166);
const _textPrimary = Color(0xFFDCE2EA);
const _textSecondary = Color(0xFF8A94A6);
const _accentYellow = Color(0xFFFFD166);
const _accentYellowSoft = Color(0x33FFD166);
const _accentGreen = Color(0xFF06D6A0);
const _accentGreenSoft = Color(0x3306D6A0);
const _accentBlue = Color(0xFF4CC9F0);
const _accentBlueSoft = Color(0x334CC9F0);

const _cardDecoration = BoxDecoration(
  color: _surface,
  borderRadius: BorderRadius.all(Radius.circular(12)),
  boxShadow: [
    BoxShadow(
      color: Colors.black26,
      blurRadius: 10,
      offset: Offset(0, 4),
    ),
  ],
);

const _sparklineOne = LinearGradient(
  colors: [
    Color(0xFFFFD166),
    Color(0xFF06D6A0),
  ],
  begin: Alignment.bottomLeft,
  end: Alignment.topRight,
);

const _sparklineTwo = LinearGradient(
  colors: [
    Color(0xFF06D6A0),
    Color(0xFF4CC9F0),
  ],
  begin: Alignment.bottomLeft,
  end: Alignment.topRight,
);

const _sparklineThree = LinearGradient(
  colors: [
    Color(0xFF4CC9F0),
    Color(0xFFFFD166),
  ],
  begin: Alignment.bottomLeft,
  end: Alignment.topRight,
);
