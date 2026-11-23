import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/tab_notifier.dart';
import 'cart_page.dart';
import 'category_page.dart';
import 'home_page.dart';
import 'nearby_page.dart';
import 'profile_page.dart';

/// 主框架：底部五个 Tab（首页 / 附近 / 分类 / 购物车 / 个人中心）
/// 底部导航样式还原首页设计稿：
/// 白底 + 顶部 1px 分割线（#ECECEC）+ 底部圆角 26，
/// 选中红色 #F31B1B，未选中 #777777
class MainShell extends StatelessWidget {
  const MainShell({super.key});

  static const _pages = [
    HomePage(),
    NearbyPage(),
    CategoryPage(),
    CartPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final tabIndex = context.watch<TabIndexNotifier>().index;
    return Scaffold(
      body: IndexedStack(index: tabIndex, children: _pages),
      bottomNavigationBar: _DesignBottomNav(
        index: tabIndex,
        onTap: (i) => context.read<TabIndexNotifier>().select(i),
      ),
    );
  }
}

/// 设计稿样式底部导航
class _DesignBottomNav extends StatelessWidget {
  const _DesignBottomNav({required this.index, required this.onTap});

  /// 设计稿选中色 / 未选中色
  static const _activeColor = Color(0xFFF31B1B);
  static const _inactiveColor = Color(0xFF777777);

  /// (未选中 icon, 选中 icon, 文字)
  static const _items = [
    (Icons.home_outlined, Icons.home, '首页'),
    (Icons.location_on_outlined, Icons.location_on, '附近'),
    (Icons.grid_view_outlined, Icons.grid_view, '分类'),
    (Icons.shopping_cart_outlined, Icons.shopping_cart, '购物车'),
    (Icons.person_outline, Icons.person, '个人中心'),
  ];

  final int index;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        // 设计稿底部圆角 26
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(26)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 顶部分割线（设计稿 1px #ECECEC）
          const SizedBox(
            width: double.infinity,
            height: 1,
            child: ColoredBox(color: Color(0xFFECECEC)),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              children: [
                for (var i = 0; i < _items.length; i++)
                  Expanded(
                    child: _NavItem(
                      icon: i == index ? _items[i].$2 : _items[i].$1,
                      label: _items[i].$3,
                      selected: i == index,
                      onTap: () => onTap(i),
                    ),
                  ),
              ],
            ),
          ),
          // 底部安全区（设计稿 tab 总高 81 中的底部留白）
          const SafeArea(top: false, child: SizedBox(height: 15)),
        ],
      ),
    );
  }
}

/// 底部导航单项：icon 24 + 5 间距 + 文字 11px
class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? _DesignBottomNav._activeColor
        : _DesignBottomNav._inactiveColor;
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              // 设计稿：选中文字 400 / 未选中 500
              fontWeight: selected ? FontWeight.w400 : FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
