import 'dart:async';
import 'connectivity_service.dart';
import '../../features/sales/data/sales_repository.dart';

class SyncService {
  static final SyncService _instance = SyncService._();
  factory SyncService() => _instance;
  SyncService._();

  final ConnectivityService _connectivity = ConnectivityService();
  final SalesRepository _salesRepository = SalesRepository();
  StreamSubscription<bool>? _subscription;

  void start() {
    _subscription?.cancel();
    _subscription = _connectivity.connectionStream.listen((connected) {
      if (connected) {
        _salesRepository.syncPendingSales();
      }
    });
    _syncIfConnected();
  }

  void _syncIfConnected() {
    _connectivity.isConnected().then((connected) {
      if (connected) {
        _salesRepository.syncPendingSales();
      }
    });
  }

  void syncNow() {
    _salesRepository.syncPendingSales();
  }

  void stop() {
    _subscription?.cancel();
    _subscription = null;
  }
}
