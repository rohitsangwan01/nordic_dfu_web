import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

class NordicDfuWebWeb {
  static bool isReady = false;

  static void registerWith(Registrar registrar) async {
    final MethodChannel channel = MethodChannel(
      'nordic_dfu_web',
      const StandardMethodCodec(),
      registrar,
    );
    final pluginInstance = NordicDfuWebWeb();
    channel.setMethodCallHandler(pluginInstance.handleMethodCall);
  }

  Future<dynamic> handleMethodCall(MethodCall call) async {
    switch (call.method) {
      default:
        throw PlatformException(
          code: 'Unimplemented',
          details:
              'nordic_dfu_web for web doesn\'t implement \'${call.method}\'',
        );
    }
  }
}
