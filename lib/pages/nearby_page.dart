import 'package:flutter/material.dart';

/// 附近页：严格复刻设计稿 20:271
/// 顶栏（返回 + 标题 + 地址 + 搜索）+ 好吃/好玩 Tab + 附近新店列表
class NearbyPage extends StatefulWidget {
  const NearbyPage({super.key});

  @override
  State<NearbyPage> createState() => _NearbyPageState();
}

/// 附近店铺静态数据（与设计稿一致）
class _NearbyShop {
  const _NearbyShop({
    required this.name,
    required this.rating,
    required this.reviewCount,
    required this.avgPrice,
    required this.category,
    required this.area,
    required this.distance,
    required this.badge,
    required this.emoji,
    required this.colorValue,
    this.checkins,
  });

  final String name;
  final double rating;
  final int reviewCount;
  final int avgPrice;
  final String category;
  final String area;
  final String distance;

  /// 榜单文案（如“榜  江夏区川菜新店榜 · 第2名”）
  final String badge;

  final String emoji;
  final int colorValue;

  /// 打卡数；为 null 表示无打卡热度行（与设计稿湘悦情一致）
  final int? checkins;
}

class _NearbyPageState extends State<NearbyPage> {
  static const _shops = [
    _NearbyShop(
      name: '塞釜纪铁锅焖面·石锅鸡公煲',
      rating: 3.7,
      reviewCount: 50,
      avgPrice: 17,
      category: '川菜馆',
      area: '光谷/东湖高新区',
      distance: '2.7km',
      badge: '榜  江夏区川菜新店榜 · 第2名',
      emoji: '🍜',
      colorValue: 0xFFF3A24A,
      checkins: 20,
    ),
    _NearbyShop(
      name: '橙小诺东北米线',
      rating: 3.9,
      reviewCount: 14,
      avgPrice: 18,
      category: '粉面馆',
      area: '雄楚大道',
      distance: '2.9km',
      badge: '榜  雄楚大道美食新店榜 · 第10名',
      emoji: '🍜',
      colorValue: 0xFFE8B93E,
      checkins: 2,
    ),
    _NearbyShop(
      name: '湘悦情餐饮店',
      rating: 3.6,
      reviewCount: 9,
      avgPrice: 20,
      category: '湘菜',
      area: '江夏区',
      distance: '2.3km',
      badge: '榜  江夏区湘菜新店榜 · 第2名',
      emoji: '🥘',
      colorValue: 0xFFD95C4A,
    ),
    _NearbyShop(
      name: '穆疆山清真旋转火锅',
      rating: 3.6,
      reviewCount: 5,
      avgPrice: 21,
      category: '小火锅',
      area: '光谷天地',
      distance: '1.6km',
      badge: '榜  洪山区小火锅新店榜 · 第3名',
      emoji: '🍲',
      colorValue: 0xFFB3543B,
      checkins: 1,
    ),
    _NearbyShop(
      name: '学长大盘鸡',
      rating: 4.1,
      reviewCount: 51,
      avgPrice: 30,
      category: '新疆菜',
      area: '雄楚大道',
      distance: '2.9km',
      badge: '榜  洪山区新疆菜好评榜 · 第2名',
      emoji: '🍗',
      colorValue: 0xFFC87E3C,
      checkins: 22,
    ),
  ];

  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildTopBar(),
          _buildTabs(),
          Expanded(child: _buildShopList()),
        ],
      ),
    );
  }

  /// 顶栏：返回 + 标题 + 位置/地址 + 搜索（与设计稿 45 高一致）
  Widget _buildTopBar() {
    return SafeArea(
      bottom: false,
      child: SizedBox(
        height: 45,
        child: Row(
          children: [
            const SizedBox(width: 12),
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
            const Text(
              '附近（10）',
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
            const SizedBox(width: 12),
            const Icon(Icons.search, size: 22, color: Color(0xFF202024)),
            const SizedBox(width: 13),
          ],
        ),
      ),
    );
  }

  /// 好吃/好玩 Tab + 选中红色指示条
  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        children: [
          const SizedBox(width: 34),
          _buildTab('好吃', 0),
          const SizedBox(width: 60),
          _buildTab('好玩', 1),
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: selected ? const Color(0xFFED2C25) : const Color(0xFF555555),
            ),
          ),
          const SizedBox(height: 4),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 26,
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

  /// 附近新店列表（5 家店铺，与设计稿数据一致）
  Widget _buildShopList() {
    return ListView.separated(
      padding: const EdgeInsets.only(top: 12, bottom: 16),
      itemCount: _shops.length,
      separatorBuilder: (_, _) => const SizedBox(height: 0),
      itemBuilder: (context, i) => _ShopCard(shop: _shops[i]),
    );
  }
}

