import 'package:flutter/material.dart';

enum MealType { breakfast, lunch, dinner, snack }

class MealEntry {
  MealEntry({
    required this.id,
    required this.type,
    required this.date,
    required this.timeOfDay,
    required this.name,
    required this.carbs,
    required this.fats,
    required this.protein,
    this.estimatedCalories,
  });

  final String id;
  final MealType type;
  final DateTime date;
  final TimeOfDay timeOfDay;
  final String name;
  final double carbs;
  final double fats;
  final double protein;
  final double? estimatedCalories;
}

class CalorieTrackerController extends ChangeNotifier {
  DateTime selectedDate = DateTime.now();
  final List<MealEntry> _entries = [];

  List<MealEntry> mealsForSelectedDate(MealType type) {
    return _entries
        .where((e) =>
            e.type == type &&
            e.date.year == selectedDate.year &&
            e.date.month == selectedDate.month &&
            e.date.day == selectedDate.day)
        .toList();
  }

  double get totalCaloriesForSelectedDate {
    return _entries
        .where((e) =>
            e.date.year == selectedDate.year &&
            e.date.month == selectedDate.month &&
            e.date.day == selectedDate.day)
        .fold(0.0, (sum, e) => sum + (e.estimatedCalories ?? 0));
  }

  void setSelectedDate(DateTime date) {
    selectedDate = date;
    notifyListeners();
  }

  void addEntry(MealEntry entry) {
    _entries.add(entry);
    notifyListeners();
  }
}

