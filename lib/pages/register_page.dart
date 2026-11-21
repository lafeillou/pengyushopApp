import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../services/auth_service.dart';
import 'main_shell.dart';

/// 注册页：注册成功即成为「注册会员」
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _obscure = true;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _register() {
    if (_passwordController.text != _confirmController.text) {
      _toast('两次输入的密码不一致');
      return;
    }
    final error = context.read<AuthService>().register(
          phone: _phoneController.text.trim(),
          name: _nameController.text,
          password: _passwordController.text,
        );
    if (error != null) {
      _toast(error);
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('注册成功！您已成为「注册会员」，完成首笔消费后自动升格为「普通会员」')),
      );
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainShell()),
      (route) => false,
    );
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        title: const Text('注册会员'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7F0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  '本平台实行会员制：消费前需注册成为平台会员。\n注册成功即为「注册会员」，完成首笔消费后自动升格为「普通会员」。',
                  style: TextStyle(fontSize: 12, color: Color(0xFFB26A00), height: 1.6),
                ),
              ),
              const SizedBox(height: 20),
              _field(_nameController, Icons.person_outline, '请输入昵称'),
              const SizedBox(height: 14),
              _field(_phoneController, Icons.phone_android, '请输入 11 位手机号',
                  keyboardType: TextInputType.phone),
              const SizedBox(height: 14),
              _field(_passwordController, Icons.lock_outline, '请输入密码（至少 6 位）',
                  obscure: _obscure),
              const SizedBox(height: 14),
              _field(_confirmController, Icons.lock_outline, '请再次输入密码',
                  obscure: _obscure),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(23),
                    ),
                  ),
                  onPressed: _register,
                  child: const Text('注册并登录', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    IconData icon,
    String hint, {
    bool obscure = false,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.grey, size: 20),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(23),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
