import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../l10n/app_localizations.dart';
import '../models/history_item.dart';
import '../services/history_service.dart';
import '../services/favorites_service.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  List<HistoryItem> _allItems = [];
  List<FavoriteItem> _favorites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    _allItems = await HistoryService.getHistory();
    _favorites = await FavoritesService.getFavorites();
    setState(() => _isLoading = false);
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDistributionItem(
    String label,
    int count,
    String percentage,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: double.parse(percentage) / 100,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  count.toString(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$percentage%',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(String date, int count) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.calendar_today, color: Colors.blue),
        title: Text(date),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: count > 0 ? Colors.blue : Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: count > 0 ? Colors.white : Colors.black54,
            ),
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections(
    Map<String, int> distribution,
    int total,
  ) {
    return distribution.entries.map((entry) {
      final percentage = (entry.value / total * 100);
      final color = _getColorForType(entry.key);

      return PieChartSectionData(
        value: entry.value.toDouble(),
        title: '${percentage.toStringAsFixed(0)}%',
        color: color,
        radius: 100,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  List<BarChartGroupData> _buildBarChartGroups(Map<DateTime, int> data) {
    int index = 0;
    return data.entries.map((entry) {
      final barGroup = BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: entry.value.toDouble(),
            color: Colors.blue,
            width: 16,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
      );
      index++;
      return barGroup;
    }).toList();
  }

  double _getMaxYForBarChart(Map<DateTime, int> data) {
    final maxValue = data.values.fold(
      0,
      (max, value) => value > max ? value : max,
    );
    return (maxValue + 2).toDouble(); // Biraz boşluk bırak
  }

  Color _getColorForType(String type) {
    switch (type.toLowerCase()) {
      case 'url':
        return Colors.blue;
      case 'wifi':
        return Colors.purple;
      case 'telefon':
        return Colors.green;
      case 'e-mail':
        return Colors.orange;
      case 'sms':
        return Colors.teal;
      case 'konum':
        return Colors.red;
      case 'kartvizit':
        return Colors.indigo;
      case 'metin':
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(loc.homeActionAnalytics),
          backgroundColor: Theme.of(context).colorScheme.surface,
          surfaceTintColor: Colors.transparent,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // İstatistikler
    final totalCount = _allItems.length;
    final scannedCount = _allItems.where((item) => item.isScanned).length;
    final createdCount = totalCount - scannedCount;
    final archivedCount = _allItems.where((item) => item.isArchived).length;
    final favoriteCount = _favorites.length;

    // Tür dağılımı
    final typeDistribution = <String, int>{};
    for (final item in _allItems) {
      typeDistribution[item.type] = (typeDistribution[item.type] ?? 0) + 1;
    }

    // Son 7 gün aktivitesi
    final now = DateTime.now();
    final last7Days = <DateTime, int>{};
    for (int i = 6; i >= 0; i--) {
      final date = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: i));
      last7Days[date] = 0;
    }
    for (final item in _allItems) {
      final itemDate = DateTime(item.date.year, item.date.month, item.date.day);
      if (last7Days.containsKey(itemDate)) {
        last7Days[itemDate] = last7Days[itemDate]! + 1;
      }
    }

    // Kategori dağılımı
    final categoryDistribution = <String, int>{};
    for (final item in _allItems) {
      final category = item.category ?? loc.analyticsUncategorized;
      categoryDistribution[category] =
          (categoryDistribution[category] ?? 0) + 1;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.homeActionAnalytics),
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: loc.analyticsRefresh,
            onPressed: _loadData,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Genel İstatistikler
            Text(
              loc.analyticsOverview,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    loc.analyticsTotalQr,
                    totalCount.toString(),
                    Icons.qr_code_2,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    loc.homeActionFavorites,
                    favoriteCount.toString(),
                    Icons.favorite,
                    Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    loc.analyticsScanned,
                    scannedCount.toString(),
                    Icons.qr_code_scanner,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    loc.analyticsCreated,
                    createdCount.toString(),
                    Icons.create,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    loc.analyticsArchived,
                    archivedCount.toString(),
                    Icons.archive,
                    Colors.purple,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    loc.analyticsActive,
                    (totalCount - archivedCount).toString(),
                    Icons.check_circle,
                    Colors.teal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Tür Dağılımı
            Text(
              loc.analyticsTypeDistribution,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (typeDistribution.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(loc.analyticsNoData),
                ),
              )
            else ...[
              // Pasta grafiği
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    height: 250,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                        sections: _buildPieChartSections(
                          typeDistribution,
                          totalCount,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Detay listesi
              ...typeDistribution.entries.map((entry) {
                final percentage = (entry.value / totalCount * 100)
                    .toStringAsFixed(1);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _buildDistributionItem(
                    entry.key,
                    entry.value,
                    percentage,
                    _getColorForType(entry.key),
                  ),
                );
              }),
            ],
            const SizedBox(height: 32),

            // Kategori Dağılımı
            Text(
              loc.analyticsCategoryDistribution,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (categoryDistribution.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(loc.analyticsNoData),
                ),
              )
            else
              ...categoryDistribution.entries.map((entry) {
                final percentage = (entry.value / totalCount * 100)
                    .toStringAsFixed(1);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _buildDistributionItem(
                    entry.key,
                    entry.value,
                    percentage,
                    Colors.purple,
                  ),
                );
              }),
            const SizedBox(height: 32),

            // Son 7 Gün Aktivitesi
            Text(
              loc.analyticsLast7Days,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Çubuk grafik
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  height: 200,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: _getMaxYForBarChart(last7Days),
                      barTouchData: const BarTouchData(enabled: true),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final date = last7Days.keys.elementAt(
                                value.toInt(),
                              );
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}',
                                  style: const TextStyle(fontSize: 10),
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                '${value.toInt()}',
                                style: const TextStyle(fontSize: 10),
                              );
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: _buildBarChartGroups(last7Days),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Detay listesi
            ...last7Days.entries.map((entry) {
              final dateStr =
                  '${entry.key.day.toString().padLeft(2, '0')}.${entry.key.month.toString().padLeft(2, '0')}.${entry.key.year}';
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildActivityItem(dateStr, entry.value),
              );
            }),
          ],
        ),
      ),
    );
  }
}
