/// 红包状态
enum RedPacketStatus {
  /// 待领取
  pending('待领取'),

  /// 已领取（进入红包券账户）
  claimed('已领取'),

  /// 过期作废（当天未领取视为放弃）
  forfeited('已过期作废');

  const RedPacketStatus(this.label);

  final String label;
}

/// 消费红包：会员在特惠商品区消费后，平台按后台规则在
/// 某个时间段内每天发放一个红包，需当天领取，未领取视为放弃。
class RedPacket {
  RedPacket({
    required this.id,
    required this.ownerId,
    required this.amount,
    required this.availableDate,
    required this.sourceOrderId,
    this.status = RedPacketStatus.pending,
  });

  final String id;

  /// 红包所属会员 id
  final String ownerId;

  /// 红包金额（由后台配置）
  final double amount;

  /// 可领取日期（仅当天有效，当天未领取视为放弃）
  final DateTime availableDate;

  /// 来源订单 id
  final String sourceOrderId;

  RedPacketStatus status;

  /// 是否在某一天内有效
  bool isOn(DateTime day) =>
      availableDate.year == day.year &&
      availableDate.month == day.month &&
      availableDate.day == day.day;
}

/// 红包发放规则（数量与时间由后台控制设置）
class RedPacketConfig {
  /// 发放天数（消费后连续 N 天每天发一个）
  int days;

  /// 每天发放的红包金额
  double dailyAmount;

  RedPacketConfig({this.days = 7, this.dailyAmount = 1.0});
}
