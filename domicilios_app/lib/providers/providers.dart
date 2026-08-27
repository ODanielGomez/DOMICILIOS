import 'package:flutter/material.dart';
import '../core/database/database_helper.dart';
import '../models/models.dart';
class SettingsProvider extends ChangeNotifier {
  double _dp = 10.0; ThemeMode _tm = ThemeMode.system; bool _dr = true; String _rt = '20:00';
  double get deliveryPercentage => _dp; ThemeMode get themeMode => _tm; bool get dailyReminder => _dr; String get reminderTime => _rt;
  Future<void> init() async { final db = DatabaseHelper.instance; final pct = await db.getSetting('delivery_percentage'); final theme = await db.getSetting('theme_mode'); final reminder = await db.getSetting('daily_reminder'); final time = await db.getSetting('reminder_time'); _dp = double.tryParse(pct ?? '10') ?? 10.0; _tm = theme == 'dark' ? ThemeMode.dark : theme == 'light' ? ThemeMode.light : ThemeMode.system; _dr = (reminder ?? 'true') == 'true'; _rt = time ?? '20:00'; notifyListeners(); }
  Future<void> setDeliveryPercentage(double v) async { _dp = v; await DatabaseHelper.instance.setSetting('delivery_percentage', v.toString()); notifyListeners(); }
  Future<void> setThemeMode(ThemeMode m) async { _tm = m; await DatabaseHelper.instance.setSetting('theme_mode', m == ThemeMode.dark ? 'dark' : m == ThemeMode.light ? 'light' : 'system'); notifyListeners(); }
  Future<void> setDailyReminder(bool v) async { _dr = v; await DatabaseHelper.instance.setSetting('daily_reminder', v.toString()); notifyListeners(); }
  Future<void> setReminderTime(String t) async { _rt = t; await DatabaseHelper.instance.setSetting('reminder_time', t); notifyListeners(); }
}
class IncomeProvider extends ChangeNotifier {
  List<IncomeModel> _list = []; bool _loading = false;
  List<IncomeModel> get incomes => _list; bool get loading => _loading;
  double get totalIncome => _list.fold(0, (s, i) => s + i.amount);
  double get deliveryIncome => _list.where((i) => i.type == 'domicilios').fold(0, (s, i) => s + i.amount);
  List<IncomeModel> getByDate(String d) => _list.where((i) => i.date.startsWith(d)).toList();
  Future<void> loadAll() async { _loading = true; notifyListeners(); final m = await DatabaseHelper.instance.queryAll('incomes'); _list = m.map((x) => IncomeModel.fromMap(x)).toList(); _loading = false; notifyListeners(); }
  Future<void> loadByRange(String s, String e) async { _loading = true; notifyListeners(); final m = await DatabaseHelper.instance.queryByDateRange('incomes', s, e); _list = m.map((x) => IncomeModel.fromMap(x)).toList(); _loading = false; notifyListeners(); }
  Future<void> add(IncomeModel i) async { await DatabaseHelper.instance.insert('incomes', i.toMap()); await loadAll(); }
  Future<void> update(IncomeModel i) async { await DatabaseHelper.instance.update('incomes', i.toMap(), i.id!); await loadAll(); }
  Future<void> delete(int id) async { await DatabaseHelper.instance.delete('incomes', id); await loadAll(); }
}
class ExpenseProvider extends ChangeNotifier {
  List<ExpenseModel> _list = []; bool _loading = false;
  List<ExpenseModel> get expenses => _list; bool get loading => _loading;
  double get totalExpense => _list.fold(0, (s, e) => s + e.amount);
  List<ExpenseModel> getByDate(String d) => _list.where((e) => e.date.startsWith(d)).toList();
  Map<String, double> get byCategory { final map = <String, double>{}; for (final e in _list) { map[e.category] = (map[e.category] ?? 0) + e.amount; } return map; }
  Future<void> loadAll() async { _loading = true; notifyListeners(); final m = await DatabaseHelper.instance.queryAll('expenses'); _list = m.map((x) => ExpenseModel.fromMap(x)).toList(); _loading = false; notifyListeners(); }
  Future<void> loadByRange(String s, String e) async { _loading = true; notifyListeners(); final m = await DatabaseHelper.instance.queryByDateRange('expenses', s, e); _list = m.map((x) => ExpenseModel.fromMap(x)).toList(); _loading = false; notifyListeners(); }
  Future<void> add(ExpenseModel e) async { await DatabaseHelper.instance.insert('expenses', e.toMap()); await loadAll(); }
  Future<void> update(ExpenseModel e) async { await DatabaseHelper.instance.update('expenses', e.toMap(), e.id!); await loadAll(); }
  Future<void> delete(int id) async { await DatabaseHelper.instance.delete('expenses', id); await loadAll(); }
}
class SavingProvider extends ChangeNotifier {
  List<SavingModel> _list = [];
  List<SavingModel> get savings => _list;
  double get totalSaved => _list.fold(0, (s, sv) => s + sv.amount);
  Future<void> loadAll() async { final m = await DatabaseHelper.instance.queryAll('savings'); _list = m.map((x) => SavingModel.fromMap(x)).toList(); notifyListeners(); }
  Future<void> add(SavingModel s) async { await DatabaseHelper.instance.insert('savings', s.toMap()); await loadAll(); }
  Future<void> delete(int id) async { await DatabaseHelper.instance.delete('savings', id); await loadAll(); }
  double suggest(double d, double p) => d * (p / 100);
}
class GoalProvider extends ChangeNotifier {
  List<GoalModel> _list = [];
  List<GoalModel> get goals => _list;
  List<GoalModel> get activeGoals => _list.where((g) => g.isActive).toList();
  Future<void> loadAll() async { final m = await DatabaseHelper.instance.queryAll('goals'); _list = m.map((x) => GoalModel.fromMap(x)).toList(); notifyListeners(); }
  Future<void> add(GoalModel g) async { await DatabaseHelper.instance.insert('goals', g.toMap()); await loadAll(); }
  Future<void> update(GoalModel g) async { await DatabaseHelper.instance.update('goals', g.toMap(), g.id!); await loadAll(); }
  Future<void> delete(int id) async { await DatabaseHelper.instance.delete('goals', id); await loadAll(); }
  double progress(GoalModel g, double c) { if (g.targetAmount == 0) return 0; return (c / g.targetAmount).clamp(0.0, 1.0); }
}
class ReportProvider extends ChangeNotifier {
  String _period = 'mensual'; DateTime _date = DateTime.now();
  String get period => _period; DateTime get selectedDate => _date;
  void setPeriod(String p) { _period = p; notifyListeners(); }
  void setDate(DateTime d) { _date = d; notifyListeners(); }
  (String, String) get dateRange { final n = _date; switch (_period) { case 'diario': final s = '${n.year}-${_p(n.month)}-${_p(n.day)}'; return (s, s); case 'semanal': final st = n.subtract(Duration(days: n.weekday - 1)); final en = st.add(const Duration(days: 6)); return (_fmt(st), _fmt(en)); default: final s = '${n.year}-${_p(n.month)}-01'; final e = '${n.year}-${_p(n.month)}-${DateTime(n.year, n.month + 1, 0).day}'; return (s, e); } }
  String _p(int n) => n.toString().padLeft(2, '0');
  String _fmt(DateTime d) => '${d.year}-${_p(d.month)}-${_p(d.day)}';
  String generateSummary({required double totalIncome, required double totalExpense, required double totalSaved, required Map<String, double> expenseByCategory, required double deliveryPercentage, required double deliveryIncome}) {
    final balance = totalIncome - totalExpense; final suggested = deliveryIncome * (deliveryPercentage / 100);
    String tc = ''; double ta = 0; expenseByCategory.forEach((c, a) { if (a > ta) { ta = a; tc = c; } });
    final label = _period == 'diario' ? 'hoy' : _period == 'semanal' ? 'esta semana' : 'este mes';
    final b = StringBuffer();
    b.writeln('📊 Resumen $label:\n'); b.writeln('💰 Ingresos: \$${_n(totalIncome)}'); b.writeln('   • Domicilios: \$${_n(deliveryIncome)}'); b.writeln('   • Otros: \$${_n(totalIncome - deliveryIncome)}\n');
    b.writeln('💸 Gastos: \$${_n(totalExpense)}'); if (tc.isNotEmpty) b.writeln('   • Mayor: $tc (\$${_n(ta)})\n');
    b.writeln('🏦 Ahorrado: \$${_n(totalSaved)}'); b.writeln('💡 Sugerido (${deliveryPercentage.toInt()}%): \$${_n(suggested)}\n');
    b.writeln(balance >= 0 ? '✅ Balance: +\$${_n(balance)}' : '⚠️ Balance: -\$${_n(balance.abs())}');
    return b.toString();
  }
  String _n(double n) => n.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
}
