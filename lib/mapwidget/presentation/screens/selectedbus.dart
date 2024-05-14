import 'package:flutter/material.dart';

class SelectedBusDocumentIdProvider extends ChangeNotifier {
  String _selectedBusDocumentId = "";

  String get selectedBusDocumentId => _selectedBusDocumentId;

  set selectedBusDocumentId(String value) {
    _selectedBusDocumentId = value;
    notifyListeners();
  }
}