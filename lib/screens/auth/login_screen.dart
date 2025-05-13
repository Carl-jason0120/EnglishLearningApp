import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../database/db_operations.dart';
import '../../utils/shared_prefs.dart';
import '../../utils/widgets/custom_button.dart';
import '../../utils/widgets/custom_textfield.dart';
import '../home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final dbOps = Provider.of<DBOperations>(context, listen: false);
    final user = await dbOps.getUserByEmail(_emailController.text.trim());

    setState(() => _isLoading = false);

    if (user == null || user.password != _passwordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('登录失败，请检查邮箱和密码')),
      );
    } else {
      await SharedPrefs.setLoggedInUserId(user.id);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(userId: user.id),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('登录')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
              SizedBox(height: 24),
              CustomButton(
                text: '登录',
                onPressed: _isLoading ? null : _login,
                isLoading: _isLoading,
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => RegisterScreen()),
                  );
                },
                child: Text('没有账号？立即注册'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}