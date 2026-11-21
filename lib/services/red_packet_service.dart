import 'package:flutter/foundation.dart';

import '../models/order.dart';
import '../models/red_packet.dart';
import 'auth_service.dart';

/// 红包券账户变动记录类型
enum RedPacketRecordType {
  claim('领取红包'),
  transferOut('转让支出'),
  transferIn('转让收入'),
  spend('红包券消费'),
  forfeit('过期作废');

  const RedPacketRecordType(this.label);

  final String label;
}

/// 红包券账户变动记录
class RedPacketRecord {
  const RedPacketRecord({
    required this.memberId,
    required this.amount,
    required this.type,
    required this.remark,
    required this.time,
  });

  final String memberId;

  /// 变动金额（正为增加，负为减少；作废为 0）
  final double amount;

  final RedPacketRecordType type;
  final String remark;
  final DateTime time;
}

/// 红包服务：
/// 1. 会员在特惠商品区消费后，平台按后台配置在某个时间段内
///    每天发放红包（数量与时间由后台控制设置）；
/// 2. 红包需当天领取，未领取视为放弃；
/// 3. 领取后进入红包券账户，可在会员间转让、
///    在线上商城与线下合作商家消费。
class RedPacketService extends ChangeNotifier {
  RedPacketService(this._auth) {
    // 演示数据：张三的红包券账户与历史红包
    _account['u1'] = 25.0;
    _account['u2'] = 10.0;
    final now = DateTime.now();
    _packets.addAll([
      RedPacket(
        id: 'rp-demo-1',
        ownerId: 'u1',
        amount: 1.0,
        availableDate: now.subtract(const Duration(days: 2)),
        sourceOrderId: 'ord-demo',
        status: RedPacketStatus.claimed,
      ),
      RedPacket(
        id: 'rp-demo-2',
        ownerId: 'u1',
        amount: 1.0,
        availableDate: now.subtract(const Duration(days: 1)),
        sourceOrderId: 'ord-demo',
        status: RedPacketStatus.forfeited,
      ),
      RedPacket(
        id: 'rp-demo-3',
        ownerId: 'u1',
        amount: 1.0,
        availableDate: now,
        sourceOrderId: 'ord-demo',
      ),
    ]);
  }

  final AuthService _auth;

  /// 红包发放规则（由后台控制设置）
  final RedPacketConfig config = RedPacketConfig();

  /// 会员 id → 红包券账户余额
  final Map<String, double> _account = {};

  final List<RedPacket> _packets = [];
  final List<RedPacketRecord> _records = [];

  /// 红包券账户余额
  double accountOf(String memberId) => _account[memberId] ?? 0;

  /// 会员红包券账户明细（新→旧）
  List<RedPacketRecord> recordsOf(String memberId) => _records
      .where((r) => r.memberId == memberId)
      .toList()
      .reversed
      .toList();

  /// 特惠商品区消费成功后，按后台规则为会员生成
  /// 连续 [config.days] 天的红包（每天一个）。
  void generateForOrder(Order order) {
    final now = DateTime.now();
    for (var i = 0; i < config.days; i++) {
      _packets.add(RedPacket(
        id: 'rp-${order.id}-$i',
        ownerId: order.memberId,
        amount: config.dailyAmount,
        availableDate: DateTime(now.year, now.month, now.day + i),
        sourceOrderId: order.id,
      ));
    }
    notifyListeners();
  }

  /// 会员的全部红包（新→旧）
  List<RedPacket> packetsOf(String memberId) => _packets
      .where((p) => p.ownerId == memberId)
      .toList()
    ..sort((a, b) => b.availableDate.compareTo(a.availableDate));

