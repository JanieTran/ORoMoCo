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
    new DefaultCommand(function: "angle", command: "default command - set mode - 5")
  ];
}