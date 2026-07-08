import 'dart:async';
import '../../features/notifications/data/repositories/notification_repository.dart';
import '../storage/local_storage.dart';

class NotificationPollingService {
  static final NotificationPollingService _instance = NotificationPollingService._();
  factory NotificationPollingService() => _instance;
  NotificationPollingService._();

  final NotificationRepository _repository = NotificationRepository();
  final LocalStorage _storage = LocalStorage();
  Timer? _timer;
  final _controller = StreamController<int>.broadcast();
  int _lastCount = 0;

  Stream<int> get countStream => _controller.stream;
  int get lastCount => _lastCount;

  void start({Duration interval = const Duration(seconds: 30)}) {
    stop();
    _poll();
    _timer = Timer.periodic(interval, (_) => _poll());
  }

  Future<void> _poll() async {
    final vendedorId = await _storage.getVendedorId();
    if (vendedorId == null) return;

    await _repository.fetchAndPersist(vendedorId);
    final after = await _repository.getUnreadCount();

    if (after != _lastCount) {
      _lastCount = after;
      _controller.add(after);
    }
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  void dispose() {
    stop();
    _controller.close();
  }
}
