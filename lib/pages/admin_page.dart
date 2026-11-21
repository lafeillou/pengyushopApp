import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../models/member.dart';
import '../models/membership_level.dart';
import '../services/auth_service.dart';
import '../services/member_service.dart';
import '../services/merchant_service.dart';
import '../services/red_packet_service.dart';
import '../services/wallet_service.dart';
import '../utils/format.dart';
import '../widgets/common.dart';

/// 后台管理（演示版模拟后台）：
/// - 会员等级升降级（一星~四星由后台设置）
/// - 红包发放规则设置（数量与时间由后台控制）
/// - 平台拨付零钱到会员零钱账户
/// - 合作商家列表
class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('后台管理'),
          bottom: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: '会员等级'),
              Tab(text: '红包规则'),
              Tab(text: '零钱拨付'),
              Tab(text: '商家列表'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _LevelTab(),
            _RedPacketRuleTab(),
            _GrantTab(),
            _MerchantListTab(),
          ],
        ),
      ),
    );
  }
}

/// 会员等级管理：级别升降由后台设置
class _LevelTab extends StatelessWidget {
  const _LevelTab();

  @override
  Widget build(BuildContext context) {
    final members = context.watch<AuthService>().allMembers;

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7F0),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Text(
            '规则：注册会员完成首笔消费自动升为普通会员；一星~四星会员的级别升降由后台设置。',
            style: TextStyle(fontSize: 11.5, color: Color(0xFFB26A00), height: 1.5),
          ),
        ),
        const SizedBox(height: 12),
        ...members.map((m) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: SectionCard(
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: const Color(0xFFFFE0E0),
                      child: Text(
                        m.name.characters.first,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: kPrimaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            m.name,
                            style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${m.phone} · ${m.role.label}',
                            style: TextStyle(fontSize: 10.5, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                    LevelBadge(m.level, compact: true),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 30,
                      child: FilledButton.tonal(
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        onPressed: () => _showLevelPicker(context, m),
                        child: const Text('调整级别', style: TextStyle(fontSize: 11.5)),
                      ),
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }

  void _showLevelPicker(BuildContext context, Member member) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text(
                '调整 ${member.name} 的会员级别',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
            ...MembershipLevel.values.map(
              (level) => ListTile(
                dense: true,
                leading: LevelBadge(level, compact: true),
                title: Text(level.rule, style: const TextStyle(fontSize: 12.5)),
                trailing: member.level == level
                    ? const Icon(Icons.check_circle, color: kPrimaryColor, size: 18)
                    : null,
                onTap: () {
                  context.read<MemberService>().setLevel(member.id, level);
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('已将 ${member.name} 调整为「${level.label}」')),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

/// 红包发放规则：数量以及时间由后台控制设置
class _RedPacketRuleTab extends StatefulWidget {
  const _RedPacketRuleTab();

  @override
  State<_RedPacketRuleTab> createState() => _RedPacketRuleTabState();
}

class _RedPacketRuleTabState extends State<_RedPacketRuleTab> {
  late final TextEditingController _daysController;
  late final TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    final config = context.read<RedPacketService>().config;
    _daysController = TextEditingController(text: '${config.days}');
    _amountController = TextEditingController(text: '${config.dailyAmount}');
  }

  @override
  void dispose() {
    _daysController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _save() {
    final days = int.tryParse(_daysController.text.trim());
    final amount = double.tryParse(_amountController.text.trim());
    if (days == null || days <= 0 || amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入正确的天数与金额')),
      );
      return;
    }
    final config = context.read<RedPacketService>().config;
    config.days = days;
    config.dailyAmount = amount;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('规则已更新：消费后连续 $days 天每天发放 ${formatMoney(amount)} 红包')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '红包发放规则设置',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                '会员在特惠商品区消费后，将在某一时间段内每天发放红包'
                '（数量以及时间由此处控制设置）；红包须当天领取，未领取视为放弃。',
                style: TextStyle(fontSize: 12, color: Colors.black54, height: 1.6),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _daysController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: '发放天数（每天发放一个）',
                  suffixText: '天',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: '每天发放金额',
                  prefixText: '¥ ',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: FilledButton(onPressed: _save, child: const Text('保存规则')),
              ),
              const SizedBox(height: 8),
              const Text(
                '提示：规则更新后，仅影响之后产生的消费红包。',
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 平台拨付零钱
class _GrantTab extends StatefulWidget {
  const _GrantTab();

  @override
  State<_GrantTab> createState() => _GrantTabState();
}

class _GrantTabState extends State<_GrantTab> {
  Member? _selected;
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _grant() {
    if (_selected == null) {
      _toast('请先选择会员');
      return;
    }
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      _toast('请输入正确的拨付金额');
      return;
    }
    final error = context.read<WalletService>().platformGrant(
          memberId: _selected!.id,
          amount: amount,
        );
    _toast(error ?? '已拨付 ${formatMoney(amount)} 到 ${_selected!.name} 的零钱账户');
    _amountController.clear();
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final members = context.watch<AuthService>().allMembers;
    final balance = _selected == null
        ? null
        : context.watch<WalletService>().balanceOf(_selected!.id);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '平台拨付零钱',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                '平台可拨付零钱到会员的零钱账户（零钱另一来源为会员向平台充值）。',
                style: TextStyle(fontSize: 12, color: Colors.black54, height: 1.5),
              ),
              const SizedBox(height: 14),
              InkWell(
                onTap: () => _showMemberPicker(context, members),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _selected == null
                              ? '选择拨付会员'
                              : '${_selected!.name}（${_selected!.phone}）'
                                  ' · 零钱余额 ${formatMoney(balance ?? 0)}',
                          style: TextStyle(
                            fontSize: 13,
                            color: _selected == null ? Colors.grey : Colors.black87,
                          ),
                        ),
                      ),
                      const Icon(Icons.expand_more, size: 18, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: '拨付金额',
                  prefixText: '¥ ',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: FilledButton(onPressed: _grant, child: const Text('确认拨付')),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showMemberPicker(BuildContext context, List<Member> members) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: members
              .map(
                (m) => ListTile(
                  dense: true,
                  leading: const Icon(Icons.person_outline, size: 20),
                  title: Text('${m.name}（${m.phone}）', style: const TextStyle(fontSize: 13)),
                  trailing: LevelBadge(m.level, compact: true),
                  onTap: () {
                    setState(() => _selected = m);
                    Navigator.of(ctx).pop();
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

/// 合作商家列表
class _MerchantListTab extends StatelessWidget {
  const _MerchantListTab();

  @override
  Widget build(BuildContext context) {
    final merchants = context.watch<MerchantService>().all;
    final auth = context.read<AuthService>();

    return ListView(
      padding: const EdgeInsets.all(12),
      children: merchants.map((m) {
        final owner = auth.findById(m.ownerId);
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          child: SectionCard(
            child: Row(
              children: [
                StoreImage(emoji: m.emoji, colorValue: m.colorValue, size: 48, radius: 10),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        m.name,
                        style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '店主：${owner?.name ?? '未知'}（${owner?.phone ?? '-'}）',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        m.address,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 10.5, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
