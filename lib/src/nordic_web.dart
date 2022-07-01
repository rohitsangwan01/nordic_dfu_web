// ignore_for_file: prefer_typing_uninitialized_variables

@JS()
library ble;

import 'dart:async';
import 'dart:typed_data';
import "package:js/js.dart";
import 'package:js/js_util.dart';
import 'package:nordic_dfu_web/models/request_builder_filter.dart';

///Call [NordicDfuWeb] to Start the DFU process
class NordicDfuWeb {
  /// Call [startDfu] method after booting device to Dfu
  /// change `dfuDelay` to speed up update process , but less delay might result in crash
  /// don't change  `dfuServiceUuid` or other Uuid's unless you are sure your device requires different data
  /// get progress from  `OnProgress` callback
  /// To Filter only DFu devices , pass `RequestBuilderFilter` like this : `[RequestBuilderFilter(servicesList: [0xfe59])]`
  static Future startDfu({
    required Uint8List uint8list,
    int dfuDelay = 20,
    onProgress,
    onComplete,
    onError,
    onLogs,
    dfuServiceUuid,
    dfuControlUuid,
    dfuPacketUuid,
    dfuButtonUuid,
    List<RequestBuilderFilter>? requestBuilderFilters,
  }) async {
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

      const defaultControlUuid = "8ec90001-f315-4f60-9fb8-838830daea50";
      const defaultPacketUuid = "8ec90002-f315-4f60-9fb8-838830daea50";
      const defaultButtonUuid = "8ec90003-f315-4f60-9fb8-838830daea50";
      const defaultDfuServiceId = 0xfe59;

      ///`Get DFU Object`
      _dfu = await promiseToFuture(getDfu(
        dfuDelay,
        allowInterop((data) {
          if (onLogs != null) onLogs(data); //On Log
        }),
        allowInterop(
          (event) {
            if (onProgress != null) onProgress(event.toString()); //On Progress
          },
        ),
        dfuServiceUuid ?? defaultDfuServiceId,
        dfuControlUuid ?? defaultControlUuid,
        dfuPacketUuid ?? defaultPacketUuid,
        dfuButtonUuid ?? defaultButtonUuid,
      ));

      ///`Get Dfu Device`
      var device = await promiseToFuture(
          selectDevice(_dfu, _package, _getFilters(requestBuilderFilters)));
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

  /// To Convert `RequestBuilderFilter` into Js filter object
  static _getFilters(List<RequestBuilderFilter>? requestBuilderFilters) {
    if (requestBuilderFilters == null || requestBuilderFilters.isEmpty) {
      return null;
    }
    var filters = [];
    for (var filter in requestBuilderFilters) {
      if (filter.servicesList == null && filter.namePrefix == null) {
        continue;
      } else {
        var filterObject =
            getRequestFilter(filter.servicesList, filter.namePrefix);
        filters.add(filterObject);
      }
    }
    if (filters.isEmpty) return null;
    return filters;
  }
}

@JS()
external setFileFromByteArray(
    Uint8List uint8list, String fileName, String contentType, Function onError);

@JS()
external selectDevice(dfu, package, filters);

@JS()
external update(dfu, device, package, onError, onComplete, onLogs);

@JS()
external getDfu(
  dfuDelay,
  Function onLog,
  Function onProgress,
  serviceUuid,
  controlUuid,
  packetUuid,
  buttonUuid,
);

@JS()
external resetDfuEvents(dfu);

@JS()
external getRequestFilter(servicesList, namePrefix);
