/// 支付方式：
/// - 零钱支付（来源于会员充值、平台拨付）
/// - 微信支付 / 支付宝支付
/// - 红包券支付（红包券账户余额）
/// - 混合支付（仅支持零钱 + 红包券，按比例支付）
enum PaymentMethodType {
  balance('零钱支付', 'account_balance_wallet_outlined'),
  wechat('微信支付', 'chat'),
  alipay('支付宝支付', 'account_balance'),
  redPacket('红包券支付', 'card_giftcard'),
  mixed('混合支付（零钱+红包券）', 'currency_exchange');

  const PaymentMethodType(this.label, this.icon);

  final String label;
  final String icon;
}

/// 订单
class Order {
  Order({
    required this.id,
    required this.memberId,
    required this.subject,
    required this.totalAmount,
    required this.method,
    required this.balancePaid,
    required this.redPacketPaid,
    required this.isSpecialZone,
    required this.createdAt,
  });

  final String id;

  /// 下单会员 id
  final String memberId;

  /// 订单标题（商品名 / 到店消费-门店名）
  final String subject;

  /// 订单总额
  final double totalAmount;

  /// 支付方式
  final PaymentMethodType method;

  /// 零钱支付金额（混合支付时为其中零钱部分）
  final double balancePaid;

  /// 红包券支付金额（混合支付时为其中红包券部分）
  final double redPacketPaid;

  /// 是否特惠商品区线上订单（此类订单消费后产生红包发放）
  final bool isSpecialZone;

  final DateTime createdAt;
}

/// 支付结果
class PaymentResult {
  const PaymentResult.success(this.order)
      : success = true,
        message = '支付成功';

  const PaymentResult.failure(this.message)
      : success = false,
        order = null;

  final bool success;
  final String message;
  final Order? order;
}
