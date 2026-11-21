import '../models/membership_level.dart';
import 'auth_service.dart';

/// 会员等级服务：
/// - 注册会员 → 普通会员：消费后自动升格；
/// - 一星会员 ~ 四星会员：级别升降由后台设置。
class MemberService {
  MemberService(this._auth);

  final AuthService _auth;

  /// 消费成功后调用：注册会员自动升格为普通会员
  void upgradeAfterConsume(String memberId) {
    final m = _auth.findById(memberId);
    if (m == null || m.level != MembershipLevel.registered) return;
    m.level = MembershipLevel.normal;
    _auth.refresh();
  }

  /// 后台设置会员级别（升降级）
  void setLevel(String memberId, MembershipLevel level) {
    final m = _auth.findById(memberId);
    if (m == null) return;
    m.level = level;
    _auth.refresh();
  }
}
