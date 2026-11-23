import 'package:flutter/material.dart';

import '../models/product.dart';
import '../services/seed_data.dart';
import '../widgets/common.dart';
import '../widgets/product_card.dart';

/// 首页：严格按设计稿实现的多商户商城首页
/// ① 红色搜索区（#FF5055）+ 浅灰圆角搜索框
/// ② 分类导航：推荐 / 男装 / 数码 / 鞋类 / 美妆 / 饰品 / 图书 / 家居
/// ③ 商品推荐：双列商品卡（全球购标签 / 价格 / 物流标签或评论数 / 看相似按钮）
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /// 设计稿主红（红色渐变背景）
  static const _primary = Color(0xFFFF5055);

  /// 全部在售商品：多商户聚合（平台自营 + 线下合作商家）
  static final List<Product> _allProducts = [
    ...specialZoneProducts,
    ...merchantProducts.values.expand((e) => e),
  ];

  String _category = '推荐';
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// 按分类与搜索词过滤商品
  List<Product> get _visibleProducts {
    var list = _allProducts;
    if (_category != '推荐') {
      list = list.where((p) => p.category == _category).toList();
    }
    final q = _query.trim();
    if (q.isNotEmpty) {
      list = list
          .where((p) => p.name.contains(q) || p.desc.contains(q))
          .toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildSearchHeader(),
          _buildCategoryNav(),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  /// 红色搜索区：沉浸式状态栏 + 浅灰圆角搜索框
  Widget _buildSearchHeader() {
    return Container(
      color: _primary,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 7, 10, 7),
          child: SizedBox(
            height: 34,
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _query = v),
              style: const TextStyle(fontSize: 14, color: Color(0xFF333333)),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF8F8F8),
                isDense: true,
                contentPadding: EdgeInsets.zero,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(17),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  size: 20,
                  color: Color(0xFF888888),
                ),
                hintText: '金龙鱼调和油',
                hintStyle: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF888888),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 分类导航：白底横向 8 分类，选中项红色加粗 + 红色指示条
  Widget _buildCategoryNav() {
    return Container(
      height: 40,
      color: Colors.white,
      child: Row(
        children: [
          for (final c in homeCategories)
            Expanded(
              child: _CategoryItem(
                label: c,
                selected: c == _category,
                onTap: () => setState(() => _category = c),
              ),
            ),
        ],
      ),
    );
  }

  /// 商品推荐双列网格（设计稿：左右留白 9、纵向间距 6、顶距 2）
  Widget _buildContent() {
    final products = _visibleProducts;
    return CustomScrollView(
      slivers: [
        if (products.isEmpty)
          const SliverToBoxAdapter(
            child: EmptyView(icon: Icons.search_off, text: '未找到相关商品'),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(9, 2, 9, 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 11,
                mainAxisSpacing: 6,
                // 设计稿商品卡比例 186.5 : 302，留 0.5 像素余量避免溢出
                childAspectRatio: 0.616,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, i) => ProductCard(product: products[i]),
                childCount: products.length,
              ),
            ),
          ),
      ],
    );
  }
}

/// 分类导航单项
class _CategoryItem extends StatelessWidget {
  const _CategoryItem({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: selected ? 15 : 14,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
              color: selected
                  ? _HomePageState._primary
                  : const Color(0xFF555555),
            ),
          ),
          const SizedBox(height: 3),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: selected ? 21 : 0,
            height: 3,
            decoration: BoxDecoration(
              color: _HomePageState._primary,
              borderRadius: BorderRadius.circular(1.5),
            ),
          ),
        ],
      ),
    );
  }
}
