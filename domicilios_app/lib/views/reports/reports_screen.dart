import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/providers.dart';
import '../../core/constants/app_constants.dart';
import '../../models/models.dart';
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});
  @override
  State<ReportsScreen> createState() => _RS();
}
class _RS extends State<ReportsScreen> {
  @override
  void initState() { super.initState(); WidgetsBinding.instance.addPostFrameCallback((_) => _load()); }
  Future<void> _load() async { final r = context.read<ReportProvider>(); final (s, e) = r.dateRange; await context.read<IncomeProvider>().loadByRange(s, e); await context.read<ExpenseProvider>().loadByRange(s, e); }
  @override
  Widget build(BuildContext context) { final report = context.watch<ReportProvider>(); final income = context.watch<IncomeProvider>(); final expense = context.watch<ExpenseProvider>(); final saving = context.watch<SavingProvider>(); final settings = context.watch<SettingsProvider>(); final balance = income.totalIncome - expense.totalExpense; return Scaffold(appBar: AppBar(title: const Text('Reportes')), body: RefreshIndicator(onRefresh: _load, child: ListView(padding: const EdgeInsets.all(16), children: [_PS(selected: report.period, onChanged: (p) { report.setPeriod(p); _load(); }), const SizedBox(height: 12), _DN(report: report, onChanged: _load), const SizedBox(height: 16), _SR(totalIncome: income.totalIncome, totalExpense: expense.totalExpense, balance: balance), const SizedBox(height: 20), if (income.incomes.isNotEmpty || expense.expenses.isNotEmpty) ...[Text('Ingresos vs Gastos', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)), const SizedBox(height: 12), _BC(incomeData: _bd(income.incomes.map((i) => MapEntry(i.date, i.amount)).toList()), expenseData: _bd(expense.expenses.map((e) => MapEntry(e.date, e.amount)).toList())), const SizedBox(height: 20)], if (expense.byCategory.isNotEmpty) ...[Text('Por categoría', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)), const SizedBox(height: 12), _PC(byCategory: expense.byCategory), const SizedBox(height: 20)], Text('Análisis', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)), const SizedBox(height: 12), _ST(summary: report.generateSummary(totalIncome: income.totalIncome, totalExpense: expense.totalExpense, totalSaved: saving.totalSaved, expenseByCategory: expense.byCategory, deliveryPercentage: settings.deliveryPercentage, deliveryIncome: income.deliveryIncome)), const SizedBox(height: 32)]))); }
  Map<String, double> _bd(List<MapEntry<String, double>> items) { final map = <String, double>{}; for (final i in items) { final d = i.key.substring(0, 10); map[d] = (map[d] ?? 0) + i.value; } return map; }
}
class _PS extends StatelessWidget {
  final String selected; final ValueChanged<String> onChanged;
  const _PS({required this.selected, required this.onChanged});
  @override
  Widget build(BuildContext context) => Row(children: AppStrings.periodTypes.map((p) { final s = p == selected; return Expanded(child: GestureDetector(onTap: () => onChanged(p), child: AnimatedContainer(duration: const Duration(milliseconds: 150), margin: const EdgeInsets.symmetric(horizontal: 3), padding: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: s ? AppColors.info : Colors.transparent, borderRadius: BorderRadius.circular(10), border: Border.all(color: s ? AppColors.info : Colors.grey.withOpacity(0.3))), child: Text(p[0].toUpperCase() + p.substring(1), textAlign: TextAlign.center, style: TextStyle(color: s ? Colors.white : null, fontWeight: s ? FontWeight.w700 : FontWeight.w400, fontSize: 13))))); }).toList());
}
class _DN extends StatelessWidget {
  final ReportProvider report; final VoidCallback onChanged;
  const _DN({required this.report, required this.onChanged});
  void _shift(int dir) { final d = report.selectedDate; switch (report.period) { case 'diario': report.setDate(d.add(Duration(days: dir))); break; case 'semanal': report.setDate(d.add(Duration(days: dir * 7))); break; default: report.setDate(DateTime(d.year, d.month + dir, 1)); } onChanged(); }
  String _label() { final d = report.selectedDate; switch (report.period) { case 'diario': return '${d.day.toString().padLeft(2,'0')}/${d.month.toString().padLeft(2,'0')}/${d.year}'; case 'semanal': return 'Semana ${d.year}'; default: const m = ['','Ene','Feb','Mar','Abr','May','Jun','Jul','Ago','Sep','Oct','Nov','Dic']; return '${m[d.month]} ${d.year}'; } }
  @override
  Widget build(BuildContext context) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [IconButton(onPressed: () => _shift(-1), icon: const Icon(Icons.chevron_left_rounded)), Text(_label(), style: const TextStyle(fontWeight: FontWeight.w600)), IconButton(onPressed: () => _shift(1), icon: const Icon(Icons.chevron_right_rounded))]);
}
class _SR extends StatelessWidget {
  final double totalIncome, totalExpense, balance;
  const _SR({required this.totalIncome, required this.totalExpense, required this.balance});
  @override
  Widget build(BuildContext context) { final dark = Theme.of(context).brightness == Brightness.dark; final bg = dark ? const Color(0xFF16213E) : Colors.white; return Row(children: [_SC(label: 'Ingresos', amount: totalIncome, color: AppColors.income, bg: bg), const SizedBox(width: 8), _SC(label: 'Gastos', amount: totalExpense, color: AppColors.expense, bg: bg), const SizedBox(width: 8), _SC(label: 'Balance', amount: balance, color: balance >= 0 ? AppColors.income : AppColors.expense, bg: bg)]); }
}
class _SC extends StatelessWidget {
  final String label; final double amount; final Color color, bg;
  const _SC({required this.label, required this.amount, required this.color, required this.bg});
  @override
  Widget build(BuildContext context) => Expanded(child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 11)), const SizedBox(height: 4), Text('\$${amount.abs().toStringAsFixed(0)}', style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 14))])));
}
class _BC extends StatelessWidget {
  final Map<String, double> incomeData, expenseData;
  const _BC({required this.incomeData, required this.expenseData});
  @override
  Widget build(BuildContext context) { final keys = {...incomeData.keys, ...expenseData.keys}.toList()..sort(); if (keys.isEmpty) return const SizedBox(); final dark = Theme.of(context).brightness == Brightness.dark; return Container(height: 180, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: dark ? const Color(0xFF16213E) : Colors.white, borderRadius: BorderRadius.circular(16)), child: BarChart(BarChartData(barGroups: keys.asMap().entries.map((e) => BarChartGroupData(x: e.key, barRods: [BarChartRodData(toY: incomeData[e.value] ?? 0, color: AppColors.income, width: 8, borderRadius: const BorderRadius.vertical(top: Radius.circular(4))), BarChartRodData(toY: expenseData[e.value] ?? 0, color: AppColors.expense, width: 8, borderRadius: const BorderRadius.vertical(top: Radius.circular(4)))])).toList(), titlesData: FlTitlesData(bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 20, getTitlesWidget: (v, _) { final i = v.toInt(); if (i >= keys.length) return const SizedBox(); final p = keys[i].split('-'); return Text(p.length >= 3 ? p[2] : '', style: const TextStyle(fontSize: 10)); })), leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)), topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)), rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false))), borderData: FlBorderData(show: false), gridData: FlGridData(drawVerticalLine: false, getDrawingHorizontalLine: (_) => FlLine(color: Colors.grey.withOpacity(0.1), strokeWidth: 1))))); }
}
class _PC extends StatefulWidget {
  final Map<String, double> byCategory;
  const _PC({required this.byCategory});
  @override
  State<_PC> createState() => _PCS();
}
class _PCS extends State<_PC> {
  int _touched = -1;
  @override
  Widget build(BuildContext context) { final dark = Theme.of(context).brightness == Brightness.dark; final entries = widget.byCategory.entries.toList(); final total = entries.fold(0.0, (s, e) => s + e.value); return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: dark ? const Color(0xFF16213E) : Colors.white, borderRadius: BorderRadius.circular(16)), child: Column(children: [SizedBox(height: 180, child: PieChart(PieChartData(pieTouchData: PieTouchData(touchCallback: (ev, res) { setState(() => _touched = (!ev.isInterestedForInteractions || res?.touchedSection == null) ? -1 : res!.touchedSection!.touchedSectionIndex); }), sections: entries.asMap().entries.map((e) { final t = e.key == _touched; final color = AppColors.categoryColors[e.value.key] ?? const Color(0xFF8D99AE); return PieChartSectionData(value: e.value.value, color: color, radius: t ? 65 : 55, title: '${(e.value.value / total * 100).toStringAsFixed(0)}%', titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 11)); }).toList(), sectionsSpace: 2, centerSpaceRadius: 36))), const SizedBox(height: 12), Wrap(spacing: 12, runSpacing: 6, children: entries.map((e) { final color = AppColors.categoryColors[e.key] ?? const Color(0xFF8D99AE); final emoji = AppStrings.categoryIcons[e.key] ?? '📦'; return Row(mainAxisSize: MainAxisSize.min, children: [Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)), const SizedBox(width: 4), Text('$emoji ${e.key}: \$${e.value.toStringAsFixed(0)}', style: const TextStyle(fontSize: 11))]); }).toList())])); }
}
class _ST extends StatelessWidget {
  final String summary;
  const _ST({required this.summary});
  @override
  Widget build(BuildContext context) { final dark = Theme.of(context).brightness == Brightness.dark; return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: dark ? const Color(0xFF16213E) : Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.info.withOpacity(0.3))), child: Text(summary, style: const TextStyle(height: 1.6, fontSize: 13))); }
}
