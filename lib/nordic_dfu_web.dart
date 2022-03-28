// ignore_for_file: avoid_print, body_might_complete_normally_nullable, unused_field, unused_element, non_constant_identifier_names, prefer_typing_uninitialized_variables
@JS()
library ble;

import 'dart:async';
import 'dart:html';
import 'dart:typed_data';
import "package:js/js.dart";
import 'package:js/js_util.dart';
import 'dart:js_util';

class NordicDfuWeb {
  bool isInitialised = false;

  late StreamController _eventStream;
  late StreamController _dfuProgresStream;
  late StreamController _dfuComplete;
  late StreamController _dfuError;

  StreamSubscription? eventStream;
  StreamSubscription? progressStream;
  StreamSubscription? dfuCompleteStream;
  StreamSubscription? dfuErrorStream;

  ensureInit() {
    if (isInitialised) return;

    _eventStream = StreamController.broadcast();
    _dfuProgresStream = StreamController.broadcast();
    _dfuComplete = StreamController.broadcast();
    _dfuError = StreamController.broadcast();

    ///EventListener for Everything
    window.addEventListener("message", (event) {
      MessageEvent ev = event as MessageEvent;
      String type = ev.data['type'];
      var data = ev.data['data'].toString();
      switch (type) {
        case Events.logs:
          //print(ev.data);
          _eventStream.add(data);
          break;
        case Events.dfuProgress:
          _dfuProgresStream.add(data);
          break;
        case Events.dfuComplete:
          _dfuComplete.add(data);
          break;
        case Events.dfuError:
          _dfuError.add(data);
          break;
      }
    });

    print('NordicWeb Initialised');
    isInitialised = true;
  }

  var _package;
  var _dfu;

  Future<String?> scanDevice({pkg, dfuDelay}) async {
    await ensureInit();
    await selectDevice(_dfu, pkg ?? _package, dfuDelay ?? 15);
  }

  Future startDfu(
      {required Uint8List uint8list,
      int dfuDelay = 15,
      onDfuModeAvailable,
      onProgress,
      onComplete,
      onError,
      onLogs}) async {
    try {
      await ensureInit();
      //cancel All Streams
      eventStream?.cancel();
      progressStream?.cancel();
      dfuCompleteStream?.cancel();
      dfuErrorStream?.cancel();

      String fileName = DateTime.now().toUtc().toString();
      _package = await promiseToFuture(setFileFromByteArray(
          uint8list, fileName, 'application/octet-stream'));

      _dfu ??= await promiseToFuture(getDfu());

      var data = await promiseToFuture(selectDevice(_dfu, _package, dfuDelay));

      if (!data) {
        ///means Device was not in Dfu , But now it is , so ask user to click Again
        if (onDfuModeAvailable != null) onDfuModeAvailable(_package);
      }

      ///run a Progress Stream
      if (onProgress != null) {
        progressStream?.cancel();
        progressStream = _dfuProgresStream.stream.listen((data) {
          if (onProgress != null) onProgress(data);
        });
      }
      //Catch Dfu Complete
      if (onComplete != null) {
        dfuCompleteStream?.cancel();
        dfuCompleteStream = _dfuComplete.stream.listen((data) {
          onComplete(data);
          dfuCompleteStream?.cancel();
        });
      }

      //Catch Dfu Error
      if (onError != null) {
        dfuErrorStream?.cancel();
        dfuErrorStream = _dfuError.stream.listen((data) {
          onError(data);
          onError?.cancel();
        });
      }

      //Catch Logs
      if (onLogs != null) {
        eventStream?.cancel();
        eventStream = _eventStream.stream.listen((data) {
          onLogs(data);
        });
      }
    } catch (e) {
       //cancel All Streams
      eventStream?.cancel();
      progressStream?.cancel();
      dfuCompleteStream?.cancel();
      dfuErrorStream?.cancel();
      if (onError != null) onError(e.toString());
    }
  }
}

class Events {
  static const String logs = 'logs';
  static const String dfuError = 'dfuError';
  static const String dfuProgress = 'dfuProgress';
  static const String dfuComplete = 'dfuComplete';
}

@JS()
external setFileFromByteArray(
    Uint8List uint8list, String fileName, String contentType);

@JS()
external selectDevice(dfu, package, dfuDelay);

@JS()
external update(dfu, device, package);

@JS()
external getDfu();
