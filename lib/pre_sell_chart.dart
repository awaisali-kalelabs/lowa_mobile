import 'dart:math';

/// Gauge chart example, where the data does not cover a full revolution in the
/// chart.
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:order_booker/gauge_segment.dart';

class PreSellChart extends StatefulWidget {
  var seriesList;
  final bool animate;
  PreSellChart(this.seriesList, {this.animate});
  @override
  _PreSellChart createState() => _PreSellChart(seriesList);
}

class _PreSellChart extends State<PreSellChart>  {
   var seriesList;
  final bool animate;

  _PreSellChart(this.seriesList, {this.animate});

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    print(seriesList.toString());
    return new charts.PieChart([new charts.Series<GaugeSegment, String>(
      id: 'Segments',
      domainFn: (GaugeSegment segment, _) => segment.segment,
      measureFn: (GaugeSegment segment, _) => segment.size,
      data: seriesList,
    )],
        animate: true,

        behaviors: [new charts.ChartTitle('Deliveries (%)',
            //subTitle: 'Sales (%)',
            titleStyleSpec: new charts.TextStyleSpec(fontSize: 16),
            behaviorPosition: charts.BehaviorPosition.bottom,
            titleOutsideJustification:
            charts.OutsideJustification.middleDrawArea)],
        // Configure the width of the pie slices to 30px. The remaining space in
        // the chart will be left as a hole in the center. Adjust the start
        // angle and the arc length of the pie so it resembles a gauge.
        defaultRenderer: new charts.ArcRendererConfig(
            arcWidth: 30, startAngle: 4 / 5 * pi, arcLength: 7 / 5 * pi));
  }

  /// Create one series with sample hard coded data.

}
/// Sample data type.