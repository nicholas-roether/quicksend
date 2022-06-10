import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

class PlatformInfo {
  final String deviceDescriptor;
  final int platformCode;

  const PlatformInfo({
    required this.deviceDescriptor,
    required this.platformCode,
  });
}

String _uuid() {
  final random = Random();
  final bytes = List.generate(12, (_) => random.nextInt(8));
  return base64Encode(bytes);
}

String _prettyBrowserName(BrowserName browserName) {
  switch (browserName) {
    case BrowserName.chrome:
      return "Google Chrome";
    case BrowserName.edge:
      return "Microsoft Edge";
    case BrowserName.firefox:
      return "Mozilla Firefox";
    case BrowserName.msie:
      return "Microsoft IE";
    case BrowserName.opera:
      return "Opera";
    case BrowserName.safari:
      return "Safari";
    case BrowserName.samsungInternet:
      return "Samsung Internet";
    case BrowserName.unknown:
      return "Web Browser";
  }
}

String _browserDescriptor(WebBrowserInfo browserInfo) {
  String desc = _prettyBrowserName(browserInfo.browserName);
  if (browserInfo.platform != null) desc += "(${browserInfo.platform})";
  return desc;
}

Future<PlatformInfo> getPlatformInfo() async {
  final deviceInfoPlugin = DeviceInfoPlugin();
  if (kIsWeb) {
    final browserInfo = await deviceInfoPlugin.webBrowserInfo;
    return PlatformInfo(
      deviceDescriptor: _browserDescriptor(browserInfo),
      platformCode: 4,
    );
  }
  if (Platform.isAndroid) {
    final androidInfo = await deviceInfoPlugin.androidInfo;
    return PlatformInfo(
      deviceDescriptor: androidInfo.product ?? "Android Device",
      platformCode: 1,
    );
  }
  if (Platform.isIOS) {
    final iosInfo = await deviceInfoPlugin.iosInfo;
    return PlatformInfo(
      deviceDescriptor: iosInfo.name ?? "iOS Device",
      platformCode: 1,
    );
  }
  if (Platform.isLinux) {
    final linuxInfo = await deviceInfoPlugin.linuxInfo;
    return PlatformInfo(
      deviceDescriptor: linuxInfo.name,
      platformCode: 2,
    );
  }
  if (Platform.isMacOS) {
    final macOsInfo = await deviceInfoPlugin.macOsInfo;
    return PlatformInfo(
      deviceDescriptor: macOsInfo.computerName,
      platformCode: 2,
    );
  }
  if (Platform.isWindows) {
    final windowsInfo = await deviceInfoPlugin.windowsInfo;
    return PlatformInfo(
      deviceDescriptor: windowsInfo.computerName,
      platformCode: 2,
    );
  }
  return const PlatformInfo(
    deviceDescriptor: "Unknown Device",
    platformCode: 0,
  );
}
