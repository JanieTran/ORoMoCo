import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class HorizontalBarLabelCustomChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  HorizontalBarLabelCustomChart(this.seriesList, {this.animate});

  /// Creates a [BarChart] with sample data and no transition.
  static HorizontalBarLabelCustomChart setData({int rfPercentage, int bluetoothPercentage}) {
    return new HorizontalBarLabelCustomChart(
      _setData(rfPercentage: rfPercentage, bluetoothPercentage: bluetoothPercentage),
      // Disable animations for image tests.
      animate: false
    );
  }


  // The [BarLabelDecorator] has settings to set the text style for all labels
  // for inside the bar and outside the bar. To be able to control each datum's
  // style, set the style accessor functions on the series.
  @override
  Widget build(BuildContext context) {
    return new charts.BarChart(
      seriesList,
      animate: animate,
      vertical: false,
      barRendererDecorator: new charts.BarLabelDecorator<String>(),
      // Hide domain axis.
      domainAxis:
          new charts.OrdinalAxisSpec(renderSpec: new charts.NoneRenderSpec()),
    );
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<PerSignalChart, String>> _setData({int rfPercentage, int bluetoothPercentage}) {
    final rfData = [
      new PerSignalChart('RF', rfPercentage),
    ];

    final bluetoothData = [
      new PerSignalChart('Bluetooth', bluetoothPercentage),
    ];

    return [
      new charts.Series<PerSignalChart, String>(
        id: 'RF',
        domainFn: (PerSignalChart signal, _) => signal.connectionType,
        measureFn: (PerSignalChart signal, _) => signal.percentage,
        data: rfData,
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        // Set a label accessor to control the text of the bar label.
        labelAccessorFn: (PerSignalChart signal, _) =>
            '${signal.connectionType}: ${signal.percentage.toString()}%',
        insideLabelStyleAccessorFn: (PerSignalChart signal, _) {
          final color = charts.MaterialPalette.white;
          return new charts.TextStyleSpec(color: color);
        },
        outsideLabelStyleAccessorFn: (PerSignalChart signal, _) {
          final color = charts.MaterialPalette.gray.shadeDefault.darker;
          return new charts.TextStyleSpec(color: color);
        },
      ),

      new charts.Series<PerSignalChart, String>(
        id: 'Bluetooth',
        domainFn: (PerSignalChart signal, _) => signal.connectionType,
        measureFn: (PerSignalChart signal, _) => signal.percentage,
        data: bluetoothData,
        colorFn: (_, __) => charts.MaterialPalette.teal.shadeDefault.darker,
        // Set a label accessor to control the text of the bar label.
        labelAccessorFn: (PerSignalChart signal, _) =>
            '${signal.connectionType}: ${signal.percentage.toString()}%',
        insideLabelStyleAccessorFn: (PerSignalChart signal, _) {
          final color = charts.MaterialPalette.white;
          return new charts.TextStyleSpec(color: color);
        },
        outsideLabelStyleAccessorFn: (PerSignalChart signal, _) {
          final color = charts.MaterialPalette.gray.shadeDefault.darker;
          return new charts.TextStyleSpec(color: color);
        },
      ),
    ];
  }
}

/// Sample ordinal data type.
class PerSignalChart {
  final String connectionType;
  final int percentage;

  PerSignalChart(this.connectionType, this.percentage);
}

//------------------------------------------------------
class NumericComboLinePointChart extends StatefulWidget {
  List<charts.Series> seriesList;
  final bool animate;

  NumericComboLinePointChart({this.seriesList, this.animate = false, Key key}): super(key: key);

  @override
  NumericComboLinePointChartState createState() => NumericComboLinePointChartState();
}

class NumericComboLinePointChartState extends State<NumericComboLinePointChart> {
  List<PerSignalHistory> rfSignalData = [];
  List<PerSignalHistory> bluetoothSignalData = [];

  int indexCounter = 0;

  List<charts.Series<PerSignalHistory, int>> _initData() {
    return [
      new charts.Series<PerSignalHistory, int>(
        id: 'RF',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (PerSignalHistory sales, _) => sales.index,
        measureFn: (PerSignalHistory sales, _) => sales.percentage,
        data: rfSignalData,
      ),
      new charts.Series<PerSignalHistory, int>(
        id: 'Bluetooth',
        colorFn: (_, __) => charts.MaterialPalette.teal.shadeDefault.darker,
        domainFn: (PerSignalHistory sales, _) => sales.index,
        measureFn: (PerSignalHistory sales, _) => sales.percentage,
        data: bluetoothSignalData,
      )
    ];
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.seriesList = _initData();
  }

  @override
  Widget build(BuildContext context) {
    return new charts.NumericComboChart(widget.seriesList,
      animate: widget.animate,
      // Configure the default renderer as a line renderer. This will be used
      // for any series that does not define a rendererIdKey.
      defaultRenderer: new charts.LineRendererConfig(),
      // Custom renderer configuration for the point series.
      customSeriesRenderers: [
        new charts.PointRendererConfig(
            // ID used to link series to this renderer.
            customRendererId: 'customPoint')
      ]
    );
  }

  void setData({int rfPercentage, int bluetoothPercentage}){
    indexCounter = indexCounter + 1;

    rfSignalData.add(new PerSignalHistory(
      indexCounter,
      rfPercentage
    ));

    bluetoothSignalData.add(new PerSignalHistory(
      indexCounter, 
      bluetoothPercentage
    ));

    while(rfSignalData.length > 20){
      rfSignalData.removeAt(0);
    }

    while(bluetoothSignalData.length > 20){
      bluetoothSignalData.removeAt(0);
    }

    List<charts.Series<PerSignalHistory, int>> newSeries = [
      new charts.Series<PerSignalHistory, int>(
        id: 'RF',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (PerSignalHistory signalData, _) => signalData.index - rfSignalData[0].index,
        measureFn: (PerSignalHistory signalData, _) => signalData.percentage,
        data: rfSignalData,
      ),
      new charts.Series<PerSignalHistory, int>(
        id: 'Bluetooth',
        colorFn: (_, __) => charts.MaterialPalette.teal.shadeDefault.darker,
        domainFn: (PerSignalHistory signalData, _) => signalData.index - bluetoothSignalData[0].index,
        measureFn: (PerSignalHistory signalData, _) => signalData.percentage,
        data: bluetoothSignalData,
      )
      //..setAttribute(charts.rendererIdKey, 'customPoint'),
    ];

    setState(() {
      widget.seriesList = newSeries;
    });
  }
}

/// Sample linear data type.
class PerSignalHistory {
  final int index;
  final int percentage;

  PerSignalHistory(this.index, this.percentage);
}