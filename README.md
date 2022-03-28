# nordic_dfu_web

This library allows you to do a Device Firmware Update (DFU) of your nrf51 or nrf52 chip from Nordic Semiconductor from Flutter Web

## Getting started

add this package to pubspec.yaml file

```dart
nordic_dfu_web: 0.0.1
```

add this script tag in web/index.html file inside of head tag

```html
<script src="https://cdn.jsdelivr.net/gh/rohitsangwan01/nordic_dfu_web/ble.js" defer></script> 
```

## Features

To Start Dfu Pic a file by using any File Picker Plugin and convert File to buffer
pass that buffer to this method and start DFU

Note: startDfu will open dialog to choose for a Device
if , that device is already in Dfu mode , then it will start transfeing firmware
else ,first device will be booted to Dfu and onDfuModeAvailable callback will be called , here ask user to
scan for device again by using any dialog or someting

```dart
  NordicDfuWeb nordicDfuWeb = NordicDfuWeb();


  startDfu() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      PlatformFile file = result.files.first;
      await nordicDfuWeb.startDfu(
          uint8list: file.bytes!,
          onProgress: (data) {
            print(data);
          },
          onComplete: (data) {
            print(data);
          },
          onError: (err) {
           print(err);
          },
          onLogs: (data) {
            print(data);
          },
          onDfuModeAvailable: (package) {
              ///Show Dialog to The User to choose Dfu Device Again
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
```

TODO : Add Features Description

## Usage

Added longer examples to `/example` folder.

## Resources

- [DFU Introduction](https://infocenter.nordicsemi.com/topic/com.nordic.infocenter.sdk5.v11.0.0/examples_ble_dfu.html?cp=6_0_0_4_3_1 "BLE Bootloader/DFU")
- [Secure DFU Introduction](https://infocenter.nordicsemi.com/topic/com.nordic.infocenter.sdk5.v12.0.0/ble_sdk_app_dfu_bootloader.html?cp=4_0_0_4_3_1 "BLE Secure DFU Bootloader")
- [How to create init packet](https://github.com/NordicSemiconductor/Android-nRF-Connect/tree/master/init%20packet%20handling "Init packet handling")
- [nRF51 Development Kit (DK)](https://www.nordicsemi.com/eng/Products/nRF51-DK "nRF51 DK") (compatible with Arduino Uno Revision 3)
- [nRF52 Development Kit (DK)](https://www.nordicsemi.com/eng/Products/Bluetooth-Smart-Bluetooth-low-energy/nRF52-DK "nRF52 DK") (compatible with Arduino Uno Revision 3)

## Additional information

This is Just The Initial Version feel free to Contribute or Report any Bug!
