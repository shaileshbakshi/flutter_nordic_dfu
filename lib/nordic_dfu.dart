import 'dart:async';

import 'package:flutter/services.dart';

/// Some parameter just use in Android
/// All this parameters can see in <a href="https://github.com/NordicSemiconductor/Android-DFU-Library">
class AndroidSpecialParameter {
  ///Sets whether the progress notification in the status bar should be disabled.
  ///Defaults to false.
  final bool? disableNotification;

  ///
  /// Sets whether the DFU service should be started as a foreground service. By default it's
  /// <i>true</i>. According to
  /// <a href="https://developer.android.com/about/versions/oreo/background.html">
  /// https://developer.android.com/about/versions/oreo/background.html</a>
  /// the background service may be killed by the system on Android Oreo after user quits the
  /// application so it is recommended to keep it as a foreground service (default) at least on
  /// Android Oreo+.
  ///
  final bool? startAsForegroundService;

  /// Sets whether the bond information should be preserver after flashing new application.
  /// This feature requires DFU Bootloader version 0.6 or newer (SDK 8.0.0+).
  /// Please see the {@link DfuBaseService#EXTRA_KEEP_BOND} for more information regarding
  /// requirements. Remember that currently updating the Soft Device will remove the bond
  /// information.
  ///
  /// This flag is ignored when Secure DFU Buttonless Service is used. It will keep or remove the
  /// bond depending on the Buttonless service type.
  ///
  final bool? keepBond;

  /// Sets whether the bond should be created after the DFU is complete.
  /// Please see the {@link DfuBaseService#EXTRA_RESTORE_BOND} for more information regarding
  /// requirements.
  ///
  /// This flag is ignored when Secure DFU Buttonless Service is used. It will keep or will not
  /// restore the bond depending on the Buttonless service type.
  final bool? restoreBond;

  /// Enables or disables the Packet Receipt Notification (PRN) procedure.
  ///
  /// By default the PRNs are disabled on devices with Android Marshmallow or newer and enabled on
  /// older ones.
  final bool? packetReceiptNotificationsEnabled;

  const AndroidSpecialParameter({
    this.disableNotification,
    this.keepBond,
    this.packetReceiptNotificationsEnabled,
    this.restoreBond,
    this.startAsForegroundService,
  });
}

/// Some parameter just use in iOS
/// All this parameters can see in <a href="https://github.com/NordicSemiconductor/IOS-Pods-DFU-Library">
class IosSpecialParameter {
  ///Sets whether to send unique name to device before it is switched into bootloader mode
  ///Defaults to true.
  final bool? alternativeAdvertisingNameEnabled;

  const IosSpecialParameter({
    this.alternativeAdvertisingNameEnabled,
  });
}

class NordicDfu {
  static const String namespace = 'dev.steenbakker.nordic_dfu';

  static const MethodChannel _channel = MethodChannel('$namespace/method');

