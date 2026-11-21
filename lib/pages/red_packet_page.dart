import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/red_packet.dart';
import '../services/auth_service.dart';
import '../services/red_packet_service.dart';
import '../utils/format.dart';
import '../widgets/common.dart';
import 'red_packet_transfer_page.dart';

/// 红包券中心：
/// - 每日红包需当天领取，未领取视为放弃；
/// - 领取后进入红包券账户，可在会员间转让、
///   在线上商城与线下合作商家消费。
class RedPacketPage extends StatefulWidget {
  const RedPacketPage({super.key});

  @override
  State<RedPacketPage> createState() => _RedPacketPageState();
}

class _RedPacketPageState extends State<RedPacketPage> {
  @override
  void initState() {
    super.initState();
    // 刷新过期未领取的红包（视为放弃）
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final member = context.read<AuthService>().current;
      if (member != null) {
        context.read<RedPacketService>().refreshExpired(member.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final member = context.watch<AuthService>().current!;
    final service = context.watch<RedPacketService>();
    final account = service.accountOf(member.id);
    final claimable = service.claimableToday(member.id);
    final upcoming = service.upcomingPackets(member.id);
    final records = service.recordsOf(member.id);

    return Scaffold(
      appBar: AppBar(title: const Text('红包券')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // 红包券账户余额
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFE53935), Color(0xFFB71C1C)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '红包券账户余额（元）',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 6),
                Text(
                  account.toStringAsFixed(2),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    SizedBox(
                      height: 34,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFFE53935),
                        ),
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const RedPacketTransferPage(),
                          ),
                        ),
                        child: const Text('转让给会员', style: TextStyle(fontSize: 12.5)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        '红包券可在会员间转让，可线上商城与线下商家消费',
                        style: TextStyle(color: Colors.white70, fontSize: 10.5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 今日可领
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      '今日可领红包',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE53935),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${claimable.length}',
                        style: const TextStyle(fontSize: 11, color: Colors.white),
                      ),
                    ),
                    const Spacer(),
                    if (claimable.isNotEmpty)
                      TextButton(
                        onPressed: () {
                          final count = service.claimAllToday(member.id);
                          _toast('已领取 $count 个红包，已转入红包券账户');
                        },
                        child: const Text('一键领取', style: TextStyle(fontSize: 12)),
                      ),
                  ],
                ),
                if (claimable.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      '今日暂无红包可领取。\n在特惠商品区消费后可获得每日红包。',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.6),
                    ),
                  )
                else
                  ...claimable.map((p) => _packetRow(service, p, claimable: true)),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 待发放
          if (upcoming.isNotEmpty)
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '待发放红包',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '按后台规则每天发放，请在发放当天及时领取',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  ...upcoming.take(5).map((p) => _packetRow(service, p, claimable: false)),
                ],
              ),
            ),
          if (upcoming.isNotEmpty) const SizedBox(height: 12),

          // 规则说明
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '红包规则说明',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  '1. 特惠商品区消费后，平台按后台配置在某个时间段内每天发放红包；\n'
                  '2. 红包须当天领取，未领取视为放弃；\n'
                  '3. 领取后进入红包券账户，可在会员间相互转让；\n'
                  '4. 红包券可在线上商城与线下合作商家消费（含混合支付）。',
                  style: TextStyle(fontSize: 12, color: Colors.black54, height: 1.7),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 历史记录
          if (records.isNotEmpty)
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '账户明细',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  ...records.take(20).map((r) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            Text(
                              r.type.label,
                              style: const TextStyle(fontSize: 12.5),
                            ),
                            const Spacer(),
                            Text(
                              r.remark,
                              style: TextStyle(fontSize: 10.5, color: Colors.grey.shade500),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              r.amount > 0
                                  ? '+${formatMoney(r.amount)}'
                                  : r.amount < 0
                                      ? formatMoney(r.amount)
                                      : '—',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: r.amount > 0
                                    ? const Color(0xFFE53935)
                                    : r.amount < 0
                                        ? const Color(0xFF43A047)
                                        : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _packetRow(
    RedPacketService service,
    RedPacket packet, {
    required bool claimable,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: const LinearGradient(
          colors: [Color(0xFFFF7043), Color(0xFFE53935)],
        ),
      ),
      child: Row(
        children: [
          const Text('🧧', style: TextStyle(fontSize: 26)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${formatMoney(packet.amount)} 红包',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  claimable ? '今天 ${formatDateTime(DateTime.now())} 前领取有效' : '发放日：${formatDate(packet.availableDate)}',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 10.5),
                ),
              ],
            ),
          ),
          if (claimable)
            SizedBox(
              height: 30,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFE53935),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                ),
                onPressed: () {
                  if (service.claim(packet.id)) {
                    _toast('领取成功，已转入红包券账户');
                  }
                },
                child: const Text('领取', style: TextStyle(fontSize: 12)),
              ),
            ),
        ],
      ),
    );
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }
}
