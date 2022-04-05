# nordic_dfu_web

This library allows you to do a Device Firmware Update (DFU) of your nrf51 or nrf52 chip from Nordic Semiconductor from Flutter Web

## Getting started

add this package to pubspec.yaml file

```dart
nordic_dfu_web: 0.0.3
```

add this script tag in web/index.html file inside of head tag (check [example](https://github.com/rohitsangwan01/nordic_dfu_web/tree/main/example) folder)

```html
<script
  src="https://cdn.jsdelivr.net/gh/rohitsangwan01/nordic_dfu_web@latest/ble.js"
  defer
></script>
```

## Features

To Start Dfu Pic a file by using any File Picker Plugin and convert File to buffer
pass that buffer to this method and start DFU

Note: startDfu will open dialog to choose for a Device
if , that device is already in Dfu mode , then it will start transfeing firmware
else ,first device will be booted to Dfu and and it will throw an error,
and increase dfuDelay if getting any issue while transfering

```dart
    await NordicDfuWeb.startDfu(
      uint8list: bytes,
      dfuDelay: 25,
      onProgress: (progress) {
        print(progress);
      },
      onComplete: (data) {
       print(data);
      },
      onError: (err) {
       print(err);
      },
      onLogs: (logs) {
        print(logs);
      },
    );
```

## TODO

Host example

## Usage

Added longer examples to [/example](https://github.com/rohitsangwan01/nordic_dfu_web/tree/main/example) folder.

## Resources

- [DFU Introduction](https://infocenter.nordicsemi.com/topic/com.nordic.infocenter.sdk5.v11.0.0/examples_ble_dfu.html?cp=6_0_0_4_3_1 "BLE Bootloader/DFU")
- [Secure DFU Introduction](https://infocenter.nordicsemi.com/topic/com.nordic.infocenter.sdk5.v12.0.0/ble_sdk_app_dfu_bootloader.html?cp=4_0_0_4_3_1 "BLE Secure DFU Bootloader")
- [How to create init packet](https://github.com/NordicSemiconductor/Android-nRF-Connect/tree/master/init%20packet%20handling "Init packet handling")
- [nRF51 Development Kit (DK)](https://www.nordicsemi.com/eng/Products/nRF51-DK "nRF51 DK") (compatible with Arduino Uno Revision 3)
- [nRF52 Development Kit (DK)](https://www.nordicsemi.com/eng/Products/Bluetooth-Smart-Bluetooth-low-energy/nRF52-DK "nRF52 DK") (compatible with Arduino Uno Revision 3)

## Additional information

This is Just The Initial Version feel free to Contribute or Report any Bug!
