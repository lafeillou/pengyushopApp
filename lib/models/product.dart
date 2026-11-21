/// 商品
class Product {
  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.desc,
    required this.emoji,
    required this.colorValue,
    this.merchantId,
  });

  final String id;
  final String name;
  final double price;
  final String desc;

  /// 商品图占位 emoji（演示用，正式项目替换为网络图片 URL）
  final String emoji;

  /// 商品图占位底色
  final int colorValue;

  /// 所属线下合作商家 id；为 null 表示平台自营特惠商品
  final String? merchantId;

  /// 是否属于特惠商品展示区（平台自营）
  bool get isSpecial => merchantId == null;
}
