import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/providers.dart';
import '../../core/constants/app_constants.dart';
import '../../models/models.dart';
class ExpenseListScreen extends StatelessWidget {
  const ExpenseListScreen({super.key});
  @override
  Widget build(BuildContext context) { final p = context.watch<ExpenseProvider>(); return Scaffold(appBar: AppBar(title: const Text('Gastos'), actions: [Padding(padding: const EdgeInsets.only(right: 16), child: Chip(label: Text('\$${p.totalExpense.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)), backgroundColor: AppColors.expense))]), floatingActionButton: FloatingActionButton.extended(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExpenseFormScreen())), backgroundColor: AppColors.expense, icon: const Icon(Icons.add), label: const Text('Nuevo gasto')), body: p.loading ? const Center(child: CircularProgressIndicator()) : p.expenses.isEmpty ? _EmptyE() : _ListE(expenses: p.expenses)); }
}
class _EmptyE extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Text('💸', style: TextStyle(fontSize: 64)), const SizedBox(height: 16), Text('Sin gastos registrados', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[600]))]));
}
class _ListE extends StatelessWidget {
  final List<ExpenseModel> expenses;
  const _ListE({required this.expenses});
  String _fd(String date) { final now = DateTime.now(); final today = '${now.year}-${now.month.toString().padLeft(2,'0')}-${now.day.toString().padLeft(2,'0')}'; if (date == today) return 'Hoy'; final p = date.split('-'); return '${p[2]}/${p[1]}/${p[0]}'; }
  @override
  Widget build(BuildContext context) { final grouped = <String, List<ExpenseModel>>{}; for (final e in expenses) grouped.putIfAbsent(e.date.substring(0, 10), () => []).add(e); return ListView(padding: const EdgeInsets.all(16), children: grouped.entries.map((e) { final dt = e.value.fold(0.0, (s, i) => s + i.amount); return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(_fd(e.key), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)), Text('-\$${dt.toStringAsFixed(0)}', style: const TextStyle(color: AppColors.expense, fontWeight: FontWeight.w700, fontSize: 13))]), const SizedBox(height: 6), ...e.value.map((ex) => _CardE(expense: ex)), const SizedBox(height: 12)]); }).toList()); }
}
class _CardE extends StatelessWidget {
  final ExpenseModel expense;
  const _CardE({required this.expense});
  @override
  Widget build(BuildContext context) { final dark = Theme.of(context).brightness == Brightness.dark; final cc = AppColors.categoryColors[expense.category] ?? const Color(0xFF8D99AE); final em = AppStrings.categoryIcons[expense.category] ?? '📦'; return Dismissible(key: Key('e_${expense.id}'), direction: DismissDirection.endToStart, background: Container(alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 16), decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.delete_rounded, color: Colors.white)), confirmDismiss: (_) async => await showDialog<bool>(context: context, builder: (_) => AlertDialog(title: const Text('Eliminar'), content: const Text('¿Eliminar este gasto?'), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')), ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red, minimumSize: const Size(60, 40)), onPressed: () => Navigator.pop(context, true), child: const Text('Sí'))])), onDismissed: (_) { context.read<ExpenseProvider>().delete(expense.id!); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Eliminado'), backgroundColor: Colors.red)); }, child: GestureDetector(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ExpenseFormScreen(expense: expense))), child: Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: dark ? const Color(0xFF16213E) : Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: cc.withOpacity(0.2))), child: Row(children: [Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: cc.withOpacity(0.15), borderRadius: BorderRadius.circular(10)), child: Text(em, style: const TextStyle(fontSize: 20))), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(expense.category[0].toUpperCase() + expense.category.substring(1), style: const TextStyle(fontWeight: FontWeight.w600)), if (expense.note != null && expense.note!.isNotEmpty) Text(expense.note!, style: TextStyle(color: Colors.grey[600], fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis)])), Text('-\$${expense.amount.toStringAsFixed(0)}', style: const TextStyle(color: AppColors.expense, fontWeight: FontWeight.w800, fontSize: 16))])))); }
}
class ExpenseFormScreen extends StatefulWidget {
  final ExpenseModel? expense;
  const ExpenseFormScreen({super.key, this.expense});
  @override
  State<ExpenseFormScreen> createState() => _EFS();
}
class _EFS extends State<ExpenseFormScreen> {
  final _fk = GlobalKey<FormState>(); final _ac = TextEditingController(); final _nc = TextEditingController();
  String _cat = 'comida'; DateTime _date = DateTime.now(); bool _saving = false;
  bool get isEdit => widget.expense != null;
  @override
  void initState() { super.initState(); if (isEdit) { _ac.text = widget.expense!.amount.toStringAsFixed(0); _nc.text = widget.expense!.note ?? ''; _cat = widget.expense!.category; _date = DateTime.parse(widget.expense!.date); } }
  @override
  void dispose() { _ac.dispose(); _nc.dispose(); super.dispose(); }
  Future<void> _pickDate() async { final p = await showDatePicker(context: context, initialDate: _date, firstDate: DateTime(2020), lastDate: DateTime.now().add(const Duration(days: 1))); if (p != null) setState(() => _date = p); }
  Future<void> _submit() async {
    if (!_fk.currentState!.validate()) return; setState(() => _saving = true);
    final now = DateTime.now(); final ds = '${_date.year}-${_date.month.toString().padLeft(2,'0')}-${_date.day.toString().padLeft(2,'0')}';
    final expense = ExpenseModel(id: widget.expense?.id, amount: double.parse(_ac.text.replaceAll(',','')), category: _cat, note: _nc.text.isEmpty ? null : _nc.text, date: ds, createdAt: widget.expense?.createdAt ?? now.toIso8601String());
    final prov = context.read<ExpenseProvider>(); if (isEdit) await prov.update(expense); else await prov.add(expense);
    if (mounted) { setState(() => _saving = false); Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEdit ? 'Actualizado ✅' : 'Guardado ✅'), backgroundColor: AppColors.expense)); }
  }
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text(isEdit ? 'Editar gasto' : 'Nuevo gasto')), body: Form(key: _fk, child: ListView(padding: const EdgeInsets.all(20), children: [const Text('Monto *', style: TextStyle(fontWeight: FontWeight.w600)), const SizedBox(height: 8), TextFormField(controller: _ac, keyboardType: TextInputType.number, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800), decoration: const InputDecoration(prefixText: '\$  ', hintText: '0'), validator: (v) { if (v == null || v.isEmpty) return 'Ingresa un monto'; if (double.tryParse(v.replaceAll(',','')) == null) return 'Inválido'; return null; }), const SizedBox(height: 20), const Text('Categoría *', style: TextStyle(fontWeight: FontWeight.w600)), const SizedBox(height: 10), GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 0.9), itemCount: AppStrings.expenseCategories.length, itemBuilder: (ctx, i) { final cat = AppStrings.expenseCategories[i]; final sel = _cat == cat; final color = AppColors.categoryColors[cat] ?? const Color(0xFF8D99AE); final emoji = AppStrings.categoryIcons[cat] ?? '📦'; return GestureDetector(onTap: () => setState(() => _cat = cat), child: AnimatedContainer(duration: const Duration(milliseconds: 150), decoration: BoxDecoration(color: sel ? color.withOpacity(0.15) : Colors.transparent, borderRadius: BorderRadius.circular(12), border: Border.all(color: sel ? color : Colors.grey.withOpacity(0.3), width: sel ? 2 : 1)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(emoji, style: const TextStyle(fontSize: 22)), const SizedBox(height: 4), Text(cat, style: TextStyle(fontSize: 10, fontWeight: sel ? FontWeight.w700 : FontWeight.w400, color: sel ? color : null), textAlign: TextAlign.center, maxLines: 1)]))); }), const SizedBox(height: 20), const Text('Fecha *', style: TextStyle(fontWeight: FontWeight.w600)), const SizedBox(height: 8), GestureDetector(onTap: _pickDate, child: Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), decoration: BoxDecoration(color: Theme.of(context).inputDecorationTheme.fillColor, borderRadius: BorderRadius.circular(12)), child: Row(children: [const Icon(Icons.calendar_today_rounded, size: 18), const SizedBox(width: 10), Text('${_date.day.toString().padLeft(2,'0')}/${_date.month.toString().padLeft(2,'0')}/${_date.year}', style: const TextStyle(fontWeight: FontWeight.w500)), const Spacer(), const Icon(Icons.edit_rounded, size: 16, color: Colors.grey)]))), const SizedBox(height: 20), const Text('Nota', style: TextStyle(fontWeight: FontWeight.w600)), const SizedBox(height: 8), TextFormField(controller: _nc, maxLines: 3, decoration: const InputDecoration(hintText: 'Ej: Almuerzo...')), const SizedBox(height: 32), ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.expense), onPressed: _saving ? null : _submit, child: _saving ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Text(isEdit ? 'Actualizar' : 'Guardar gasto'))])));
}
