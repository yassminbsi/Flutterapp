
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/favoris/viewfavoris.dart';
import 'package:flutter_app/mapwidget/business_logic/cubit/maps/maps_cubit.dart';
import 'package:flutter_app/mapwidget/constnats/my_colors.dart';
import 'package:flutter_app/mapwidget/data/models/Place_suggestion.dart';
import 'package:flutter_app/mapwidget/data/models/place.dart';
import 'package:flutter_app/mapwidget/data/models/place_directions.dart';
import 'package:flutter_app/mapwidget/helpers/location_helper.dart';
import 'package:flutter_app/mapwidget/presentation/screens/selectedbus.dart';
import 'package:flutter_app/mapwidget/presentation/screens/selectedbusfavoris.dart';
import 'package:flutter_app/mapwidget/presentation/screens/selectedstationname.dart';
import 'package:flutter_app/mapwidget/presentation/widgets/distance_and_time.dart';
import 'package:flutter_app/mapwidget/presentation/widgets/my_drawer.dart';
import 'package:flutter_app/mapwidget/presentation/widgets/place_item.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:material_floating_search_bar_2/material_floating_search_bar_2.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class SelectedStationsProvider with ChangeNotifier {
  String? station1Id;
  String? station2Id;
  String _station1Name = "";
  String _station2Name = "";

  String get station1Name => _station1Name;
  String get station2Name =>  _station2Name;

  void setStation1(String id1, String name1) {
    station1Id = id1;
    _station1Name = name1;
    notifyListeners();
  }
  void setStation2(String id2, String name2) {
    station2Id = id2;
    _station2Name = name2;
    notifyListeners();
  } 

  /*void setStations(String id1, String name1, String id2, String name2) {
    station1Id = id1;
    _station1Name = name1;
    station2Id = id2;
    _station2Name = name2;
  }*/
  void resetStations() {
    station1Id = null;
    _station1Name = "Sélectionner une station...";
    station2Id = null;
    _station2Name = "station destination";
    notifyListeners();
  }
}
class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);
  @override
  // ignore: library_private_types_in_public_api
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List<PlaceSuggestion> places = [];
  FloatingSearchBarController controller = FloatingSearchBarController();
  static Position? position;
  final Completer<GoogleMapController> _mapController = Completer();

  static final CameraPosition _myCurrentLocationCameraPosition = CameraPosition(
    bearing: 0.0,
    target: LatLng(position!.latitude, position!.longitude),
    tilt: 0.0,
    zoom: 9,
  );
 
   String? station1Id;
   String? station2Id;
   String station1Name="";
   String station2Name="";
List<DocumentSnapshot> filteredStationList = [];
List<DocumentSnapshot>  filteredStationListTextField = [];
  bool showFilteredListForSearchBar = false;
  bool showFilteredListForTextField = false;
 
  Set<Marker> markers = Set();
  late PlaceSuggestion placeSuggestion;
  late Place selectedPlace;
  late Marker searchedPlaceMarker;
  late Marker currentLocationMarker;
  late CameraPosition goToSearchedForPlace;
  String? selectedStation1Id;
 String? selectedStation2Id;
 bool showFilteredList = false;
  String selectedStation = '';
  String selectedStationName = 'Sélectionner une station...';
  String selectedstationn = 'station destination';
  double? startStationLatitude;
  double? startStationLongitude;
  double? endStationLatitude;
  double? endStationLongitude;
  List<String> stationNames = [];
  final FocusNode locationFocusNode = FocusNode();
  FocusNode destinationLocationFocusNode = FocusNode();
  List<QueryDocumentSnapshot> data = [];
  bool isLoading = true;
  LatLng? selectedStation1;
  LatLng? selectedStation2;
  String selectedBusDocumentId = "";
  String estimatedTimeToStation= "";
  String? busDocumentId;
  Future<void> getData() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection("bus").get();
    setState(() {
      data.addAll(querySnapshot.docs);
       isLoading = false;
    });
  }


double calculateDistance(double startLatitude, double startLongitude, double endLatitude, double endLongitude) {
  return Geolocator.distanceBetween(startLatitude, startLongitude, endLatitude, endLongitude);
}

