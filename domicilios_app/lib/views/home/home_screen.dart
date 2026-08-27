import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/providers.dart';
import '../../core/constants/app_constants.dart';
import '../../models/models.dart';
import '../income/income_screens.dart';
import '../expense/expense_screens.dart';
import '../savings/savings_screen.dart';
import '../reports/reports_screen.dart';
import '../settings/settings_screen.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> {
  int _idx = 0;
  final _pages = const [_DashboardTab(), IncomeListScreen(), ExpenseListScreen(), SavingsScreen(), ReportsScreen()];
  @override
  Widget build(BuildContext context) => Scaffold(
    body: IndexedStack(index: _idx, children: _pages),
    bottomNavigationBar: BottomNavigationBar(currentIndex: _idx, onTap: (i) => setState(() => _idx = i), items: const [
      BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Inicio'),
      BottomNavigationBarItem(icon: Icon(Icons.trending_up_rounded), label: 'Ingresos'),
      BottomNavigationBarItem(icon: Icon(Icons.trending_down_rounded), label: 'Gastos'),
      BottomNavigationBarItem(icon: Icon(Icons.savings_rounded), label: 'Ahorro'),
      BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded), label: 'Reportes'),
    ]),
  );
}
class _DashboardTab extends StatelessWidget {
  const _DashboardTab();
  @override
  Widget build(BuildContext context) {
    final income = context.watch<IncomeProvider>(); final expense = context.watch<ExpenseProvider>(); final saving = context.watch<SavingProvider>(); final settings = context.watch<SettingsProvider>(); final goals = context.watch<GoalProvider>();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final todayIncome = income.getByDate(today).fold(0.0, (s, i) => s + i.amount);
    final todayExpense = expense.getByDate(today).fold(0.0, (s, e) => s + e.amount);
    final balance = income.totalIncome - expense.totalExpense;
    final suggested = income.deliveryIncome * (settings.deliveryPercentage / 100);
    return Scaffold(
      appBar: AppBar(title: const Text('DomiFinance'), actions: [IconButton(icon: const Icon(Icons.settings_rounded), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())))]),
      body: RefreshIndicator(onRefresh: () async { await income.loadAll(); await expense.loadAll(); await saving.loadAll(); },
        child: ListView(padding: const EdgeInsets.all(16), children: [
          _BalanceCard(totalIncome: income.totalIncome, totalExpense: expense.totalExpense, balance: balance),
          const SizedBox(height: 16),
          Text('Hoy', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: _MiniCard(label: 'Ingresos hoy', amount: todayIncome, color: AppColors.income, icon: Icons.arrow_upward_rounded)),
            const SizedBox(width: 12),
            Expanded(child: _MiniCard(label: 'Gastos hoy', amount: todayExpense, color: AppColors.expense, icon: Icons.arrow_downward_rounded)),
          ]),
          const SizedBox(height: 16),
          _SavingsCard(saved: saving.totalSaved, suggested: suggested, percentage: settings.deliveryPercentage),
          const SizedBox(height: 16),
          if (goals.activeGoals.isNotEmpty) ...[
            Text('Metas activas', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            ...goals.activeGoals.map((g) => _GoalCard(goal: g, current: g.period == 'diario' ? todayIncome : income.totalIncome, gp: goals)),
          ],
          const SizedBox(height: 16),
          Text('Últimas transacciones', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          if (income.incomes.isEmpty && expense.expenses.isEmpty) const _Empty() else ..._recent(income, expense),
        ]),
      ),
    );
  }
  List<Widget> _recent(IncomeProvider inc, ExpenseProvider exp) {
    final list = <Map<String, dynamic>>[];
    for (final i in inc.incomes.take(5)) list.add({'t': 'i', 'item': i, 'd': i.date});
    for (final e in exp.expenses.take(5)) list.add({'t': 'e', 'item': e, 'd': e.date});
    list.sort((a, b) => (b['d'] as String).compareTo(a['d'] as String));
    return list.take(8).map((x) {
      if (x['t'] == 'i') { final i = x['item'] as IncomeModel; return _TTile(title: i.type == 'domicilios' ? '🛵 Domicilio' : '💼 Otros', sub: i.note ?? i.type, amount: i.amount, date: i.date, isIncome: true); }
      final e = x['item'] as ExpenseModel;
      return _TTile(title: '${AppStrings.categoryIcons[e.category] ?? '📦'} ${e.category[0].toUpperCase()}${e.category.substring(1)}', sub: e.note ?? e.category, amount: e.amount, date: e.date, isIncome: false);
    }).toList();
  }
}
class _BalanceCard extends StatelessWidget {
  final double totalIncome, totalExpense, balance;
  const _BalanceCard({required this.totalIncome, required this.totalExpense, required this.balance});
  String _f(double n) => n.abs().toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
  @override
  Widget build(BuildContext context) { final pos = balance >= 0; return Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(gradient: LinearGradient(colors: pos ? [const Color(0xFF00C896), const Color(0xFF00A87E)] : [const Color(0xFFFF6B6B), const Color(0xFFE55555)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(20)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Balance total', style: TextStyle(color: Colors.white70, fontSize: 14)), const SizedBox(height: 4), Text('${pos ? '+' : ''}\$${_f(balance)}', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800)), const SizedBox(height: 16), Row(children: [_BS(label: 'Ingresos', amount: totalIncome, icon: Icons.arrow_upward_rounded), const SizedBox(width: 24), _BS(label: 'Gastos', amount: totalExpense, icon: Icons.arrow_downward_rounded)])])); }
}
class _BS extends StatelessWidget {
  final String label; final double amount; final IconData icon;
  const _BS({required this.label, required this.amount, required this.icon});
  @override
  Widget build(BuildContext context) => Row(children: [Icon(icon, color: Colors.white70, size: 16), const SizedBox(width: 4), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)), Text('\$${amount.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14))])]);
}
class _MiniCard extends StatelessWidget {
  final String label; final double amount; final Color color; final IconData icon;
  const _MiniCard({required this.label, required this.amount, required this.color, required this.icon});
  @override
  Widget build(BuildContext context) { final dark = Theme.of(context).brightness == Brightness.dark; return Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: dark ? const Color(0xFF16213E) : Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: color.withOpacity(0.3))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle), child: Icon(icon, color: color, size: 14)), const SizedBox(width: 8), Flexible(child: Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 11)))]), const SizedBox(height: 8), Text('\$${amount.toStringAsFixed(0)}', style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 18))])); }
}
class _SavingsCard extends StatelessWidget {
  final double saved, suggested, percentage;
  const _SavingsCard({required this.saved, required this.suggested, required this.percentage});
  @override
  Widget build(BuildContext context) { final p = suggested > 0 ? (saved / suggested).clamp(0.0, 1.0) : 0.0; final dark = Theme.of(context).brightness == Brightness.dark; return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: dark ? const Color(0xFF16213E) : Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.saving.withOpacity(0.3))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Row(children: [const Text('💰', style: TextStyle(fontSize: 18)), const SizedBox(width: 8), Text('Ahorro sugerido (${percentage.toInt()}%)', style: const TextStyle(fontWeight: FontWeight.w600))]), Text('\$${suggested.toStringAsFixed(0)}', style: const TextStyle(color: AppColors.saving, fontWeight: FontWeight.w800))]), const SizedBox(height: 12), ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: p, backgroundColor: AppColors.saving.withOpacity(0.15), valueColor: const AlwaysStoppedAnimation<Color>(AppColors.saving), minHeight: 8)), const SizedBox(height: 6), Text('Ahorrado: \$${saved.toStringAsFixed(0)} (${(p * 100).toInt()}%)', style: TextStyle(color: Colors.grey[600], fontSize: 12))])); }
}
class _GoalCard extends StatelessWidget {
  final GoalModel goal; final double current; final GoalProvider gp;
  const _GoalCard({required this.goal, required this.current, required this.gp});
  @override
  Widget build(BuildContext context) { final progress = gp.progress(goal, current); final met = progress >= 1.0; final dark = Theme.of(context).brightness == Brightness.dark; return Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: dark ? const Color(0xFF16213E) : Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: met ? AppColors.income.withOpacity(0.5) : Colors.grey.withOpacity(0.2))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Flexible(child: Text('${met ? '✅' : '🎯'} ${goal.title}', style: const TextStyle(fontWeight: FontWeight.w600))), Text(goal.period, style: const TextStyle(color: AppColors.info, fontSize: 11, fontWeight: FontWeight.w600))]), const SizedBox(height: 8), ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: progress, backgroundColor: AppColors.info.withOpacity(0.15), valueColor: AlwaysStoppedAnimation<Color>(met ? AppColors.income : AppColors.info), minHeight: 8)), const SizedBox(height: 4), Text('\$${current.toStringAsFixed(0)} / \$${goal.targetAmount.toStringAsFixed(0)} (${(progress * 100).toInt()}%)', style: TextStyle(color: Colors.grey[600], fontSize: 11))])); }
}
class _TTile extends StatelessWidget {
  final String title, sub, date; final double amount; final bool isIncome;
  const _TTile({required this.title, required this.sub, required this.amount, required this.date, required this.isIncome});
  @override
  Widget build(BuildContext context) { final dark = Theme.of(context).brightness == Brightness.dark; return Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12), decoration: BoxDecoration(color: dark ? const Color(0xFF16213E) : Colors.white, borderRadius: BorderRadius.circular(12)), child: Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)), Text(sub.length > 30 ? '${sub.substring(0, 30)}...' : sub, style: TextStyle(color: Colors.grey[600], fontSize: 12))])), Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text('${isIncome ? '+' : '-'}\$${amount.toStringAsFixed(0)}', style: TextStyle(color: isIncome ? AppColors.income : AppColors.expense, fontWeight: FontWeight.w700, fontSize: 15)), Text(date.substring(0, 10), style: TextStyle(color: Colors.grey[500], fontSize: 11))])])); }
}
class _Empty extends StatelessWidget {
  const _Empty();
  @override
  Widget build(BuildContext context) => Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(children: [const Text('💸', style: TextStyle(fontSize: 48)), const SizedBox(height: 12), Text('Sin transacciones aún', style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w600)), Text('Registra tus ingresos y gastos', style: TextStyle(color: Colors.grey[500], fontSize: 12))])));
}
