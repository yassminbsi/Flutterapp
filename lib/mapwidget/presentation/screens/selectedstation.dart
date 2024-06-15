import 'package:flutter/material.dart';

class SelectedStationDocumentIdProvider extends ChangeNotifier {
  String _selectedStationDocumentId = "";

  String get selectedStationDocumentId => _selectedStationDocumentId;

  set selectedStationDocumentId(String value) {
    _selectedStationDocumentId = value;
    notifyListeners();
  }
}