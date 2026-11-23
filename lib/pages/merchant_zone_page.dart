import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/merchant.dart';
import '../services/merchant_service.dart';
import '../utils/format.dart';
import '../widgets/common.dart';
import 'merchant_detail_page.dart';

/// 合作商家（线下）展示区（主导航“附近”页）：
/// 展示商家门店（门头照片）、地址定位、离会员之间的距离，
/// 商家展示按距离由近到远排列。
class MerchantZonePage extends StatelessWidget {
  const MerchantZonePage({super.key, this.title = '合作商家展示区'});

  /// 页面标题（作为“附近”Tab 页时传入“附近”）
  final String title;

  @override
  Widget build(BuildContext context) {
    final service = context.watch<MerchantService>();
    final merchants = service.sortedByDistance();

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                colors: [Color(0xFF1E88E5), Color(0xFF0D47A1)],
              ),
            ),
            child: const Row(
              children: [
                Text('🏬', style: TextStyle(fontSize: 26)),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '线下合作商家 · 已按距离由近到远排列\n支持红包券与混合支付',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.5,
                      height: 1.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              itemCount: merchants.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final m = merchants[index];
                return _merchantCard(context, service, m);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _merchantCard(
    BuildContext context,
    MerchantService service,
    Merchant m,
  ) {
    final distance = service.distanceToMe(m);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => MerchantDetailPage(merchant: m)),
        ),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // 门头照片
              StoreImage(
                emoji: m.emoji,
                colorValue: m.colorValue,
                size: 72,
                radius: 10,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            m.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE3F2FD),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Text(
                            m.category,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF1565C0),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 13, color: Colors.grey.shade500),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            m.address,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE53935),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '距您 ${formatDistance(distance)}',
                            style: const TextStyle(
                              fontSize: 10.5,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '进店逛逛 >',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
