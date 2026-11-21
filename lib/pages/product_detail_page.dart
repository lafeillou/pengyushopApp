import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../services/red_packet_service.dart';
import '../utils/format.dart';
import '../widgets/common.dart';
import 'checkout_page.dart';

/// 特惠商品详情页
class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final config = context.watch<RedPacketService>().config;
    return Scaffold(
      appBar: AppBar(title: const Text('商品详情')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                StoreImage(
                  emoji: product.emoji,
                  colorValue: product.colorValue,
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
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          MoneyText(product.price, fontSize: 26),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF3E0),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              '会员特惠',
                              style: TextStyle(
                                fontSize: 10,
                                color: Color(0xFFE65100),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        product.name,
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product.desc,
                        style: const TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.redeem, color: Color(0xFFE53935), size: 18),
                            SizedBox(width: 6),
                            Text(
                              '红包发放说明',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '在本特惠商品区消费后，平台将按后台规则在连续 ${config.days} 天内每天发放 ${formatMoney(config.dailyAmount)} 红包，'
                          '需当天在「红包券」页面领取，未领取视为放弃。领取后进入红包券账户，'
                          '可在会员间转让、在线上商城与线下合作商家消费。',
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: Colors.black54,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(23),
                  ),
                ),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CheckoutPage(
                      subject: '特惠商品-${product.name}',
                      amount: product.price,
                      generateRedPacket: true,
                    ),
                  ),
                ),
                child: Text('立即购买 ${formatMoney(product.price)}'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
