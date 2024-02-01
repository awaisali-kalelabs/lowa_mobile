import 'dart:math';

/// Gauge chart example, where the data does not cover a full revolution in the
/// chart.
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:order_booker/gauge_segment.dart';

void main() {
  runApp(SpotSellChart(_createSampleData()));
}

class SpotSellChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  SpotSellChart(this.seriesList, {this.animate});

  /// Creates a [PieChart] with sample data and no transition.
  factory SpotSellChart.withSampleData() {
    return new SpotSellChart(
      _createSampleData(),
      // Disable animations for image tests.
      animate: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return new charts.PieChart(seriesList,
        animate: true,
        behaviors: [
          new charts.ChartTitle('Sales (%)',
              //subTitle: 'Sales (%)',
              titleStyleSpec: new charts.TextStyleSpec(fontSize: 16),
              behaviorPosition: charts.BehaviorPosition.bottom,
              titleOutsideJustification:
                  charts.OutsideJustification.middleDrawArea)
        ],
        // Configure the width of the pie slices to 30px. The remaining space in
        // the chart will be left as a hole in the center. Adjust the start
        // angle and the arc length of the pie so it resembles a gauge.
        defaultRenderer: new charts.ArcRendererConfig(
            arcWidth: 30, startAngle: 4 / 5 * pi, arcLength: 7 / 5 * pi));
  }

  /// Create one series with sample hard coded data.

}

List<charts.Series<GaugeSegment, String>> _createSampleData() {
  final data = [
    new GaugeSegment('Low', 75, null),
    new GaugeSegment('Acceptable', 100, null),
    new GaugeSegment('High', 50, null),
    new GaugeSegment('Highly Unusual', 5, null),
  ];

  return [
    new charts.Series<GaugeSegment, String>(
      id: 'Segments',
      domainFn: (GaugeSegment segment, _) => segment.segment,
      measureFn: (GaugeSegment segment, _) => segment.size,
      data: data,
    )
  ];
}

/// Sample data type.
