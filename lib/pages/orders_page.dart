import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/order.dart';
import '../services/auth_service.dart';
import '../services/payment_service.dart';
import '../utils/format.dart';
import '../widgets/common.dart';

/// 我的订单列表
class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final member = context.watch<AuthService>().current!;
    final orders = context.watch<PaymentService>().ordersOf(member.id);

    return Scaffold(
      appBar: AppBar(title: const Text('我的订单')),
      body: orders.isEmpty
          ? const Center(
              child: EmptyView(icon: Icons.receipt_long_outlined, text: '暂无订单，快去特惠区逛逛吧'),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: orders.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) => _orderCard(orders[index]),
            ),
    );
  }

  Widget _orderCard(Order order) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  order.subject,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
                ),
              ),
              if (order.isSpecialZone)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: const Text(
                    '特惠区·返红包',
                    style: TextStyle(fontSize: 9, color: Color(0xFFE65100)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                order.method.label,
                style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600),
              ),
              const Spacer(),
              MoneyText(order.totalAmount, fontSize: 15),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            formatDateTime(order.createdAt),
            style: TextStyle(fontSize: 10.5, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}
