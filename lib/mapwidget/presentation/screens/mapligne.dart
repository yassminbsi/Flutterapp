import 'dart:async';
import 'dart:math';

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
import 'package:flutter_app/mapwidget/presentation/widgets/distance_and_time.dart';
import 'package:flutter_app/mapwidget/presentation/widgets/place_item.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:material_floating_search_bar_2/material_floating_search_bar_2.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';


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
    zoom: 17,
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
  String selectedStation = '';
  String estimatedTimeToStation='';
  List<String> stationNames = [];
  final FocusNode locationFocusNode = FocusNode();
  FocusNode destinationLocationFocusNode = FocusNode();
  List<QueryDocumentSnapshot> data = [];
  bool isLoading = true;
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

          // Afficher la durée calculée
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
                        "Direction du bus $nomBus: $busDirection",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 5.0),
                    Center(
                      child: Text(
                        "Temps d'arrivée de bus au station $selectedStation: $estimatedTimeToStation",
                        style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                      ),
                    ),
                  ],
                ),
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
  late List<LatLng> polylinePoints;
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
    
  }

  Future<void> getMyCurrentLocation() async {
    position = await LocationHelper.getCurrentLocation().whenComplete(() {
      setState(() {});
    });
  }

  Widget buildMap() {
    return GoogleMap(
      mapType: MapType.normal,
      myLocationEnabled: true,
      zoomControlsEnabled: false,
      myLocationButtonEnabled: false,
      markers: markers,
      initialCameraPosition: _myCurrentLocationCameraPosition,
      onMapCreated: (GoogleMapController controller) {
        _mapController.complete(controller);
      },
      polylines: placeDirections != null
          ? {
              Polyline(
                polylineId: const PolylineId('my_polyline'),
                color: MyColors.blue,
                width: 8,
                points: polylinePoints,
              ),
            }
          : {},
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
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return Stack(
      children: [
        FloatingSearchBar(
          controller: controller,
          elevation: 6,
          hintStyle: TextStyle(fontSize: 15, color: Colors.black),
          queryStyle: TextStyle(fontSize: 15),
          hint: 'Current Location',
          borderRadius: BorderRadius.circular(24),
          margins: EdgeInsets.fromLTRB(20, 70, 20, 0),
          padding: EdgeInsets.fromLTRB(2, 0, 2, 0),
          height: 50,
          backgroundColor: Color.fromARGB(255, 226, 222, 222),
          iconColor: MyColors.blue,
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
                icon: Icon(Icons.search, color: Colors.blue),
                onPressed: () {
                  controller.query = 'Current Location';
                  locationController.text = '';
                  toggleAdditionalTextFieldVisibility();
                  FocusScope.of(context).requestFocus(locationFocusNode);
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
                      hintText: 'Select a station For Current Position',
                      hintStyle: TextStyle(fontSize: 14, color: Colors.black),
                      labelText: selectedStation,
                      labelStyle: TextStyle(fontSize: 14, color: Colors.black),
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
                    
                       suffix:  
                        StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('bus')
                            .doc(selectedBusProvider.selectedBusDocumentId)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return CircularProgressIndicator();
                          }

                          // Extract station names from the snapshot
                          List<String> nomstations = [];
                          snapshot.data!['nomstation'].forEach((station) {
                            String stationName = station.split('(')[0].trim();
                            nomstations.add(stationName);
                           
                          });

                          // Create DropdownMenuItem list
                          List<DropdownMenuItem<String>> items = [
                            DropdownMenuItem<String>(
                              child: Center(
                                child: Text(
                                  'Sélectionnez une station de départ',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                                ),
                              ),
                              value: null,
                              enabled: false,
                            ),
                          ];
                          nomstations.forEach((nomstation) {
                            items.add(DropdownMenuItem(
                              child: Text('      $nomstation', style: TextStyle(fontSize: 15, fontWeight: FontWeight.normal)),
                              value: nomstation,
                            ));
                            
                          });
                          
                          return DropdownButtonFormField(
                            items: items,
onChanged: (value) async {
  if (value != null) {
    setState(() {
      selectedStation = value;
    });

    try {
      // Get current time and first departure time
      DateTime currentTime = DateTime.now();
      DateTime firstDeparture = _parseTime(snapshot.data!['firstdepart']);

      // Calculate total route duration in minutes
      double totalDurationMinutes = double.parse(snapshot.data!['route_details']['total_duration'].replaceAll(' min', ''));

      // Calculate minutes since first departure
      int minutesSinceDeparture = currentTime.difference(firstDeparture).inMinutes;

      // Calculate current trip minutes (time within current cycle)
      int currentTripMinutes = minutesSinceDeparture % totalDurationMinutes.toInt();

      // Fetch station details and prepare for traversal
      List stations = snapshot.data!['route_details']['stations'];

      // Determine current trip cycle and direction
      int currentCycle = minutesSinceDeparture ~/ totalDurationMinutes.toInt();
      bool isGoDirection = currentCycle % 2 == 0;

      // Find the index of the selected station in the stations list
      int selectedIndex = stations.indexWhere((station) => station['name'] == value);

      if (selectedIndex != -1) {
        double timeToStation = 0.0;

        if (isGoDirection) {
          // Calculate the remaining duration from the current trip position to the selected station in "Go" direction
          double durationToSelectedStation = 0.0;
          for (int i = 0; i <= selectedIndex; i++) {
            durationToSelectedStation += double.parse(stations[i]['duration_to_next'].replaceAll(' min', ''));
          }

          if (currentTripMinutes <= durationToSelectedStation) {
            // The bus has not yet reached the selected station in "Go" direction
            timeToStation = durationToSelectedStation - currentTripMinutes;
          } else {
            // The bus has passed the selected station in "Go" direction
            double remainingDuration = 0.0;
            for (int i = selectedIndex ; i < stations.length ; i++) {
              remainingDuration += double.parse(stations[i]['duration_to_next'].replaceAll(' min', ''));
            }
            double returnRouteDuration = 0.0;
            for (int i = stations.length  -2  ; i >= selectedIndex ; i--) {
              returnRouteDuration += double.parse(stations[i]['duration_to_next'].replaceAll(' min', ''));
            }
            timeToStation = remainingDuration + returnRouteDuration - currentTripMinutes;
          }
        } else {
          // Calculate the remaining duration from the current trip position to the selected station in "Return" direction
          double durationToSelectedStation = 0.0;
          for (int i = stations.length - 2; i >= selectedIndex; i--) {
            durationToSelectedStation += double.parse(stations[i]['duration_to_next'].replaceAll(' min', ''));
          }

          if (currentTripMinutes <= durationToSelectedStation) {
            // The bus has not yet reached the selected station in "Return" direction
            timeToStation = durationToSelectedStation - currentTripMinutes;
          } else {
            // The bus has passed the selected station in "Return" direction
            double remainingDuration = 0.0;
            for (int i = selectedIndex -1; i >= 0; i--) {
              remainingDuration += double.parse(stations[i]['duration_to_next'].replaceAll(' min', ''));
            }
            double goRouteDuration = 0.0;
            for (int i = 0; i < selectedIndex; i++) {
              goRouteDuration += double.parse(stations[i]['duration_to_next'].replaceAll(' min', ''));
            }
            timeToStation = remainingDuration + goRouteDuration - currentTripMinutes;
          }
        }

        // Update the UI with the calculated time
        setState(() {
          estimatedTimeToStation = '${timeToStation.toStringAsFixed(2)} minutes';
        });
      } else {
        // Handle case where selected station is not found
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
                                // Fetch the station details based on the selected station name
                                QuerySnapshot stationSnapshot = await FirebaseFirestore.instance
                                    .collection('station')
                                    .where('nomstation', isEqualTo: value)
                                    .get();
                                if (stationSnapshot.docs.isNotEmpty) {
                                  DocumentSnapshot stationDoc = stationSnapshot.docs.first;
                                  double? latitude = double.tryParse(stationDoc['latitude'] ?? '');
                                  double? longitude = double.tryParse(stationDoc['longtude'] ?? '');
                                  if (latitude != null && longitude != null) {
                                    markStationOnMapForCurrentPosition(latitude, longitude);
                                  }
                                }
                              }
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
double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  // Calculate distance using Haversine formula
  const double R = 6371e3; // Radius of Earth in meters
  double phi1 = lat1 * (pi / 180);
  double phi2 = lat2 * (pi / 180);
  double deltaPhi = (lat2 - lat1) * (pi / 180);
  double deltaLambda = (lon2 - lon1) * (pi / 180);

  double a = sin(deltaPhi / 2) * sin(deltaPhi / 2) +
      cos(phi1) * cos(phi2) *
      sin(deltaLambda / 2) * sin(deltaLambda / 2);
  double c = 2 * atan2(sqrt(a), sqrt(1 - a));

  double distance = R * c; // Distance in meters
  return distance / 1000; // Distance in kilometers
}

double getAverageBusSpeed(List<dynamic> stations) {
  double totalDuration = 0;
  double totalDistance = 0;

  for (var station in stations) {
    double? distanceToNext = double.tryParse(station['distance_to_next']?.replaceAll(' km', '') ?? '');
    double? durationToNext = double.tryParse(station['duration_to_next']?.replaceAll(' min', '') ?? '');

    if (distanceToNext != null && durationToNext != null) {
      totalDistance += distanceToNext;
      totalDuration += durationToNext;
    }
  }

  return totalDistance / (totalDuration / 60); // Speed in km/h
}


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
    double locationLatitude, double locationLongitude) async {
  try {
    if (_documentLatitude != null && _documentLongitude != null) {
      LatLng locationLatLng = LatLng(locationLatitude, locationLongitude);
      LatLng documentLatLng = LatLng(_documentLatitude!, _documentLongitude!);
      BlocProvider.of<MapsCubit>(context).emitPlaceDirections(
        locationLatLng,
        documentLatLng,
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
      ],
    ),
    floatingActionButton: Container(
      margin: EdgeInsets.fromLTRB(0, 0, 8, 30),
      child: FloatingActionButton(
        backgroundColor: MyColors.blue,
        onPressed: _goToMyCurrentLocation,
        child: Icon(Icons.place, color: Colors.white),
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

/* i want to calculate the duration (to arrive the bus at the selected station) between the current position of the bus (knowing that the bus is still moving) and the selected station, knowing that:
firstdepart: the first departure time of bus n.
total_duration: the total duration of the journey of bus n.
instantaneous_duration: the current time.
I propose a form to calculate the duration (to arrive at the selected station) between the current position of the bus and the selected station:
R= (instantaneous_duration - firstdepart)/ total_duration.
line1 (go): station 1, station2, station3, station4.
line1 (return): station4, station3, station2, station1.
if the integer R is an even number, then the bus line1 is "go".
if the integer R is an odd number, then the bus line1 is "return".
and the value of R after the versil: it is the bus time to arrive at the selected station,*/