import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nordic DFU Web'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                controller.startDfu();
              },
              child: const Text(
                'Start Dfu',
                style: TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Obx(() => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0),
                  child: LinearProgressIndicator(
                      value: controller.progress.value, minHeight: 10),
                )),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: () {
                controller.connectDevice();
              },
              child: const Text(
                'Boot To Dfu',
                style: TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: () {
                controller.scanDevice();
              },
              child: const Text(
                'Scan Devices',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
