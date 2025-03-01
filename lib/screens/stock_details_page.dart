import 'package:flutter/material.dart';
import 'package:yahoo_finance_data_reader/yahoo_finance_data_reader.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../services/api_service.dart';
import 'dart:math';
import 'package:intl/intl.dart'; // For date formatting

// A simple model for chart data (used for the moving average series)
class ChartData {
  final DateTime date;
  final double value;
  ChartData(this.date, this.value);
}

class StockDetailsPage extends StatefulWidget {
  final String ticker;
  const StockDetailsPage({Key? key, required this.ticker}) : super(key: key);

  @override
  _StockDetailsPageState createState() => _StockDetailsPageState();
}

class _StockDetailsPageState extends State<StockDetailsPage> {
  late Future<YahooFinanceResponse> futureData;
  final ApiService apiService = ApiService();
  bool showAverage = false;
  late TooltipBehavior _tooltipBehavior;

  @override
  void initState() {
    super.initState();
    futureData = apiService.fetchDailyData(widget.ticker);
    _tooltipBehavior = TooltipBehavior(enable: true);
  }

  // Filter data to last 6 months
  List<YahooFinanceCandleData> filterLastSixMonths(
      List<YahooFinanceCandleData> data) {
    if (data.isEmpty) return [];
    final now = DateTime.now();
    final sixMonthsAgo = DateTime(now.year, now.month - 6, now.day);
    return data.where((candle) => candle.date.isAfter(sixMonthsAgo)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.ticker} - Last 6 Months'),
        actions: [
          IconButton(
            icon: Icon(showAverage ? Icons.show_chart : Icons.trending_up),
            onPressed: () {
              setState(() {
                showAverage = !showAverage;
              });
            },
            tooltip: 'Toggle Average Line',
          ),
        ],
      ),
      body: FutureBuilder<YahooFinanceResponse>(
        future: futureData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.candlesData.isEmpty) {
            return const Center(child: Text('No data available'));
          }

          // Get and filter data to last 6 months
          final allData = snapshot.data!.candlesData;
          final filteredData = filterLastSixMonths(allData);

          if (filteredData.isEmpty) {
            return const Center(
                child: Text('No data available for the last 6 months'));
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Price Information Card
                _buildPriceInfoCard(filteredData.last),
                const SizedBox(height: 20),
                // Stock Chart using Syncfusion Flutter Charts
                Expanded(
                  child: _buildStockChart(filteredData),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPriceInfoCard(YahooFinanceCandleData latestData) {
    final priceChange = latestData.close - latestData.open;
    final priceChangePercentage = (priceChange / latestData.open) * 100;
    final isPositive = priceChange >= 0;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '\$${latestData.close.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                  color: isPositive ? Colors.green : Colors.red,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '${isPositive ? "+" : ""}${priceChange.toStringAsFixed(2)} (${priceChangePercentage.toStringAsFixed(2)}%)',
                  style: TextStyle(
                    color: isPositive ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
                'Last updated: ${latestData.date.toLocal().toString().split(' ')[0]}'),
          ],
        ),
      ),
    );
  }

  Widget _buildStockChart(List<YahooFinanceCandleData> data) {
    // Compute moving average data if enabled
    List<ChartData> movingAverageData = [];
    if (showAverage && data.length >= 20) {
      const int movingAveragePeriod = 20;
      for (int i = movingAveragePeriod - 1; i < data.length; i++) {
        double sum = 0;
        for (int j = 0; j < movingAveragePeriod; j++) {
          sum += data[i - j].close;
        }
        final average = sum / movingAveragePeriod;
        movingAverageData.add(ChartData(data[i].date, average));
      }
    }

    return SfCartesianChart(
      title: ChartTitle(text: '${widget.ticker} - Last 6 Months'),
      legend: Legend(isVisible: true, position: LegendPosition.bottom),
      tooltipBehavior: _tooltipBehavior,
      primaryXAxis: DateTimeAxis(
        dateFormat: DateFormat.MMMd(),
        intervalType: DateTimeIntervalType.auto,
        edgeLabelPlacement: EdgeLabelPlacement.shift,
      ),
      primaryYAxis: NumericAxis(
        labelFormat: '\${value}',
      ),
      series: <CartesianSeries>[
        // Main price series
        LineSeries<YahooFinanceCandleData, DateTime>(
          dataSource: data,
          xValueMapper: (YahooFinanceCandleData candle, _) => candle.date,
          yValueMapper: (YahooFinanceCandleData candle, _) => candle.close,
          name: 'Close Price',
          markerSettings: MarkerSettings(isVisible: true),
          enableTooltip: true,
        ),
        // 20-Day Moving Average series (if enabled)
        if (showAverage && movingAverageData.isNotEmpty)
          LineSeries<ChartData, DateTime>(
            dataSource: movingAverageData,
            xValueMapper: (ChartData chartData, _) => chartData.date,
            yValueMapper: (ChartData chartData, _) => chartData.value,
            name: '20-Day Moving Average',
            dashArray: <double>[5, 5],
            color: Colors.orange,
            markerSettings: MarkerSettings(isVisible: false),
            enableTooltip: true,
          ),
      ],
    );
  }
}
