import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../models/order.dart';
import '../services/auth_service.dart';
import '../services/payment_service.dart';
import '../services/red_packet_service.dart';
import '../services/wallet_service.dart';
import '../utils/format.dart';
import '../widgets/common.dart';
import 'order_result_page.dart';

/// 结算页：
/// 支持零钱支付、微信支付、支付宝支付、红包券支付、混合支付；
/// 混合支付仅支持零钱 + 红包券，按比例支付。
class CheckoutPage extends StatefulWidget {
  const CheckoutPage({
    super.key,
    required this.subject,
    required this.amount,
    this.generateRedPacket = false,
  });

  /// 订单标题（商品名 / 到店消费-门店名）
  final String subject;

  /// 支付金额
  final double amount;

  /// 特惠商品区线上订单：支付成功后按规则发放红包
  final bool generateRedPacket;

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  PaymentMethodType _method = PaymentMethodType.balance;

  /// 混合支付时零钱占比（0~1），其余由红包券支付
  double _balanceRatio = 0.5;

  @override
  Widget build(BuildContext context) {
    final member = context.watch<AuthService>().current!;
    final balance = context.watch<WalletService>().balanceOf(member.id);
    final redPacketBalance = context.watch<RedPacketService>().accountOf(member.id);

    final balancePart = (widget.amount * _balanceRatio * 100).round() / 100;
    final redPacketPart = ((widget.amount - balancePart) * 100).round() / 100;

    // 支付可行性校验
    String? error;
    switch (_method) {
      case PaymentMethodType.balance:
        if (balance < widget.amount) error = '零钱余额不足，请充值或更换支付方式';
      case PaymentMethodType.redPacket:
        if (redPacketBalance < widget.amount) error = '红包券余额不足';
      case PaymentMethodType.mixed:
        if (balance < balancePart) error = '零钱余额不足，混合支付失败';
        if (redPacketBalance < redPacketPart) error = '红包券余额不足，混合支付失败';
      case PaymentMethodType.wechat:
      case PaymentMethodType.alipay:
        break;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('确认订单')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('订单信息', style: TextStyle(fontSize: 13, color: Colors.grey)),
                      const SizedBox(height: 8),
                      Text(
                        widget.subject,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Text('应付金额：', style: TextStyle(fontSize: 13)),
                          MoneyText(widget.amount, fontSize: 24),
                        ],
                      ),
                      if (widget.generateRedPacket) ...[
                        const SizedBox(height: 6),
                        const Text(
                          '🎁 特惠区订单：支付成功后将按后台规则每天发放红包',
                          style: TextStyle(fontSize: 11.5, color: Color(0xFFE65100)),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SectionCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(14, 12, 14, 4),
                        child: Text(
                          '选择支付方式',
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      ),
                      _methodTile(PaymentMethodType.balance, '零钱余额 ${formatMoney(balance)}'),
                      _methodTile(PaymentMethodType.wechat, '微信在线支付'),
                      _methodTile(PaymentMethodType.alipay, '支付宝在线支付'),
                      _methodTile(PaymentMethodType.redPacket, '红包券余额 ${formatMoney(redPacketBalance)}'),
                      _methodTile(
                        PaymentMethodType.mixed,
                        '零钱 + 红包券 按比例组合支付',
                      ),
                    ],
                  ),
                ),
                if (_method == PaymentMethodType.mixed) ...[
                  const SizedBox(height: 12),
                  SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '混合支付比例（仅支持零钱 + 红包券）',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '零钱 ${(_balanceRatio * 100).round()}% · 红包券 ${((1 - _balanceRatio) * 100).round()}%',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                        Slider(
                          value: _balanceRatio,
                          divisions: 20,
                          label: '零钱 ${(_balanceRatio * 100).round()}%',
                          onChanged: (v) => setState(() => _balanceRatio = v),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _splitItem('零钱支付', balancePart, Colors.blueGrey),
                            _splitItem('红包券支付', redPacketPart, const Color(0xFFE53935)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
                if (error != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      error,
                      style: const TextStyle(fontSize: 12.5, color: Color(0xFFC62828)),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
            color: Colors.white,
            child: SizedBox(
              width: double.infinity,
              height: 46,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(23),
                  ),
                ),
                onPressed: error != null ? null : _pay,
                child: Text('确认支付 ${formatMoney(widget.amount)}'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _splitItem(String label, double amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
        const SizedBox(height: 2),
        MoneyText(amount, fontSize: 15, color: color),
      ],
    );
  }

  Widget _methodTile(PaymentMethodType method, String subtitle) {
    final selected = _method == method;
    return InkWell(
      onTap: () => setState(() => _method = method),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.grey.shade100),
          ),
          color: selected ? const Color(0xFFFFF1F1) : null,
        ),
        child: Row(
          children: [
            Icon(
              method == PaymentMethodType.wechat
                  ? Icons.chat
                  : method == PaymentMethodType.alipay
                      ? Icons.account_balance
                      : method == PaymentMethodType.balance
                          ? Icons.account_balance_wallet_outlined
                          : method == PaymentMethodType.redPacket
                              ? Icons.card_giftcard
                              : Icons.currency_exchange,
              size: 22,
              color: selected ? kPrimaryColor : Colors.grey.shade600,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                      color: selected ? kPrimaryColor : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ),
            Icon(
              selected ? Icons.check_circle : Icons.circle_outlined,
              size: 20,
              color: selected ? kPrimaryColor : Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  void _pay() {
    final member = context.read<AuthService>().current!;
    final result = context.read<PaymentService>().pay(
          memberId: member.id,
          amount: widget.amount,
          method: _method,
          subject: widget.subject,
          balanceRatio: _balanceRatio,
          generateRedPacket: widget.generateRedPacket,
        );
    if (!result.success) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(result.message)));
      return;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => OrderResultPage(order: result.order!),
      ),
    );
  }
}
