import 'package:flutter/material.dart';
class AppColors {
  static const primary = Color(0xFF00C896);
  static const income = Color(0xFF00C896);
  static const expense = Color(0xFFFF6B6B);
  static const saving = Color(0xFF4ECDC4);
  static const warning = Color(0xFFFFBE0B);
  static const info = Color(0xFF3A86FF);
  static const categoryColors = {
    'comida': Color(0xFFFF6B6B),'transporte': Color(0xFF3A86FF),
    'servicios': Color(0xFFFFBE0B),'salud': Color(0xFF06D6A0),
    'entretenimiento': Color(0xFFFF006E),'ropa': Color(0xFF8338EC),
    'educacion': Color(0xFFFB5607),'otros': Color(0xFF8D99AE),
  };
}
class AppStrings {
  static const incomeTypes = ['domicilios', 'otros'];
  static const expenseCategories = ['comida','transporte','servicios','salud','entretenimiento','ropa','educacion','otros'];
  static const categoryIcons = {'comida':'🍔','transporte':'🚌','servicios':'💡','salud':'💊','entretenimiento':'🎮','ropa':'👕','educacion':'📚','otros':'📦'};
  static const periodTypes = ['diario', 'semanal', 'mensual'];
}
