import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/mapwidget/business_logic/cubit/maps/maps_cubit.dart';
import 'package:flutter_app/mapwidget/constnats/my_colors.dart';
import 'package:flutter_app/mapwidget/data/models/Place_suggestion.dart';
import 'package:flutter_app/mapwidget/data/models/place.dart';
import 'package:flutter_app/mapwidget/data/models/place_directions.dart';
import 'package:flutter_app/mapwidget/helpers/location_helper.dart';
import 'package:flutter_app/mapwidget/presentation/screens/custombloclistener.dart';
import 'package:flutter_app/mapwidget/presentation/screens/selectedbus.dart';
import 'package:flutter_app/mapwidget/presentation/screens/selectedstationname.dart';
import 'package:flutter_app/mapwidget/presentation/widgets/distance_and_time.dart';
import 'package:flutter_app/mapwidget/presentation/widgets/place_item.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_google_maps_webservices/directions.dart' as gmaps;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:material_floating_search_bar_2/material_floating_search_bar_2.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';


class SelectedStationssProvider with ChangeNotifier {
  String? station1Id;
  String? station2Id;
  String _station1Name = "";
  String _station2Name = "";

  String get station1Name => _station1Name;
  String get station2Name => _station2Name;

  void setStation1(String id, String name) {
    station1Id = id;
    _station1Name = name;
    notifyListeners();
  }

  void setStation2(String id, String name) {
    station2Id = id;
    _station2Name = name;
    notifyListeners();
  }

  void setStations(String id1, String name1, String id2, String name2) {
    station1Id = id1;
    _station1Name = name1;
    station2Id = id2;
    _station2Name = name2;
  }
}
class MapLigne extends StatefulWidget {
  const MapLigne({super.key});

  @override
  State<MapLigne> createState() => _MapLigneState();
}

class _MapLigneState extends State<MapLigne> {
List<PlaceSuggestion> places = [];
  FloatingSearchBarController controller = FloatingSearchBarController();
  FloatingSearchBarController controller2 = FloatingSearchBarController();
  static Position? position;
  static Position? positionStation;
  Completer<GoogleMapController> _mapController = Completer();

  static final CameraPosition _myCurrentLocationCameraPosition = CameraPosition(
    bearing: 0.0,
    target: LatLng(position!.latitude, position!.longitude),
    tilt: 0.0,
    zoom: 20,
  );

  // these variables for getPlaceLocation
  Set<Marker> markers = Set();
  late PlaceSuggestion placeSuggestion;
  late Place selectedPlace;
  late Marker searchedPlaceMarker;
  late Marker currentLocationMarker;
  late CameraPosition goToSearchedForPlace;
  late final Timer _debounce;
  String? selectedStation1Id;
String? selectedStation2Id;
double? _documentLatitude;
double? _documentLongitude;
double? startStationLatitude;
double? startStationLongitude;
double? endStationLatitude;
double? endStationLongitude;
  LatLng? selectedStation1;
  LatLng? selectedStation2;
  String selectedStation =  'Station Départ';
  String estimatedTimeToStation='';
  List<String> stationNames = [];
  final FocusNode locationFocusNode = FocusNode();
  FocusNode destinationLocationFocusNode = FocusNode();
  List<QueryDocumentSnapshot> data = [];
  bool isLoading = true;
  String  selectedstationn= 'Station Destination';
  Future<void> getData() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection("bus").get();
    setState(() {
      data.addAll(querySnapshot.docs);
       isLoading = false;
    });
  }
   Widget buildSuggestionsBloc() {
     final mapsCubit = BlocProvider.of<MapsCubit>(context);
    return BlocBuilder<MapsCubit, MapsState>(
      builder: (context, state) {
        if (state is PlacesLoaded) {
          places = (state).places;
          if (places.length != 0) {
            return buildPlacesList();
          } else {
            return Container();
          }
        } else {
          return Container();
        }
      },
    );
  }

  Widget buildSelectedPlaceLocationBloc() {
    final mapsCubit = BlocProvider.of<MapsCubit>(context);
    return CustomBlocListener<MapsCubit, MapsState>(
      listener: (context, state) {
        if (state is PlaceLocationLoaded) {
          selectedPlace = (state).place;

          goToMySearchedForLocation();
          getDirections();
        }
      },
      bloc: mapsCubit,
      listenWhen: (previous, current) {
        return true; 
      },
      child: Container(),
    );
  }
  void getDirections() {
    BlocProvider.of<MapsCubit>(context).emitPlaceDirections(
      LatLng(position!.latitude, position!.longitude),
      LatLng(selectedPlace.result.geometry.location.lat,
          selectedPlace.result.geometry.location.lng),
    );
  }
    Widget buildDirectionsBloc() {
    final mapsCubit = BlocProvider.of<MapsCubit>(context);
     return CustomBlocListener<MapsCubit, MapsState>(
      listener: (context, state) {
         if (state is DirectionsLoaded) {
          placeDirections = (state).placeDirections;

          getPolylinePoints();
          setState(() {
             
            addMarker(position!.latitude,
                position!.longitude); 
         });
          
        }
      },
     bloc: mapsCubit, 
      listenWhen: (previous, current) {
       
        return true; 
      },
      child: MyBloc(),
    );
  }
  Widget MyBloc() {
    return Container(
     
    );
  }