void findNearestStation() async {
  try {
    Position userLocation = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    double userLatitude = userLocation.latitude;
    double userLongitude = userLocation.longitude;

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('station').get();
    List<DocumentSnapshot> documents = querySnapshot.docs;

    String nearestStationId = '';
    double minDistance = double.infinity;

    for (DocumentSnapshot document in documents) {
      double stationLatitude = double.tryParse(document['latitude'] ?? '') ?? 0.0;
      double stationLongitude = double.tryParse(document['longtude'] ?? '') ?? 0.0;

      double distance = calculateDistance(userLatitude, userLongitude, stationLatitude, stationLongitude);

      if (distance < minDistance) {
        minDistance = distance;
        nearestStationId = document.id;
        //markLocationOnMap(document.id);
        addMarker(stationLatitude, stationLongitude);
        //drawPolylineBetweenLocationAndDocument();
      }
    }

    DocumentSnapshot nearestStationSnapshot = await FirebaseFirestore.instance.collection('station').doc(nearestStationId).get();
    String nearestStationName = nearestStationSnapshot.get('nomstation');

    setState(() {
      controller.query = nearestStationName;
      
    });

  } catch (error) {
    print("Error finding nearest station: $error");
  }
}


  
Widget listBus() {
  return Material(
          clipBehavior: Clip.antiAlias,
          shape: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Color(0xFFffd400), width:2.0),
          ),
          child: Container(
    color: const Color.fromARGB(255, 43, 26, 92),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                   padding: EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                       'Liste de toutes les lignes',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFFffd400)
                      ),
                    ),
                  ),
                ),
      Expanded(
      child: Consumer<SelectedBusDocumentIdProvider>(
       builder: (context, provider, _) {
        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisExtent: 55,
          ),
          itemCount: data.length,
          itemBuilder: (context, i) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(15), // Circular border radius
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFffd400),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Color(0xFFffd400), width: 2), // Border color and width
                ),
                margin: const EdgeInsets.all(5),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10), // Padding inside the card
                          child: Text(
                            "L${i + 1}: ${data[i]['nombus']}",
                            style: const TextStyle(fontSize: 9,fontWeight: FontWeight.bold, color: Color.fromARGB(255, 43, 26, 92)),
                          ),
                        ),
                      ],
                    ),
                    Spacer(), // Pushes the MaterialButton to the right
                    MaterialButton(
                      child: const Icon(Icons.directions, color: Color.fromARGB(255, 43, 26, 92), size: 30),
                      onPressed: () async {
                        provider.selectedBusDocumentId = data[i].id;
                        Navigator.of(context).pushNamed("/MapLigne");
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ),
      ),
    ]  ),
  )
  );
}
  
  void buildCameraNewPosition() {
    goToSearchedForPlace = CameraPosition(
      bearing: 0.0,
      tilt: 0.0,
      target: LatLng(
        selectedPlace.result.geometry.location.lat,
        selectedPlace.result.geometry.location.lng,
      ),
      zoom: 15,
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
   List<DocumentSnapshot> allStations = [];
  List<DocumentSnapshot> filteredStations = [];
  List<DocumentSnapshot> filteredStationsTextField= [];
  late Future<Map<String, dynamic>?> _dataFuture;

  @override
  void initState() {
    super.initState();
    getMyCurrentLocation();
   // _goToMyCurrentLocation();
    getData();
    controller = FloatingSearchBarController();
     _dataFuture = _fetchData();
     MyCard;
     buildMap;
    // updateProvider;

     
     }
 void _refreshScreen(BuildContext context) {
    final selectedStationsProvider = Provider.of<SelectedStationsProvider>(context, listen: false);
    final selectedStationsProviderName = Provider.of<SelectedStationNameProvider>(context, listen: false);
    selectedStationName = 'Sélectionner une station...';
    selectedstationn = 'station destination';
     markers.clear();
     selectedStation1 = null;
     selectedStation2 = null;
     placeDirections = null;
    // Reset the station names and trigger refresh
    selectedStationsProvider.resetStations();
    selectedStationsProviderName.resetStations();
    // Reset other states if needed
     selectedStationsProvider.station1Id == null;
     selectedStationsProvider.station2Id == null;
    // Refresh the UI by rebuilding the future data and triggering rebuilds
    setState(() {
      _dataFuture = _fetchData();
      updateSelectedStations(selectedStation1!, selectedStation2!);
     // HomeFavoris();
       // Refresh the future data
      // You may need to refresh other parts of your UI depending on how they are implemented
      // For example, if listBus and buildMap are methods or widgets, ensure they are called or rebuilt here
    });
  }

  Future<void> getMyCurrentLocation() async {
    position = await LocationHelper.getCurrentLocation().whenComplete(() {
      setState(() {});
    });
  }
void selectStation(String selectedStationId) {
    setState(() {
      stationId = selectedStationId;
    });
  }
 void centerCameraBetweenStations() async {
    if (selectedStation1 != null) {
      // Calculate the midpoint between the two selected stations
      LatLng midPoint = LatLng(
        selectedStation1!.latitude  ,
        selectedStation1!.longitude ,
      );
      double zoomLevel = 13; 
      GoogleMapController controller = await _mapController.future;
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: midPoint, zoom: zoomLevel),
        ),
      );
    }
     else if (selectedStation2 != null) {
      // Calculate the midpoint between the two selected stations
      LatLng midPoint = LatLng(
        selectedStation2!.latitude  ,
        selectedStation2!.longitude ,
      );
      double zoomLevel = 13; 
      GoogleMapController controller = await _mapController.future;
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: midPoint, zoom: zoomLevel),
        ),
      );
    }
  }
 Widget buildMap() {
 Set<Marker> selectedMarkers = {};
    if (selectedStation1 != null) {
      selectedMarkers.add(Marker(
        markerId: const MarkerId('station1'),
        position: selectedStation1!,
      ));
    }
    if (selectedStation2 != null) {
      selectedMarkers.add(Marker(
        markerId: const MarkerId('station2'),
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
       if (selectedStation1 != null  && selectedStation2 != null) {
          centerCameraBetweenStations();
        }
    },
    polylines: placeDirections != null
        ? {
            Polyline(
              polylineId: const PolylineId('my_polyline'),
              color: MyColors.blue,
              width: 5,
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
  final TextEditingController destinationController = TextEditingController();

  bool showAdditionalTextField = false;

  void toggleAdditionalTextFieldVisibility() {
    setState(() {
      showAdditionalTextField = !showAdditionalTextField;
    });
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

  void toggleTextFieldVisibility(
      {bool showList = true, bool showStation = true}) {
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
Widget buildFloatingSearchBar(BuildContext context, SelectedStationsProvider selectedStationsProvider) {
  final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
  return Stack(
    children: [
      // FloatingSearchBar in the background
      FloatingSearchBar(
        controller: controller,
        elevation: 6,
        hintStyle: const TextStyle(fontSize: 15),
        queryStyle: const TextStyle(fontSize: 16),
        hint: selectedStationName,
        borderRadius: BorderRadius.circular(24),
        margins: const EdgeInsets.fromLTRB(20, 70, 20, 0),
        padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
        height: 50,
        backgroundColor: const Color.fromARGB(255, 226, 222, 222),
        iconColor: const Color.fromARGB(255, 43, 26, 92),
        scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),
        transitionDuration: const Duration(milliseconds: 600),
        transitionCurve: Curves.easeInOut,
        physics: const BouncingScrollPhysics(),
        axisAlignment: isPortrait ? 0.0 : -1.0,
        openAxisAlignment: 0.0,
        width: isPortrait ? 600 : 500,
        debounceDelay: const Duration(milliseconds: 500),
        onFocusChanged: (isFocused) async {
          if (isFocused) {
            await fetchStations();
            setState(() {
              showFilteredListForSearchBar = true;
              showFilteredListForTextField = false;
            });
          }
        },
        builder: (context, transition) {
          return SizedBox.shrink(); // An empty widget when the search bar is focused
        },
        onQueryChanged: (query) async {
          if (query.isEmpty) {
            setState(() {
              showFilteredListForSearchBar = false;
            });
            return;
          }
          List<DocumentSnapshot> filteredStations = filteredStationList.where((doc) {
            String nomstation = doc.get('nomstation');
            return nomstation.toLowerCase().startsWith(query.toLowerCase());
          }).toList();
          setState(() {
            filteredStationList = filteredStations;
            showFilteredListForSearchBar = true;
          });
        },
      ),

      // Positioned TextField in the background
      Positioned(
        top: 135,
        left: 20,
        right: 20,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            buildSuggestionsBloc(),
            buildSelectedPlaceLocationBloc(),
            buildDiretionsBloc(),
            TextField(
              controller: locationController,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.only(left: 20.0, bottom: 8.0),
                hintText: selectedstationn,
                hintStyle: const TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.normal),
                labelStyle: const TextStyle(fontSize: 15, color: Colors.black),
                filled: true,
                fillColor: Color.fromARGB(255, 226, 222, 222),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: const BorderSide(color: Colors.transparent),
                ) ,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: const BorderSide(color: Colors.transparent),
                ),

                prefixIcon: const Icon(Icons.directions_bus, color: Color.fromARGB(255, 43, 26, 92)),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_drop_down, size: 35, color: Color.fromARGB(255, 43, 26, 92)),
                  onPressed: () async {
                    await fetchStations();
                    setState(() {
                      showFilteredListForTextField = !showFilteredListForTextField;
                      showFilteredListForSearchBar = false;
                    });
                  },
                ),
              ),
              onTap: () async {
                await fetchStations();
                setState(() {
                  showFilteredListForTextField = true;
                });
              },
              onChanged: (query) async {
          if (query.isEmpty) {
            setState(() {
              showFilteredListForTextField = false;
            });
            return;
          }
          List<DocumentSnapshot> filteredStationsTextField = filteredStationListTextField.where((doc) {
            String nomstation = doc.get('nomstation');
            return nomstation.toLowerCase().startsWith(query.toLowerCase());
          }).toList();
          setState(() {
            filteredStationListTextField = filteredStationsTextField;
            showFilteredListForTextField = true;
          });
        },
            ),
            if (showFilteredListForTextField)
              Positioned(
                left: 30,
                right: 30,
                top: 150,
                child: Container(
                  color: Colors.white,
                  height: 300,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: filteredStationListTextField.length,
                    itemBuilder: (context, index) {
                      String stationName = filteredStationListTextField[index].get('nomstation');
                      return ListTile(
                        title: Text(stationName),
                        onTap: () async {
                          String station2Id = filteredStationListTextField[index].id;
                          DocumentSnapshot document = filteredStationListTextField[index];
                          String nomstation = document.get('nomstation');
                          setState(() {
                            selectedstationn = nomstation;
                            showFilteredListForTextField = false;
                            locationController.clear();
                          });
                          setState(() {
                            endStationLatitude = double.tryParse(document['latitude'] ?? '') ?? 0.0;
                            endStationLongitude = double.tryParse(document['longtude'] ?? '') ?? 0.0;
                          });
                          final selectedStationNameProvider = Provider.of<SelectedStationNameProvider>(context, listen: false);
                    selectedStationNameProvider.setSelectedStation2(selectedstationn, station2Id);
                          drawPolylineBetweenLocationAndDocument();
                           selectedStationsProvider.setStation2(station2Id, selectedstationn);
                          updateSelectedStations(
                            selectedStation1 ?? const LatLng(0.0, 0.0),
                            LatLng(endStationLatitude!, endStationLongitude!),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),

      // showFilteredListForSearchBar in the foreground
      if (showFilteredListForSearchBar)
        Positioned(
          top: 125, // Adjust the position as needed
          left: 26,
          right: 26,
          child: Container(
            color: Colors.white,
            height: 300,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: filteredStationList.length,
              itemBuilder: (context, index) {
                String stationName = filteredStationList[index].get('nomstation');
                return ListTile(
                  title: Text(stationName),
                  onTap: () async {
                    String station1Id = filteredStationList[index].id;
                    DocumentSnapshot document = filteredStationList[index];
                    String nomstation = document.get('nomstation');
                    setState(() {
                      selectedStationName = nomstation;
                      showFilteredListForTextField = false;
                      showFilteredListForSearchBar = false;
                      controller.close();
                    });
                    setState(() {
                      startStationLatitude = double.tryParse(document['latitude'] ?? '') ?? 0.0;
                      startStationLongitude = double.tryParse(document['longtude'] ?? '') ?? 0.0;
                    });
                    markLocationOnMap(station1Id);
                    final selectedStationNameProvider = Provider.of<SelectedStationNameProvider>(context, listen: false);
                    selectedStationNameProvider.setSelectedStation1(selectedStationName, station1Id);
                    drawPolylineBetweenLocationAndDocument();
                    selectedStationsProvider.setStation1(station1Id, selectedStationName);
                    updateSelectedStations(
                      LatLng(startStationLatitude!, startStationLongitude!),
                      selectedStation2 ?? const LatLng(0.0, 0.0),
                    );
                  },
                );
              },
            ),
          ),
        ),
    ],
  );
}

 Future<void> fetchStations() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('station').get();
    setState(() {
      filteredStationList = querySnapshot.docs;
      filteredStationListTextField = querySnapshot.docs;
    });
  }

Future<List<Map<String, dynamic>>> fetchBusDocumentsWithStations(String station1Id, String station2Id) async {
  try {
    QuerySnapshot busSnapshot = await FirebaseFirestore.instance.collection('bus').get();
    List<Map<String, dynamic>> busDocs = [];
    for (var doc in busSnapshot.docs) {
      List<dynamic> stationsDoc = doc['nomstation'];

      // Check if both station1Id and station2Id are in the list of stations
      bool hasStation1 = stationsDoc.any((station) => station.contains("ID: $station1Id"));
      bool hasStation2 = stationsDoc.any((station) => station.contains("ID: $station2Id"));

      if (hasStation1 && hasStation2) {
        busDocs.add({
          'doc': doc,
          'nombus': doc['nombus'],
          'stations': stationsDoc,
        });
      }
    }
    return busDocs;
  } catch (e) {
    print('Error fetching bus documents: $e');
    return [];
  }
}


Widget displayBusDocuments(String station1Id, String station2Id, String selectedStationName , String selectedstationn ) {
  return FutureBuilder<List<Map<String, dynamic>>>(
    future: fetchBusDocumentsWithStations(station1Id, station2Id),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      } else if (snapshot.hasError) {
        return Center(child: Text('Error: ${snapshot.error}'));
      } else if (snapshot.hasData) {
        List<Map<String, dynamic>> busDocs = snapshot.data!;
        if (busDocs.isNotEmpty) {
          List<String> busNames = busDocs.map((map) => map['doc']['nombus'] as String).toList();
          String stationName = busDocs.first['stations'].join(', ');
          return Material(
            clipBehavior: Clip.antiAlias,
            shape: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(color: Color.fromARGB(255, 43, 26, 92), width: 2.0),
            ),
            child: Container(
              color: const Color(0xFFffd400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Center(
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          children: [
                            const TextSpan(
                              text: 'Liste des lignes passant par les stations',
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 20,
                                color: Color(0xFF25243A),
                              ),
                            ),
                            TextSpan(
                              text: ' $selectedStationName  & $selectedstationn',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF25243A),
                              ),
                            ), 
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Consumer<SelectedBusDocumentIdProvider>(
                      builder: (context, provider, _) {
                        return GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisExtent: 60,
                          ),
                          itemCount: busNames.length,
                          itemBuilder: (context, index) {
                            final busName = busNames[index];
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: InkWell(
                                onTap: () {
                                  print('Selected bus line: $busName');
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(255, 43, 26, 92),
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(color: Color(0xFFffd400), width: 2),
                                  ),
                                  margin: const EdgeInsets.all(5),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(10),
                                            child: Text(
                                              "L${index + 1}: $busName",
                                              style: const TextStyle(fontSize: 9, color: Color(0xFFffd400)),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Spacer(),
                                      MaterialButton(
                                        child: const Icon(Icons.directions, color: Color(0xFFffd400), size: 30),
                                        onPressed: () {
                                          provider.selectedBusDocumentId = busDocs[index]['doc'].id;
                                          Navigator.of(context).pushNamed("/MapLigne");
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          return const Center(child: Text('Aucun bus trouvé.'));
        }
      } else {
        return Container();
      }
    },
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

void markStationOnMap(String stationId) async {
    try {
      // Fetch station details from Firestore
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
        // Create a CameraPosition for the selected station
        CameraPosition newPosition = CameraPosition(
          bearing: 0.0,
          tilt: 0.0,
          target: LatLng(latitude, longitude),
          zoom: 13,
        );

        final GoogleMapController controller = await _mapController.future;
        controller.animateCamera(CameraUpdate.newCameraPosition(newPosition));
        setState(() {
          addMarker(latitude, longitude);
        });
        

     //  drawPolylineBetweenLocationAndDocument();
      }
    } catch (error) {
      print("Error fetching destination location: $error");
    }
  }
  void markStationOnMapForCurrentPosition(String stationId) async {
    try {
      // Fetch station details from Firestore
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
        // Create a CameraPosition for the selected station
        CameraPosition newPosition = CameraPosition(
          bearing: 0.0,
          tilt: 0.0,
          target: LatLng(latitude, longitude),
          zoom: 13,
        );

        final GoogleMapController controller = await _mapController.future;
        controller.animateCamera(CameraUpdate.newCameraPosition(newPosition));

        addMarker(latitude, longitude);

       drawPolylineBetweenStationAndCurrentPosition(latitude, longitude);
      }
    } catch (error) {
      print("Error fetching destination location: $error");
    }
  }

  Widget buildDiretionsBloc() {
    return BlocListener<MapsCubit, MapsState>(
      listener: (context, state) {
        if (state is DirectionsLoaded) {
          placeDirections = (state).placeDirections;

          getPolylinePoints();

          setState(() {
           // markers.clear();
            
            addMarker(position!.latitude,
                position!.longitude); // Add current position marker
          });
          
        }
        
      },
      child: Container(),
    );
  }
  /*void addMarker(double lat, double lng) {
    Marker marker = Marker(
      markerId: MarkerId('$lat-$lng'),
      position: LatLng(lat, lng),
      infoWindow: InfoWindow(title: 'Station'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );
    addMarkerToMarkersAndUpdateUI(marker);
  } */
   void addMarker(double lat, double lng) {
    Marker marker = Marker(
      markerId: MarkerId('$lat-$lng'),
      position: LatLng(lat, lng),
      infoWindow: const InfoWindow(title: 'Station'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );
   addMarkerToMarkersAndUpdateUI(marker);
    setState(() {
    markers.add(marker);
  });
  }

   void updateSelectedStations(LatLng station1, LatLng station2) {
    setState(() {
      selectedStation1 = station1;
      selectedStation2 = station2;

      // Clear existing markers and add only selected station markers
      markers.clear();
      markers.add(Marker(
        markerId: const MarkerId('station1'),
        position: station1,
      ));
      markers.add(Marker(
        markerId: const MarkerId('station2'),
        position: station2,
      ));
    });
     if (selectedStation1 != null && selectedStation2 != null) {
    // Update camera position to center between both markers
    centerCameraBetweenStations();
     } 
  }


  void getPolylinePoints() {
    polylinePoints = placeDirections!.polylinePoints
        .map((e) => LatLng(e.latitude, e.longitude))
        .toList();
  }

  Widget buildSelectedPlaceLocationBloc() {
    return BlocListener<MapsCubit, MapsState>(
      listener: (context, state) {
        if (state is PlaceLocationLoaded) {
          selectedPlace = (state).place;
          goToMySearchedForLocation();
          getDirections();
        }
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
      markerId: const MarkerId('1'),
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
      markerId: const MarkerId('2'),
      onTap: () {},
      infoWindow: const InfoWindow(title: "Your current Location"),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );
    addMarkerToMarkersAndUpdateUI(currentLocationMarker);
  }
  void addMarkerToMarkersAndUpdateUI(Marker marker) {
    setState(() {
      markers.add(marker);
    });
  }

  void getPlacesSuggestions(String query) {
    final sessionToken = const Uuid().v4();
    BlocProvider.of<MapsCubit>(context)
        .emitPlaceSuggestions(query, sessionToken);
  }

  Widget buildSuggestionsBloc() {
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

  void removeAllMarkersAndUpdateUI() {
    setState(() {
      markers.clear();
    });
  }

  void getSelectedPlaceLocation() {
    final sessionToken = const Uuid().v4();
    BlocProvider.of<MapsCubit>(context)
        .emitPlaceLocation(placeSuggestion.placeId, sessionToken);
  }
 Widget MyCard(Map<String, dynamic>? data) {
     return Material(
                  clipBehavior: Clip.antiAlias,
                  shape: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: Color.fromARGB(255, 43, 26, 92), width: 2.0),
                  ),
                  child: Container(
                    color: const Color(0xFFffd400),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                            children: [
            IconButton(
            icon: const Icon(Icons.list, size: 35, color: Color.fromARGB(255, 43, 26, 92),),
            onPressed: () async {
              // Navigate to HomeFavoris and wait for the result
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HomeFavoris()),
              );
              // Refresh data when returning from HomeFavoris
              setState(() {
                _dataFuture = _fetchData();
              });
            },
          ),
                              const Center(
                                child: Text(
                                  "Favori par défaut",
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 43, 26, 92)),
                                ),
                                
                              ),
                   
                            ],
                          ),
                          const SizedBox(height: 5.0),
                          Row(
                            children: [
                              Expanded(
                                child: Material(
                                  clipBehavior: Clip.antiAlias,
                                  shape: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: const BorderSide(color: Color(0xFFffd400), width: 2.0),
                                  ),
                                  child: Container(
                                    color: const Color.fromARGB(255, 43, 26, 92),
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Center(
                                          child: Text(
                                            "Départ",
                                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFffd400)),
                                          ),
                                        ),
                                        Center(
                                          child: Text(
                                            "${data?['stationSource'] ?? ''}",
                                            style: const TextStyle(fontSize: 10, color: Color(0xFFffd400)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Container(child: const Icon(Icons.arrow_circle_right_rounded, size: 30, color: Color.fromARGB(255, 43, 26, 92),)),
                              Expanded(
                                child: Material(
                                  clipBehavior: Clip.antiAlias,
                                  shape: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: const BorderSide(color: Color(0xFFffd400), width: 2.0),
                                  ),
                                  child: Container(
                                    color: const Color.fromARGB(255, 43, 26, 92),
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Center(
                                          child: Text(
                                            "Destination",
                                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFffd400)),
                                          ),
                                        ),
                                        Center(
                                          child: Text(
                                            "${data?['stationDestination'] ?? ''}",
                                            style: const TextStyle(fontSize: 10, color: Color(0xFFffd400)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 7.0),
                           Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.directions_bus, size: 23, color: Color.fromARGB(255, 43, 26, 92),),
                               Text(
                                    "Ligne : ${data?['nomLigne'] ?? ''} ",
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 43, 26, 92)),
                                    textAlign: TextAlign.center ,
                                  ),
                                
                              ],
                            ),
                          const SizedBox(height: 3,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                               const Icon(Icons.watch_later_outlined, size: 23, color: Color.fromARGB(255, 43, 26, 92),),

                              Center(
                                child: Text(
                                  "Temps d'arrivée : $estimatedTimeToStation",
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 43, 26, 92)),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5.0),
                        ],
                      ),
                    ),
                  ),
                );
              }
            
    Future<Map<String, dynamic>?> _fetchData() async {
    try {
      final favorisSnapshot = await FirebaseFirestore.instance
          .collection('favoris')
          .where('isDefault', isEqualTo: true)
          .get();

      if (favorisSnapshot.docs.isEmpty) {
        throw Exception('No default favorite found');
      }

      DocumentSnapshot doc = favorisSnapshot.docs.first;
      String? stationSource = doc.get('stationSource');
      String? stationDestination = doc.get('stationDestination');
      String? nomLigne = doc.get('nomLigne');
      String? idLigne = doc.get('idLigne');

      final busSnapshot = await FirebaseFirestore.instance
          .collection('bus')
          .doc(idLigne)
          .get();

      if (!busSnapshot.exists) {
        throw Exception('No bus found');
      }

      Map<String, dynamic>? data = busSnapshot.data();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (data != null) {
          calculateEstimatedTime(data, stationSource ?? '', stationDestination ?? '');
        }
      });

      return {
        'stationSource': stationSource,
        'stationDestination': stationDestination,
        'nomLigne': nomLigne,
        'busData': data,
      };
    } catch (e) {
      print('Error fetching data: $e');
      return null;
    }
  }

  void calculateEstimatedTime(Map<String, dynamic> data, String stationSource, String stationDestination) {
     try {
      DateTime currentTime = DateTime.now();
      DateTime firstDeparture = _parseTime(data?['firstdepart']);
      if (firstDeparture != null) {
        double totalDurationMinutes = double.parse(data!['route_details']['total_duration'].replaceAll(' min', ''));
        int minutesSinceDeparture = currentTime.difference(firstDeparture).inMinutes;
        int currentTripMinutes = minutesSinceDeparture % totalDurationMinutes.toInt();
        List stations = data['route_details']['stations'];
        int currentCycle = minutesSinceDeparture ~/ totalDurationMinutes.toInt();
        bool isGoDirection = currentCycle % 2 == 0;

        int selectedIndex = stations.indexWhere((station) => station['name'] == stationSource);

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
            estimatedTimeToStation = '${timeToStation.toStringAsFixed(2)} min';
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

  void updateProvider(BuildContext context, String busDocumentId) {
    final selectedBusProviderForFavoris = Provider.of<SelectedBusDocumentIdProviderForFavoris>(context, listen: false);
    selectedBusProviderForFavoris.selectedBusDocumentIdForFavoris = busDocumentId;
  }

@override
Widget build(BuildContext context) {
  final selectedStationsProvider = Provider.of<SelectedStationsProvider>(context);
  return Scaffold(
    drawer: MyDrawer(),
    body: Stack(
      fit: StackFit.expand,
      children: [
        position != null
            ? buildMap()
            : Center(
                child: Container(
                  child: const CircularProgressIndicator(
                    color: MyColors.blue,
                  ),
                ),
              ),
           IconButton(
            onPressed: () => _refreshScreen(context),
            icon: Icon(Icons.refresh),
          ),
        buildFloatingSearchBar(context, selectedStationsProvider),
        isSearchedPlaceMarkerClicked
            ? DistanceAndTime(
                isTimeAndDistanceVisible: isTimeAndDistanceVisible,
                placeDirections: placeDirections,
              )
            : Container(),
      ],
    ),
    floatingActionButton: Container(
      margin: const EdgeInsets.fromLTRB(0, 0, 8, 30),
      child: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 43, 26, 92),
        onPressed: _goToMyCurrentLocation,
        child: const Icon(Icons.place, color: Color(0xFFffd400)),
      ),
    ),
      bottomNavigationBar: SizedBox(
      height: 380,
      child: Column(
        children: [
          Expanded(
            child: selectedStationsProvider.station1Id != null && selectedStationsProvider.station2Id != null
                ? displayBusDocuments(selectedStationsProvider.station1Id!, selectedStationsProvider.station2Id!, selectedStationName, selectedstationn)
                : listBus(),
          ),
            const SizedBox(height: 5,),
            FutureBuilder<Map<String, dynamic>?>(
              future: _dataFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  final data = snapshot.data!;
                  return MyCard(data);
                }
                return Container(); // or a placeholder
              },
            ), // Add your MyCard widget here
          ],
        ),
      ),
  );
}
}