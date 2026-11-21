import 'membership_level.dart';

/// 商城角色：会员 / 线下合作商家。
/// 前提必须是平台会员，才能申请成为合作商家。
enum MemberRole {
  member('会员'),
  merchant('合作商家');

  const MemberRole(this.label);

  final String label;
}

/// 平台会员
class Member {
  Member({
    required this.id,
    required this.phone,
    required this.name,
    required this.password,
    required this.level,
    this.role = MemberRole.member,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final String id;

  /// 手机号（登录账号）
  final String phone;

  /// 昵称
  final String name;

  /// 登录密码（演示环境明文存储，正式项目应由后端加密）
  final String password;

  /// 会员级别（可由后台升降级）
  MembershipLevel level;

  /// 角色（会员可升级为合作商家）
  MemberRole role;

  final DateTime createdAt;
}
