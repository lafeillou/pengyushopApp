import 'package:flutter/material.dart';

/// 购物车页：严格复刻设计稿 21:791
/// 顶栏（返回 + 标题 + 地址 + 管理）+ #F2F2F7 商品列表 + 底部结算栏
class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: Column(
        children: [
          _buildTopBar(context),
          Expanded(child: _buildShopList()),
          _buildCheckoutBar(),
        ],
      ),
    );
  }

  /// 顶栏：返回 + 标题“购物车（10）” + 地址 + 搜索 + 管理（45 高白底）
  Widget _buildTopBar(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 45,
          child: Row(
            children: [
              const SizedBox(width: 8),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                icon: const Icon(
                  Icons.chevron_left,
                  size: 20,
                  color: Color(0xFF1A1A1A),
                ),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              const SizedBox(width: 10),
              const Text(
                '购物车（10）',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const Spacer(),
              const Icon(Icons.location_on, size: 16, color: Color(0xFF202024)),
              const SizedBox(width: 4),
              const Text(
                '新建街57号福…',
                style: TextStyle(fontSize: 12, color: Color(0x993C3C43)),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_drop_down, size: 10, color: Color(0xFF8A8A8E)),
              const SizedBox(width: 17),
              const Icon(Icons.search, size: 22, color: Color(0xFF202024)),
              const SizedBox(width: 12),
              const Text(
                '管理',
                style: TextStyle(fontSize: 15, color: Colors.black),
              ),
              const SizedBox(width: 16),
            ],
          ),
        ),
      ),
    );
  }

  /// 商品列表：#F2F2F7 背景，3 张同款商品卡（与设计稿一致）
  Widget _buildShopList() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 9, 12, 15),
      itemCount: 3,
      separatorBuilder: (_, _) => const SizedBox(height: 15),
      itemBuilder: (_, _) => const _CartItemCard(),
    );
  }

  /// 结算栏：全选 + 合计 + 结算按钮（63 高白底）
  Widget _buildCheckoutBar() {
    return Container(
      color: Colors.white,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 63,
          child: Row(
            children: [
              const SizedBox(width: 18),
              _UncheckedCircle(15),
              const SizedBox(width: 6),
              const Text(
                '全选',
                style: TextStyle(fontSize: 14, color: Color(0x993C3C43)),
              ),
              const SizedBox(width: 35),
              const Text(
                '合计:',
                style: TextStyle(fontSize: 13, color: Colors.black),
              ),
              const SizedBox(width: 6),
              const Text(
                '¥0.00',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFFF0053),
                ),
              ),
              const Spacer(),
              Container(
                width: 166,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFF31B1B),
                  borderRadius: BorderRadius.circular(26),
                ),
                child: const Text(
                  '结算(0)',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 16),
            ],
          ),
        ),
      ),
    );
  }
}

/// 未选中圆：边框 #C6C6C8 1.2px（选中态为实心红）
class _UncheckedCircle extends StatelessWidget {
  const _UncheckedCircle(this.size);

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFC6C6C8), width: 1.2),
      ),
    );
  }
}

/// 购物车商品卡：378 宽 161 高白底圆角 18（与设计稿一致）
class _CartItemCard extends StatelessWidget {
  const _CartItemCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 161,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: 7),
          const _UncheckedCircle(15),
          const SizedBox(width: 12),
          _buildProductImage(),
          const SizedBox(width: 12),
          Expanded(child: _buildInfo()),
          const SizedBox(width: 12),
        ],
      ),
    );
  }

  /// 商品图 94x94 圆角 12（emoji 占位，正式项目替换为网络图片）
  Widget _buildProductImage() {
    return Container(
      width: 94,
      height: 94,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF7E9CC8), Color(0xFF4A6A99)],
        ),
      ),
      child: const Text('👖', style: TextStyle(fontSize: 44)),
    );
  }

  Widget _buildInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 促销标签 + 标题 + 数量
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0.5),
              decoration: BoxDecoration(
                color: const Color(0xFFFF8D28),
                borderRadius: BorderRadius.circular(3),
              ),
              child: const Text(
                '降温惊喜',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 7),
            const Expanded(
              child: Text(
                '【买一送一】',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ),
            Container(
              width: 30,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F7),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                '×1',
                style: TextStyle(fontSize: 12, color: Color(0x993C3C43)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // 规格 + 展开箭头
        const Row(
          children: [
            Text(
              '黑色+蓝色（2件更实惠…',
              style: TextStyle(fontSize: 16, color: Color(0x993C3C43)),
            ),
            SizedBox(width: 2),
            Icon(Icons.keyboard_arrow_down, size: 12, color: Color(0x993C3C43)),
          ],
        ),
        const SizedBox(height: 5),
        // 退货保障
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            border: Border.all(color: const Color(0xFF0088FF), width: 0.5),
          ),
          child: const Text(
            '7天无理由退货',
            style: TextStyle(fontSize: 11, color: Color(0xFF0088FF)),
          ),
        ),
        const SizedBox(height: 5),
        // 价格
        const Text(
          '¥59.9',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Color(0xFFFF0053),
          ),
        ),
        const SizedBox(height: 4),
        // 发货提示
        const Text(
          '⚡ 极速发 · 预计明天上午发货',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF34C759),
          ),
        ),
      ],
    );
  }
}
