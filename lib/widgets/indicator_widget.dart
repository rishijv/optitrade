import 'package:flutter/material.dart';

class IndicatorWidget extends StatelessWidget {
  final String indicatorName;
  final double value;

  const IndicatorWidget(
      {super.key, required this.indicatorName, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(indicatorName),
        Text(value.toStringAsFixed(2)),
      ],
    );
  }
}