  /// Start dfu handle
  /// [address] android: mac address iOS: device uuid
  /// [filePath] zip file path
  /// [name] device name
  /// [progressListener] Dfu progress listener, You can use [DefaultDfuProgressListenerAdapter]
  /// [fileInAsset] if [filePath] is a asset path like 'asset/file.zip', must set this value to true, else false
  /// [forceDfu] Legacy DFU only, see in nordic library, default is false
  /// [enableUnsafeExperimentalButtonlessServiceInSecureDfu] see in nordic library, default is false
  /// [androidSpecialParameter] this parameters is only used by android lib
  /// [iosSpecialParameter] this parameters is only used by ios lib
  static Future<String?> startDfu(
    String address,
    String filePath, {
    String? name,
    DfuProgressListenerAdapter? progressListener,
    bool? fileInAsset,
    bool? forceDfu,
    bool? enablePRNs,
    int? numberOfPackets,
    bool? enableUnsafeExperimentalButtonlessServiceInSecureDfu,
    AndroidSpecialParameter androidSpecialParameter =
        const AndroidSpecialParameter(),
    IosSpecialParameter iosSpecialParameter = const IosSpecialParameter(),
  }) async {
    _channel.setMethodCallHandler((MethodCall call) {
      switch (call.method) {
        case 'onDeviceConnected':
          progressListener?.onDeviceConnected(call.arguments);
          break;
        case 'onDeviceConnecting':
          progressListener?.onDeviceConnecting(call.arguments);
          break;
        case 'onDeviceDisconnected':
          progressListener?.onDeviceDisconnected(call.arguments);
          break;
        case 'onDeviceDisconnecting':
          progressListener?.onDeviceDisconnecting(call.arguments);
          break;
        case 'onDfuAborted':
          progressListener?.onDfuAborted(call.arguments);
          break;
        case 'onDfuCompleted':
          progressListener?.onDfuCompleted(call.arguments);
          break;
        case 'onDfuProcessStarted':
          progressListener?.onDfuProcessStarted(call.arguments);
          break;
        case 'onDfuProcessStarting':
          progressListener?.onDfuProcessStarting(call.arguments);
          break;
        case 'onEnablingDfuMode':
          progressListener?.onEnablingDfuMode(call.arguments);
          break;
        case 'onFirmwareValidating':
          progressListener?.onFirmwareValidating(call.arguments);
          break;
        case 'onError':
          progressListener?.onError(
            call.arguments['deviceAddress'],
            call.arguments['error'],
            call.arguments['errorType'],
            call.arguments['message'],
          );
          break;
        case 'onProgressChanged':
          progressListener?.onProgressChanged(
            call.arguments['deviceAddress'],
            call.arguments['percent'],
            call.arguments['speed'],
            call.arguments['avgSpeed'],
            call.arguments['currentPart'],
            call.arguments['partsTotal'],
          );
          break;
        default:
          throw UnimplementedError();
      }
      throw UnimplementedError();
    });

    return await _channel.invokeMethod('startDfu', <String, dynamic>{
      'address': address,
      'filePath': filePath,
      'name': name,
      'fileInAsset': fileInAsset,
      'forceDfu': forceDfu,
      'enablePRNs': enablePRNs,
      'numberOfPackets': numberOfPackets,
      'enableUnsafeExperimentalButtonlessServiceInSecureDfu':
          enableUnsafeExperimentalButtonlessServiceInSecureDfu,
      'disableNotification': androidSpecialParameter.disableNotification,
      'keepBond': androidSpecialParameter.keepBond,
      'restoreBond': androidSpecialParameter.restoreBond,
      'packetReceiptNotificationsEnabled':
          androidSpecialParameter.packetReceiptNotificationsEnabled,
      'startAsForegroundService':
          androidSpecialParameter.startAsForegroundService,
      'alternativeAdvertisingNameEnabled':
          iosSpecialParameter.alternativeAdvertisingNameEnabled,
    });
  }

  static Future<String?> abortDfu() async {
    return await _channel.invokeMethod('abortDfu');
  }
}

abstract class DfuProgressListenerAdapter {
  /// Callback for when device is connected
  /// [deviceAddress] Device connected to
  void onDeviceConnected(String? deviceAddress) {}

  /// Callback for when device is connecting
  /// [deviceAddress] Device connecting to
  void onDeviceConnecting(String? deviceAddress) {}

  /// Callback for when device is disconnected
  /// [deviceAddress] Device disconnected from
  void onDeviceDisconnected(String? deviceAddress) {}

  /// Callback for when device is disconnecting
  /// [deviceAddress] Device disconnecting from
  void onDeviceDisconnecting(String? deviceAddress) {}

  /// Callback for dfu is Aborted
  /// [deviceAddress] Device aborted from
  void onDfuAborted(String? deviceAddress) {}

  /// Callback for when dfu is completed
  /// [deviceAddress] Device
  void onDfuCompleted(String? deviceAddress) {}

  /// Callback for when dfu has been started
  /// [deviceAddress] Device with dfu
  void onDfuProcessStarted(String? deviceAddress) {}

  /// Callback for when dfu is starting
  /// [deviceAddress] Device with dfu
  void onDfuProcessStarting(String? deviceAddress) {}

  /// Callback for when dfu mode is being enabled
  /// [deviceAddress] Device with dfu
  void onEnablingDfuMode(String? deviceAddress) {}

  /// Callback for when dfu is being verified
  /// [deviceAddress] Device from which dfu is being verified
  void onFirmwareValidating(String? deviceAddress) {}

  /// Callback for when dfu has error
  /// [deviceAddress] Device with error
  void onError(
    String? deviceAddress,
    int? error,
    int? errorType,
    String? message,
  ) {}

  /// Callback for when the dfu progress has changed
  /// [deviceAddress] Device with dfu
  /// [percent] Percentage dfu completed
  /// [speed] Speed of the dfu proces
  /// [avgSpeed] Average speed of the dfu process
  /// [currentPart] Current part being uploaded
  /// [partsTotal] All parts that need to be uploaded
  void onProgressChanged(
    String? deviceAddress,
    int? percent,
    double? speed,
    double? avgSpeed,
    int? currentPart,
    int? partsTotal,
  ) {}
}

class DefaultDfuProgressListenerAdapter extends DfuProgressListenerAdapter {
  void Function(String? deviceAddress)? onDeviceConnectedHandle;

  void Function(String? deviceAddress)? onDeviceConnectingHandle;

  void Function(String? deviceAddress)? onDeviceDisconnectedHandle;