  /// 将已过期且未领取的红包作废（未领取视为放弃）。
  /// [now] 仅用于测试注入。
  void refreshExpired(String memberId, {DateTime? now}) {
    final today = now ?? DateTime.now();
    var changed = false;
    for (final p in _packets) {
      if (p.ownerId != memberId || p.status != RedPacketStatus.pending) continue;
      final d = DateTime(p.availableDate.year, p.availableDate.month, p.availableDate.day);
      final t = DateTime(today.year, today.month, today.day);
      if (d.isBefore(t)) {
        p.status = RedPacketStatus.forfeited;
        _records.add(RedPacketRecord(
          memberId: memberId,
          amount: 0,
          type: RedPacketRecordType.forfeit,
          remark: '${formatDateOf(p.availableDate)} 红包未领取，视为放弃',
          time: today,
        ));
        changed = true;
      }
    }
    if (changed) notifyListeners();
  }

  /// 今日可领取的红包
  List<RedPacket> claimableToday(String memberId) {
    final now = DateTime.now();
    return _packets
        .where((p) =>
            p.ownerId == memberId &&
            p.status == RedPacketStatus.pending &&
            p.isOn(now))
        .toList();
  }

  /// 未来待发放的红包（尚未到可领取日期）
  List<RedPacket> upcomingPackets(String memberId) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final result = _packets
        .where((p) =>
            p.ownerId == memberId &&
            p.status == RedPacketStatus.pending &&
            DateTime(p.availableDate.year, p.availableDate.month,
                    p.availableDate.day)
                .isAfter(today))
        .toList()
      ..sort((a, b) => a.availableDate.compareTo(b.availableDate));
    return result;
  }

  RedPacket? packetById(String packetId) {
    for (final p in _packets) {
      if (p.id == packetId) return p;
    }
    return null;
  }

  /// 领取单个红包（仅当天可领）。成功返回 true。
  bool claim(String packetId, {DateTime? now}) {
    final p = packetById(packetId);
    if (p == null || p.status != RedPacketStatus.pending) return false;
    if (!p.isOn(now ?? DateTime.now())) return false;
    p.status = RedPacketStatus.claimed;
    _account[p.ownerId] = accountOf(p.ownerId) + p.amount;
    _records.add(RedPacketRecord(
      memberId: p.ownerId,
      amount: p.amount,
      type: RedPacketRecordType.claim,
      remark: '领取 ${formatDateOf(p.availableDate)} 红包',
      time: DateTime.now(),
    ));
    notifyListeners();
    return true;
  }

  /// 一键领取今日全部红包，返回领取数量
  int claimAllToday(String memberId) {
    var count = 0;
    for (final p in claimableToday(memberId).toList()) {
      if (claim(p.id)) count++;
    }
    return count;
  }

  /// 红包券消费扣减（支付使用）；余额不足返回 false
  bool spend({
    required String memberId,
    required double amount,
    String remark = '红包券消费',
  }) {
    if (accountOf(memberId) < amount) return false;
    _account[memberId] = accountOf(memberId) - amount;
    _records.add(RedPacketRecord(
      memberId: memberId,
      amount: -amount,
      type: RedPacketRecordType.spend,
      remark: remark,
      time: DateTime.now(),
    ));
    notifyListeners();
    return true;
  }

  /// 会员之间转让红包券。
  /// 成功返回 null，失败返回错误信息。
  String? transfer({
    required String fromId,
    required String toPhone,
    required double amount,
  }) {
    if (amount <= 0) return '转让金额需大于 0';
    if (accountOf(fromId) < amount) return '红包券账户余额不足';
    final to = _auth.findByPhone(toPhone);
    if (to == null) return '未找到该手机号对应的会员';
    if (to.id == fromId) return '不能转让给自己';

    _account[fromId] = accountOf(fromId) - amount;
    _account[to.id] = accountOf(to.id) + amount;
    final now = DateTime.now();
    _records.add(RedPacketRecord(
      memberId: fromId,
      amount: -amount,
      type: RedPacketRecordType.transferOut,
      remark: '转让给 ${to.name}（${to.phone}）',
      time: now,
    ));
    _records.add(RedPacketRecord(
      memberId: to.id,
      amount: amount,
      type: RedPacketRecordType.transferIn,
      remark: '收到 ${_auth.findById(fromId)?.name ?? ''} 转让',
      time: now,
    ));
    notifyListeners();
    return null;
  }
}

String formatDateOf(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
