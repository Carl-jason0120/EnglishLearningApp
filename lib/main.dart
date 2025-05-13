import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'database/database_helper.dart';
import 'database/db_operations.dart';
import 'screens/auth/login_screen.dart';
import 'utils/shared_prefs.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPrefs.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final DatabaseHelper dbHelper = DatabaseHelper.instance;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<DatabaseHelper>(create: (_) => dbHelper),
        Provider<DBOperations>(
          create: (_) => DBOperations(dbHelper),
        ),
      ],
      child: MaterialApp(
        title: '英语单词学习',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        themeMode: SharedPrefs.getDarkMode() ? ThemeMode.dark : ThemeMode.light,
        home: LoginScreen(),
      ),
    );
  }
}