import 'package:flutter/foundation.dart';

import '../models/member.dart';
import '../models/membership_level.dart';
import 'seed_data.dart';

/// 会员认证服务：注册、登录、退出。
/// 会员制平台：消费前必须注册成为平台会员；
/// 注册成功即为「注册会员」。
class AuthService extends ChangeNotifier {
  AuthService() {
    for (final m in seedMembers()) {
      _byPhone[m.phone] = m;
    }
  }

  final Map<String, Member> _byPhone = {};
  Member? _current;

  /// 当前登录会员
  Member? get current => _current;

  /// 全部会员（后台管理用）
  List<Member> get allMembers =>
      _byPhone.values.toList()..sort((a, b) => a.createdAt.compareTo(b.createdAt));

  Member? findByPhone(String phone) => _byPhone[phone];

  Member? findById(String id) {
    for (final m in _byPhone.values) {
      if (m.id == id) return m;
    }
    return null;
  }

  /// 登录。成功返回 null，失败返回错误信息。
  String? login(String phone, String password) {
    final m = _byPhone[phone];
    if (m == null) return '该手机号尚未注册会员，请先注册';
    if (m.password != password) return '密码错误';
    _current = m;
    notifyListeners();
    return null;
  }

  /// 注册会员。成功自动登录，返回 null；失败返回错误信息。
  String? register({
    required String phone,
    required String name,
    required String password,
  }) {
    if (phone.length != 11 || int.tryParse(phone) == null) {
      return '请输入 11 位手机号';
    }
    if (_byPhone.containsKey(phone)) return '该手机号已注册会员';
    if (name.trim().isEmpty) return '请输入昵称';
    if (password.length < 6) return '密码至少 6 位';

    final member = Member(
      id: 'u${DateTime.now().microsecondsSinceEpoch}',
      phone: phone,
      name: name.trim(),
      password: password,
      level: MembershipLevel.registered, // 注册成功即为注册会员
    );
    _byPhone[phone] = member;
    _current = member;
    notifyListeners();
    return null;
  }

  void logout() {
    _current = null;
    notifyListeners();
  }

  /// 供其它服务在修改会员数据后触发界面刷新
  void refresh() => notifyListeners();
}
