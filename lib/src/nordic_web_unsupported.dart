import 'dart:async';
import 'dart:typed_data';

class NordicDfuWeb {
  bool isInitialised = false;

  ensureInit() {
    if (isInitialised) return;
    isInitialised = true;
  }

  Future<String?> scanDevice({pkg, dfuDelay}) async {}

  Future startDfu(
      {required Uint8List uint8list,
      int dfuDelay = 15,
      onDfuModeAvailable,
      onProgress,
      onComplete,
      onError,
      onLogs}) async {}
}
