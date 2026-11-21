import 'package:flutter_test/flutter_test.dart';
import 'package:pengyu_shop/models/membership_level.dart';
import 'package:pengyu_shop/models/order.dart';
import 'package:pengyu_shop/services/auth_service.dart';
import 'package:pengyu_shop/services/member_service.dart';
import 'package:pengyu_shop/services/merchant_service.dart';
import 'package:pengyu_shop/services/payment_service.dart';
import 'package:pengyu_shop/services/red_packet_service.dart';
import 'package:pengyu_shop/services/wallet_service.dart';

void main() {
  group('会员体系', () {
    test('注册成功即为注册会员，首笔消费后自动升格为普通会员', () {
      final auth = AuthService();
      final error = auth.register(
        phone: '13900000001',
        name: '测试会员',
        password: '123456',
      );
      expect(error, isNull);
      final member = auth.current!;
      expect(member.level, MembershipLevel.registered);

      final wallet = WalletService();
      final redPackets = RedPacketService(auth);
      final members = MemberService(auth);
      final payment = PaymentService(
        wallet: wallet,
        redPackets: redPackets,
        members: members,
      );
      wallet.recharge(memberId: member.id, amount: 100, channel: '微信');

      final result = payment.pay(
        memberId: member.id,
        amount: 50,
        method: PaymentMethodType.balance,
        subject: '测试商品',
      );
      expect(result.success, isTrue);
      expect(member.level, MembershipLevel.normal);
      expect(wallet.balanceOf(member.id), 50);
    });

    test('后台可设置会员级别升降级', () {
      final auth = AuthService();
      auth.register(phone: '13900000002', name: '测试会员2', password: '123456');
      final member = auth.current!;
      final members = MemberService(auth);

      members.setLevel(member.id, MembershipLevel.star3);
      expect(member.level, MembershipLevel.star3);
      members.setLevel(member.id, MembershipLevel.star1);
      expect(member.level, MembershipLevel.star1);
    });
  });

  group('红包体系', () {
    test('特惠区消费后按规则生成红包，当天可领，逾期未领取视为放弃', () {
      final auth = AuthService();
      auth.register(phone: '13900000003', name: '测试会员3', password: '123456');
      final member = auth.current!;
      final wallet = WalletService();
      final redPackets = RedPacketService(auth);
      final members = MemberService(auth);
      final payment = PaymentService(
        wallet: wallet,
        redPackets: redPackets,
        members: members,
      );
      redPackets.config.days = 3;
      redPackets.config.dailyAmount = 2.0;
      wallet.recharge(memberId: member.id, amount: 100, channel: '微信');

      final result = payment.pay(
        memberId: member.id,
        amount: 30,
        method: PaymentMethodType.balance,
        subject: '特惠商品',
        generateRedPacket: true,
      );
      expect(result.success, isTrue);

      // 生成 3 个红包（当天 + 后两天）
      expect(redPackets.packetsOf(member.id).length, 3);
      // 当天可领 1 个
      final claimable = redPackets.claimableToday(member.id);
      expect(claimable.length, 1);

      // 领取后进入红包券账户
      expect(redPackets.claim(claimable.first.id), isTrue);
      expect(redPackets.accountOf(member.id), 2.0);
      // 重复领取失败
      expect(redPackets.claim(claimable.first.id), isFalse);

      // 模拟三天后：剩余两个红包均已过期作废
      redPackets.refreshExpired(
        member.id,
        now: DateTime.now().add(const Duration(days: 3)),
      );
      final packets = redPackets.packetsOf(member.id);
      expect(
        packets.where((p) => p.status.name == 'forfeited').length,
        2,
      );
    });

    test('红包券可在会员之间相互转让', () {
      final auth = AuthService();
      auth.register(phone: '13900000004', name: '测试会员4', password: '123456');
      final from = auth.current!;
      auth.register(phone: '13900000005', name: '测试会员5', password: '123456');
      final to = auth.current!;
      final wallet = WalletService();
      final redPackets = RedPacketService(auth);
      final members = MemberService(auth);
      final payment = PaymentService(
        wallet: wallet,
        redPackets: redPackets,
        members: members,
      );
      redPackets.config.days = 1;
      redPackets.config.dailyAmount = 10.0;
      wallet.recharge(memberId: from.id, amount: 100, channel: '微信');
      payment.pay(
        memberId: from.id,
        amount: 20,
        method: PaymentMethodType.balance,
        subject: '特惠商品',
        generateRedPacket: true,
      );
      redPackets.claimAllToday(from.id);
      expect(redPackets.accountOf(from.id), 10.0);

      // 转让 6 元给 to
      final error = redPackets.transfer(
        fromId: from.id,
        toPhone: to.phone,
        amount: 6,
      );
      expect(error, isNull);
      expect(redPackets.accountOf(from.id), 4.0);
      expect(redPackets.accountOf(to.id), 6.0);

      // 余额不足转让失败
      expect(
        redPackets.transfer(fromId: from.id, toPhone: to.phone, amount: 100),
        isNotNull,
      );
      // 转让给自己失败
      expect(
        redPackets.transfer(fromId: from.id, toPhone: from.phone, amount: 1),
        isNotNull,
      );
      // 不存在的会员失败
      expect(
        redPackets.transfer(fromId: from.id, toPhone: '13700000000', amount: 1),
        isNotNull,
      );
    });
  });

  group('支付体系', () {
    test('零钱/红包券/混合支付及余额校验', () {
      final auth = AuthService();
      auth.register(phone: '13900000006', name: '测试会员6', password: '123456');
      final member = auth.current!;
      final wallet = WalletService();
      final redPackets = RedPacketService(auth);
      final members = MemberService(auth);
      final payment = PaymentService(
        wallet: wallet,
        redPackets: redPackets,
        members: members,
      );
      wallet.recharge(memberId: member.id, amount: 10, channel: '微信');
      // 通过红包收入模拟红包券余额 5 元
      auth.register(phone: '13900000007', name: '测试会员7', password: '123456');
      final giver = auth.current!;
      redPackets.config.days = 1;
      redPackets.config.dailyAmount = 5.0;
      wallet.recharge(memberId: giver.id, amount: 100, channel: '微信');
      payment.pay(
        memberId: giver.id,
        amount: 20,
        method: PaymentMethodType.balance,
        subject: '特惠商品',
        generateRedPacket: true,
      );
      redPackets.claimAllToday(giver.id);
      redPackets.transfer(fromId: giver.id, toPhone: member.phone, amount: 5);
      expect(redPackets.accountOf(member.id), 5.0);

      // 混合支付 10 元，零钱 60%（6 元）+ 红包券 40%（4 元）
      final mixed = payment.pay(
        memberId: member.id,
        amount: 10,
        method: PaymentMethodType.mixed,
        subject: '混合支付测试',
        balanceRatio: 0.6,
      );
      expect(mixed.success, isTrue);
      expect(mixed.order!.balancePaid, 6.0);
      expect(mixed.order!.redPacketPaid, 4.0);
      expect(wallet.balanceOf(member.id), 4.0);
      expect(redPackets.accountOf(member.id), 1.0);

      // 零钱不足的混合支付失败
      final fail = payment.pay(
        memberId: member.id,
        amount: 10,
        method: PaymentMethodType.mixed,
        subject: '混合支付测试',
        balanceRatio: 0.9,
      );
      expect(fail.success, isFalse);

      // 红包券支付余额不足失败
      final failRp = payment.pay(
        memberId: member.id,
        amount: 10,
        method: PaymentMethodType.redPacket,
        subject: '红包券支付测试',
      );
      expect(failRp.success, isFalse);

      // 微信/支付宝模拟成功
      expect(
        payment
            .pay(
              memberId: member.id,
              amount: 10,
              method: PaymentMethodType.wechat,
              subject: '微信支付测试',
            )
            .success,
        isTrue,
      );
      expect(
        payment
            .pay(
              memberId: member.id,
              amount: 10,
              method: PaymentMethodType.alipay,
              subject: '支付宝支付测试',
            )
            .success,
        isTrue,
      );
    });
  });

  group('合作商家', () {
    test('商家按距离由近到远排序', () {
      final auth = AuthService();
      final merchants = MerchantService(auth).sortedByDistance();
      expect(merchants.length, greaterThanOrEqualTo(5));
      for (var i = 1; i < merchants.length; i++) {
        final service = MerchantService(auth);
        expect(
          service.distanceToMe(merchants[i - 1]),
          lessThanOrEqualTo(service.distanceToMe(merchants[i])),
        );
      }
    });

    test('会员可申请成为合作商家', () {
      final auth = AuthService();
      auth.register(phone: '13900000008', name: '测试会员8', password: '123456');
      final member = auth.current!;
      final service = MerchantService(auth);

      final error = service.apply(
        owner: member,
        name: '测试小店',
        category: '零售',
        address: '杭州市测试路 1 号',
        emoji: '🛒',
        colorValue: 0xFF66BB6A,
      );
      expect(error, isNull);
      expect(member.role.name, 'merchant');
      expect(service.byOwnerId(member.id), isNotNull);
      // 重复申请失败
      expect(
        service.apply(
          owner: member,
          name: '测试小店2',
          category: '零售',
          address: '杭州市测试路 2 号',
          emoji: '🛒',
          colorValue: 0xFF66BB6A,
        ),
        isNotNull,
      );
    });
  });
}
