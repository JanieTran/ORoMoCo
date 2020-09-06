import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.transparent,
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
      body: Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: _buildLeftPanel(theme),
          ),
          Expanded(
            flex: 2,
            child: Container(
              color: theme.primaryColor,
            ),
          ),
          Expanded(
            flex: 1,
            child: _buildRightPanel(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildLeftPanel(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        SizedBox(height: 20),
        GestureDetector(
          onTap: () {
            Fluttertoast.showToast(msg: 'Up');
          },
          child: Icon(Icons.keyboard_arrow_up, color: theme.primaryColor, size: 50),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                Fluttertoast.showToast(msg: 'Left');
              },
              child: Icon(Icons.keyboard_arrow_left, color: theme.primaryColor, size: 50),
            ),
            SizedBox(width: 40),
            GestureDetector(
              onTap: () {
                Fluttertoast.showToast(msg: 'Right');
              },
              child: Icon(Icons.keyboard_arrow_right, color: theme.primaryColor, size: 50),
            ),
          ],
        ),
        GestureDetector(
          onTap: () {
            Fluttertoast.showToast(msg: 'Down');
          },
          child: Icon(Icons.keyboard_arrow_down, color: theme.primaryColor, size: 50),
        ),
      ],
    );
  }

  Widget _buildRightPanel(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        SizedBox(height: 20),
        _buildRoundButton(theme, 'X'),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _buildRoundButton(theme, 'Y'),
            SizedBox(width: 40),
            _buildRoundButton(theme, 'A')
          ],
        ),
        _buildRoundButton(theme, 'B')
      ],
    );
  }

  Widget _buildRoundButton(ThemeData theme, String buttonName) {
    return ButtonTheme(
      minWidth: 50,
      height: 50,
      buttonColor: theme.accentColor,
      child: RaisedButton(
        elevation: 0,
        onPressed: () {
          Fluttertoast.showToast(msg: buttonName);
        },
        child: Text(
          buttonName,
          style: theme.textTheme.headline5
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25)
        ),
      ),
    );
  }
}
