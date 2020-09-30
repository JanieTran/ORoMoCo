import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class PerBattery{
  @required final String id;
  @required final String type;
  @required final String capacity;
  String percentage = "0.1";

  PerBattery({
    this.id = "",
    this.type = "",
    this.capacity = ""
  });
}

class BatteryWidget extends StatefulWidget {
  @override
  _BatteryWidgetState createState() => _BatteryWidgetState();
}

class _BatteryWidgetState extends State<BatteryWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      
    );
  }
}

class DonutPieChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  DonutPieChart(this.seriesList, {this.animate});

  /// Creates a [PieChart] with sample data and no transition.
  factory DonutPieChart.setData({int used, int left, bool payment}) {
    return new DonutPieChart(
      _createData(used, left, payment),
      // Disable animations for image tests.
      animate: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return new IgnorePointer(
      child: charts.PieChart(
        seriesList,
        animate: animate,
        // Configure the width of the pie slices to 60px. The remaining space in
        // the chart will be left as a hole in the center.
        defaultRenderer: new charts.ArcRendererConfig(arcWidth: 25)
      )
    );
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<ChartItem, String>> _createData(int paid, int debt, bool payment) {
    final data = [
      new ChartItem("used", paid, payment ? charts.MaterialPalette.green.shadeDefault.darker : charts.MaterialPalette.yellow.shadeDefault.darker),
      new ChartItem("left", debt, payment ? charts.MaterialPalette.transparent : charts.MaterialPalette.gray.shadeDefault.darker),
    ];

    return [
      new charts.Series<ChartItem, String>(
        id: 'Segment',
        domainFn: (ChartItem segment, _) => segment.segment,
        measureFn: (ChartItem segment, _) => segment.amount,
        colorFn: (ChartItem segment, _) => segment.color,
        data: data,
      )
    ];
  }
}

class ChartItem {
  final String segment;
  final charts.Color color;
  final int amount;

  ChartItem(this.segment, this.amount, this.color);
}