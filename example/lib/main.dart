import 'package:flutter/material.dart';
import 'package:nordic_dfu_web_example/home.dart';

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Nordic Dfu",
      home: Home(),
    ),
  );
}
