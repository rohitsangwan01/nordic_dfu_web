// ignore_for_file: avoid_print, avoid_web_libraries_in_flutter

import 'dart:async';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_bluetooth/flutter_web_bluetooth.dart';
import 'package:nordic_dfu_web/nordic_dfu_web.dart';
import 'dart:js' as js;

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Color background = const Color(0xff072b44);
  Color boxColor = const Color(0xff204157);

  var progress = 0.0;
  late BluetoothDevice device;
  Uint8List? file;
  String dfuService = '0000fe59-0000-1000-8000-00805f9b34fb';
  String dfuCharacteristics = '8ec90003-f315-4f60-9fb8-838830daea50';
  String logs = '';
  bool filePicked = false;
  bool dfuReady = false;
  bool showConnectDevice = true;

  pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result == null) return;
    setState(() {
      file = result.files.first.bytes;
      filePicked = true;
    });
  }

  connectDevice() async {
    if (file == null) {
      showAlertDialog('Error !', 'Please pick a file first',
          onPressed: () => pickFile());
      return;
    }
    try {
      final requestOptions = RequestOptionsBuilder.acceptAllDevices(
          optionalServices: [dfuService]);
      device = await FlutterWebBluetooth.instance.requestDevice(requestOptions);
      await device.connect();
      final services = await device.discoverServices();
      final service = services.firstWhere((e) => e.uuid == dfuService);
      var characteristic = await service.getCharacteristic(dfuCharacteristics);
      late StreamSubscription charStream;

      //start a Stream
      charStream = characteristic.value.listen((event) async {
        print('recieved Event for Dfu mode ${event.buffer.asUint8List()}');
        charStream.cancel();
        characteristic.stopNotifications();

        setState(() {
          dfuReady = true;
          showConnectDevice = false;
        });

        ///here on Successfull Dfu Boot , start Dfu Process
      });
      await characteristic.startNotifications();
      var writeData = Uint8List.fromList([01]);
      await characteristic.writeValueWithResponse(writeData);
    } catch (err) {
      print(err);
    }
  }

  startDfu() async {
    if (file == null) {
      showAlertDialog('Error !', 'Please pick a file first',
          onPressed: () => pickFile());
      return;
    }
    await NordicDfuWeb.startDfu(
      uint8list: file!,
      dfuDelay: 25,
      onProgress: (data) {
        int progressData = double.parse(data).toInt();
        double percentage = (progressData / 100);
        setState(() {
          progress = percentage;
        });
      },
      onComplete: (data) {
        showAlertDialog('Completed !', data);
        setState(() {
          dfuReady = false;
          filePicked = false;
        });
        logs = '';
      },
      onError: (err) {
        showAlertDialog('Error !', err.toString());
        setState(() {
          dfuReady = false;
        });
        logs = err;
      },
      onLogs: (data) {
        setState(() {
          logs = data;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            children: [
              ///`Top Text`
              const Padding(
                padding: EdgeInsets.only(bottom: 18.0, top: 20),
                child: Text(
                  'Flutter Web Secure Dfu',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

              ///`Card`
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: FractionallySizedBox(
                  widthFactor: 0.7,
                  child: Card(
                    elevation: 5,
                    color: boxColor,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          ///`File Pick`
                          Visibility(
                            visible: !dfuReady,
                            child: Column(
                              children: [
                                IconButton(
                                  onPressed: () => pickFile(),
                                  icon:
                                      const Icon(Icons.file_download_outlined),
                                  color: Colors.white,
                                  iconSize: 50,
                                ),
                                const Text(
                                  'Choose a Firmware Package',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          ///`Choose Device`
                          Visibility(
                            visible: filePicked && !dfuReady,
                            child: Padding(
                              padding: const EdgeInsets.all(18.0),
                              child: ElevatedButton(
                                onPressed: () {
                                  connectDevice();
                                },
                                child: const Text(
                                  'Choose Device',
                                  style: TextStyle(fontSize: 20),
                                ),
                              ),
                            ),
                          ),

                          ///`Start Dfu`
                          Visibility(
                            visible: dfuReady,
                            child: Padding(
                              padding: const EdgeInsets.all(18.0),
                              child: ElevatedButton(
                                onPressed: () {
                                  startDfu();
                                },
                                child: const Text(
                                  'Start Dfu',
                                  style: TextStyle(fontSize: 20),
                                ),
                              ),
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18.0, vertical: 20),
                            child: LinearProgressIndicator(
                                value: progress, minHeight: 10),
                          ),

                          Text(logs,
                              style: const TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              ///`GitHub`
              InkWell(
                onTap: () {
                  js.context.callMethod(
                      'open', ['https://pub.dev/packages/nordic_dfu_web']);
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                      width: 100, child: Image.asset('assets/icon.png')),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  showAlertDialog(String title, String body, {onPressed}) {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: Text(title),
              content: Text(body),
              actions: [
                ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      if (onPressed != null) onPressed();
                    },
                    child: const Text('Ok'))
              ],
            ));
  }
}