String departStation = '';
String nextStation = '';
String durationToNext = '';
/*Widget MyCard(String selectedBusDocumentId) {
  return FutureBuilder<DocumentSnapshot>(
    future: FirebaseFirestore.instance.collection('bus').doc(selectedBusDocumentId).get(),
    builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return CircularProgressIndicator();
      } else if (snapshot.hasError) {
        return Text('Error: ${snapshot.error}');
      } else if (!snapshot.hasData || !snapshot.data!.exists) {
        return Text('Document does not exist');
      } else {
        // Retrieve necessary data from Firestore
        String? firstDeparture = snapshot.data!.get('firstdepart');
        String? totalDuration = snapshot.data!.get('route_details.total_duration');
        String instantaneousDuration = ''; // You need to calculate this based on your implementation

        // Perform the calculation
        int R;
        try {
          R = (int.parse(instantaneousDuration) - int.parse(firstDeparture!)) ~/ int.parse(totalDuration!);
        } catch (e) {
          print('Error calculating R: $e');
          R = 0; // Default value or fallback behavior
        }

        // Determine if the bus is going or returning
        String busDirection = (R % 2 == 0) ? 'Go' : 'Return';

        // Display the calculated duration
        return Material(
          clipBehavior: Clip.antiAlias,
          shape: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Color.fromARGB(255, 221, 221, 221)),
          ),
          child: Container(
            color: Color.fromARGB(255, 236, 236, 236),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Center(
                    child: Text(
                      "Bus Direction: $busDirection",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 5.0),
                  Center(
                    child: Text(
                      "Duration to Selected Station: ${R.toString()} minutes",
                      style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    },
  );
} */
Widget MyCard(String selectedBusDocumentId, String selectedStation, String estimatedTimeToStation) {
  return FutureBuilder<DocumentSnapshot>(
    future: FirebaseFirestore.instance.collection('bus').doc(selectedBusDocumentId).get(),
    builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return CircularProgressIndicator();
      } else if (snapshot.hasError) {
        return Text('Erreur: ${snapshot.error}');
      } else if (!snapshot.hasData || !snapshot.data!.exists) {
        return Text('Le document n\'existe pas');
      } else {
        try {
          // Récupérer les données nécessaires depuis Firestore
          String nomBus = snapshot.data!.get('nombus');
          String? firstDeparture = snapshot.data!.get('firstdepart');
          String? totalDuration = snapshot.data!.get('route_details.total_duration');
          String instantaneousTime = DateTime.now().toIso8601String(); // Temps actuel au format ISO8601

          // Valider et parser les données
          if (firstDeparture == null || totalDuration == null) {
            throw Exception('Données requises manquantes pour le calcul');
          }

          // Parse the time string with the correct format
          DateTime departureTime = _parseTime(firstDeparture);
          double totalDurationMinutes = double.parse(totalDuration.replaceAll(' min', ''));

          // Calculer le temps écoulé depuis le départ du premier trajet
          int minutesSinceDeparture = DateTime.parse(instantaneousTime).difference(departureTime).inMinutes;

          // Calculer le nombre de trajets complets effectués
          int R = minutesSinceDeparture ~/ totalDurationMinutes.toInt();
          
          // Déterminer si le bus va ou revient
          String busDirection = (R % 2 == 0) ? 'Aller' : 'Retour';

          // Définir le widget à afficher en fonction de selectedStation
          Widget contentWidget;
          if (selectedStation == "Station Départ") {
            contentWidget = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Center(
                  child: Text(
                    " Sélectionner une station...",
                    style: TextStyle(fontSize: 15, color: Color(0xFFffd400)),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            );
          } else {
            contentWidget = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Center(
                  child: Text(
                    "Ligne $nomBus",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFffd400)),
                    textAlign: TextAlign.center,
                  ),
                ), 
                SizedBox(height: 5.0),
                Center(
                  child: RichText(
                    textAlign: TextAlign.center, // Center-align the text within the RichText
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Temps d\'arrivée de bus au station $selectedStation:',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                        TextSpan(
                          text: ' $estimatedTimeToStation',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
          
                ),
              ],
            );
          }

          // Afficher la carte avec le contenu conditionnel
          return Material(
            clipBehavior: Clip.antiAlias,
            shape: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(color: Color(0xFFffd400), width: 2.0 ),
            ),
            child: Container(
              color: Color.fromARGB(255, 43, 26, 92),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: contentWidget,
              ),
            ),
          );
        } catch (e) {
          return Text('Erreur de calcul de la durée: $e');
        }
      }
    },
  );
}








  // Function to parse time string in "HH:mm" format
  DateTime _parseTime(String timeString) {
    final parts = timeString.split(':');
    if (parts.length != 2) {
      throw FormatException('Invalid time format: $timeString');
    }
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return DateTime(2024, 1, 1, hour, minute); // Date doesn't matter, only time is considered
  }









 void buildCameraNewPosition() {
    goToSearchedForPlace = CameraPosition(
      bearing: 0.0,
      tilt: 0.0,
      target: LatLng(
        selectedPlace.result.geometry.location.lat,
        selectedPlace.result.geometry.location.lng,
      ),
      zoom: 13,
    );
  }

  void updateSearchBarQuery(double latitude, double longitude) {
    String query = 'Lat: $latitude, Lng: $longitude';
    controller.query = query;
  }
  PlaceDirections? placeDirections;
  var progressIndicator = false;
  late List<LatLng> polylinePoints=[];
  late String duration ='';
  var isSearchedPlaceMarkerClicked = false;
  var isTimeAndDistanceVisible = false;
  List<String> selectedStations = [];
  late String time;
  late String distance;
  List<double> latitudes = [];
  List<double> longitudes = [];
  bool showListTextField = true;
  bool showStationTextField = false;
  String? selectedStationId;
  LatLng? documentLatLng;
  String? stationId;
    
  Map<PolylineId, Polyline> polylines = {};
  String? selectedLocationId; 
  double? selectedDocumentLatitude; 
  double? selectedDocumentLongitude;
  

  @override
  void initState() {
    super.initState();
    getMyCurrentLocation();
    _goToMyCurrentLocation();
    getData();  
     markLocationOnMap;
    drawPolylineBetweenLocationAndDocument();
    final selectedBusProvider = Provider.of<SelectedBusDocumentIdProvider>(context, listen: false); 
    _performInitialActions(selectedBusProvider.selectedBusDocumentId);

    
  }
