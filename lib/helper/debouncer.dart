
import 'dart:async';
import 'dart:ui';

import 'package:get/get_rx/src/rx_workers/utils/debouncer.dart';

class Debouncer{

  final int milliseconds;
  Timer? _timer;
  Debouncer({required this.milliseconds});

  void run(VoidCallback action){
    _timer?.cancel();
    _timer = Timer(Duration(microseconds: milliseconds), action);
  }

  void dispose(){
    _timer?.cancel();
  }
}