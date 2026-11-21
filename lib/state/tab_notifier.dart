import 'package:flutter/foundation.dart';

/// 主框架底部 Tab 索引（供子页面切换 Tab）
class TabIndexNotifier extends ChangeNotifier {
  int _index = 0;

  int get index => _index;

  void select(int i) {
    if (i == _index) return;
    _index = i;
    notifyListeners();
  }
}
