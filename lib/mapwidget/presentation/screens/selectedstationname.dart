import 'package:flutter/material.dart';

class SelectedStationNameProvider with ChangeNotifier {
  String? _selectedStationName;
  String? _selectedStationId;

  String? get selectedStationName => _selectedStationName;
  String? get selectedStationId => _selectedStationId;

  void setSelectedStation(String name, String id) {
    _selectedStationName = name;
    _selectedStationId = id;
    notifyListeners();
  }
}