import 'package:flutter/foundation.dart';

/// 零钱账户收支记录
class WalletRecord {
  const WalletRecord({
    required this.memberId,
    required this.amount,
    required this.remark,
    required this.time,
  });

  final String memberId;

  /// 变动金额（正为收入，负为支出）
  final double amount;

  final String remark;
  final DateTime time;
}

/// 零钱账户服务：
/// 零钱来源于会员向平台充值，以及平台拨付零钱到会员零钱账户；
/// 零钱可用于平台消费（含混合支付）。
class WalletService extends ChangeNotifier {
  WalletService() {
    // 演示数据：张三的零钱余额与流水
    _balance['u1'] = 100.0;
    _balance['u2'] = 50.0;
    final now = DateTime.now();
    _records.addAll([
      WalletRecord(
        memberId: 'u1',
        amount: 100,
        remark: '微信充值（模拟）',
        time: now.subtract(const Duration(days: 10)),
      ),
      WalletRecord(
        memberId: 'u1',
        amount: 50,
        remark: '平台拨付',
        time: now.subtract(const Duration(days: 3)),
      ),
      WalletRecord(
        memberId: 'u1',
        amount: -25,
        remark: '特惠商品消费',
        time: now.subtract(const Duration(days: 1)),
      ),
    ]);
  }

  final Map<String, double> _balance = {};
  final List<WalletRecord> _records = [];

  /// 零钱余额
  double balanceOf(String memberId) => _balance[memberId] ?? 0;

  /// 会员收支明细（新→旧）
  List<WalletRecord> recordsOf(String memberId) => _records
      .where((r) => r.memberId == memberId)
      .toList()
      .reversed
      .toList();

  /// 会员向平台充值（演示：模拟微信/支付宝充值通道直接到账）
  String? recharge({
    required String memberId,
    required double amount,
    required String channel,
  }) {
    if (amount <= 0) return '充值金额需大于 0';
    _balance[memberId] = balanceOf(memberId) + amount;
    _records.add(WalletRecord(
      memberId: memberId,
      amount: amount,
      remark: '$channel充值（模拟）',
      time: DateTime.now(),
    ));
    notifyListeners();
    return null;
  }

  /// 平台拨付零钱到会员零钱账户（后台操作）
  String? platformGrant({
    required String memberId,
    required double amount,
    String reason = '平台拨付',
  }) {
    if (amount <= 0) return '拨付金额需大于 0';
    _balance[memberId] = balanceOf(memberId) + amount;
    _records.add(WalletRecord(
      memberId: memberId,
      amount: amount,
      remark: reason,
      time: DateTime.now(),
    ));
    notifyListeners();
    return null;
  }

  /// 零钱消费扣减；余额不足返回 false
  bool deduct({
    required String memberId,
    required double amount,
    String remark = '消费支付',
  }) {
    if (balanceOf(memberId) < amount) return false;
    _balance[memberId] = balanceOf(memberId) - amount;
    _records.add(WalletRecord(
      memberId: memberId,
      amount: -amount,
      remark: remark,
      time: DateTime.now(),
    ));
    notifyListeners();
    return true;
  }
}