Future<void> _performInitialActions(String selectedBusDocumentId) async {
    final selectedStationProvider = Provider.of<SelectedStationNameProvider>(context, listen: false);
    final selectedStationsProvider = Provider.of<SelectedStationssProvider>(context, listen: false);
    String? selectedStationName = selectedStationProvider.selectedStationName;
    String? stationId = selectedStationProvider.selectedStationId;
      // Fetch the selected bus document
    DocumentSnapshot busSnapshot = await FirebaseFirestore.instance
        .collection('bus')
        .doc(selectedBusDocumentId)
        .get();
    if (!busSnapshot.exists) {
      print("Selected bus document not found.");
      return;
    }

    Map<String, dynamic> busData = busSnapshot.data() as Map<String, dynamic>;

    if (busData['nomstation'] == null) {
      print("No stations found in the selected bus document.");
      return;
    }
    if (selectedStationName != null && stationId != null) {
      // Fetch station document and update end station coordinates
      QuerySnapshot stationSnapshot = await FirebaseFirestore.instance
          .collection('station')
          .where('nomstation', isEqualTo: selectedStationName)
          .get();
      if (stationSnapshot.docs.isNotEmpty) {
        DocumentSnapshot stationDoc = stationSnapshot.docs.first;
        setState(() {
          startStationLatitude = double.tryParse(stationDoc['latitude'] ?? '');
          startStationLongitude = double.tryParse(stationDoc['longtude'] ?? '');
          selectedStation = selectedStationName;
        });

        if (startStationLatitude != null && startStationLongitude != null) {
          markLocationOnMap(stationId);
          drawPolylineBetweenLocationAndDocument();
          selectedStationsProvider.setStation1(stationId, selectedStationName);
          updateSelectedStations(
            LatLng(startStationLatitude!, startStationLongitude!),
            selectedStation2 ?? LatLng(0.0, 0.0), // Pass the existing second station or a default value
          );

          // Calculate the duration
          try {DocumentSnapshot busSnapshot = await FirebaseFirestore.instance
        .collection('bus')
        .doc(selectedBusDocumentId)
        .get();

            if (busSnapshot.exists) {
              DateTime currentTime = DateTime.now();
              DateTime firstDeparture = _parseTime(busSnapshot['firstdepart']);
              double totalDurationMinutes = double.parse(busSnapshot['route_details']['total_duration'].replaceAll(' min', ''));

              int minutesSinceDeparture = currentTime.difference(firstDeparture).inMinutes;
              int currentTripMinutes = minutesSinceDeparture % totalDurationMinutes.toInt();
              List stations = busSnapshot['route_details']['stations'];
              int currentCycle = minutesSinceDeparture ~/ totalDurationMinutes.toInt();
              bool isGoDirection = currentCycle % 2 == 0;

              int selectedIndex = stations.indexWhere((station) => station['name'] == selectedStationName);

              if (selectedIndex != -1) {
                double timeToStation = 0.0;

                if (isGoDirection) {
                  double durationToSelectedStation = 0.0;
                  for (int i = 0; i <= selectedIndex; i++) {
                    durationToSelectedStation += double.parse(stations[i]['duration_to_next'].replaceAll(' min', ''));
                  }
                  if (currentTripMinutes <= durationToSelectedStation) {
                    timeToStation = durationToSelectedStation - currentTripMinutes;
                  } else {
                    double remainingDuration = 0.0;
                    for (int i = selectedIndex; i < stations.length; i++) {
                      remainingDuration += double.parse(stations[i]['duration_to_next'].replaceAll(' min', ''));
                    }
                    double returnRouteDuration = 0.0;
                    for (int i = stations.length - 2; i >= selectedIndex; i--) {
                      returnRouteDuration += double.parse(stations[i]['duration_to_next'].replaceAll(' min', ''));
                    }
                    timeToStation = remainingDuration + returnRouteDuration - currentTripMinutes;
                  }
                } else {
                  double durationToSelectedStation = 0.0;
                  for (int i = stations.length - 2; i >= selectedIndex; i--) {
                    durationToSelectedStation += double.parse(stations[i]['duration_to_next'].replaceAll(' min', ''));
                  }
                  if (currentTripMinutes <= durationToSelectedStation) {
                    timeToStation = durationToSelectedStation - currentTripMinutes;
                  } else {
                    double remainingDuration = 0.0;
                    for (int i = selectedIndex - 1; i >= 0; i--) {
                      remainingDuration += double.parse(stations[i]['duration_to_next'].replaceAll(' min', ''));
                    }
                    double goRouteDuration = 0.0;
                    for (int i = 0; i < selectedIndex; i++) {
                      goRouteDuration += double.parse(stations[i]['duration_to_next'].replaceAll(' min', ''));
                    }
                    timeToStation = remainingDuration + goRouteDuration - currentTripMinutes;
                  }
                }

                setState(() {
                  estimatedTimeToStation = '${timeToStation.toStringAsFixed(2)} minutes';
                });
              } else {
                setState(() {
                  estimatedTimeToStation = 'Station not found';
                });
              }
            }
          } catch (e) {
            print('Error calculating time to arrival: $e');
            setState(() {
              estimatedTimeToStation = 'Error calculating time';
            });
          }
        }
      }
    }
  }

double calculateDistance(double startLatitude, double startLongitude, double endLatitude, double endLongitude) {
  return Geolocator.distanceBetween(startLatitude, startLongitude, endLatitude, endLongitude);
}

