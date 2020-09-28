import 'package:flutter/material.dart';
import 'package:oromoco/helper/authenticate.dart';
import 'package:oromoco/helper/helperFunctions.dart';
import 'package:oromoco/utils/theme/theme.dart';
import 'package:oromoco/views/loadingScreen.dart';

void main() {
  runApp(OROMOCO());
}

class OROMOCO extends StatefulWidget {
  @override
  _OROMOCOState createState() => _OROMOCOState();
}

class _OROMOCOState extends State<OROMOCO> {
  bool userIsLoggedIn;

  @override
  void initState() {
    getLoggedInState();
    super.initState();
  }

  getLoggedInState() async {
    await HelperFunctions.getUserLoggedInSharedPreferences().then((value) async {
      setState(() {
        userIsLoggedIn = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OROMOCO',
      theme: ORoMoCoTheme.theme,
      home: userIsLoggedIn != null ? userIsLoggedIn ? LoadingScreen() : Authenticate() : Authenticate(),
      debugShowCheckedModeBanner: false
    );
  }
}

class BlankScreen extends StatefulWidget {
  @override
  _BlankScreenState createState() => _BlankScreenState();
}

class _BlankScreenState extends State<BlankScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      
    );
  }
}