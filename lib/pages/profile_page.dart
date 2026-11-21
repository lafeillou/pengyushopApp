import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../models/member.dart';
import '../models/membership_level.dart';
import '../services/auth_service.dart';
import '../services/merchant_service.dart';
import '../services/payment_service.dart';
import '../widgets/common.dart';
import 'admin_page.dart';
import 'login_page.dart';
import 'merchant_apply_page.dart';
import 'merchant_detail_page.dart';
import 'orders_page.dart';

/// 我的：会员信息、等级体系、商家中心、订单、退出登录
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  /// 后台管理员账号
  static const adminPhone = '13800000000';

  @override
  Widget build(BuildContext context) {
    final member = context.watch<AuthService>().current!;
    final merchant = context.watch<MerchantService>().byOwnerId(member.id);
    final orderCount = context.watch<PaymentService>().ordersOf(member.id).length;

    return Scaffold(
      appBar: AppBar(title: const Text('我的')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // 会员信息
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFE53935), Color(0xFFB71C1C)],
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.white,
                  child: Text(
                    member.name.characters.first,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE53935),
                    ),
                  ),
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
                              member.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          LevelBadge(member.level),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        member.phone,
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '角色：${member.role.label}',
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 会员等级体系
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '会员等级体系',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  '共六级：注册会员 → 普通会员 → 一星~四星会员',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 8),
                ...MembershipLevel.values.map(
                  (level) => Container(
                    margin: const EdgeInsets.symmetric(vertical: 3),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: level == member.level
                          ? const Color(0xFFFFF1F1)
                          : const Color(0xFFFAFAFA),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: level == member.level
                            ? kPrimaryColor
                            : Colors.grey.shade200,
                      ),
                    ),
                    child: Row(
                      children: [
                        LevelBadge(level, compact: true),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            level.rule,
                            style: TextStyle(
                              fontSize: 11.5,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                        if (level == member.level)
                          const Icon(Icons.check_circle, size: 16, color: kPrimaryColor),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '级别升降由后台设置（一星~四星），普通会员由消费自动升格',
                  style: TextStyle(fontSize: 10.5, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 商家中心
          SectionCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                if (member.role == MemberRole.merchant && merchant != null)
                  ListTile(
                    leading: const Icon(Icons.storefront, color: Color(0xFF1E88E5)),
                    title: const Text('我的门店', style: TextStyle(fontSize: 14)),
                    subtitle: Text(
                      merchant.name,
                      style: const TextStyle(fontSize: 11.5, color: Colors.grey),
                    ),
                    trailing: const Icon(Icons.chevron_right, size: 18),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => MerchantDetailPage(merchant: merchant),
                      ),
                    ),
                  )
                else
                  ListTile(
                    leading: const Icon(Icons.storefront, color: Color(0xFF1E88E5)),
                    title: const Text('申请成为合作商家', style: TextStyle(fontSize: 14)),
                    subtitle: const Text(
                      '前提：先注册成为平台会员',
                      style: TextStyle(fontSize: 11.5, color: Colors.grey),
                    ),
                    trailing: const Icon(Icons.chevron_right, size: 18),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const MerchantApplyPage()),
                    ),
                  ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.receipt_long, color: Color(0xFF43A047)),
                  title: const Text('我的订单', style: TextStyle(fontSize: 14)),
                  subtitle: Text(
                    '共 $orderCount 笔',
                    style: const TextStyle(fontSize: 11.5, color: Colors.grey),
                  ),
                  trailing: const Icon(Icons.chevron_right, size: 18),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const OrdersPage()),
                  ),
                ),
                if (member.phone == adminPhone) ...[
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.admin_panel_settings, color: Color(0xFFF57C00)),
                    title: const Text('后台管理', style: TextStyle(fontSize: 14)),
                    subtitle: const Text(
                      '会员等级升降 / 红包规则 / 零钱拨付',
                      style: TextStyle(fontSize: 11.5, color: Colors.grey),
                    ),
                    trailing: const Icon(Icons.chevron_right, size: 18),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AdminPage()),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 退出登录
          SizedBox(
            height: 44,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: kPrimaryColor,
                side: const BorderSide(color: kPrimaryColor),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
              ),
              onPressed: () {
                context.read<AuthService>().logout();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              },
              child: const Text('退出登录'),
            ),
          ),
          const SizedBox(height: 12),
          const Center(
            child: Text(
              '鹏宇商城 · 演示版 v0.1.0\n数据存储于内存，重启后重置',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10.5, color: Colors.grey, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
