import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/app_state.dart';
import '../services/firestore_service.dart';
import '../services/local_storage_service.dart';
import '../models/journal_entry.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedPeriod = 7; // 7, 14, 30 days
  List<JournalEntry> _entries = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final appState = Provider.of<AppState>(context, listen: false);
      final endDate = DateTime.now();
      final startDate = endDate.subtract(Duration(days: _selectedPeriod));

      List<JournalEntry> entries;
      if (appState.localOnlyMode) {
        final localService = LocalStorageService();
        entries = await localService.getJournalEntriesForPeriod(startDate, endDate);
      } else {
        final firestoreService = FirestoreService();
        entries = await firestoreService.getJournalEntriesForPeriod(startDate, endDate);
      }

      setState(() {
        _entries = entries;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error loading entries: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood Dashboard'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          return RefreshIndicator(
            onRefresh: _loadEntries,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatsOverview(appState),
                  const SizedBox(height: 24),
                  _buildPeriodSelector(),
                  const SizedBox(height: 16),
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (_entries.isEmpty)
                    _buildEmptyState()
                  else ...[
                    _buildMoodChart(),
                    const SizedBox(height: 24),
                    _buildEmotionBreakdown(),
                    const SizedBox(height: 24),
                    _buildInsights(),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsOverview(AppState appState) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Journey',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Current Streak',
                    '${appState.userStats?.streak ?? 0}',
                    Icons.local_fire_department,
                    Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Total Entries',
                    '${appState.userStats?.totalJournalEntries ?? 0}',
                    Icons.book,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Badges Earned',
                    '${appState.userStats?.badges.length ?? 0}',
                    Icons.emoji_events,
                    Colors.amber,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPeriodSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Time Period',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildPeriodButton('7 Days', 7),
                const SizedBox(width: 8),
                _buildPeriodButton('14 Days', 14),
                const SizedBox(width: 8),
                _buildPeriodButton('30 Days', 30),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodButton(String label, int days) {
    final isSelected = _selectedPeriod == days;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedPeriod = days;
          });
          _loadEntries();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected 
                ? Theme.of(context).colorScheme.primary 
                : Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(
              Icons.insights,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'No Data Yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start journaling to see your mood insights and patterns here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodChart() {
    if (_entries.isEmpty) return const SizedBox();

    final chartData = _prepareChartData();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mood Trend',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            _getEmotionLabel(value),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                        reservedSize: 40,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final date = DateTime.now().subtract(
                            Duration(days: _selectedPeriod - value.toInt()),
                          );
                          return Text(
                            '${date.day}/${date.month}',
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
                  lineBarsData: [
                    LineChartBarData(
                      spots: chartData,
                      isCurved: true,
                      color: Theme.of(context).colorScheme.primary,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmotionBreakdown() {
    final emotionCounts = <String, int>{};
    for (final entry in _entries) {
      if (entry.analysis != null) {
        final emotion = entry.analysis!.emotion;
        emotionCounts[emotion] = (emotionCounts[emotion] ?? 0) + 1;
      }
    }

    if (emotionCounts.isEmpty) return const SizedBox();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Emotion Breakdown',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...emotionCounts.entries.map((entry) {
              final percentage = (entry.value / _entries.length * 100).round();
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: _getEmotionColor(entry.key),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              entry.key.toUpperCase(),
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        Text('$percentage%'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: entry.value / _entries.length,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getEmotionColor(entry.key),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildInsights() {
    final insights = _generateInsights();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Insights',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...insights.map((insight) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lightbulb,
                    size: 16,
                    color: Colors.amber[600],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      insight,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _prepareChartData() {
    final spots = <FlSpot>[];
    final now = DateTime.now();
    
    for (int i = 0; i < _selectedPeriod; i++) {
      final date = now.subtract(Duration(days: _selectedPeriod - i - 1));
      final dayEntries = _entries.where((entry) {
        final entryDate = DateTime(
          entry.timestamp.year,
          entry.timestamp.month,
          entry.timestamp.day,
        );
        final targetDate = DateTime(date.year, date.month, date.day);
        return entryDate == targetDate;
      }).toList();

      if (dayEntries.isNotEmpty) {
        final avgMood = dayEntries
            .where((e) => e.analysis != null)
            .map((e) => _getEmotionValue(e.analysis!.emotion))
            .fold(0.0, (a, b) => a + b) / dayEntries.length;
        spots.add(FlSpot(i.toDouble(), avgMood));
      }
    }

    return spots;
  }

  double _getEmotionValue(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'depressed': return 1;
      case 'sad': return 2;
      case 'frustrated': return 3;
      case 'angry': return 3.5;
      case 'neutral': return 4;
      case 'anxious': return 4.5;
      case 'calm': return 5;
      case 'hopeful': return 6;
      case 'happy': return 7;
      case 'excited': return 8;
      default: return 4;
    }
  }

  String _getEmotionLabel(double value) {
    if (value <= 2) return 'Low';
    if (value <= 4) return 'Neutral';
    if (value <= 6) return 'Good';
    return 'High';
  }

  Color _getEmotionColor(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'happy': return Colors.green;
      case 'excited': return Colors.orange;
      case 'calm': return Colors.blue;
      case 'hopeful': return Colors.teal;
      case 'sad': return Colors.indigo;
      case 'anxious': return Colors.purple;
      case 'angry': return Colors.red;
      case 'frustrated': return Colors.deepOrange;
      case 'depressed': return Colors.grey;
      default: return Colors.grey;
    }
  }

  List<String> _generateInsights() {
    final insights = <String>[];
    
    if (_entries.isEmpty) return insights;

    // Most common emotion
    final emotionCounts = <String, int>{};
    for (final entry in _entries) {
      if (entry.analysis != null) {
        final emotion = entry.analysis!.emotion;
        emotionCounts[emotion] = (emotionCounts[emotion] ?? 0) + 1;
      }
    }

    if (emotionCounts.isNotEmpty) {
      final mostCommon = emotionCounts.entries
          .reduce((a, b) => a.value > b.value ? a : b);
      insights.add(
        'Your most frequent emotion this period was ${mostCommon.key}.',
      );
    }

    // Journaling consistency
    if (_entries.length >= _selectedPeriod * 0.7) {
      insights.add('Great job maintaining consistent journaling habits!');
    } else if (_entries.length < _selectedPeriod * 0.3) {
      insights.add('Try to journal more regularly to better track your mood patterns.');
    }

    // Crisis triggers
    final triggersCount = _entries.where((e) => e.localQuickTrigger).length;
    if (triggersCount > 0) {
      insights.add(
        'Consider reaching out to a mental health professional for additional support.',
      );
    }

    return insights;
  }
}
