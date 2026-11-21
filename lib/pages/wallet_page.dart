import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../services/auth_service.dart';
import '../services/wallet_service.dart';
import '../utils/format.dart';
import '../widgets/common.dart';

/// 钱包页：零钱账户。
/// 零钱来源于会员向平台充值，平台拨付零钱到会员的零钱账户；
/// 零钱可用于平台消费（含混合支付）。
class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  String _channel = '微信';

  void _showRechargeDialog() {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('零钱充值'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: controller,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  hintText: '请输入充值金额',
                  prefixText: '¥ ',
                ),
              ),
              const SizedBox(height: 12),
              const Text('充值通道（模拟）', style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 6),
              Row(
                children: [
                  ChoiceChip(
                    label: const Text('微信', style: TextStyle(fontSize: 12)),
                    selected: _channel == '微信',
                    onSelected: (_) => setState(() => _channel = '微信'),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('支付宝', style: TextStyle(fontSize: 12)),
                    selected: _channel == '支付宝',
                    onSelected: (_) => setState(() => _channel = '支付宝'),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                '演示环境：充值直接到账零钱账户（正式项目对接支付通道）',
                style: TextStyle(fontSize: 10.5, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('取消')),
            FilledButton(
              onPressed: () {
                final amount = double.tryParse(controller.text.trim());
                Navigator.of(ctx).pop();
                if (amount == null) {
                  _toast('请输入正确的充值金额');
                  return;
                }
                final member = context.read<AuthService>().current!;
                final error = context.read<WalletService>().recharge(
                      memberId: member.id,
                      amount: amount,
                      channel: _channel,
                    );
                _toast(error ?? '充值成功');
              },
              child: const Text('确认充值'),
            ),
          ],
        ),
      ),
    );
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final member = context.watch<AuthService>().current!;
    final wallet = context.watch<WalletService>();
    final balance = wallet.balanceOf(member.id);
    final records = wallet.recordsOf(member.id);

    return Scaffold(
      appBar: AppBar(title: const Text('我的钱包')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF7E57C2), Color(0xFF4527A0)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '零钱余额（元）',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 6),
                Text(
                  balance.toStringAsFixed(2),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 34,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF4527A0),
                    ),
                    onPressed: _showRechargeDialog,
                    child: const Text('充 值', style: TextStyle(fontSize: 12.5)),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '零钱来源于会员向平台充值，平台亦可拨付零钱到会员零钱账户',
                  style: TextStyle(color: Colors.white70, fontSize: 10.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '收支明细',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                if (records.isEmpty)
                  const EmptyView(icon: Icons.receipt_long_outlined, text: '暂无收支记录')
                else
                  ...records.map((r) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                r.remark,
                                style: const TextStyle(fontSize: 12.5),
                              ),
                            ),
                            Text(
                              formatDateTime(r.time),
                              style: TextStyle(fontSize: 10.5, color: Colors.grey.shade500),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              r.amount > 0 ? '+${formatMoney(r.amount)}' : formatMoney(r.amount),
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: r.amount > 0 ? kPrimaryColor : const Color(0xFF43A047),
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
}
