import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/member.dart';
import '../services/auth_service.dart';
import '../services/red_packet_service.dart';
import '../services/wallet_service.dart';
import '../utils/format.dart';
import '../widgets/common.dart';
import 'merchant_zone_page.dart';
import 'special_zone_page.dart';

/// 首页：平台商城设置两个入口
/// ① 特惠商品展示区：会员优惠活动区（消费后按规则每天发放红包）
/// ② 合作商家（线下）展示区：展示商家门店，按距离由近到远排列
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final member = context.watch<AuthService>().current!;
    final wallet = context.watch<WalletService>();
    final redPackets = context.watch<RedPacketService>();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          children: [
            _header(context, member, wallet, redPackets),
            _banner(),
            const SectionTitle('平台入口'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _entranceCard(
                      icon: Icons.local_offer_outlined,
                      emoji: '🎁',
                      title: '特惠商品展示区',
                      subtitle: '会员优惠专区 · 消费返红包',
                      gradient: const [Color(0xFFE53935), Color(0xFFB71C1C)],
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SpecialZonePage()),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _entranceCard(
                      icon: Icons.storefront_outlined,
                      emoji: '🏬',
                      title: '合作商家展示区',
                      subtitle: '线下商家 · 由近到远',
                      gradient: const [Color(0xFF1E88E5), Color(0xFF0D47A1)],
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const MerchantZonePage()),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SectionTitle('平台规则速览'),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _RuleRow('🎖️', '会员六级：注册会员 → 普通会员 → 一星~四星会员（后台升降级）'),
                    SizedBox(height: 8),
                    _RuleRow('🧧', '特惠商品区消费后，按后台规则每天发放红包，需当天领取'),
                    SizedBox(height: 8),
                    _RuleRow('💳', '支持零钱 / 微信 / 支付宝 / 红包券 / 混合支付'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  /// 顶部问候与账户概览
  Widget _header(
    BuildContext context,
    Member member,
    WalletService wallet,
    RedPacketService redPackets,
  ) {
    final claimable = redPackets.claimableToday(member.id).length;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE53935), Color(0xFFB71C1C)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person_pin_circle, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                '您好，${member.name}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              LevelBadge(member.level),
              if (member.role == MemberRole.merchant) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD54F),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    '合作商家',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF7A4E00),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _stat('零钱余额', formatMoney(wallet.balanceOf(member.id))),
              _divider(),
              _stat('红包券余额', formatMoney(redPackets.accountOf(member.id))),
              _divider(),
              _stat('今日可领红包', '$claimable 个'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _divider() =>
      Container(width: 1, height: 30, color: Colors.white.withValues(alpha: 0.3));

  Widget _banner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [Color(0xFFFF7043), Color(0xFFE53935)],
        ),
      ),
      child: const Row(
        children: [
          Text('🛒', style: TextStyle(fontSize: 36)),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '会员专享 · 购物返红包',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '特惠区下单立享每日红包，红包券全场通用、可转让',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _entranceCard({
    required IconData icon,
    required String emoji,
    required String title,
    required String subtitle,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradient,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 30)),
                  Icon(icon, color: Colors.white.withValues(alpha: 0.9), size: 20),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RuleRow extends StatelessWidget {
  const _RuleRow(this.emoji, this.text);

  final String emoji;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 15)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 12.5, color: Colors.black87, height: 1.5),
          ),
        ),
      ],
    );
  }
}
