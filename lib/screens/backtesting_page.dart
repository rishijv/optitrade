import 'package:flutter/material.dart';

class BacktestingPage extends StatelessWidget {
  const BacktestingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Backtesting')),
      body: Center(child: Text('Backtesting Results here')),
    );
  }
}
