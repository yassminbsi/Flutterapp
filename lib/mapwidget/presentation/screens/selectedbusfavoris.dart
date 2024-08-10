import 'package:flutter/material.dart';

class SelectedBusDocumentIdProviderForFavoris extends ChangeNotifier {
  // Private variable to hold the selected bus document ID
  String _selectedBusDocumentIdForFavoris = "";

  // Getter to retrieve the selected bus document ID
  String get selectedBusDocumentIdForFavoris => _selectedBusDocumentIdForFavoris;

  // Setter to update the selected bus document ID and notify listeners
  set selectedBusDocumentIdForFavoris(String value) {
    _selectedBusDocumentIdForFavoris = value;
    notifyListeners();
  }
}