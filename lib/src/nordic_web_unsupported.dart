import 'dart:async';
import 'dart:typed_data';
import '../models/request_builder_filter.dart';

class NordicDfuWeb {

  /// This will be called in Non Web environment
  static Future startDfu({
    required Uint8List uint8list,
    int dfuDelay = 15,
    onProgress,
    onComplete,
    onError,
    onLogs,
    serviceUuid,
    controlUuid,
    packetUuid,
    buttonUuid,
    List<RequestBuilderFilter>? requestBuilderFilters,
  }) async {}
}
