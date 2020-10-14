import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class PerBattery{
  @required final String type;
  @required final String capacity;
  String percentage = "0.1";

  PerBattery({
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
  factory DonutPieChart.setData({int used, int left, bool doubleLayer}) {
    return new DonutPieChart(
      _createData(used, left),
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
  static List<charts.Series<ChartItem, String>> _createData(int used, int left) {
    final data = [
      new ChartItem("used", used, charts.MaterialPalette.gray.shadeDefault.darker),
      new ChartItem("left", left, charts.MaterialPalette.yellow.shadeDefault.darker),
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

class StackedAreaLineChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  StackedAreaLineChart(this.seriesList, {this.animate});

  /// Creates a [LineChart] with sample data and no transition.
  factory StackedAreaLineChart.idealDataPlot() {
    return new StackedAreaLineChart(
      _idealData(),
      // Disable animations for image tests.
      animate: false,
    );
  }

  factory StackedAreaLineChart.sampleActualDataPlot() {
    return new StackedAreaLineChart(
      _sampleActualData(),
      // Disable animations for image tests.
      animate: false,
    );
  }


  @override
  Widget build(BuildContext context) {
    return new charts.LineChart(seriesList,
        defaultRenderer:
            new charts.LineRendererConfig(includeArea: true, stacked: true),
        animate: animate);
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<BatteryLevel, int>> _idealData() {
    final idealLifeData = [
      new BatteryLevel(0, 100),
      new BatteryLevel(10, 99),
      new BatteryLevel(20, 98),
      new BatteryLevel(30, 97),
      new BatteryLevel(40, 96),
      new BatteryLevel(50, 94),
      new BatteryLevel(60, 92),
      new BatteryLevel(70, 90),
      new BatteryLevel(80, 87),
      new BatteryLevel(90, 84),
      new BatteryLevel(100, 80),
      new BatteryLevel(110, 76),
      new BatteryLevel(120, 72),
      new BatteryLevel(130, 67),
      new BatteryLevel(140, 62),
      new BatteryLevel(150, 56),
      new BatteryLevel(160, 50),
      new BatteryLevel(170, 43),
      new BatteryLevel(180, 36),
      new BatteryLevel(190, 29),
      new BatteryLevel(200, 21),
      new BatteryLevel(210, 13),
      new BatteryLevel(220, 8),
      new BatteryLevel(230, 2),
      new BatteryLevel(240, 0),
      new BatteryLevel(250, 0),
    ];

    return [
      new charts.Series<BatteryLevel, int>(
        id: 'data',
        colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
        domainFn: (BatteryLevel battery, _) => battery.tenthMinute,
        measureFn: (BatteryLevel battery, _) => battery.percentage,
        data: idealLifeData,
      )
    ];
  }

  static List<charts.Series<BatteryLevel, int>> _sampleActualData() {
    final actualLifeData = [
      new BatteryLevel(0, 100),
      new BatteryLevel(10, 98),
      new BatteryLevel(20, 97),
      new BatteryLevel(30, 96),
      new BatteryLevel(40, 95),
      new BatteryLevel(50, 93),
      new BatteryLevel(60, 90),
      new BatteryLevel(70, 88),
      new BatteryLevel(80, 85),
      new BatteryLevel(90, 82),
      new BatteryLevel(100, 78),
      new BatteryLevel(110, 73),
      new BatteryLevel(120, 68),
      new BatteryLevel(130, 63),
      new BatteryLevel(140, 58),
      new BatteryLevel(150, 52),
      new BatteryLevel(160, 45),
      new BatteryLevel(170, 38),
      new BatteryLevel(180, 31),
      new BatteryLevel(190, 24),
      new BatteryLevel(200, 15),
      new BatteryLevel(210, 6),
      new BatteryLevel(220, 2),
      new BatteryLevel(230, 0),
      new BatteryLevel(240, 0),
      new BatteryLevel(250, 0),
    ];

    return [
      new charts.Series<BatteryLevel, int>(
        id: 'data',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (BatteryLevel battery, _) => battery.tenthMinute,
        measureFn: (BatteryLevel battery, _) => battery.percentage,
        data: actualLifeData,
      )
    ];
  }
}

/// Sample linear data type.
class BatteryLevel {
  final int tenthMinute;
  final int percentage;

  BatteryLevel(this.tenthMinute, this.percentage);
}
