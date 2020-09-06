import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Console extends StatefulWidget {
  @override
  _ConsoleState createState() => _ConsoleState();
}

class _ConsoleState extends State<Console> {
  @override
  void initState() {
    super.initState();
    // Change to landscape orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight
    ]);
  }

  @override
  void dispose() {
    super.dispose();
    // Switch back to normal orientation when screen dismisses
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).primaryColor),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'CONSOLE',
          style: Theme.of(context).textTheme.headline5.copyWith(color: Theme.of(context).primaryColor),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: Center(
          child: Text('Console'),
        ),
      ),
    );
  }
}
