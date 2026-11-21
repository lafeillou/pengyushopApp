import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'pages/splash_page.dart';
import 'services/auth_service.dart';
import 'services/member_service.dart';
import 'services/merchant_service.dart';
import 'services/payment_service.dart';
import 'services/red_packet_service.dart';
import 'services/wallet_service.dart';
import 'state/tab_notifier.dart';

void main() {
  runApp(const PengyuApp());
}

/// 应用主题色（京东红）
const kPrimaryColor = Color(0xFFE4393C);

class PengyuApp extends StatelessWidget {
  const PengyuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => WalletService()),
        ChangeNotifierProvider(
          create: (ctx) => RedPacketService(ctx.read<AuthService>()),
        ),
        Provider(
          create: (ctx) => MemberService(ctx.read<AuthService>()),
        ),
        ChangeNotifierProvider(
          create: (ctx) => PaymentService(
            wallet: ctx.read<WalletService>(),
            redPackets: ctx.read<RedPacketService>(),
            members: ctx.read<MemberService>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (ctx) => MerchantService(ctx.read<AuthService>()),
        ),
        ChangeNotifierProvider(create: (_) => TabIndexNotifier()),
      ],
      child: MaterialApp(
        title: '鹏宇商城',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: kPrimaryColor),
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFF5F5F5),
          appBarTheme: const AppBarTheme(
            backgroundColor: kPrimaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
          ),
        ),
        home: const SplashPage(),
      ),
    );
  }
}
