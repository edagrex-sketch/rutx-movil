import 'dart:io';

class ApiConstants {
  static bool useMock = false;
  static bool useLocalIp =
      false; // Cambia a false si vuelves a usar el emulador (10.0.2.2)

  static String get baseUrl {
    final port = useMock ? '5048' : '5047';
    if (useLocalIp) {
      return 'http://192.168.100.61:$port';
    }
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:$port';
    }
    return 'http://localhost:$port';
  }
}