/// 店铺卡：图 78x78 + 店名 + 评分 + 分类/距离 + 榜单标签 + 打卡热度
class _ShopCard extends StatelessWidget {
  const _ShopCard({required this.shop});

  final _NearbyShop shop;

  /// 设计稿星级：实心星 #FF6937 / 灰星 #D9DCDF（四舍五入取整）
  static const _starOn = Color(0xFFFF6937);
  static const _starOff = Color(0xFFD9DCDF);
  static const _metaColor = Color(0xFF8390A7);

  @override
  Widget build(BuildContext context) {
    final filled = shop.rating.round().clamp(0, 5);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        children: [
          SizedBox(
            height: 109,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 7),
                  child: _buildImage(),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        shop.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF222222),
                        ),
                      ),
                      const SizedBox(height: 4),
                      _buildRatingRow(filled),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '${shop.category} ${shop.area}',
                            style: const TextStyle(
                              fontSize: 10.5,
                              color: _metaColor,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            shop.distance,
                            style: const TextStyle(
                              fontSize: 10.5,
                              color: _metaColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      _buildBadge(),
                      if (shop.checkins != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.local_fire_department,
                              size: 11,
                              color: Color(0xFF293044),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '${shop.checkins}打卡',
                              style: const TextStyle(
                                fontSize: 10.5,
                                color: Color(0xFF293044),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          // 店铺分隔线（文字列起，与设计稿一致）
          Padding(
            padding: const EdgeInsets.only(left: 88),
            child: Container(height: 1, color: const Color(0xFFF3F4F6)),
          ),
        ],
      ),
    );
  }

  /// 店铺图占位（渐变 + emoji，正式项目替换为网络图片）
  Widget _buildImage() {
    final base = Color(shop.colorValue);
    final dark = Color.lerp(base, Colors.black, 0.35)!;
    return Container(
      width: 78,
      height: 78,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [base, dark],
        ),
      ),
      alignment: Alignment.center,
      child: Text(shop.emoji, style: const TextStyle(fontSize: 36)),
    );
  }

  /// ★★★★ + ★ + 分数 + N条 + ¥x/人
  Widget _buildRatingRow(int filled) {
    return Row(
      children: [
        for (var i = 0; i < 5; i++)
          Text(
            '★',
            style: TextStyle(
              fontSize: 11.5,
              color: i < filled ? _starOn : _starOff,
            ),
          ),
        const SizedBox(width: 3),
        Text(
          shop.rating.toStringAsFixed(1),
          style: const TextStyle(fontSize: 10.5, color: _starOn),
        ),
        const SizedBox(width: 6),
        Text(
          '${shop.reviewCount}条',
          style: const TextStyle(fontSize: 10.5, color: _metaColor),
        ),
        const SizedBox(width: 7),
        Text(
          '¥${shop.avgPrice}/人',
          style: const TextStyle(fontSize: 10.5, color: _metaColor),
        ),
      ],
    );
  }

  /// 新店榜单标签：#FFF0E1 底 + #B96530 文字
  Widget _buildBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0E1),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(
        shop.badge,
        style: const TextStyle(fontSize: 9.5, color: Color(0xFFB96530)),
      ),
    );
  }
}