  void Function(String? deviceAddress)? onDeviceDisconnectingHandle;

  void Function(String? deviceAddress)? onDfuAbortedHandle;

  void Function(String? deviceAddress)? onDfuCompletedHandle;

  void Function(String? deviceAddress)? onDfuProcessStartedHandle;

  void Function(String? deviceAddress)? onDfuProcessStartingHandle;

  void Function(String? deviceAddress)? onEnablingDfuModeHandle;

  void Function(String? deviceAddress)? onFirmwareValidatingHandle;

  void Function(
          String? deviceAddress, int? error, int? errorType, String? message)?
      onErrorHandle;

  void Function(
      String? deviceAddress,
      int? percent,
      double? speed,
      double? avgSpeed,
      int? currentPart,
      int? partsTotal)? onProgressChangedHandle;

  DefaultDfuProgressListenerAdapter({
    this.onDeviceConnectedHandle,
    this.onDeviceConnectingHandle,
    this.onDeviceDisconnectedHandle,
    this.onDeviceDisconnectingHandle,
    this.onDfuAbortedHandle,
    this.onDfuCompletedHandle,
    this.onDfuProcessStartedHandle,
    this.onDfuProcessStartingHandle,
    this.onEnablingDfuModeHandle,
    this.onFirmwareValidatingHandle,
    this.onErrorHandle,
    this.onProgressChangedHandle,
  });

  @override
  void onDeviceConnected(String? deviceAddress) {
    super.onDeviceConnected(deviceAddress);
    if (onDeviceConnectedHandle != null) {
      onDeviceConnectedHandle!(deviceAddress);
    }
  }

  @override
  void onDeviceConnecting(String? deviceAddress) {
    super.onDeviceConnecting(deviceAddress);
    if (onDeviceConnectingHandle != null) {
      onDeviceConnectingHandle!(deviceAddress);
    }
  }

  @override
  void onDeviceDisconnected(String? deviceAddress) {
    super.onDeviceDisconnected(deviceAddress);
    if (onDeviceDisconnectedHandle != null) {
      onDeviceDisconnectedHandle!(deviceAddress);
    }
  }

  @override
  void onDeviceDisconnecting(String? deviceAddress) {
    super.onDeviceDisconnecting(deviceAddress);
    if (onDeviceDisconnectingHandle != null) {
      onDeviceDisconnectingHandle!(deviceAddress);
    }
  }

  @override
  void onDfuAborted(String? deviceAddress) {
    super.onDfuAborted(deviceAddress);
    if (onDfuAbortedHandle != null) {
      onDfuAbortedHandle!(deviceAddress);
    }
  }

  @override
  void onDfuCompleted(String? deviceAddress) {
    super.onDfuCompleted(deviceAddress);
    if (onDfuCompletedHandle != null) {
      onDfuCompletedHandle!(deviceAddress);
    }
  }

  @override
  void onDfuProcessStarted(String? deviceAddress) {
    super.onDfuProcessStarted(deviceAddress);
    if (onDfuProcessStartedHandle != null) {
      onDfuProcessStartedHandle!(deviceAddress);
    }
  }

  @override
  void onDfuProcessStarting(String? deviceAddress) {
    super.onDfuProcessStarting(deviceAddress);
    if (onDfuProcessStartingHandle != null) {
      onDfuProcessStartingHandle!(deviceAddress);
    }
  }

  @override
  void onEnablingDfuMode(String? deviceAddress) {
    super.onEnablingDfuMode(deviceAddress);
    if (onEnablingDfuModeHandle != null) {
      onEnablingDfuModeHandle!(deviceAddress);
    }
  }

  @override
  void onFirmwareValidating(String? deviceAddress) {
    super.onFirmwareValidating(deviceAddress);
    if (onFirmwareValidatingHandle != null) {
      onFirmwareValidatingHandle!(deviceAddress);
    }
  }

  @override
  void onError(
    String? deviceAddress,
    int? error,
    int? errorType,
    String? message,
  ) {
    super.onError(
      deviceAddress,
      error,
      errorType,
      message,
    );
    if (onErrorHandle != null) {
      onErrorHandle!(
        deviceAddress,
        error,
        errorType,
        message,
      );
    }
  }

  @override
  void onProgressChanged(
    String? deviceAddress,
    int? percent,
    double? speed,
    double? avgSpeed,
    int? currentPart,
    int? partsTotal,
  ) {
    super.onProgressChanged(
      deviceAddress,
      percent,
      speed,
      avgSpeed,
      currentPart,
      partsTotal,
    );
    if (onProgressChangedHandle != null) {
      onProgressChangedHandle!(
        deviceAddress,
        percent,
        speed,
        avgSpeed,
        currentPart,
        partsTotal,
      );
    }
  }
}
