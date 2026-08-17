// Add these at the top of your class
import 'dart:async';
import 'dart:ui';

final theDebouncer = Debouncer(milliseconds: 500);

// Add this debouncer class (helper)
class Debouncer {
  final int milliseconds;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}
