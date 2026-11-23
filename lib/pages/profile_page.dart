import 'package:flutter/material.dart';

import '../models/product.dart';
import '../widgets/product_card.dart';

/// 个人中心页：严格复刻设计稿 16:275（已登录态）
/// 渐变头部（头像/昵称/VIP）+ 我的订单卡 + 猜你喜欢/我的收藏 Tab + 商品推荐
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  /// 推荐商品（与设计稿商品卡一致，两组展示）
  static final List<Product> _recommendProducts = [
    const Product(
      id: 'bee-1',
      name: 'BeeBiny加拿大进口海外男士【一瓶三用】',
      price: 368.0,
      desc: '加拿大进口 · 一瓶三用',
      emoji: '🧴',
      colorValue: 0xFFB98D5F,
      isGlobal: true,
    ),
    const Product(
      id: 'ly-1',
      name: '陇宇【飞天礼盒过年送礼】枸杞原浆滋补品',
      price: 188.0,
      desc: '飞天礼盒 · 枸杞原浆',
      emoji: '🎁',
      colorValue: 0xFFC24A3A,
      merchantId: 'shop-longyu',
    ),
    const Product(
      id: 'bee-2',
      name: 'BeeBiny加拿大进口海外男士【一瓶三用】',
      price: 368.0,
      desc: '加拿大进口 · 一瓶三用',
      emoji: '🧴',
      colorValue: 0xFFB98D5F,
      isGlobal: true,
    ),
    const Product(
      id: 'ly-2',
      name: '陇宇【飞天礼盒过年送礼】枸杞原浆滋补品',
      price: 188.0,
      desc: '飞天礼盒 · 枸杞原浆',
      emoji: '🎁',
      colorValue: 0xFFC24A3A,
      merchantId: 'shop-longyu',
    ),
  ];

  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F8),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildGradientHeader(),
          _buildOrderCard(),
          _buildTabs(),
          _buildProductGrid(),
        ],
      ),
    );
  }

  /// 顶部渐变区（297 高）：头像 + 昵称 + VIP 徽章 + 铃铛 + 地址/设置
  Widget _buildGradientHeader() {
    return SizedBox(
      height: 297,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 渐变背景：红 → 浅红 → 页面底色，顶部圆角 65
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(65)),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0, 0.62, 1],
                colors: [
                  Color(0xFFFF5055),
                  Color(0xD6FFAFB1),
                  Color(0xFFF4F7F8),
                ],
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Stack(
              children: [
                // 头像 + 昵称 + VIP 徽章
                Positioned(
                  left: 24,
                  top: 6,
                  child: Row(
                    children: [
                      _buildAvatar(),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '亮太',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 9),
                          _buildVipBadge(),
                        ],
                      ),
                    ],
                  ),
                ),
                // 右上铃铛
                const Positioned(
                  right: 26,
                  top: 12,
                  child: Icon(Icons.notifications_none, size: 26, color: Color(0xFF333333)),
                ),
                // 右上“地址”“设置”
                Positioned(
                  right: 32,
                  top: 45,
                  child: Row(
                    children: [
                      _buildHeaderAction('地址'),
                      const SizedBox(width: 20),
                      _buildHeaderAction('设置'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 头像：椭圆 76x74 #D9D9D9
  Widget _buildAvatar() {
    return ClipOval(
      child: Container(
        width: 76,
        height: 74,
        color: const Color(0xFFD9D9D9),
        alignment: Alignment.center,
        child: const Icon(Icons.person, size: 40, color: Color(0xFF9E9E9E)),
      ),
    );
  }

  /// VIP 会员徽章：59x20 灰底黑字
  Widget _buildVipBadge() {
    return Container(
      width: 59,
      height: 20,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFD9D9D9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Text(
        'VIP会员',
        style: TextStyle(fontSize: 12, color: Colors.black),
      ),
    );
  }

  Widget _buildHeaderAction(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.black,
      ),
    );
  }

  /// 我的订单卡：371 宽 118 高，白底边框 #E2E2E2 圆角 16
  Widget _buildOrderCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      height: 118,
      padding: const EdgeInsets.fromLTRB(13, 11, 13, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E2E2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '我的订单',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              const Spacer(),
              const Text(
                '全部 >',
                style: TextStyle(fontSize: 14, color: Color(0xFF8C96A8)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // 订单状态横幅（占位：正式项目替换为设计稿横幅图）
          Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFFF0F0), Color(0xFFFFE9E0)],
              ),
            ),
            child: const Row(
              children: [
                Text('📦', style: TextStyle(fontSize: 26)),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '待付款 0 · 待发货 0 · 待收货 0',
                        style: TextStyle(fontSize: 13, color: Color(0xFF555555)),
                      ),
                      SizedBox(height: 3),
                      Text(
                        '查看全部订单',
                        style: TextStyle(fontSize: 11, color: Color(0xFF999999)),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, size: 16, color: Color(0xFF999999)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 猜你喜欢 / 我的收藏 Tab + 红色指示条
  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, top: 12),
      child: Row(
        children: [
          _buildTab('猜你喜欢', 0),
          const SizedBox(width: 24),
          _buildTab('我的收藏', 1),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final selected = _tab == index;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _tab = index),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: selected ? const Color(0xFFED2C25) : const Color(0xFF555555),
            ),
          ),
          const SizedBox(height: 6),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 58,
            height: 3,
            decoration: BoxDecoration(
              color: selected ? const Color(0xFFFF5055) : Colors.transparent,
              borderRadius: BorderRadius.circular(1.5),
            ),
          ),
        ],
      ),
    );
  }

  /// 商品推荐网格：2 列，卡 186.5 宽（与首页/设计稿商品卡一致）
  Widget _buildProductGrid() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(9, 12, 9, 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 11,
          mainAxisSpacing: 16,
          childAspectRatio: 186.5 / 302,
        ),
        itemCount: _recommendProducts.length,
        itemBuilder: (context, i) => ProductCard(
          product: _recommendProducts[i],
          reviewCount: _recommendProducts[i].isSpecial ? null : 60,
        ),
      ),
    );
  }
}
