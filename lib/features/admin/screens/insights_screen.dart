import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_birmingham_hub/features/admin/providers/admin_providers.dart';
import 'package:flutter_birmingham_hub/features/admin/providers/insights_providers.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = ref.watch(isUserAdminProvider);
    
    return isAdmin.when(
      data: (isAdmin) {
        if (!isAdmin) {
          // Redirect to login if not admin
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/admin/login');
          });
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return _buildInsightsScreen(context, ref);
      },
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (_, __) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Error loading admin status'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/admin/login'),
                child: const Text('Go to Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInsightsScreen(BuildContext context, WidgetRef ref) {
    final insightsAsync = ref.watch(insightsDataProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Insights'),
        actions: [
          IconButton(
            icon: const Icon(Icons.dashboard),
            tooltip: 'Dashboard',
            onPressed: () => context.go('/admin/dashboard'),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Data',
            onPressed: () => ref.invalidate(insightsDataProvider),
          ),
        ],
      ),
      body: insightsAsync.when(
        data: (_) => _buildInsightsContent(context, ref),
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading insights data...'),
            ],
          ),
        ),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading insights: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(insightsDataProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInsightsContent(BuildContext context, WidgetRef ref) {
    final totalSpeakers = ref.watch(totalSpeakersProvider);
    final totalTalks = ref.watch(totalTalksProvider);
    final acceptanceRate = ref.watch(acceptanceRateProvider);
    final averageRating = ref.watch(averageRatingProvider);
    final topRatedTalks = ref.watch(topRatedTalksProvider);
    final topTags = ref.watch(topTagsProvider);
    final submissionTrend = ref.watch(submissionTrendProvider);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Event Insights',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 24),
          
          // Summary Cards
          GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width > 900 ? 4 : 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildSummaryCard(
                context,
                'Total Speakers',
                totalSpeakers.toString(),
                Icons.people,
                Colors.blue,
              ),
              _buildSummaryCard(
                context,
                'Total Talks',
                totalTalks.toString(),
                Icons.mic,
                Colors.green,
              ),
              _buildSummaryCard(
                context,
                'Acceptance Rate',
                '${acceptanceRate.toStringAsFixed(1)}%',
                Icons.check_circle,
                Colors.orange,
              ),
              _buildSummaryCard(
                context,
                'Average Rating',
                '${averageRating.toStringAsFixed(1)}/5',
                Icons.star,
                Colors.purple,
              ),
            ],
          ),
          const SizedBox(height: 32),
          
          // Top Tags Chart
          if (topTags.isNotEmpty) ...[
            Text(
              'Top Tags',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: _buildTopTagsChart(context, topTags),
            ),
            const SizedBox(height: 32),
          ],
          
          // Submission Trend Chart
          if (submissionTrend.isNotEmpty) ...[
            Text(
              'Submission Trend',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: _buildSubmissionTrendChart(context, submissionTrend),
            ),
            const SizedBox(height: 32),
          ],
          
          // Top Rated Talks
          if (topRatedTalks.isNotEmpty) ...[
            Text(
              'Top Rated Talks',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: _buildTopRatedTalksChart(context, topRatedTalks),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: topRatedTalks.length > 5 ? 5 : topRatedTalks.length,
              itemBuilder: (context, index) {
                final talk = topRatedTalks[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(talk['title'] as String),
                    subtitle: Text('${(talk['average'] as num).toStringAsFixed(1)}/5 (${talk['count']} ratings)'),
                    leading: CircleAvatar(
                      child: Text('${index + 1}'),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(5, (starIndex) {
                        return Icon(
                          starIndex < (talk['average'] as num).floor()
                              ? Icons.star
                              : starIndex < (talk['average'] as num)
                                  ? Icons.star_half
                                  : Icons.star_border,
                          color: Colors.amber,
                          size: 20,
                        );
                      }),
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopTagsChart(BuildContext context, List<Map<String, dynamic>> topTags) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: topTags.isNotEmpty ? (topTags.first['count'] as num).toDouble() * 1.2 : 10,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.blueGrey.shade800,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${topTags[groupIndex]['tag']}: ${topTags[groupIndex]['count']} talks',
                const TextStyle(color: Colors.white),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= topTags.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    _truncateString(topTags[value.toInt()]['tag'] as String, 10),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                );
              },
              reservedSize: 40,
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
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
        gridData: const FlGridData(show: false),
        barGroups: topTags.asMap().entries.map((entry) {
          final index = entry.key;
          final tag = entry.value;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: (tag['count'] as num).toDouble(),
                color: _getColorByIndex(index),
                width: 22,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSubmissionTrendChart(BuildContext context, List<Map<String, dynamic>> submissionTrend) {
    return LineChart(
      LineChartData(
        gridData: const FlGridData(
          show: true,
          drawVerticalLine: false,
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= submissionTrend.length || value.toInt() < 0) {
                  return const SizedBox.shrink();
                }
                final month = submissionTrend[value.toInt()]['month'] as String;
                // Format as MMM YY
                final parts = month.split('-');
                if (parts.length == 2) {
                  final date = DateTime(int.parse(parts[0]), int.parse(parts[1]));
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      DateFormat('MMM yy').format(date),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey.shade300),
        ),
        minX: 0,
        maxX: (submissionTrend.length - 1).toDouble(),
        minY: 0,
        maxY: submissionTrend.isNotEmpty
            ? submissionTrend.map((item) => (item['count'] as num).toDouble()).reduce((a, b) => a > b ? a : b) * 1.2
            : 10,
        lineBarsData: [
          LineChartBarData(
            spots: submissionTrend.asMap().entries.map((entry) {
              return FlSpot(
                entry.key.toDouble(),
                (entry.value['count'] as num).toDouble(),
              );
            }).toList(),
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.blue.withOpacity(0.2),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: Colors.blueGrey.shade800,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final index = spot.x.toInt();
                if (index >= 0 && index < submissionTrend.length) {
                  final month = submissionTrend[index]['month'] as String;
                  final count = submissionTrend[index]['count'] as num;
                  final parts = month.split('-');
                  if (parts.length == 2) {
                    final date = DateTime(int.parse(parts[0]), int.parse(parts[1]));
                    return LineTooltipItem(
                      '${DateFormat('MMMM yyyy').format(date)}\n$count submissions',
                      const TextStyle(color: Colors.white),
                    );
                  }
                }
                return null;
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTopRatedTalksChart(BuildContext context, List<Map<String, dynamic>> topRatedTalks) {
    // Limit to top 5 talks for the chart
    final talksForChart = topRatedTalks.length > 5 ? topRatedTalks.sublist(0, 5) : topRatedTalks;
    
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 5, // Rating is out of 5
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.blueGrey.shade800,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${talksForChart[groupIndex]['title']}\n${(talksForChart[groupIndex]['average'] as num).toStringAsFixed(1)}/5 (${talksForChart[groupIndex]['count']} ratings)',
                const TextStyle(color: Colors.white),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= talksForChart.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    _truncateString(talksForChart[value.toInt()]['title'] as String, 15),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                );
              },
              reservedSize: 40,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                if (value == 0) return const SizedBox.shrink();
                return Text(value.toInt().toString());
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
        gridData: const FlGridData(show: true, horizontalInterval: 1),
        barGroups: talksForChart.asMap().entries.map((entry) {
          final index = entry.key;
          final talk = entry.value;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: (talk['average'] as num).toDouble(),
                color: Colors.amber,
                width: 22,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Color _getColorByIndex(int index) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.amber,
      Colors.cyan,
    ];
    return colors[index % colors.length];
  }

  String _truncateString(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text;
    }
    return '${text.substring(0, maxLength)}...';
  }
}
