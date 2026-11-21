import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../services/auth_service.dart';
import '../services/merchant_service.dart';
import '../widgets/common.dart';

/// 申请成为合作商家（前提：必须先注册成为平台会员）
class MerchantApplyPage extends StatefulWidget {
  const MerchantApplyPage({super.key});

  @override
  State<MerchantApplyPage> createState() => _MerchantApplyPageState();
}

class _MerchantApplyPageState extends State<MerchantApplyPage> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  String _category = '餐饮';

  static const _categories = ['餐饮', '零售', '商超', '咖啡', '生活服务'];
  static const _emojiOptions = [
    ('🍲', 0xFFE64A19),
    ('🛒', 0xFF66BB6A),
    ('☕', 0xFF8D6E63),
    ('🍰', 0xFFEC407A),
    ('💇', 0xFFAB47BC),
    ('📦', 0xFF29B6F6),
  ];

  String _emoji = '🍲';
  int _colorValue = 0xFFE64A19;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _submit() {
    final member = context.read<AuthService>().current!;
    final error = context.read<MerchantService>().apply(
          owner: member,
          name: _nameController.text,
          category: _category,
          address: _addressController.text,
          emoji: _emoji,
          colorValue: _colorValue,
        );
    if (error != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('申请成功！您已成为合作商家，门店已上架合作商家展示区')),
      );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('申请成为合作商家')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              '申请须知：本平台合作商家必须先注册成为平台会员方可申请；'
              '申请通过后您的门店将展示在「合作商家展示区」，按距离由近到远排列展示。',
              style: TextStyle(fontSize: 12, color: Color(0xFF1565C0), height: 1.6),
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('门头照片', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    StoreImage(emoji: _emoji, colorValue: _colorValue, size: 84, radius: 12),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('选择门店类型图标（演示用占位图）',
                              style: TextStyle(fontSize: 11, color: Colors.grey)),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _emojiOptions.map((e) {
                              final selected = _emoji == e.$1;
                              return GestureDetector(
                                onTap: () => setState(() {
                                  _emoji = e.$1;
                                  _colorValue = e.$2;
                                }),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: selected ? kPrimaryColor : Colors.grey.shade300,
                                      width: selected ? 2 : 1,
                                    ),
                                  ),
                                  child: Text(e.$1, style: const TextStyle(fontSize: 20)),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: '门店名称',
                    prefixIcon: Icon(Icons.store),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                const Text('门店分类', style: TextStyle(fontSize: 13)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _categories
                      .map(
                        (c) => ChoiceChip(
                          label: Text(c, style: const TextStyle(fontSize: 12)),
                          selected: _category == c,
                          onSelected: (_) => setState(() => _category = c),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: '门店地址（用于定位展示）',
                    prefixIcon: Icon(Icons.location_on_outlined),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  '演示环境将自动在您当前位置附近生成门店定位坐标',
                  style: TextStyle(fontSize: 10.5, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: FilledButton(
                    onPressed: _submit,
                    child: const Text('提交申请'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
