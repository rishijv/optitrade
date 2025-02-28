// routes.dart
import 'package:flutter/material.dart';
import 'screens/home_page.dart';
import 'screens/stock_details_page.dart';
import 'screens/backtesting_page.dart';
import 'screens/settings_page.dart';
import 'screens/educational_resources_page.dart';

final Map<String, WidgetBuilder> routes = {
  '/': (context) => HomePage(),
  '/stock-details': (context) {
    final ticker = ModalRoute.of(context)?.settings.arguments as String?;
    if (ticker == null) {
      return const Scaffold(
        body: Center(child: Text("Error: No ticker provided")),
      );
    }
    return StockDetailsPage(ticker: ticker);
  },
  '/backtesting': (context) => const BacktestingPage(),
  '/settings': (context) => const SettingsPage(),
  '/educational-resources': (context) => const EducationalResourcesPage(),
};
