// ignore_for_file: avoid_print, unnecessary_overrides

import 'dart:async';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_bluetooth/flutter_web_bluetooth.dart';
import 'package:get/get.dart';
import 'package:nordic_dfu_web/nordic_dfu_web.dart';

class HomeController extends GetxController {
  NordicDfuWeb nordicDfuWeb = NordicDfuWeb();
  var progress = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
  }

  scanDevice() async {
    String? getFile = await nordicDfuWeb.scanDevice();
    print(getFile);
  }

  connectDevice() async {
    // Define the services you want to communicate with here!
    final requestOptions =
        RequestOptionsBuilder.acceptAllDevices(optionalServices: [
      BluetoothDefaultServiceUUIDS.DEVICE_INFORMATION.uuid,
      '0000fe59-0000-1000-8000-00805f9b34fb'
    ]);
    try {
      final device =
          await FlutterWebBluetooth.instance.requestDevice(requestOptions);
      await device.connect();
      final services = await device.discoverServices();
      final service = services.firstWhere(
          (service) => service.uuid == '0000fe59-0000-1000-8000-00805f9b34fb');
      var chars = await service.getCharacteristics();
      print(chars.map((e) => e.uuid).toList());
      final characteristic = chars.firstWhere(
          (element) => element.uuid == '8ec90003-f315-4f60-9fb8-838830daea50');
      late StreamSubscription charStream;

      charStream = characteristic.value.listen((event) async {
        print('recieved Event $event');
        charStream.cancel();
        print('Stopping Notifcaiton');
        characteristic.stopNotifications();
      });
      
      print('starting Notification');
      await characteristic.startNotifications();
      print('Writing Data');
      var writeData = Uint8List.fromList([01]);
      await characteristic.writeValueWithResponse(writeData);
    } catch (err) {
      print(err);
    }
  }

  startDfu() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      PlatformFile file = result.files.first;
      await nordicDfuWeb.startDfu(
          uint8list: file.bytes!,
          onProgress: (data) {
            //  Get.log(data);
            int progressData = double.parse(data).toInt();
            double percentage = (progressData / 100);
            progress.value = percentage;
          },
          onComplete: (data) {
            Get.log('Dfu Completed');
          },
          onError: (err) {
            Get.log(err);
          },
          onLogs: (data) {
            Get.log(data);
          },
          onDfuModeAvailable: (package) {
            Get.defaultDialog(
                title: '',
                content: const Text('Device Booted to DFU Mode , Select Again'),
                onConfirm: () {
                  Get.back();
                  nordicDfuWeb.scanDevice(pkg: package);
                });
          });
    }
  }

  @override
  void onClose() {}
}
