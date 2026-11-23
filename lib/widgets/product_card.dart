import 'package:flutter/material.dart';

import '../models/product.dart';
import '../pages/product_detail_page.dart';

/// 商品推荐卡片（首页设计稿样式，分类页共用）
/// 方形主图 + 全球购标签 + 两行标题 + 价格 + 物流标签/评论数 + 看相似按钮
class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product, this.reviewCount});

  /// 设计稿价格红
  static const priceRed = Color(0xFFFF4B45);

  final Product product;

  /// 评论数；为 null 时由商品 id 稳定生成（演示用）
  final int? reviewCount;

  /// 演示用评论数（由商品 id 稳定生成）
  int get _reviewCount =>
      reviewCount ??
      product.id.codeUnits.fold(0, (a, b) => a + b) % 160 + 15;

  void _openDetail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ProductDetailPage(product: product)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final base = Color(product.colorValue);
    final light = Color.lerp(base, Colors.white, 0.78)!;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(9),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openDetail(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 商品主图（占位：浅色底 + emoji，正式项目替换为网络图片）
            AspectRatio(
              aspectRatio: 1,
              child: Container(
                color: light,
                alignment: Alignment.center,
                child: Text(
                  product.emoji,
                  style: const TextStyle(fontSize: 60),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(11, 9, 11, 9),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTitle(),
                    const Spacer(),
                    _buildPrice(),
                    const Spacer(),
                    _buildBottomRow(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 两行标题；全球购商品在首行前插入“全球购”紫色标签
  Widget _buildTitle() {
    return Text.rich(
      TextSpan(
        children: [
          if (product.isGlobal) ...[
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                decoration: BoxDecoration(
                  color: const Color(0xFF7C42F8),
                  borderRadius: BorderRadius.circular(1),
                ),
                child: const Text(
                  '全球购',
                  style: TextStyle(fontSize: 11, color: Colors.white),
                ),
              ),
            ),
            const TextSpan(text: '  '),
          ],
          TextSpan(text: product.name),
        ],
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontSize: 14,
        height: 1.2,
        color: Color(0xFF555555),
      ),
    );
  }

  Widget _buildPrice() {
    return Text(
      '¥${product.price.toStringAsFixed(2)}',
      style: const TextStyle(
        fontSize: 22,
        height: 1.21,
        color: priceRed,
      ),
    );
  }

  /// 底部行：平台自营显示“鹏宇物流”标签，商家商品显示评论数；右侧“看相似”按钮
  Widget _buildBottomRow(BuildContext context) {
    return Row(
      children: [
        if (product.isSpecial)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 2.5, vertical: 0.5),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF0F0),
              borderRadius: BorderRadius.circular(1),
            ),
            child: const Text(
              '鹏宇物流',
              style: TextStyle(fontSize: 11, color: Color(0xFFEA8383)),
            ),
          )
        else
          Text(
            '$_reviewCount条评论',
            style: const TextStyle(fontSize: 12, color: Color(0xFF999999)),
          ),
        const Spacer(),
        Material(
          color: const Color(0xFFF3F3F3),
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: () => _openDetail(context),
            borderRadius: BorderRadius.circular(12),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              child: Text(
                '看相似',
                style: TextStyle(fontSize: 12, color: Color(0xFF555555)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
