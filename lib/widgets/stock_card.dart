// widgets/stock_card.dart
import 'package:flutter/material.dart';
import 'package:yahoo_finance_data_reader/yahoo_finance_data_reader.dart';

class StockCard extends StatelessWidget {
  final String stockSymbol;

  const StockCard({
    Key? key,
    required this.stockSymbol,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<YahooFinanceResponse>(
      future: YahooFinanceDailyReader().getDailyDTOs(stockSymbol),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              title: Text(stockSymbol),
              subtitle: const Text('Loading price...'),
              trailing: const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(),
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              title: Text(stockSymbol),
              subtitle: const Text('Error loading price'),
              trailing: const Icon(Icons.error, color: Colors.red),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.candlesData.isEmpty) {
          return Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              title: Text(stockSymbol),
              subtitle: const Text('No data available'),
              trailing: const Icon(Icons.info),
            ),
          );
        } else {
          // Use the last candle's close price as the live price
          YahooFinanceResponse response = snapshot.data!;
          double currentPrice = response.candlesData.last.close;
          return Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              title: Text(stockSymbol),
              subtitle: Text('Price: \$${currentPrice.toStringAsFixed(2)}'),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/stock-details',
                  arguments: stockSymbol,
                );
              },
            ),
          );
        }
      },
    );
  }
}
