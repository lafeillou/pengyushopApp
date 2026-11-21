import 'product.dart';

/// 线下合作商家（门店）
class Merchant {
  Merchant({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.category,
    required this.address,
    required this.lat,
    required this.lng,
    required this.emoji,
    required this.colorValue,
    this.products = const [],
  });

  final String id;

  /// 商家对应的会员 id（必须先注册成为会员）
  final String ownerId;

  /// 门店名称
  final String name;

  /// 门店分类（餐饮/零售等）
  final String category;

  /// 门店地址
  final String address;

  /// 门店纬度（定位用）
  final double lat;

  /// 门店经度（定位用）
  final double lng;

  /// 门头照占位 emoji（演示用，正式项目替换为门头照片 URL）
  final String emoji;

  /// 门头照占位底色
  final int colorValue;

  /// 门店在售商品（到店/线上购买）
  final List<Product> products;
}
