import 'package:flutter/material.dart';

/// 分类页：严格复刻设计稿 3:3
/// 搜索头 + 左侧分类栏（11 项）+ 右侧“酒水饮料”浏览区（banner/热门分类/场景选购）
class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

/// 左侧分类项（与设计稿一致，酒水饮料为默认选中态）
class _CategoryPageState extends State<CategoryPage> {
  static const _sideCategories = [
    '为你推荐',
    '京东超市',
    '手机数码',
    '电脑办公',
    '家用电器',
    '服饰鞋包',
    '美妆个护',
    '酒水饮料',
    '食品生鲜',
    '家居日用',
    '运动户外',
  ];

  /// 热门分类（emoji 占位 + 设计稿底色）
  static const _hotCategories = [
    ('白酒', '🍶', 0xFFFFF0ED),
    ('葡萄酒', '🍷', 0xFFF9EEF3),
    ('啤酒', '🍺', 0xFFFFF5DF),
    ('洋酒', '🥃', 0xFFFAF0E6),
    ('茗茶', '🍵', 0xFFEEF4E9),
    ('咖啡', '☕', 0xFFF4EEE9),
    ('果汁饮料', '🧃', 0xFFFFF1E3),
    ('饮用水', '💧', 0xFFEDF5FA),
    ('牛奶乳品', '🥛', 0xFFF1F0F8),
  ];

  int _selected = 7; // 默认选中“酒水饮料”

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildSearchHeader(),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSidebar(),
                Expanded(child: _buildBrowsingArea()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 搜索头：搜索框 #F6F6F6 圆角 20 + 扫码 icon + 分割线
  Widget _buildSearchHeader() {
    return SafeArea(
      bottom: false,
      child: SizedBox(
        height: 66,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: TextField(
                        style: const TextStyle(fontSize: 14, color: Color(0xFF222222)),
                        textInputAction: TextInputAction.search,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFF6F6F6),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            size: 20,
                            color: Color(0xFF999999),
                          ),
                          hintText: '搜索商品、品牌',
                          hintStyle: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF777777),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.qr_code_scanner, size: 24, color: Color(0xFF222222)),
                ],
              ),
            ),
            Container(height: 1, color: const Color(0xFFECECEC)),
          ],
        ),
      ),
    );
  }

  /// 左侧分类栏：92 宽 #F6F6F6，选中项白底 + 红色指示条
  Widget _buildSidebar() {
    return Container(
      width: 92,
      color: const Color(0xFFF6F6F6),
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: _sideCategories.length,
        itemBuilder: (context, i) {
          final selected = i == _selected;
          return InkWell(
            onTap: () => setState(() => _selected = i),
            child: Container(
              height: 52,
              color: selected ? Colors.white : Colors.transparent,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (selected)
                    const Positioned(
                      left: 0,
                      child: SizedBox(
                        width: 3,
                        height: 20,
                        child: ColoredBox(color: Color(0xFFF31B1B)),
                      ),
                    ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Text(
                        _sideCategories[i],
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                          color: selected ? const Color(0xFFF31B1B) : const Color(0xFF555555),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// 右侧浏览区：标题 + 渐变 banner + 热门分类 + 按场景选购
  Widget _buildBrowsingArea() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题行：酒水饮料 + 全部 >
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              child: Row(
                children: [
                  const Text(
                    '酒水饮料',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF222222),
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    '全部',
                    style: TextStyle(fontSize: 11, color: Color(0xFF777777)),
                  ),
                  const SizedBox(width: 5),
                  const Icon(Icons.chevron_right, size: 14, color: Color(0xFF222222)),
                ],
              ),
            ),
            _buildBanner(),
            const SizedBox(height: 21),
            // 热门分类标题
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    '热门分类',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF222222),
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    '总有一款合心意',
                    style: TextStyle(fontSize: 10, color: Color(0xFF888888)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 17),
            _buildHotGrid(),
            const SizedBox(height: 21),
            // 按场景选购
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '按场景选购',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF222222),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Expanded(
                    child: _SceneCard(
                      title: '送礼有心意',
                      subtitle: '精选礼盒',
                      emoji: '🎁',
                      titleColor: Color(0xFF813D31),
                      subtitleColor: Color(0xFF98685E),
                      background: Color(0xFFFFF3EF),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: _SceneCard(
                      title: '日常好滋味',
                      subtitle: '随心囤好物',
                      emoji: '☕',
                      titleColor: Color(0xFF615844),
                      subtitleColor: Color(0xFF8A816E),
                      background: Color(0xFFF4F3EF),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 渐变 banner：好酒好茶，一站选齐（设计稿 278 宽，自适应缩窄避免小屏溢出）
  Widget _buildBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 102,
        padding: const EdgeInsets.fromLTRB(14, 14, 0, 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            colors: [Color(0xFFFFE3DF), Color(0xFFFFF4E9)],
          ),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '好酒好茶，一站选齐',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF812B20),
                  ),
                ),
                const SizedBox(height: 9),
                const Text(
                  '日常小酌 · 送礼宴请',
                  style: TextStyle(fontSize: 11, color: Color(0xFF9B5D50)),
                ),
                const SizedBox(height: 10),
                Container(
                  width: 82,
                  height: 24,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF31B1B),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '去逛逛',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 5),
                      Icon(Icons.chevron_right, size: 12, color: Colors.white),
                    ],
                  ),
                ),
              ],
            ),
            // 酒杯插图（emoji 占位，正式项目替换为设计稿插图）
            const Positioned(
              right: 20,
              top: 30,
              child: Text('🍷', style: TextStyle(fontSize: 37)),
            ),
          ],
        ),
      ),
    );
  }

  /// 热门分类九宫格：3 列 × 3 行，icon 48x48 圆角 16
  Widget _buildHotGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          for (var row = 0; row < 3; row++)
            Padding(
              padding: EdgeInsets.only(bottom: row == 2 ? 0 : 8),
              child: Row(
                children: [
                  for (var col = 0; col < 3; col++) ...[
                    if (col > 0) const SizedBox(width: 10),
                    Expanded(
                      child: _buildHotItem(_hotCategories[row * 3 + col]),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHotItem((String, String, int) item) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Color(item.$3),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(item.$2, style: const TextStyle(fontSize: 28)),
        ),
        const SizedBox(height: 7),
        Text(
          item.$1,
          style: const TextStyle(fontSize: 12, color: Color(0xFF444444)),
        ),
      ],
    );
  }
}

/// 场景卡：134x70 圆角 10
class _SceneCard extends StatelessWidget {
  const _SceneCard({
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.titleColor,
    required this.subtitleColor,
    required this.background,
  });

  final String title;
  final String subtitle;
  final String emoji;
  final Color titleColor;
  final Color subtitleColor;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.fromLTRB(12, 11, 0, 0),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: 11),
              Text(
                subtitle,
                style: TextStyle(fontSize: 11, color: subtitleColor),
              ),
            ],
          ),
          Positioned(
            right: 12,
            bottom: 13,
            child: Text(emoji, style: const TextStyle(fontSize: 22)),
          ),
        ],
      ),
    );
  }
}
