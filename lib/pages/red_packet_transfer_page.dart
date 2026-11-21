import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import '../services/red_packet_service.dart';
import '../widgets/common.dart';

/// 红包券转让：红包券可以在会员之间相互转让
class RedPacketTransferPage extends StatefulWidget {
  const RedPacketTransferPage({super.key});

  @override
  State<RedPacketTransferPage> createState() => _RedPacketTransferPageState();
}

class _RedPacketTransferPageState extends State<RedPacketTransferPage> {
  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _transfer() {
    final member = context.read<AuthService>().current!;
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null) {
      _toast('请输入正确的转让金额');
      return;
    }
    final error = context.read<RedPacketService>().transfer(
          fromId: member.id,
          toPhone: _phoneController.text.trim(),
          amount: amount,
        );
    if (error != null) {
      _toast(error);
      return;
    }
    _toast('转让成功');
    Navigator.of(context).pop();
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final member = context.watch<AuthService>().current!;
    final account = context.watch<RedPacketService>().accountOf(member.id);

    return Scaffold(
      appBar: AppBar(title: const Text('红包券转让')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('我的红包券账户余额', style: TextStyle(fontSize: 13, color: Colors.grey)),
                const SizedBox(height: 4),
                MoneyText(account, fontSize: 26),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '转让给会员',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: '对方会员手机号',
                    prefixIcon: Icon(Icons.phone_android),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: '转让金额（元）',
                    prefixIcon: Icon(Icons.card_giftcard),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: FilledButton(
                    onPressed: _transfer,
                    child: const Text('确认转让'),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '提示：红包券可在会员之间相互转让，转让后立即到账对方红包券账户。',
                  style: TextStyle(fontSize: 11, color: Colors.grey, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
