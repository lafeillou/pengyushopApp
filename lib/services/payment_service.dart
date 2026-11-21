import 'package:flutter/foundation.dart';

import '../models/order.dart';
import 'member_service.dart';
import 'red_packet_service.dart';
import 'wallet_service.dart';

/// 支付服务：统一处理平台消费支付。
/// 支持：零钱支付、微信支付、支付宝支付、红包券支付、
/// 以及混合支付（仅零钱 + 红包券，按比例支付）。
class PaymentService extends ChangeNotifier {
  PaymentService({
    required WalletService wallet,
    required RedPacketService redPackets,
    required MemberService members,
  })  : _wallet = wallet,
        _redPackets = redPackets,
        _members = members;

  final WalletService _wallet;
  final RedPacketService _redPackets;
  final MemberService _members;

  final List<Order> _orders = [];

  /// 会员订单（新→旧）
  List<Order> ordersOf(String memberId) => _orders
      .where((o) => o.memberId == memberId)
      .toList()
      .reversed
      .toList();

  /// 发起支付。
  /// - [balanceRatio]：混合支付时零钱占比（0~1），其余由红包券支付；
  /// - [generateRedPacket]：特惠商品区线上订单支付成功后产生红包发放。
  PaymentResult pay({
    required String memberId,
    required double amount,
    required PaymentMethodType method,
    required String subject,
    double balanceRatio = 0.5,
    bool generateRedPacket = false,
  }) {
    if (amount <= 0) return const PaymentResult.failure('支付金额无效');

    var balancePaid = 0.0;
    var redPacketPaid = 0.0;

    switch (method) {
      case PaymentMethodType.balance:
        if (!_wallet.deduct(
          memberId: memberId,
          amount: amount,
          remark: '零钱支付-$subject',
        )) {
          return const PaymentResult.failure('零钱余额不足');
        }
        balancePaid = amount;

      case PaymentMethodType.wechat:
      case PaymentMethodType.alipay:
        // 演示环境：第三方支付直接模拟成功，正式项目接入微信/支付宝 SDK
        break;

      case PaymentMethodType.redPacket:
        if (!_redPackets.spend(
          memberId: memberId,
          amount: amount,
          remark: '红包券支付-$subject',
        )) {
          return const PaymentResult.failure('红包券余额不足');
        }
        redPacketPaid = amount;

      case PaymentMethodType.mixed:
        // 混合支付：仅支持零钱 + 红包券，按比例支付
        final ratio = balanceRatio.clamp(0.0, 1.0);
        final balancePart = (amount * ratio * 100).round() / 100;
        final redPacketPart = ((amount - balancePart) * 100).round() / 100;
        if (_wallet.balanceOf(memberId) < balancePart) {
          return const PaymentResult.failure('零钱余额不足，混合支付失败');
        }
        if (_redPackets.accountOf(memberId) < redPacketPart) {
          return const PaymentResult.failure('红包券余额不足，混合支付失败');
        }
        _wallet.deduct(
          memberId: memberId,
          amount: balancePart,
          remark: '混合支付-零钱部分（$subject）',
        );
        _redPackets.spend(
          memberId: memberId,
          amount: redPacketPart,
          remark: '混合支付-红包券部分（$subject）',
        );
        balancePaid = balancePart;
        redPacketPaid = redPacketPart;
    }

    final order = Order(
      id: 'ord${DateTime.now().microsecondsSinceEpoch}',
      memberId: memberId,
      subject: subject,
      totalAmount: amount,
      method: method,
      balancePaid: balancePaid,
      redPacketPaid: redPacketPaid,
      isSpecialZone: generateRedPacket,
      createdAt: DateTime.now(),
    );
    _orders.add(order);

    // 特惠商品区线上消费 → 按后台规则生成每日红包
    if (generateRedPacket) {
      _redPackets.generateForOrder(order);
    }

    // 首笔消费后：注册会员自动升格为普通会员
    _members.upgradeAfterConsume(memberId);

    notifyListeners();
    return PaymentResult.success(order);
  }
}
