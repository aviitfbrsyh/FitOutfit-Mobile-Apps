import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PersonalizationData {
  // Step 1: Gender Selection
  String? selectedGender;

  // Step 2: Photo Upload // Add this new field

  // Sep 3: Body Shape
  String? selectedBodyShape;

  // Step 4: Skin Tone and Undertone
  Color? selectedSkinTone;
  String? selectedUndertone; // Add this property

  // Step 5: Hair Color
  String? selectedHairColor;

  // Step 6: Personal Color
  String? selectedPersonalColor;

  // Step 7: Style Preferences
  List<String> selectedStyles = [];

  // Default constructor
  PersonalizationData();

  // Method untuk validasi setiap step
  bool isStepComplete(int step) {
    switch (step) {
      case 0:
        return selectedGender != null;
      case 1:
        return true; // Photo optional
      case 2:
        return selectedBodyShape != null;
      case 3:
        return selectedSkinTone != null && selectedUndertone != null;
      case 4:
        return selectedHairColor != null;
      case 5:
        return selectedPersonalColor != null;
      case 6:
        return selectedStyles.isNotEmpty;
      case 7:
        return true; // Completion page
      default:
        return false;
    }
  }

  // Method untuk cek apakah bisa lanjut ke step berikutnya
  bool canProceedFromStep(int step) {
    switch (step) {
      case 0:
        return selectedGender != null;
      case 1:
        return true; // Photo upload is optional
      case 2:
        return selectedBodyShape != null;
      case 3:
        return selectedSkinTone != null;
      case 4:
        return selectedHairColor != null;
      case 5:
        return selectedPersonalColor != null;
      case 6:
        return selectedStyles.isNotEmpty;
      case 7:
        return true; // Completion step
      default:
        return false;
    }
  }

  // Method untuk mendapatkan progress completion
  double getProgressPercentage() {
    int completedSteps = 0;
    for (int i = 0; i < 7; i++) {
      // 7 steps (excluding completion)
      if (isStepComplete(i)) {
        completedSteps++;
      }
    }
    return completedSteps / 7.0;
  }

  // Convert to Map untuk save ke database/SharedPreferences
  Map<String, dynamic> toJson() {
    return {
      'selectedGender': selectedGender,
      'selectedBodyShape': selectedBodyShape,
      'selectedSkinTone': selectedSkinTone?.toARGB32(),
      'selectedUndertone': selectedUndertone,
      'selectedHairColor': selectedHairColor,
      'selectedPersonalColor': selectedPersonalColor,
      'selectedStyles': selectedStyles,
   
    };
  }

  // Create from Map untuk load dari database/SharedPreferences
  factory PersonalizationData.fromJson(Map<String, dynamic> json) {
    final data = PersonalizationData();
    data.selectedGender = json['selectedGender'];
    data.selectedBodyShape = json['selectedBodyShape'];
    data.selectedSkinTone =
        json['selectedSkinTone'] != null
            ? Color(json['selectedSkinTone'])
            : null;
    data.selectedUndertone = json['selectedUndertone'];
    data.selectedHairColor = json['selectedHairColor'];
    data.selectedPersonalColor = json['selectedPersonalColor'];
    data.selectedStyles = List<String>.from(json['selectedStyles'] ?? []);
    return data;
  }

  // Method untuk reset semua data
  void reset() {
    selectedGender = null;

    selectedBodyShape = null;
    selectedSkinTone = null;
    selectedUndertone = null;
    selectedHairColor = null;
    selectedPersonalColor = null;
    selectedStyles.clear();
  }

  // Method untuk mendapatkan summary data
  String getSummary() {
    List<String> summary = [];

    if (selectedGender != null) {
      summary.add('Gender: $selectedGender');
    }
    
    if (selectedBodyShape != null) {
      summary.add('Body Shape: $selectedBodyShape');
    }
    if (selectedSkinTone != null) {
      summary.add('Skin Tone: Selected');
    }
    if (selectedUndertone != null) {
      summary.add('Undertone: $selectedUndertone');
    }
    if (selectedHairColor != null) {
      summary.add('Hair Color: $selectedHairColor');
    }
    if (selectedPersonalColor != null) {
      summary.add('Personal Color: $selectedPersonalColor');
    }
    if (selectedStyles.isNotEmpty) {
      summary.add('Styles: ${selectedStyles.join(", ")}');
    }

    return summary.join('\n');
  }
}

Future<void> savePersonalizationData(PersonalizationData data) async {
  final user = FirebaseAuth.instance.currentUser; // <-- di sini
  final uid = user?.uid;                          // <-- di sini
  if (uid == null) return;

  await FirebaseFirestore.instance
      .collection('personalisasi')
      .doc(uid)
      .set(data.toJson());
}