void findNearestStation(String selectedBusDocumentId) async {
   try {
    Position userLocation = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    double userLatitude = userLocation.latitude;
    double userLongitude = userLocation.longitude;

    // Fetch the selected bus document
    DocumentSnapshot busSnapshot = await FirebaseFirestore.instance
        .collection('bus')
        .doc(selectedBusDocumentId)
        .get();
    if (!busSnapshot.exists) {
      print("Selected bus document not found.");
      return;
    }

    Map<String, dynamic> busData = busSnapshot.data() as Map<String, dynamic>;

    if (busData['nomstation'] == null) {
      print("No stations found in the selected bus document.");
      return;
    }

    List<String> stationIds = [];
    List<String> nomstation = List<String>.from(busData['nomstation']);
    for (String station in nomstation) {
      RegExp regExp = RegExp(r"\(ID: (.+?)\)");
      Match? match = regExp.firstMatch(station);
      if (match != null) {
        stationIds.add(match.group(1)!);
      }
    }

    String nearestStationId = '';
    double minDistance = double.infinity;

    for (String stationId in stationIds) {
      DocumentSnapshot stationSnapshot = await FirebaseFirestore.instance
          .collection('station')
          .doc(stationId)
          .get();

      if (!stationSnapshot.exists) {
        continue;
      }

      double stationLatitude = double.tryParse(stationSnapshot['latitude'] ?? '') ?? 0.0;
      double stationLongitude = double.tryParse(stationSnapshot['longtude'] ?? '') ?? 0.0;

      double distance = calculateDistance(userLatitude, userLongitude, stationLatitude, stationLongitude);

      if (distance < minDistance) {
        minDistance = distance;
        nearestStationId = stationId;
      }
    }

    if (nearestStationId.isEmpty) {
      print("No nearest station found.");
      return;
    }

    DocumentSnapshot nearestStationSnapshot = await FirebaseFirestore.instance
        .collection('station')
        .doc(nearestStationId)
        .get();

    String nearestStationName = nearestStationSnapshot.get('nomstation');
    double nearestStationLatitude = double.tryParse(nearestStationSnapshot['latitude'] ?? '') ?? 0.0;
    double nearestStationLongitude = double.tryParse(nearestStationSnapshot['longtude'] ?? '') ?? 0.0;

    // Calculate the duration to the nearest station
    try {
      if (busSnapshot.exists) {
        DateTime? firstDeparture = busData['firstdepart'] != null ? _parseTime(busData['firstdepart']) : null;

        if (firstDeparture != null) {
          double totalDurationMinutes = double.parse(busData['route_details']['total_duration'].replaceAll(' min', ''));
          int minutesSinceDeparture = DateTime.now().difference(firstDeparture).inMinutes;
          int currentTripMinutes = minutesSinceDeparture % totalDurationMinutes.toInt();
          List stations = busData['route_details']['stations'];
          int currentCycle = minutesSinceDeparture ~/ totalDurationMinutes.toInt();
          bool isGoDirection = currentCycle % 2 == 0;
          int selectedIndex = stations.indexWhere((station) => station['name'] == nearestStationName);

          if (selectedIndex != -1) {
            double timeToStation = 0.0;

            if (isGoDirection) {
              double durationToSelectedStation = 0.0;
              for (int i = 0; i <= selectedIndex; i++) {
                durationToSelectedStation += double.parse(stations[i]['duration_to_next'].replaceAll(' min', ''));
              }
              if (currentTripMinutes <= durationToSelectedStation) {
                timeToStation = durationToSelectedStation - currentTripMinutes;
              } else {
                double remainingDuration = 0.0;
                for (int i = selectedIndex; i < stations.length; i++) {
                  remainingDuration += double.parse(stations[i]['duration_to_next'].replaceAll(' min', ''));
                }
                double returnRouteDuration = 0.0;
                for (int i = stations.length - 2; i >= selectedIndex; i--) {
                  returnRouteDuration += double.parse(stations[i]['duration_to_next'].replaceAll(' min', ''));
                }
                timeToStation = remainingDuration + returnRouteDuration - currentTripMinutes;
              }
            } else {
              double durationToSelectedStation = 0.0;
              for (int i = stations.length - 2; i >= selectedIndex; i--) {
                durationToSelectedStation += double.parse(stations[i]['duration_to_next'].replaceAll(' min', ''));
              }
              if (currentTripMinutes <= durationToSelectedStation) {
                timeToStation = durationToSelectedStation - currentTripMinutes;
              } else {
                double remainingDuration = 0.0;
                for (int i = selectedIndex - 1; i >= 0; i--) {
                  remainingDuration += double.parse(stations[i]['duration_to_next'].replaceAll(' min', ''));
                }
                double goRouteDuration = 0.0;
                for (int i = 0; i < selectedIndex; i++) {
                  goRouteDuration += double.parse(stations[i]['duration_to_next'].replaceAll(' min', ''));
                }
                timeToStation = remainingDuration + goRouteDuration - currentTripMinutes;
              }
            }

            setState(() {
              estimatedTimeToStation = '${timeToStation.toStringAsFixed(2)} minutes';
            });
          } else {
            setState(() {
              estimatedTimeToStation = 'Station not found';
            });
          }
        } else {
          setState(() {
            estimatedTimeToStation = 'Error: First departure time is null';
          });
        }
      }
    } catch (e) {
      print('Error calculating time to arrival: $e');
      setState(() {
        estimatedTimeToStation = 'Error calculating time';
      });
    }

    setState(() {
      selectedStation = nearestStationName;
      startStationLatitude = nearestStationLatitude;
      startStationLongitude = nearestStationLongitude;
      updateSelectedStations(
        LatLng(startStationLatitude!, startStationLongitude!),
        selectedStation2 ?? LatLng(0.0, 0.0),
      );
    });

    markLocationOnMap(nearestStationId);
    addMarker(nearestStationLatitude, nearestStationLongitude);
    drawPolylineBetweenLocationAndDocument();

  } catch (error) {
    print("Error finding nearest station: $error");
  }
}

  Future<void> getMyCurrentLocation() async {
    position = await LocationHelper.getCurrentLocation().whenComplete(() {
      setState(() {});
    });
  }
  
   void updateSelectedStations(LatLng station1, LatLng station2) {
    setState(() {
      selectedStation1 = station1;
      selectedStation2 = station2;

      // Clear existing markers and add only selected station markers
      markers.clear();
      markers.add(Marker(
        markerId: MarkerId('station1'),
        position: station1,
      ));
      markers.add(Marker(
        markerId: MarkerId('station2'),
        position: station2,
      ));
    });
  }
  Widget buildMap() {
    Set<Marker> selectedMarkers = {};

  if (selectedStation1 != null) {
    selectedMarkers.add(Marker(
      markerId: MarkerId('station1'),
      position: selectedStation1!,
    ));
  }

  if (selectedStation2 != null) {
    selectedMarkers.add(Marker(
      markerId: MarkerId('station2'),
      position: selectedStation2!,
    ));
  }

    return GoogleMap(
      mapType: MapType.normal,
      myLocationEnabled: true,
      zoomControlsEnabled: false,
      myLocationButtonEnabled: false,
      markers: selectedMarkers,
      initialCameraPosition: _myCurrentLocationCameraPosition,
      onMapCreated: (GoogleMapController controller) {
        _mapController.complete(controller);
      },
      polylines: {
      if (polylinePoints.isNotEmpty)
        Polyline(
          polylineId: PolylineId('polyline'),
          points: polylinePoints,
          color: MyColors.blue,
          width: 5,
        ),
    },
    
    );
  }
 
  Widget buildDurationDisplay() {
  return Positioned(
    top: 20,
    left: 20,
    child: Container(
      padding: EdgeInsets.all(10),
      color: Colors.white,
      child: Text(
        duration,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
  );
}
  Future<void> _goToMyCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    String currentLocation =
        'Lat: ${position.latitude}, Lng: ${position.longitude}';
    controller.query = currentLocation;
  }

 final TextEditingController locationController = TextEditingController();
// final TextEditingController destinationController = TextEditingController();
bool showAdditionalTextField = true;

void toggleAdditionalTextFieldVisibility() {
  setState(() {
    showAdditionalTextField = !showAdditionalTextField;
  });
}

void toggleTextFieldVisibility({bool showList = true, bool showStation = true}) {
  setState(() {
    showListTextField = showList;
    showStationTextField = showStation;
  });
}

void hideOtherTextField({bool showList = true, bool showStation = true}) {
  setState(() {
    showListTextField = showList;
    showStationTextField = showStation;
  });
}

 Widget buildFloatingSearchBar() {
    final selectedBusProvider = Provider.of<SelectedBusDocumentIdProvider>(context);
    final selectedStationsProvider = Provider.of<SelectedStationssProvider>(context);
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    
    return Stack(
      children: [
        FloatingSearchBar(
          controller: controller,
          elevation: 6,
          hintStyle: TextStyle(fontSize: 15, color: Colors.black),
          queryStyle: TextStyle(fontSize: 15),
          hint:  selectedStation,
          borderRadius: BorderRadius.circular(24),
          margins: EdgeInsets.fromLTRB(20, 70, 20, 0),
          padding: EdgeInsets.fromLTRB(2, 0, 2, 0),
          height: 50,
          backgroundColor: Color.fromARGB(255, 226, 222, 222),
          iconColor: Color.fromARGB(255, 43, 26, 92),
          scrollPadding: const EdgeInsets.only(top: 20, bottom: 56),
          transitionDuration: const Duration(milliseconds: 600),
          transitionCurve: Curves.easeInOut,
          physics: const BouncingScrollPhysics(),
          axisAlignment: isPortrait ? 0.0 : -1.0,
          openAxisAlignment: 0.0,
          width: isPortrait ? 600 : 500,
          debounceDelay: const Duration(milliseconds: 500),
          progress: progressIndicator,
          onFocusChanged: (isFocused) {
            setState(() {
              isTimeAndDistanceVisible = false;
            });
            if (isFocused) {
              hideOtherTextField();
            } else {
              toggleTextFieldVisibility(showList: true, showStation: true);
            }
          },
          transition: CircularFloatingSearchBarTransition(),
         actions: [
          FloatingSearchBarAction(
            showIfOpened: false,
            child: CircularButton(
              icon: Icon(Icons.arrow_drop_down, size: 40, color: Color.fromARGB(255, 43, 26, 92)),
              onPressed: () async {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Center(child: Text('Choisir une station départ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 43, 26, 92)),)),
                      content: Container(
                        width: double.maxFinite,
                        child: StreamBuilder<DocumentSnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('bus')
                              .doc(selectedBusProvider.selectedBusDocumentId)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return CircularProgressIndicator();
                            }

                            List<String> nomstations = [];
                            snapshot.data!['nomstation'].forEach((station) {
                              String stationName = station.split('(')[0].trim();
                              nomstations.add(stationName);
                            });

                            // Ensure the return statement always returns a widget
                             return Column(
                              children: [
                                ElevatedButton(
                                  onPressed: () async {
                                    findNearestStation(selectedBusProvider.selectedBusDocumentId); // Call the function here
                                    Navigator.of(context).pop();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color.fromARGB(255, 43, 26, 92),
                                  ),
                                  child: Text(
                                    'Chercher la station la plus proche',
                                    style: TextStyle(color: Color(0xFFffd400), fontSize: 12),
                                  ),
                                ),
                                Expanded(
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: nomstations.length,
                                    itemBuilder: (context, index) {
                                      String stationName = nomstations[index];
                                      String? durationToNext;
                                      if (index < snapshot.data!['route_details']['stations'].length - 1) {
                                        durationToNext = snapshot.data!['route_details']['stations'][index]['duration_to_next'];
                                      }
                                      return ListTile(
                                        title: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text( stationName, style: TextStyle(fontSize: 15, fontWeight: FontWeight.normal)),
                                            if (durationToNext != null) ...[
                                              SizedBox(height: 4), // Add some space between station name and arrow
                                              Center(
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.arrow_downward, size: 20, color: Colors.grey),
                                                    SizedBox(width: 4),
                                                    Text(durationToNext, style: TextStyle(fontSize: 12, color: Colors.grey)),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                        onTap: () async {
                                          Navigator.of(context).pop();
                                          
                                          setState(() {
                                            selectedStation =  stationName;
                                          });
                              String stationId = snapshot.data!['route_details']['stations'][index]['id'];
  
  
  // Fetch station document and update end station coordinates
  QuerySnapshot stationSnapshot = await FirebaseFirestore.instance
    .collection('station')
    .where('nomstation', isEqualTo: selectedStation)
    .get();
  
  if (stationSnapshot.docs.isNotEmpty) {
    DocumentSnapshot stationDoc = stationSnapshot.docs.first;
    setState(() {
      startStationLatitude = double.tryParse(stationDoc['latitude'] ?? '');
      startStationLongitude = double.tryParse(stationDoc['longtude'] ?? '');
    });
    markLocationOnMap(stationId);
    drawPolylineBetweenLocationAndDocument();
    selectedStationsProvider.setStation1(stationId, selectedStation);
     updateSelectedStations(
             LatLng(startStationLatitude!, startStationLongitude!),
                 selectedStation2 ?? LatLng(0.0, 0.0), // Pass the existing second station or a default value
                                              );
   
  }
                                          try {
                                            DateTime currentTime = DateTime.now();
                                            DateTime firstDeparture = _parseTime(snapshot.data!['firstdepart']);
                                  
                                            double totalDurationMinutes = double.parse(snapshot.data!['route_details']['total_duration'].replaceAll(' min', ''));
                                  
                                            int minutesSinceDeparture = currentTime.difference(firstDeparture).inMinutes;
                                            int currentTripMinutes = minutesSinceDeparture % totalDurationMinutes.toInt();
                                  
                                            List stations = snapshot.data!['route_details']['stations'];
                                            int currentCycle = minutesSinceDeparture ~/ totalDurationMinutes.toInt();
                                            bool isGoDirection = currentCycle % 2 == 0;
                                  
                                            int selectedIndex = stations.indexWhere((station) => station['name'] == selectedStation);
                                  
                                            if (selectedIndex != -1) {
                                              double timeToStation = 0.0;
                                  
                                              if (isGoDirection) {
                                                double durationToSelectedStation = 0.0;
                                                for (int i = 0; i <= selectedIndex; i++) {
                                                  durationToSelectedStation += double.parse(stations[i]['duration_to_next'].replaceAll(' min', ''));
                                                }
                                                if (currentTripMinutes <= durationToSelectedStation) {
                                                  timeToStation = durationToSelectedStation - currentTripMinutes;
                                                } else {
                                                  double remainingDuration = 0.0;
                                                  for (int i = selectedIndex; i < stations.length; i++) {
                                                    remainingDuration += double.parse(stations[i]['duration_to_next'].replaceAll(' min', ''));
                                                  }
                                                  double returnRouteDuration = 0.0;
                                                  for (int i = stations.length - 2; i >= selectedIndex; i--) {
                                                    returnRouteDuration += double.parse(stations[i]['duration_to_next'].replaceAll(' min', ''));
                                                  }
                                                  timeToStation = remainingDuration + returnRouteDuration - currentTripMinutes;
                                                }
                                              } else {
                                                double durationToSelectedStation = 0.0;
                                                for (int i = stations.length - 2; i >= selectedIndex; i--) {
                                                  durationToSelectedStation += double.parse(stations[i]['duration_to_next'].replaceAll(' min', ''));
                                                }
                                                if (currentTripMinutes <= durationToSelectedStation) {
                                                  timeToStation = durationToSelectedStation - currentTripMinutes;
                                                } else {
                                                  double remainingDuration = 0.0;
                                                  for (int i = selectedIndex - 1; i >= 0; i--) {
                                                    remainingDuration += double.parse(stations[i]['duration_to_next'].replaceAll(' min', ''));
                                                  }
                                                  double goRouteDuration = 0.0;
                                                  for (int i = 0; i < selectedIndex; i++) {
                                                    goRouteDuration += double.parse(stations[i]['duration_to_next'].replaceAll(' min', ''));
                                                  }
                                                  timeToStation = remainingDuration + goRouteDuration - currentTripMinutes;
                                                }
                                              }
                                  
                                              setState(() {
                                                estimatedTimeToStation = '${timeToStation.toStringAsFixed(2)} minutes';
                                              });
                                            } else {
                                              setState(() {
                                                estimatedTimeToStation = 'Station not found';
                                              });
                                            }
                                          } catch (e) {
                                            print('Error calculating time to arrival: $e');
                                            setState(() {
                                              estimatedTimeToStation = 'Error calculating time';
                                            });
                                          }
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
          builder: (context, transition) {
            return SizedBox.shrink(); // Empty builder for the first FloatingSearchBar
          },
        ),
        SizedBox(height: 10), // Add some space between the search bars
        Positioned(
            top: 140, // Adjust this value as needed to position the second search bar correctly
            left: 20,
            right: 20,
            child:
        Column(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                buildSuggestionsBloc(),
                buildSelectedPlaceLocationBloc(),
                buildDirectionsBloc(),
                // Only show the text field if showAdditionalTextField is true
                  TextField(
                    controller: locationController,
                   // focusNode: locationFocusNode,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(left: 20.0, bottom: 8.0),
                      hintText: selectedstationn,
                      hintStyle: TextStyle(fontSize: 15, color: Colors.black),
                     // labelText: '',
                      labelStyle: TextStyle(fontSize: 15, color: Colors.black),
                      filled: true,
                      fillColor: Color.fromARGB(255, 226, 222, 222),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
              suffixIcon: CircularButton(
            icon: Icon(Icons.arrow_drop_down, size: 40, color: Color.fromARGB(255, 43, 26, 92)),
            onPressed: () async {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Center(child: Text('Choisir une station destination', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 43, 26, 92)),)),
                    content: Container(
                      width: double.maxFinite,
                      child: StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('bus')
                            .doc(selectedBusProvider.selectedBusDocumentId)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return CircularProgressIndicator();
                          }

                          List<String> nomstations = [];
                          snapshot.data!['nomstation'].forEach((station) {
                            String stationNames = station.split('(')[0].trim();
                            nomstations.add(stationNames);
                          });

                          // Ensure the return statement always returns a widget
                          return ListView.builder(
                            shrinkWrap: true,
                            itemCount: nomstations.length,
                            itemBuilder: (context, index) {
                              String stationNames = nomstations[index];
                              String? durationToNext;
                              if (index < snapshot.data!['route_details']['stations'].length - 1) {
                                durationToNext = snapshot.data!['route_details']['stations'][index]['duration_to_next'];
                              }
                              return ListTile(
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(stationNames, style: TextStyle(fontSize: 15, )),
                                    if (durationToNext != null) ...[
                                      SizedBox(height: 4), // Add some space between station name and arrow
                                      Center(
                                        child: Row(
                                          children: [
                                            Icon(Icons.arrow_downward, size: 20, color: Colors.grey),
                                            SizedBox(width: 4),
                                            Text(durationToNext, style: TextStyle(fontSize: 12, color: Colors.grey)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                onTap: () async {
                                  Navigator.of(context).pop();
                                  setState(() {
                                    selectedstationn = stationNames;
                                  });
  String stationId = snapshot.data!['route_details']['stations'][index]['id'];
  
  // Fetch station document and update end station coordinates
  QuerySnapshot stationSnapshot = await FirebaseFirestore.instance
    .collection('station')
    .where('nomstation', isEqualTo: stationNames)
    .get();
  
  if (stationSnapshot.docs.isNotEmpty) {
    DocumentSnapshot stationDoc = stationSnapshot.docs.first;
    setState(() {
      endStationLatitude = double.tryParse(stationDoc['latitude'] ?? '');
      endStationLongitude = double.tryParse(stationDoc['longtude'] ?? '');
    });
   // markLocationOnMap(stationId);
    drawPolylineBetweenLocationAndDocument();
   selectedStationsProvider.setStation2(stationId, stationNames);

                                            // Update the selected station
                                            updateSelectedStations(
                                              selectedStation1 ?? LatLng(0.0, 0.0), // Pass the existing first station or a default value
                                              LatLng(endStationLatitude!, endStationLongitude!),
                                            );

  }
                                
                                              }
                              );
                            },
                          );
                        },
                      ),
                    ),
                  );
                },
              );
            },
          ), 
                       
                    ),
                    
                  ),
              ],
            )
    )
      ],
    );
  }

/* departStation = value;
              setState(() {});
              // Fetch details for the next station
              var busDoc = await FirebaseFirestore.instance
                  .collection('bus')
                  .doc(selectedBusProvider.selectedBusDocumentId)
                  .get();
              List<dynamic> routeDetails = busDoc.data()?['route_details']['stations'] ?? [];
              int currentIndex = routeDetails.indexWhere((station) => station['name'] == value);
              if (currentIndex != -1 && currentIndex < routeDetails.length - 1) {
                nextStation = routeDetails[currentIndex + 1]['name'];
                durationToNext = routeDetails[currentIndex ]['duration_to_next'];
              } else if (currentIndex == routeDetails.length - 1) {
                nextStation = 'End of route';
                durationToNext = 'N/A';
              } else {
                nextStation = 'Station not found';
                durationToNext = 'N/A';
              }
              setState(() {}); */

void markStationOnMapForCurrentPosition(double latitude, double longitude) async {
  try {
    CameraPosition newPosition = CameraPosition(
      bearing: 0.0,
      tilt: 0.0,
      target: LatLng(latitude, longitude),
      zoom: 13,
    );
    final GoogleMapController controller = await _mapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(newPosition));
    
    // Clear existing markers and add only the two necessary markers
    setState(() {
      markers.clear();
      addMarker(latitude, longitude);
      addMarker(position!.latitude, position!.longitude);
    });
    fetchDirectionsAndDuration(LatLng(position!.latitude, position!.longitude), LatLng(latitude, longitude));

    drawPolylineBetweenStationAndCurrentPosition(latitude, longitude);
  } catch (error) {
    print("Error marking station on map: $error");
  }
}

   void drawPolylineBetweenStationAndCurrentPosition(
      double stationLatitude, double stationLongitude) {
    LatLng stationLatLng = LatLng(stationLatitude, stationLongitude);
    LatLng currentLatLng = LatLng(position!.latitude, position!.longitude);
    BlocProvider.of<MapsCubit>(context).emitPlaceDirections(
      currentLatLng,
      stationLatLng,
    );
      fetchDirectionsAndDuration(currentLatLng, stationLatLng);

  }
 void fetchDirectionsAndDuration(LatLng currentLocation, LatLng stationLocation) async {
  final directions = gmaps.GoogleMapsDirections(apiKey: 'AIzaSyBq0BhOTqB2jW6wW2ZHNxQRYFzDaEZRL7o');
  final response = await directions.directionsWithLocation(
    gmaps.Location(
      lat: currentLocation.latitude, 
      lng: currentLocation.longitude
    ),
    gmaps.Location(
      lat: stationLocation.latitude, 
      lng: stationLocation.longitude
    ),
    travelMode: gmaps.TravelMode.walking,
  );

  if (response.isOkay && response.routes.isNotEmpty) {
    final route = response.routes.first;
    final duration = route.legs.first.duration;

    // Decode the polyline string
    final polylinePoints = PolylinePoints().decodePolyline(route.overviewPolyline.points);
    final latLngPoints = polylinePoints.map((point) => LatLng(point.latitude, point.longitude)).toList();

    setState(() {
      this.polylinePoints = latLngPoints;
      this.duration = duration.text;
    });
  }
}

void markLocationOnMap(String stationId) async {
  try {
    DocumentSnapshot stationDoc = await FirebaseFirestore.instance
        .collection('station')
        .doc(stationId)
        .get();

    if (!stationDoc.exists) {
      return;
    }

    double? latitude = double.tryParse(stationDoc['latitude'] ?? '');
    double? longitude = double.tryParse(stationDoc['longtude'] ?? '');

    if (latitude != null && longitude != null) {
      addMarker(latitude, longitude);
    }
  } catch (error) {
    print("Error fetching station location: $error");
  }
}

  void addMarker(double lat, double lng) {
    Marker marker = Marker(
      markerId: MarkerId('$lat-$lng'),
      position: LatLng(lat, lng),
      infoWindow: InfoWindow(title: 'Station'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );
   addMarkerToMarkersAndUpdateUI(marker);
    setState(() {
    markers.add(marker);
  });
  }
void drawPolylineBetweenLocationAndDocument(
 ) async {
  try {
    if (startStationLatitude != null &&
      startStationLongitude != null &&
      endStationLatitude != null &&
      endStationLongitude != null) {
      LatLng selectedStation1 = LatLng(startStationLatitude!, startStationLongitude!);
      LatLng selectedStation2 = LatLng(endStationLatitude!, endStationLongitude!);
      BlocProvider.of<MapsCubit>(context).emitPlaceDirections(
        selectedStation1,
        selectedStation2,
      );
    }
  } catch (error) {
    print("Error fetching station location: $error");
  }
}
  void getPolylinePoints() {
    polylinePoints = placeDirections!.polylinePoints
        .map((e) => LatLng(e.latitude, e.longitude))
        .toList();
  }

  Future<void> goToMySearchedForLocation() async {
    buildCameraNewPosition();
    final GoogleMapController controller = await _mapController.future;
    controller
        .animateCamera(CameraUpdate.newCameraPosition(goToSearchedForPlace));
    buildSearchedPlaceMarker();
  }

  void buildSearchedPlaceMarker() {
    searchedPlaceMarker = Marker(
      position: goToSearchedForPlace.target,
      markerId: MarkerId('1'),
      onTap: () {
        buildCurrentLocationMarker();
        // show time and distance
        setState(() {
          isSearchedPlaceMarkerClicked = true;
          isTimeAndDistanceVisible = true;
        });
      },
      infoWindow: InfoWindow(title: "${placeSuggestion.description}"),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );

    addMarkerToMarkersAndUpdateUI(searchedPlaceMarker);
  }

  void buildCurrentLocationMarker() {
    currentLocationMarker = Marker(
      position: LatLng(position!.latitude, position!.longitude),
      markerId: MarkerId('2'),
      onTap: () {},
      infoWindow: InfoWindow(title: "Your current Location"),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );
    addMarkerToMarkersAndUpdateUI(currentLocationMarker);
  }

  void addMarkerToMarkersAndUpdateUI(Marker marker) {
   setState(() {
      markers.add(marker);
   });
  }
 
  Widget buildPlacesList() {
    return ListView.builder(
        itemBuilder: (ctx, index) {
          return InkWell(
            onTap: () async {
              placeSuggestion = places[index];
              controller.close();
              getSelectedPlaceLocation();
              polylinePoints.clear();
              removeAllMarkersAndUpdateUI();
            },
            child: PlaceItem(
              suggestion: places[index],
            ),
          );
        },
        itemCount: places.length,
        shrinkWrap: true,
        physics: const ClampingScrollPhysics());
  }
 void getSelectedPlaceLocation() {
    final sessionToken = Uuid().v4();
    BlocProvider.of<MapsCubit>(context)
        .emitPlaceLocation(placeSuggestion.placeId, sessionToken);
  }
  void removeAllMarkersAndUpdateUI() {
    setState(() {
      markers.clear();
    });
  }

@override
Widget build(BuildContext context) {
  
  final selectedBusProvider = Provider.of<SelectedBusDocumentIdProvider>(context);
   print("Selected Station___________________________________________________________: $selectedStation");
  print("Selected Bus Document ID___________________________________________________: ${selectedBusProvider.selectedBusDocumentId}");
  return Scaffold(
    body: Stack(
      fit: StackFit.expand,
      children: [
        position != null
            ? buildMap()
            : Center(
                child: Container(
                  child: CircularProgressIndicator(
                    color: MyColors.blue,
                  ),
                ),
              ),
        buildFloatingSearchBar(), // Pass the context here
        isSearchedPlaceMarkerClicked
            ? DistanceAndTime(
                isTimeAndDistanceVisible: isTimeAndDistanceVisible,
                placeDirections: placeDirections,
              )
            : Container(),
           // buildDurationDisplay(),
      ],
    ),
    floatingActionButton: Container(
      margin: EdgeInsets.fromLTRB(0, 0, 8, 30),
      child: FloatingActionButton(
        backgroundColor: Color.fromARGB(255, 43, 26, 92),
        onPressed: _goToMyCurrentLocation,
        child: Icon(Icons.place, color: Color(0xFFffd400)),
      ),
    ),
     bottomNavigationBar: selectedStation != null && selectedBusProvider.selectedBusDocumentId != null
  ? SizedBox(
      height: 150,
      width: 50,
      child: MyCard(selectedBusProvider.selectedBusDocumentId, selectedStation, estimatedTimeToStation)
    )
  : Container(), 
  
    );

}
}
