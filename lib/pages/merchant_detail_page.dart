import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/merchant.dart';
import '../models/product.dart';
import '../services/merchant_service.dart';
import '../utils/format.dart';
import '../widgets/common.dart';
import 'checkout_page.dart';

/// 合作商家门店详情：
/// 门头照片、地址定位、距离、在售商品、到店买单。
/// 线下消费同样支持红包券支付与混合支付。
class MerchantDetailPage extends StatelessWidget {
  const MerchantDetailPage({super.key, required this.merchant});

  final Merchant merchant;

  @override
  Widget build(BuildContext context) {
    final service = context.watch<MerchantService>();
    final distance = service.distanceToMe(merchant);

    return Scaffold(
      appBar: AppBar(title: const Text('门店详情')),
      body: ListView(
        children: [
          StoreImage(
            emoji: merchant.emoji,
            colorValue: merchant.colorValue,
            size: double.infinity,
            radius: 0,
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        merchant.name,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3F2FD),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        merchant.category,
                        style: const TextStyle(fontSize: 11, color: Color(0xFF1565C0)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 15, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        merchant.address,
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.near_me, size: 15, color: const Color(0xFFE53935)),
                    const SizedBox(width: 4),
                    Text(
                      '距您 ${formatDistance(distance)}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFFE53935),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: SectionCard(
              child: Row(
                children: [
                  const Text('🎁', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      '线下合作商家支持：零钱 / 微信 / 支付宝 / 红包券 / 混合支付',
                      style: TextStyle(fontSize: 12, color: Colors.black54, height: 1.5),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 34,
                    child: FilledButton.tonal(
                      onPressed: () => _payAtStore(context),
                      child: const Text('到店买单', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SectionTitle('门店商品'),
          if (merchant.products.isEmpty)
            const EmptyView(icon: Icons.inventory_2_outlined, text: '门店暂无在售商品，可使用「到店买单」'),
          ...merchant.products.map(
            (p) => Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: _productRow(context, p),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  /// 到店买单：输入消费金额后进入结算
  void _payAtStore(BuildContext context) {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('到店买单'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            hintText: '请输入本次消费金额',
            prefixText: '¥ ',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('取消')),
          FilledButton(
            onPressed: () {
              final amount = double.tryParse(controller.text.trim());
              Navigator.of(ctx).pop();
              if (amount == null || amount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('请输入正确的消费金额')),
                );
                return;
              }
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CheckoutPage(
                    subject: '到店消费-${merchant.name}',
                    amount: amount,
                    generateRedPacket: false,
                  ),
                ),
              );
            },
            child: const Text('去支付'),
          ),
        ],
      ),
    );
  }

  Widget _productRow(BuildContext context, Product product) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => _buyProduct(context, product),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              StoreImage(
                emoji: product.emoji,
                colorValue: product.colorValue,
                size: 56,
                radius: 10,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      product.desc,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  MoneyText(product.price, fontSize: 15),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE53935),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Text(
                      '购买',
                      style: TextStyle(fontSize: 11, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _buyProduct(BuildContext context, Product product) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CheckoutPage(
          subject: '到店消费-${merchant.name}-${product.name}',
          amount: product.price,
          generateRedPacket: false,
        ),
      ),
    );
  }
}
