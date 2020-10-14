import 'package:flutter/cupertino.dart';

class DefaultCommand{
  final String function;
  final String command;
  DefaultCommand(
    {
      @required this.function,
      @required this.command
    }
  );
}

class BluetoothDefaultCommand{
  static List<DefaultCommand> defaultCommandList = [
    new DefaultCommand(function: "buffer", command: "default command - set mode - 1"),
    new DefaultCommand(function: "battery", command: "default command - set mode - 2"),
    new DefaultCommand(function: "connection", command: "default command - set mode - 3"),
    new DefaultCommand(function: "download", command: "default command - set mode - 4"),
    new DefaultCommand(function: "angle", command: "default command - set mode - 5"),
    new DefaultCommand(function: "LED", command: "default command - set mode - 6"),
    new DefaultCommand(function: "all", command: "default command - set mode - 7"),
    new DefaultCommand(function: "Get Mode", command: "default command - set mode - 1000"),
    new DefaultCommand(function: "Cancel", command: "default command - set mode - 1001"),
  ];
}

class PerPackage{
  int battery;
  int angle;
  int upperLimit;
  int lowerLimit;
  int motorSpeed;
  int buttonDirection;
  int red;
  int green;
  int blue;
  int connection;
  bool initialized = false;

  int setValue(List<String> data){
    if(data.length != 10){
      return 0;
    }
    try{
      battery = int.parse(data[0]);
      angle = int.parse(data[1]);
      upperLimit = int.parse(data[2]);
      lowerLimit = int.parse(data[3]);
      motorSpeed = int.parse(data[4]);
      buttonDirection = int.parse(data[5]);
      red = int.parse(data[6]);
      green = int.parse(data[7]);
      blue = int.parse(data[8]);
      connection = int.parse(data[9]);
    }catch(e){
      return 0;
    }
    initialized = true;
    return 1;
  }

  bool isInitialized(){
    return initialized;
  }

  int getAngle(){
    return angle;
  }
}