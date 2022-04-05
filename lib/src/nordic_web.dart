// ignore_for_file: prefer_typing_uninitialized_variables

@JS()
library ble;

import 'dart:async';
import 'dart:typed_data';
import "package:js/js.dart";
import 'package:js/js_util.dart';

class NordicDfuWeb {
  static Future startDfu(
      {required Uint8List uint8list,
      int dfuDelay = 20,
      onProgress,
      onComplete,
      onError,
      onLogs}) async {
    var _package;
    var _dfu;
    try {
      ///`Get Random File Name`
      String fileName = DateTime.now().toUtc().toString();

      ///`Get Package Object`
      _package = await promiseToFuture(setFileFromByteArray(
        uint8list,
        fileName,
        'application/octet-stream',
        allowInterop((e) {
          throw e.toString();
        }),
      ));

      ///`Get DFU Object`
      _dfu = await promiseToFuture(getDfu(dfuDelay, allowInterop((data) {
        if (onLogs != null) onLogs(data); //On Log
      }), allowInterop((event) {
        if (onProgress != null) onProgress(event.toString()); //On Progress
      })));

      ///`Get Dfu Device`
      var device = await promiseToFuture(selectDevice(_dfu, _package));
      if (device == null) throw 'Device was not in Dfu Mode , Try again';

      ///`Start Update`
      update(_dfu, device, _package, allowInterop((e) => throw e.toString()),
          allowInterop((data) {
        resetDfuEvents(_dfu); //Reset Events
        if (onComplete != null) onComplete(data); //On Complete
      }), allowInterop((logs) {
        if (onLogs != null) onLogs(logs);
      }));
    } catch (e) {
      if (_dfu != null) resetDfuEvents(_dfu); //Reset Events
      if (onError != null) onError(e.toString());
    }
  }
}

@JS()
external setFileFromByteArray(
    Uint8List uint8list, String fileName, String contentType, Function onError);

@JS()
external selectDevice(dfu, package);

@JS()
external update(dfu, device, package, onError, onComplete, onLogs);

@JS()
external getDfu(dfuDelay, Function onLog, Function onProgress);

@JS()
external resetDfuEvents(dfu);
