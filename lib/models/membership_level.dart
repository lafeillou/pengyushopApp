/// 会员级别：共六级，由低到高依次为：
/// 注册会员 → 普通会员 → 一星会员 → 二星会员 → 三星会员 → 四星会员
///
/// 升降级规则：
/// - 注册会员：注册成功即为注册会员
/// - 普通会员：在平台完成首笔消费后自动升级
/// - 一星会员 ~ 四星会员：由后台设置升降级
enum MembershipLevel {
  registered('注册会员'),
  normal('普通会员'),
  star1('一星会员'),
  star2('二星会员'),
  star3('三星会员'),
  star4('四星会员');

  const MembershipLevel(this.label);

  /// 级别名称
  final String label;

  /// 各级别升降级规则说明
  String get rule => switch (this) {
        registered => '注册成功即为注册会员',
        normal => '在平台完成首笔消费后自动升级',
        star1 || star2 || star3 || star4 => '由后台设置升降级',
      };
}
