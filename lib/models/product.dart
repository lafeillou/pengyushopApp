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
    this.category,
    this.isGlobal = false,
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

  /// 首页分类（对应首页分类导航：数码/家居/…）；为 null 时仅出现在“推荐”聚合流
  final String? category;

  /// 是否全球购商品（首页商品卡展示“全球购”标签）
  final bool isGlobal;

  /// 是否属于特惠商品展示区（平台自营）
  bool get isSpecial => merchantId == null;
}

/// 首页分类导航（与首页设计稿一致，“推荐”为默认聚合流）
const homeCategories = ['推荐', '男装', '数码', '鞋类', '美妆', '饰品', '图书', '家居'];
