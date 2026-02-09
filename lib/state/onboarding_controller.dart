import 'package:flutter/material.dart';

/// Central controller holding auth + onboarding data.
class OnboardingController extends ChangeNotifier {
  // Auth
  String? email;
  String? password;
  String displayName = 'Youssef';

  // Basic metrics
  int age = 25;
  double weight = 70; // kg
  double height = 170; // cm
  bool useMetricWeight = true; // true: kg, false: lb
  bool useMetricHeight = true; // true: cm, false: inches

  // Derived
  double get bmi {
    final hMeters = height / 100;
    if (hMeters == 0) return 0;
    return weight / (hMeters * hMeters);
  }

  // Step 3 details
  String? gender; // 'male', 'female', 'other'
  bool hasBackPain = false;
  bool hasKneePain = false;
  bool hasHeartIssue = false;

  String? goal; // e.g. 'Lose weight', 'Build muscle'

  void setAuth(String email, String password) {
    this.email = email;
    this.password = password;
    notifyListeners();
  }

  void setAge(int value) {
    age = value;
    notifyListeners();
  }

  void setWeight(double value) {
    weight = value;
    notifyListeners();
  }

  void setHeight(double value) {
    height = value;
    notifyListeners();
  }

  void toggleWeightUnit() {
    useMetricWeight = !useMetricWeight;
    notifyListeners();
  }

  void toggleHeightUnit() {
    useMetricHeight = !useMetricHeight;
    notifyListeners();
  }

  void setGender(String value) {
    gender = value;
    notifyListeners();
  }

  void setHealth({
    bool? backPain,
    bool? kneePain,
    bool? heartIssue,
  }) {
    hasBackPain = backPain ?? hasBackPain;
    hasKneePain = kneePain ?? hasKneePain;
    hasHeartIssue = heartIssue ?? hasHeartIssue;
    notifyListeners();
  }

  void setGoal(String value) {
    goal = value;
    notifyListeners();
  }
}

