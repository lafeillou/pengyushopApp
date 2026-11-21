import 'dart:math';

/// 经纬度坐标
class LatLng {
  const LatLng(this.lat, this.lng);

  final double lat;
  final double lng;
}

/// 演示用：模拟当前会员所在位置（杭州市中心）。
/// 正式项目应使用定位插件（如 geolocator）获取真实位置。
const mockMemberLocation = LatLng(30.2741, 120.1551);

/// 计算两点间距离（公里，Haversine 公式）
double distanceKm(LatLng a, LatLng b) {
  const earthRadius = 6371.0;
  final dLat = _rad(b.lat - a.lat);
  final dLng = _rad(b.lng - a.lng);
  final h = pow(sin(dLat / 2), 2) +
      cos(_rad(a.lat)) * cos(_rad(b.lat)) * pow(sin(dLng / 2), 2);
  return 2 * earthRadius * asin(sqrt(h.toDouble()));
}

double _rad(double deg) => deg * pi / 180;
