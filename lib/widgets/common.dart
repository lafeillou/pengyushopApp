import 'package:flutter/material.dart';

import '../models/membership_level.dart';
import '../utils/format.dart';

/// 会员级别徽章
class LevelBadge extends StatelessWidget {
  const LevelBadge(this.level, {super.key, this.compact = false});

  final MembershipLevel level;
  final bool compact;

  Color get _color => switch (level) {
        MembershipLevel.registered => Colors.blueGrey,
        MembershipLevel.normal => const Color(0xFF43A047),
        MembershipLevel.star1 => const Color(0xFF1E88E5),
        MembershipLevel.star2 => const Color(0xFF8E24AA),
        MembershipLevel.star3 => const Color(0xFFF57C00),
        MembershipLevel.star4 => const Color(0xFFE53935),
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 2 : 3,
      ),
      decoration: BoxDecoration(
        color: _color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        level.label,
        style: TextStyle(
          color: Colors.white,
          fontSize: compact ? 10 : 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// 商品/门头照占位图（演示用，正式项目替换为网络图片）
class StoreImage extends StatelessWidget {
  const StoreImage({
    super.key,
    required this.emoji,
    required this.colorValue,
    this.size,
    this.radius = 12,
    this.emojiSize,
  });

  final String emoji;
  final int colorValue;
  final double? size;
  final double radius;
  final double? emojiSize;

  @override
  Widget build(BuildContext context) {
    final base = Color(colorValue);
    final dark = Color.lerp(base, Colors.black, 0.35)!;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [base, dark],
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        emoji,
        style: TextStyle(fontSize: emojiSize ?? (size != null ? size! * 0.45 : 28)),
      ),
    );
  }
}

/// 金额文本（红色醒目）
class MoneyText extends StatelessWidget {
  const MoneyText(this.amount, {super.key, this.fontSize = 16, this.color});

  final double amount;
  final double fontSize;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      formatMoney(amount),
      style: TextStyle(
        color: color ?? const Color(0xFFE53935),
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

/// 空数据提示
class EmptyView extends StatelessWidget {
  const EmptyView({super.key, required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Icon(icon, size: 44, color: Colors.grey.shade400),
          const SizedBox(height: 8),
          Text(
            text,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

/// 白底圆角卡片
class SectionCard extends StatelessWidget {
  const SectionCard({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}

/// 区块标题
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key, this.trailing});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 14,
            decoration: BoxDecoration(
              color: const Color(0xFFE53935),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          ?trailing,
        ],
      ),
    );
  }
}
