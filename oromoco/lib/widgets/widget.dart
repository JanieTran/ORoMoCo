import 'package:flutter/material.dart';

Widget appBarMain(BuildContext context){
  return AppBar(
    title: Text('OROMOCO')
  );
}

InputDecoration textFieldInputDecoration(String hintText){
  return InputDecoration(
    hintText: hintText,
    hintStyle: TextStyle(
      color: Colors.black26
    ),
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.black26)
    ),
    enabledBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.black26)
    )
  );
}

TextStyle simnpleTextStyle(){
  return TextStyle(
    color: Colors.black,
    fontSize: 16
  );
}

TextStyle mediumTextStyle(){
  return TextStyle(
    color: Colors.black,
    fontSize: 17
  );
}