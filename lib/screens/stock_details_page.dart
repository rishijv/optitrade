// screens/stock_details_page.dart
import 'package:flutter/material.dart';
import 'package:yahoo_finance_data_reader/yahoo_finance_data_reader.dart';
import '../services/api_service.dart';

class StockDetailsPage extends StatefulWidget {
  final String ticker;
  const StockDetailsPage({Key? key, required this.ticker}) : super(key: key);

  @override
  _StockDetailsPageState createState() => _StockDetailsPageState();
}

class _StockDetailsPageState extends State<StockDetailsPage> {
  late Future<YahooFinanceResponse> futureData;
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    futureData = apiService.fetchDailyData(widget.ticker);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stock Details - ${widget.ticker}'),
      ),
      body: FutureBuilder<YahooFinanceResponse>(
        future: futureData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No data'));
          }

          YahooFinanceResponse response = snapshot.data!;
          return ListView.builder(
            itemCount: response.candlesData.length,
            itemBuilder: (context, index) {
              YahooFinanceCandleData candle = response.candlesData[index];
              return _CandleCard(candle: candle);
            },
          );
        },
      ),
    );
  }
}

class _CandleCard extends StatelessWidget {
  final YahooFinanceCandleData candle;
  const _CandleCard({Key? key, required this.candle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String date = candle.date.toIso8601String().split('T').first;
    return Card(
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(date, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text('Open: ${candle.open.toStringAsFixed(2)}'),
                Text('Close: ${candle.close.toStringAsFixed(2)}'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text('High: ${candle.high.toStringAsFixed(2)}'),
                Text('Low: ${candle.low.toStringAsFixed(2)}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
