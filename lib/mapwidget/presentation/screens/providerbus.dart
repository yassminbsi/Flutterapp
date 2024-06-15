import 'package:flutter/material.dart';

class SelectedStationProvider extends ChangeNotifier {
 // String? sourceStationId;
  String _destinationStationId = "";
  String _sourceStationId= "";

 String get destinationStationId => _destinationStationId ;
 String get sourceStationId => _sourceStationId;

  set destinationStationId (String value) {
    _destinationStationId = value;
    notifyListeners();
  }
  set sourceStationId (String value) {
    _sourceStationId = value;
    notifyListeners();
  }
}

