import 'dart:io';

class ApiConstants {
  static bool useMock = false;

  static String get baseUrl {
    final port = useMock ? '5048' : '5047';
    if (Platform.isAndroid) {
      return 'http://192.168.100.65:$port';
    }
    return 'http://localhost:$port';
  }
}
