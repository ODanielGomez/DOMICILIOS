import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/providers.dart';
import '../../core/constants/app_constants.dart';
import '../../models/models.dart';

class IncomeListScreen extends StatelessWidget {
  const IncomeListScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final p = context.watch<IncomeProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ingresos'),
        actions: [
          Padding(padding: const EdgeInsets.only(right: 8), child: Center(child: Text('Total: ${p.incomes.length}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)))),
          Padding(padding: const EdgeInsets.only(right: 16), child: Chip(label: Text('\$${p.totalIncome.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)), backgroundColor: AppColors.income)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const IncomeFormScreen())), icon: const Icon(Icons.add), label: const Text('Nuevo ingreso')),
      body: p.loading ? const Center(child: CircularProgressIndicator()) : p.incomes.isEmpty ? _EmptyI() : _ListI(incomes: p.incomes),
    );
  }
}
class _EmptyI extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Text('🛵', style: TextStyle(fontSize: 64)), const SizedBox(height: 16), Text('Sin ingresos registrados', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[600]))]));
}
class _ListI extends StatelessWidget {
  final List<IncomeModel> incomes;
  const _ListI({required this.incomes});
  String _fd(String date) {
    final now = DateTime.now();
    final today = '${now.year}-${now.month.toString().padLeft(2, "0")}-${now.day.toString().padLeft(2, "0")}';
    if (date == today) return 'Hoy';
    final p = date.split('-');
    return '${p[2]}/${p[1]}/${p[0]}';
  }
  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<IncomeModel>>{};
    for (final i in incomes) grouped.putIfAbsent(i.date.substring(0, 10), () => []).add(i);
    return ListView(padding: const EdgeInsets.all(16), children: grouped.entries.map((e) {
      final dt = e.value.fold(0.0, (s, i) => s + i.amount);
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(_fd(e.key), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          Row(children: [
            Text('${e.value.length} ingreso${e.value.length != 1 ? "s" : ""}', style: TextStyle(color: Colors.grey[500], fontSize: 11)),
            const SizedBox(width: 8),
            Text('+\$${dt.toStringAsFixed(0)}', style: const TextStyle(color: AppColors.income, fontWeight: FontWeight.w700, fontSize: 13)),
          ]),
        ]),
        const SizedBox(height: 6),
        ...e.value.map((i) => _CardI(income: i)),
        const SizedBox(height: 12),
      ]);
    }).toList());
  }
}
class _CardI extends StatelessWidget {
  final IncomeModel income;
  const _CardI({required this.income});
  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final isD = income.type == 'domicilios';
    return Dismissible(
      key: Key('i_${income.id}'),
      direction: DismissDirection.endToStart,
      background: Container(alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 16), decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.delete_rounded, color: Colors.white)),
      confirmDismiss: (_) async => await showDialog<bool>(context: context, builder: (_) => AlertDialog(title: const Text('Eliminar'), content: const Text('¿Eliminar este ingreso?'), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')), ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red, minimumSize: const Size(60, 40)), onPressed: () => Navigator.pop(context, true), child: const Text('Si'))])),
      onDismissed: (_) { context.read<IncomeProvider>().delete(income.id!); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Eliminado'), backgroundColor: Colors.red)); },
      child: GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => IncomeFormScreen(income: income))),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: dark ? const Color(0xFF16213E) : Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.income.withOpacity(0.2))),
          child: Row(children: [
            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.income.withOpacity(0.15), borderRadius: BorderRadius.circular(10)), child: Text(isD ? '🛵' : '💼', style: const TextStyle(fontSize: 20))),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: AppColors.info.withOpacity(0.15), borderRadius: BorderRadius.circular(6)), child: Text('#${income.id}', style: const TextStyle(color: AppColors.info, fontSize: 11, fontWeight: FontWeight.w700))),
                const SizedBox(width: 6),
                Text(isD ? 'Domicilio' : 'Otros ingresos', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              ]),
              const SizedBox(height: 4),
              Row(children: [
                Icon(Icons.access_time_rounded, size: 12, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text(income.time, style: TextStyle(color: Colors.grey[500], fontSize: 12, fontWeight: FontWeight.w500)),
                if (income.note != null && income.note!.isNotEmpty) ...[const SizedBox(width: 8), const Text('·', style: TextStyle(color: Colors.grey)), const SizedBox(width: 8), Flexible(child: Text(income.note!, style: TextStyle(color: Colors.grey[600], fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis))],
              ]),
            ])),
            Text('+\$${income.amount.toStringAsFixed(0)}', style: const TextStyle(color: AppColors.income, fontWeight: FontWeight.w800, fontSize: 16)),
          ]),
        ),
      ),
    );
  }
}
class IncomeFormScreen extends StatefulWidget {
  final IncomeModel? income;
  const IncomeFormScreen({super.key, this.income});
  @override
  State<IncomeFormScreen> createState() => _IFS();
}
class _IFS extends State<IncomeFormScreen> {
  final _fk = GlobalKey<FormState>();
  final _ac = TextEditingController();
  final _nc = TextEditingController();
  String _type = 'domicilios';
  DateTime _date = DateTime.now();
  TimeOfDay _time = TimeOfDay.now();
  bool _saving = false;
  bool get isEdit => widget.income != null;
  @override
  void initState() {
    super.initState();
    if (isEdit) {
      _ac.text = widget.income!.amount.toStringAsFixed(0);
      _nc.text = widget.income!.note ?? '';
      _type = widget.income!.type;
      _date = DateTime.parse(widget.income!.date);
      final parts = widget.income!.time.split(':');
      _time = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }
  }
  @override
  void dispose() { _ac.dispose(); _nc.dispose(); super.dispose(); }
  Future<void> _pickDate() async {
    final p = await showDatePicker(context: context, initialDate: _date, firstDate: DateTime(2020), lastDate: DateTime.now().add(const Duration(days: 1)));
    if (p != null) setState(() => _date = p);
  }
  Future<void> _pickTime() async {
    final p = await showTimePicker(context: context, initialTime: _time);
    if (p != null) setState(() => _time = p);
  }
  Future<void> _submit() async {
    if (!_fk.currentState!.validate()) return;
    setState(() => _saving = true);
    final now = DateTime.now();
    final ds = '${_date.year}-${_date.month.toString().padLeft(2, "0")}-${_date.day.toString().padLeft(2, "0")}';
    final ts = '${_time.hour.toString().padLeft(2, "0")}:${_time.minute.toString().padLeft(2, "0")}';
    final income = IncomeModel(id: widget.income?.id, amount: double.parse(_ac.text.replaceAll(',', '')), type: _type, note: _nc.text.isEmpty ? null : _nc.text, date: ds, time: ts, createdAt: widget.income?.createdAt ?? now.toIso8601String());
    final prov = context.read<IncomeProvider>();
    if (isEdit) await prov.update(income); else await prov.add(income);
    if (mounted) {
      setState(() => _saving = false);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEdit ? 'Actualizado' : 'Guardado'), backgroundColor: AppColors.income));
    }
  }
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(isEdit ? 'Editar ingreso' : 'Nuevo ingreso')),
    body: Form(key: _fk, child: ListView(padding: const EdgeInsets.all(20), children: [
      const Text('Monto *', style: TextStyle(fontWeight: FontWeight.w600)), const SizedBox(height: 8),
      TextFormField(controller: _ac, keyboardType: TextInputType.number, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800), decoration: const InputDecoration(prefixText: r'$ ', hintText: '0'), validator: (v) { if (v == null || v.isEmpty) return 'Ingresa un monto'; if (double.tryParse(v.replaceAll(',', '')) == null) return 'Invalido'; return null; }),
      const SizedBox(height: 20),
      const Text('Tipo *', style: TextStyle(fontWeight: FontWeight.w600)), const SizedBox(height: 8),
      Row(children: AppStrings.incomeTypes.map((t) { final sel = _type == t; return Expanded(child: GestureDetector(onTap: () => setState(() => _type = t), child: Container(margin: const EdgeInsets.symmetric(horizontal: 4), padding: const EdgeInsets.symmetric(vertical: 14), decoration: BoxDecoration(color: sel ? AppColors.income : Colors.transparent, borderRadius: BorderRadius.circular(12), border: Border.all(color: sel ? AppColors.income : Colors.grey.withOpacity(0.4), width: 2)), child: Column(children: [Text(t == 'domicilios' ? '🛵' : '💼', style: const TextStyle(fontSize: 24)), const SizedBox(height: 4), Text(t, style: TextStyle(color: sel ? Colors.white : null, fontWeight: FontWeight.w600))])))); }).toList()),
      const SizedBox(height: 20),
      const Text('Fecha *', style: TextStyle(fontWeight: FontWeight.w600)), const SizedBox(height: 8),
      GestureDetector(onTap: _pickDate, child: Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), decoration: BoxDecoration(color: Theme.of(context).inputDecorationTheme.fillColor, borderRadius: BorderRadius.circular(12)), child: Row(children: [const Icon(Icons.calendar_today_rounded, size: 18), const SizedBox(width: 10), Text('${_date.day.toString().padLeft(2, "0")}/${_date.month.toString().padLeft(2, "0")}/${_date.year}'), const Spacer(), const Icon(Icons.edit_rounded, size: 16, color: Colors.grey)]))),
      const SizedBox(height: 16),
      const Text('Hora *', style: TextStyle(fontWeight: FontWeight.w600)), const SizedBox(height: 8),
      GestureDetector(onTap: _pickTime, child: Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), decoration: BoxDecoration(color: Theme.of(context).inputDecorationTheme.fillColor, borderRadius: BorderRadius.circular(12)), child: Row(children: [const Icon(Icons.access_time_rounded, size: 18), const SizedBox(width: 10), Text('${_time.hour.toString().padLeft(2, "0")}:${_time.minute.toString().padLeft(2, "0")}'), const Spacer(), const Icon(Icons.edit_rounded, size: 16, color: Colors.grey)]))),
      const SizedBox(height: 20),
      const Text('Nota (opcional)', style: TextStyle(fontWeight: FontWeight.w600)), const SizedBox(height: 8),
      TextFormField(controller: _nc, maxLines: 3, decoration: const InputDecoration(hintText: 'Ej: 5 domicilios tarde...')),
      const SizedBox(height: 32),
      ElevatedButton(onPressed: _saving ? null : _submit, child: _saving ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Text(isEdit ? 'Actualizar ingreso' : 'Guardar ingreso')),
    ])),
  );
}
