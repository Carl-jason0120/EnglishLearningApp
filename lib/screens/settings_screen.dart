import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../database/db_operations.dart';
import '../../models/settings.dart';
import '../../utils/shared_prefs.dart';
import '../screens/auth/login_screen.dart';
import '../main.dart';

class SettingsScreen extends StatefulWidget {
  final int userId;

  const SettingsScreen({required this.userId});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late Future<UserSettings> _settingsFuture;

  @override
  void initState() {
    super.initState();
    _settingsFuture = _loadSettings();
  }

  Future<UserSettings> _loadSettings() async {
    final dbOps = Provider.of<DBOperations>(context, listen: false);
    return await dbOps.getUserSettings(widget.userId);
  }

  Future<void> _saveSettings(UserSettings settings) async {
    final dbOps = Provider.of<DBOperations>(context, listen: false);
    await dbOps.saveUserSettings(settings);
    setState(() {
      _settingsFuture = Future.value(settings);
    });
  }

  Future<void> _logout() async {
    await SharedPrefs.clear();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('设置')),
      body: FutureBuilder<UserSettings>(
        future: _settingsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return Center(child: Text('加载设置失败'));
          }

          final settings = snapshot.data!;

          return ListView(
            padding: EdgeInsets.all(16),
            children: [
              _buildSettingSection('学习目标'),
              _buildDailyGoalSetting(settings),
              Divider(),
              _buildSettingSection('外观'),
              _buildDarkModeSetting(settings),
              Divider(),
              _buildSettingSection('通知'),
              _buildNotificationSetting(settings),
              Divider(),
              SizedBox(height: 32),
              _buildLogoutButton(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSettingSection(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme
              .of(context)
              .primaryColor,
        ),
      ),
    );
  }

  Widget _buildDailyGoalSetting(UserSettings settings) {
    return ListTile(
      title: Text('每日学习目标'),
      subtitle: Text('${settings.dailyGoal} 个单词/天'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.remove),
            onPressed: () {
              if (settings.dailyGoal > 1) {
                _saveSettings(
                    settings.copyWith(dailyGoal: settings.dailyGoal - 1));
              }
            },
          ),
          Text('${settings.dailyGoal}'),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              if (settings.dailyGoal < 50) {
                _saveSettings(
                    settings.copyWith(dailyGoal: settings.dailyGoal + 1));
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDarkModeSetting(UserSettings settings) {
    return SwitchListTile(
      title: Text('深色模式'),
      value: SharedPrefs.getDarkMode(),
      onChanged: (value) async {
        await SharedPrefs.setDarkMode(value);
        final newSettings = settings.copyWith(darkMode: value);
        await _saveSettings(newSettings);
        // 重建MaterialApp以应用主题更改
        final widget = MyApp();
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => widget),
              (route) => false,
        );
      },
    );
  }

  Widget _buildNotificationSetting(UserSettings settings) {
    return SwitchListTile(
      title: Text('通知开关'),
      value: settings.notificationEnabled,
      onChanged: (value) {
        _saveSettings(settings.copyWith(notificationEnabled: value));
      },
    );
  }

  Widget _buildLogoutButton() {
    return ElevatedButton(
      onPressed: _logout,
      child: Text('退出登录'),
    );
  }
}