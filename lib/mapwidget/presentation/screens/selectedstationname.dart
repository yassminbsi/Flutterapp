import 'package:flutter/material.dart';

class SelectedStationNameProvider with ChangeNotifier {
  String? _selectedStationName1;
  String? _selectedStationId1;
  String? _selectedStationName2;
  String? _selectedStationId2;

  String? get selectedStationName1 => _selectedStationName1;
  String? get selectedStationId1 => _selectedStationId1;
  String? get selectedStationName2 => _selectedStationName2;
  String? get selectedStationId2 => _selectedStationId2;

  void setSelectedStation1(String name, String id) {
    _selectedStationName1 = name;
    _selectedStationId1 = id;
    notifyListeners();
  }
   void setSelectedStation2(String name, String id) {
    _selectedStationName2 = name;
    _selectedStationId2 = id;
    notifyListeners();
  }
  void resetStations() {
    _selectedStationId1 = null;
    _selectedStationName1 = "Sélectionner une station...";
  _selectedStationId2 = null;
    _selectedStationName1= "station destination";
    notifyListeners();
  }
}