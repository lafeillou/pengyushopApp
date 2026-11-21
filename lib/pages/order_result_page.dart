import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/order.dart';
import '../services/red_packet_service.dart';
import '../state/tab_notifier.dart';
import '../utils/format.dart';
import '../widgets/common.dart';

/// 支付结果页：展示支付明细；特惠区订单展示红包发放信息
class OrderResultPage extends StatelessWidget {
  const OrderResultPage({super.key, required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final config = context.watch<RedPacketService>().config;

    return Scaffold(
      appBar: AppBar(title: const Text('支付结果'), automaticallyImplyLeading: false),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 20),
          const Icon(Icons.check_circle, color: Color(0xFF43A047), size: 72),
          const SizedBox(height: 12),
          const Center(
            child: Text(
              '支付成功',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 24),
          SectionCard(
            child: Column(
              children: [
                _row('订单标题', order.subject),
                _row('订单编号', order.id),
                _row('支付方式', order.method.label),
                if (order.balancePaid > 0)
                  _row('零钱支付', '-${formatMoney(order.balancePaid)}'),
                if (order.redPacketPaid > 0)
                  _row('红包券支付', '-${formatMoney(order.redPacketPaid)}'),
                _row('支付时间', formatDateTime(order.createdAt)),
                const Divider(height: 20),
                Row(
                  children: [
                    const Text('实付金额', style: TextStyle(fontSize: 14)),
                    const Spacer(),
                    MoneyText(order.totalAmount, fontSize: 20),
                  ],
                ),
              ],
            ),
          ),
          if (order.isSpecialZone) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  colors: [Color(0xFFE53935), Color(0xFFB71C1C)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Text('🧧', style: TextStyle(fontSize: 22)),
                      SizedBox(width: 8),
                      Text(
                        '恭喜获得消费红包',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '平台已为您发放连续 ${config.days} 天红包，每天 ${formatMoney(config.dailyAmount)}。\n'
                    '请在「红包券」页面每天领取，当天未领取视为放弃。',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.95),
                      fontSize: 12.5,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () =>
                      Navigator.of(context).popUntil((route) => route.isFirst),
                  child: const Text('返回首页'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    context.read<TabIndexNotifier>().select(1);
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: const Text('去领红包'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
