import 'dart:math';

import 'package:flutter/foundation.dart';

import '../models/member.dart';
import '../models/merchant.dart';
import '../utils/geo.dart';
import 'auth_service.dart';
import 'seed_data.dart';

/// 线下合作商家服务：
/// - 商家展示按距离会员由近到远排列；
/// - 会员（须先注册成为平台会员）可申请成为合作商家。
class MerchantService extends ChangeNotifier {
  MerchantService(this._auth) {
    _merchants.addAll(seedMerchants());
  }

  final AuthService _auth;
  final List<Merchant> _merchants = [];

  List<Merchant> get all => List.unmodifiable(_merchants);

  /// 按离会员距离由近到远排序
  List<Merchant> sortedByDistance() {
    final list = [..._merchants];
    list.sort((a, b) => distanceToMe(a).compareTo(distanceToMe(b)));
    return list;
  }

  /// 商家与会员之间的距离（公里）
  double distanceToMe(Merchant m) =>
      distanceKm(mockMemberLocation, LatLng(m.lat, m.lng));

  Merchant? byId(String id) {
    for (final m in _merchants) {
      if (m.id == id) return m;
    }
    return null;
  }

  /// 会员名下的门店
  Merchant? byOwnerId(String ownerId) {
    for (final m in _merchants) {
      if (m.ownerId == ownerId) return m;
    }
    return null;
  }

  /// 会员申请成为合作商家（演示环境自动通过）。
  /// 成功返回 null，失败返回错误信息。
  String? apply({
    required Member owner,
    required String name,
    required String category,
    required String address,
    required String emoji,
    required int colorValue,
  }) {
    if (name.trim().isEmpty) return '请填写门店名称';
    if (address.trim().isEmpty) return '请填写门店地址';
    if (byOwnerId(owner.id) != null) return '您已是合作商家';

    // 模拟定位：在会员当前位置附近生成门店坐标（正式项目由地图选点获得）
    final rng = Random();
    final merchant = Merchant(
      id: 'm${DateTime.now().microsecondsSinceEpoch}',
      ownerId: owner.id,
      name: name.trim(),
      category: category,
      address: address.trim(),
      lat: mockMemberLocation.lat + rng.nextDouble() * 0.01,
      lng: mockMemberLocation.lng + rng.nextDouble() * 0.01,
      emoji: emoji,
      colorValue: colorValue,
    );
    _merchants.add(merchant);
    owner.role = MemberRole.merchant;
    _auth.refresh();
    notifyListeners();
    return null;
  }
}
