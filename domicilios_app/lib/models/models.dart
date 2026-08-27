class IncomeModel {
  final int? id;
  final double amount;
  final String type;
  final String? note;
  final String? imagePath;
  final String date;
  final String time;
  final String createdAt;

  IncomeModel({this.id, required this.amount, required this.type, this.note, this.imagePath, required this.date, required this.time, required this.createdAt});

  Map<String, dynamic> toMap() => {if (id != null) 'id': id, 'amount': amount, 'type': type, 'note': note, 'image_path': imagePath, 'date': date, 'time': time, 'created_at': createdAt};

  factory IncomeModel.fromMap(Map<String, dynamic> m) => IncomeModel(id: m['id'], amount: (m['amount'] as num).toDouble(), type: m['type'], note: m['note'], imagePath: m['image_path'], date: m['date'], time: m['time'] ?? '00:00', createdAt: m['created_at']);

  IncomeModel copyWith({int? id, double? amount, String? type, String? note, String? imagePath, String? date, String? time, String? createdAt}) => IncomeModel(id: id ?? this.id, amount: amount ?? this.amount, type: type ?? this.type, note: note ?? this.note, imagePath: imagePath ?? this.imagePath, date: date ?? this.date, time: time ?? this.time, createdAt: createdAt ?? this.createdAt);
}

class ExpenseModel {
  final int? id; final double amount; final String category; final String? note; final String? imagePath; final String date; final String createdAt;
  ExpenseModel({this.id, required this.amount, required this.category, this.note, this.imagePath, required this.date, required this.createdAt});
  Map<String, dynamic> toMap() => {if (id != null) 'id': id, 'amount': amount, 'category': category, 'note': note, 'image_path': imagePath, 'date': date, 'created_at': createdAt};
  factory ExpenseModel.fromMap(Map<String, dynamic> m) => ExpenseModel(id: m['id'], amount: (m['amount'] as num).toDouble(), category: m['category'], note: m['note'], imagePath: m['image_path'], date: m['date'], createdAt: m['created_at']);
  ExpenseModel copyWith({int? id, double? amount, String? category, String? note, String? imagePath, String? date, String? createdAt}) => ExpenseModel(id: id ?? this.id, amount: amount ?? this.amount, category: category ?? this.category, note: note ?? this.note, imagePath: imagePath ?? this.imagePath, date: date ?? this.date, createdAt: createdAt ?? this.createdAt);
}

class SavingModel {
  final int? id; final double amount; final String? note; final String type; final String date; final String createdAt;
  SavingModel({this.id, required this.amount, this.note, required this.type, required this.date, required this.createdAt});
  Map<String, dynamic> toMap() => {if (id != null) 'id': id, 'amount': amount, 'note': note, 'type': type, 'date': date, 'created_at': createdAt};
  factory SavingModel.fromMap(Map<String, dynamic> m) => SavingModel(id: m['id'], amount: (m['amount'] as num).toDouble(), note: m['note'], type: m['type'], date: m['date'], createdAt: m['created_at']);
}

class GoalModel {
  final int? id; final String title; final double targetAmount; final String period; final String startDate; final String? endDate; final bool isActive; final String createdAt;
  GoalModel({this.id, required this.title, required this.targetAmount, required this.period, required this.startDate, this.endDate, this.isActive = true, required this.createdAt});
  Map<String, dynamic> toMap() => {if (id != null) 'id': id, 'title': title, 'target_amount': targetAmount, 'period': period, 'start_date': startDate, 'end_date': endDate, 'is_active': isActive ? 1 : 0, 'created_at': createdAt};
  factory GoalModel.fromMap(Map<String, dynamic> m) => GoalModel(id: m['id'], title: m['title'], targetAmount: (m['target_amount'] as num).toDouble(), period: m['period'], startDate: m['start_date'], endDate: m['end_date'], isActive: (m['is_active'] as int) == 1, createdAt: m['created_at']);
}
