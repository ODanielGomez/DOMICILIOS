import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'app.dart';
import 'providers/providers.dart';
import 'core/database/database_helper.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await DatabaseHelper.instance.database;
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => SettingsProvider()..init()),
    ChangeNotifierProvider(create: (_) => IncomeProvider()..loadAll()),
    ChangeNotifierProvider(create: (_) => ExpenseProvider()..loadAll()),
    ChangeNotifierProvider(create: (_) => SavingProvider()..loadAll()),
    ChangeNotifierProvider(create: (_) => GoalProvider()..loadAll()),
    ChangeNotifierProvider(create: (_) => ReportProvider()),
  ], child: const DomiFinanceApp()));
}
