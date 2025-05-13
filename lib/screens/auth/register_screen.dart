import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../database/db_operations.dart';
import '../../models/user.dart';
import '../../utils/shared_prefs.dart';
import '../../utils/widgets/custom_button.dart';
import '../../utils/widgets/custom_textfield.dart';
import '../home_screen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _displayNameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('两次输入的密码不一致')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final dbOps = Provider.of<DBOperations>(context, listen: false);

    // 检查邮箱是否已存在
    final existingUser = await dbOps.getUserByEmail(_emailController.text.trim());
    if (existingUser != null) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('该邮箱已被注册')),
      );
      return;
    }

    final user = AppUser(
      id: 0,
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      displayName: _displayNameController.text.trim(),
      createdAt: DateTime.now().toString(),
    );

    final userId = await dbOps.createUser(user);

    setState(() => _isLoading = false);

    if (userId > 0) {
      await SharedPrefs.setLoggedInUserId(userId);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(userId: userId),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('注册失败，请重试')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('注册')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomTextField(
                controller: _displayNameController,
                label: '昵称',
                validator: (value) =>
                value!.isEmpty ? '请输入昵称' : null,
                prefixIcon: Icons.person,
              ),
              SizedBox(height: 16),
              CustomTextField(
                controller: _emailController,
                label: '邮箱',
                validator: (value) =>
                value!.isEmpty ? '请输入邮箱' : null,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email,
              ),
              SizedBox(height: 16),
              CustomTextField(
                controller: _passwordController,
                label: '密码',
                validator: (value) =>
                value!.isEmpty ? '请输入密码' : null,
                obscureText: true,
                prefixIcon: Icons.lock,
              ),
              SizedBox(height: 16),
              CustomTextField(
                controller: _confirmPasswordController,
                label: '确认密码',
                validator: (value) =>
                value!.isEmpty ? '请再次输入密码' : null,
                obscureText: true,
                prefixIcon: Icons.lock_outline,
              ),
              SizedBox(height: 24),
              CustomButton(
                text: '注册',
                onPressed: _isLoading ? null : _register,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}