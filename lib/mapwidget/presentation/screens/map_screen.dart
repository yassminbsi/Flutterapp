
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/mapwidget/business_logic/cubit/maps/maps_cubit.dart';
import 'package:flutter_app/mapwidget/constnats/my_colors.dart';
import 'package:flutter_app/mapwidget/data/models/Place_suggestion.dart';
import 'package:flutter_app/mapwidget/data/models/place.dart';
import 'package:flutter_app/mapwidget/data/models/place_directions.dart';
import 'package:flutter_app/mapwidget/helpers/location_helper.dart';
import 'package:flutter_app/mapwidget/presentation/screens/selectedbus.dart';
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
class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List<PlaceSuggestion> places = [];
  FloatingSearchBarController controller = FloatingSearchBarController();
  static Position? position;
  Completer<GoogleMapController> _mapController = Completer();

  static final CameraPosition _myCurrentLocationCameraPosition = CameraPosition(
    bearing: 0.0,
    target: LatLng(position!.latitude, position!.longitude),
    tilt: 0.0,
    zoom: 11,
  );
 
   String? station1Id;
   String station1Name="";
List<DocumentSnapshot> filteredStationList = [];
  bool showFilteredListForSearchBar = false;
  bool showFilteredListForTextField = false;
 
  Set<Marker> markers = Set();
  late PlaceSuggestion placeSuggestion;
  late Place selectedPlace;
  late Marker searchedPlaceMarker;
  late Marker currentLocationMarker;
  late CameraPosition goToSearchedForPlace;
  late final Timer _debounce;
  String? selectedStation1Id;
String? selectedStation2Id;
 bool showFilteredList = false;
double? _documentLatitude;
double? _documentLongitude;
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
            borderSide: BorderSide(color: Color(0xFFffd400), width:2.0),
          ),
          child: Container(
    color: Color.fromARGB(255, 43, 26, 92),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                   padding: const EdgeInsets.all(8.0),
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
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisExtent: 60,
          ),
          itemCount: data.length,
          itemBuilder: (context, i) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(15), // Circular border radius
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFFffd400),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Color(0xFFffd400), width: 2), // Border color and width
                ),
                margin: EdgeInsets.all(5),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(10), // Padding inside the card
                          child: Text(
                            "L${i + 1}: ${data[i]['nombus']}",
                            style: TextStyle(fontSize: 9,fontWeight: FontWeight.bold, color: Color.fromARGB(255, 43, 26, 92)),
                          ),
                        ),
                      ],
                    ),
                    Spacer(), // Pushes the MaterialButton to the right
                    MaterialButton(
                      child: Icon(Icons.directions, color: Color.fromARGB(255, 43, 26, 92), size: 30),
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

  @override
  void initState() {
    super.initState();
    getMyCurrentLocation();
   // _goToMyCurrentLocation();
    getData();
    controller = FloatingSearchBarController();
    
   
    
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
    if (selectedStation1 != null && selectedStation2 != null) {
      // Calculate the midpoint between the two selected stations
      LatLng midPoint = LatLng(
        selectedStation1!.latitude  ,
        selectedStation1!.longitude ,
      );

      // Calculate the zoom level
      double zoomLevel = 14; // Adjust zoom level as needed

      // Get GoogleMapController from the Completer
      GoogleMapController controller = await _mapController.future;

      // Animate camera to the midpoint with the calculated zoom level
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
       if (selectedStation1 != null ) {
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
      FloatingSearchBar(
        controller: controller,
        elevation: 6,
        hintStyle: TextStyle(fontSize: 15),
        queryStyle: TextStyle(fontSize: 16),
        hint: selectedStationName,
        borderRadius: BorderRadius.circular(24),
        margins: EdgeInsets.fromLTRB(20, 70, 20, 0),
        padding: EdgeInsets.fromLTRB(2, 0, 2, 0),
        height: 50,
        backgroundColor: Color.fromARGB(255, 226, 222, 222),
        iconColor: Color.fromARGB(255, 43, 26, 92),
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
              /* actions: [
            FloatingSearchBarAction(
              showIfOpened: false,
              child: CircularButton(
                icon: Icon(Icons.arrow_drop_down, size: 40, color: Color.fromARGB(255, 43, 26, 92)),
                onPressed: () async {
                  QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('station').get();
                  List<DocumentSnapshot> documents = querySnapshot.docs;
                  showMenu(
                    surfaceTintColor: Color.fromARGB(255, 226, 222, 222),
                    context: context,
                    position: RelativeRect.fromLTRB(30, 120, 30, 30),
                    items: documents.map((document) {
                      String nomstation = document.get('nomstation');
                      return PopupMenuItem<String>(
                        value: document.id,
                        child: Text(nomstation),
                      );
                    }).toList(),
                  ).then((selectedStationId) {
                    if (selectedStationId != null) {
                      DocumentSnapshot document = documents.firstWhere((doc) => doc.id == selectedStationId);
                      String nomstation = document.get('nomstation');
                      double stationLatitude = double.tryParse(document['latitude'] ?? '') ?? 0.0;
                      double stationLongitude = double.tryParse(document['longtude'] ?? '') ?? 0.0;
                      controller.query = nomstation;
                      markLocationOnMap(document.id);
                      selectedStationsProvider.setStation1(document.id, nomstation);
                      final selectedStationNameProvider = Provider.of<SelectedStationNameProvider>(context, listen: false);
                      selectedStationNameProvider.setSelectedStation(nomstation, document.id);
                      updateSelectedStations(
                        LatLng(stationLatitude, stationLongitude),
                        selectedStation1 ?? LatLng(0.0, 0.0),
                      );
                      setState(() {
                        selectedStationName = nomstation;
                        isStationListVisible = false; // Hide the list after selection
                      });
                    }
                  });
                },
              ),
            ),
          ], */
           builder: (context, transition) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Material(
              color: Color.fromARGB(255, 226, 222, 222),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (showFilteredListForSearchBar)
                   Container(
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
                       // double startStationLatitude = double.tryParse(document['latitude'] ?? '') ?? 0.0;
                       // double startStationLongitude = double.tryParse(document['longtude'] ?? '') ?? 0.0;
                        setState(() {
                          selectedStationName = nomstation;
                          showFilteredListForTextField = false;
                          controller.close();
                        });
                     /*   selectedStationsProvider.setStation1(station1Id, selectedstationn);
                        markLocationOnMap(station1Id);
                        
                        drawPolylineBetweenLocationAndDocument();
                        final selectedStationNameProvider = Provider.of<SelectedStationNameProvider>(context, listen: false);
                        selectedStationNameProvider.setSelectedStation(selectedStationName, station1Id);
                        updateSelectedStations(
                          LatLng(startStationLatitude, startStationLongitude),
                          selectedStation1 ?? LatLng(0.0, 0.0),
                        ); */
                        // Fetch station document and update end station coordinates

    setState(() {
       startStationLatitude = double.tryParse(document['latitude'] ?? '') ?? 0.0;
       startStationLongitude = double.tryParse(document['longtude'] ?? '') ?? 0.0;
    });
    markLocationOnMap(station1Id);
    final selectedStationNameProvider = Provider.of<SelectedStationNameProvider>(context, listen: false);
    selectedStationNameProvider.setSelectedStation(selectedStationName, station1Id);
    drawPolylineBetweenLocationAndDocument();
   selectedStationsProvider.setStation1(station1Id, selectedStationName);
     updateSelectedStations(
             LatLng(startStationLatitude!, startStationLongitude!),
                 selectedStation2 ?? LatLng(0.0, 0.0), // Pass the existing second station or a default value
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
      Positioned(
        top: 140,
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
                contentPadding: EdgeInsets.only(left: 20.0, bottom: 8.0),
                hintText: selectedstationn,
                hintStyle: TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.normal),
                labelStyle: TextStyle(fontSize: 15, color: Colors.black),
                filled: true,
                fillColor: Color.fromARGB(255, 226, 222, 222),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: BorderSide(color: Colors.transparent),
                ),
                prefixIcon: Icon(Icons.directions_bus, color: Color.fromARGB(255, 43, 26, 92)),
                suffixIcon: IconButton(
                  icon: Icon(Icons.arrow_drop_down, size: 40, color: Color.fromARGB(255, 43, 26, 92)),
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
                //  showFilteredListForSearchBar = false;
                });
              },
            ),
            if (showFilteredListForTextField)
              Container(
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
                        String station2Id = filteredStationList[index].id;
                        DocumentSnapshot document = filteredStationList[index];
                        String nomstation = document.get('nomstation');
                       // double endStationLatitude = double.tryParse(document['latitude'] ?? '') ?? 0.0;
                     //   double endStationLongitude = double.tryParse(document['longtude'] ?? '') ?? 0.0;
                        setState(() {
                          selectedstationn = nomstation;
                          showFilteredListForTextField = false;
                          locationController.clear();
                        });
                     /*   selectedStationsProvider.setStation2(station2Id, selectedstationn);
                        markLocationOnMap(station2Id);
                        
                        drawPolylineBetweenLocationAndDocument();
                        updateSelectedStations(
                          LatLng(endStationLatitude, endStationLongitude),
                          selectedStation2 ?? LatLng(0.0, 0.0),
                        );*/
                         // Fetch station document and update end station coordinates
  
    setState(() {
      endStationLatitude = double.tryParse(document['latitude'] ?? '') ?? 0.0;
      endStationLongitude = double.tryParse(document['longtude'] ?? '') ?? 0.0;
    });
   // markLocationOnMap(station2Id);
    drawPolylineBetweenLocationAndDocument();
   // Update the selected station
     updateSelectedStations(selectedStation1 ?? LatLng(0.0, 0.0), // Pass the existing first station or a default value
                                              LatLng(endStationLatitude!, endStationLongitude!),
                                            );
  
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    ],
  );
}
 Future<void> fetchStations() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('station').get();
    setState(() {
      filteredStationList = querySnapshot.docs;
    });
  }

Future<List<Map<String, dynamic>>> fetchBusDocumentsWithStations(String station1Id) async {
  try {
    DocumentSnapshot stationSnapshot = await FirebaseFirestore.instance.collection('station').doc(station1Id).get();
    String stationName = stationSnapshot['nomstation'] as String;

    QuerySnapshot busSnapshot = await FirebaseFirestore.instance.collection('bus').get();

    List<Map<String, dynamic>> busDocs = [];
    for (var doc in busSnapshot.docs) {
      List<dynamic> stations = doc['nomstation'];
      bool station1Exists = stations.any((station) => station.contains("ID: $station1Id"));
      
      if (station1Exists) {
        busDocs.add({
          'doc': doc,
          'nomstation': stationName,
        });
      }
    }
    return busDocs;
  } catch (e) {
    print('Error fetching bus documents: $e');
    return [];
  }
}

Widget displayBusDocuments(String stationId) {
  return FutureBuilder<List<Map<String, dynamic>>>(
    future: fetchBusDocumentsWithStations(stationId),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(child: CircularProgressIndicator());
      } else if (snapshot.hasError) {
        return Center(child: Text('Error: ${snapshot.error}'));
      } else if (snapshot.hasData) {
        List<Map<String, dynamic>> busDocs = snapshot.data!;
        if (busDocs.isNotEmpty) {
          List<String> busNames = busDocs.map((map) => map['doc']['nombus'] as String).toList();
          String stationName = busDocs.first['nomstation'] as String;
          return Material(
             clipBehavior: Clip.antiAlias,
          shape: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Color.fromARGB(255, 43, 26, 92), width:2.0),
          ),
          child: Container(
            color: Color(0xFFffd400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                     padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: RichText(
                        textAlign: TextAlign.center, // Center-align the text within the RichText
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Liste des lignes passant par la station',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Color(0xFF25243A),
                              ),
                            ),
                            TextSpan(
                              text: ' $stationName ',
                              style: TextStyle(
                                fontSize: 20,
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
                    child:  Consumer<SelectedBusDocumentIdProvider>(
                    builder: (context, provider, _) {
                  return  GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisExtent: 60,
                      ),
                      itemCount: busNames.length,
                      itemBuilder: (context, index) {
                        final busName = busNames[index];
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(15), // Circular border radius
                          child: InkWell(
                            onTap: () {
                              // Handle bus line tap action
                              print('Selected bus line: $busName');
                            },
                            child: Container(
                            decoration: BoxDecoration(
                    color: Color.fromARGB(255, 43, 26, 92),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Color(0xFFffd400), width: 2), // Border color and width
                  ),
                  margin: EdgeInsets.all(5),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                     Padding(
                                 padding: EdgeInsets.all(10), // Padding inside the card
                                  child: Text(
                                        "L${index + 1}: $busName",
                                        style: TextStyle(fontSize: 9, color:Color(0xFFffd400) ),
                                      ),
                                  )
                                  ],
                                  ),
                                  Spacer(),
                                  MaterialButton(
                                    child: Icon(Icons.directions, color: Color(0xFFffd400), size: 30),
                                    onPressed: () {
                                        provider.selectedBusDocumentId = busDocs[index]['doc'].id;
                                       Navigator.of(context).pushNamed("/MapLigne");
                                    },
                                  )
                                ],
                              ),
                    
                            ),
                            
                          ),
                        );
                      },
                    );
              }  ),
                 )   ],
              ),
            ),
          );
        } else {
          return Center(child: Text('Aucun bus trouvé.'));
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
      infoWindow: InfoWindow(title: 'Station'),
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
        markerId: MarkerId('station1'),
        position: station1,
      ));
      markers.add(Marker(
        markerId: MarkerId('station2'),
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

  void getPlacesSuggestions(String query) {
    final sessionToken = Uuid().v4();
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
    final sessionToken = Uuid().v4();
    BlocProvider.of<MapsCubit>(context)
        .emitPlaceLocation(placeSuggestion.placeId, sessionToken);
  }
Widget MyCard() {
  return FutureBuilder<QuerySnapshot>(
    future: FirebaseFirestore.instance.collection('favoris').where('isDefault', isEqualTo: true).get(),
    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return CircularProgressIndicator();
      } else if (snapshot.hasError) {
        return Text('Error: ${snapshot.error}');
      } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
        return Text('No default favorite found');
      } else {
        DocumentSnapshot doc = snapshot.data!.docs.first;
        String? nomLigne = doc.get('nomLigne');
        String? stationSource = doc.get('stationSource');
        String? stationDestination = doc.get('stationDestination');

        return Material(
          clipBehavior: Clip.antiAlias,
          shape: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Color.fromARGB(255, 43, 26, 92), width:2.0),
          ),
          child: Container(
            color: Color(0xFFffd400),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                    
                        Center(
                          child: Text(
                            "Favoris par défaut",
                            style: TextStyle( fontSize: 18, fontWeight: FontWeight.bold , color: Color.fromARGB(255, 43, 26, 92)),
                          ),
                          
                        ),
                        
//Icon(Icons.star, size: 50, color: Color.fromARGB(242, 255, 226, 61),),
                                        
                                      
                      
                    
                  
                 
                  SizedBox(height: 5.0),
                 Row(
  children: [
    Expanded(
      child: Material(
        clipBehavior: Clip.antiAlias,
        shape: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Color(0xFFffd400), width: 2.0),
        ),
        child: Container(
          color: Color.fromARGB(255, 43, 26, 92),
          padding: EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  "Départ",
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFffd400)),
                ),
              ),
              Center(
                child: Text(
                  "${stationSource}",
                  style: TextStyle(fontSize: 10, color: Color(0xFFffd400)),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    
    Container(child: Icon(Icons.arrow_circle_right_rounded, size: 30,color: Color.fromARGB(255, 43, 26, 92),)),
   // Space between the two materials
    Expanded(
      child: Material(
        clipBehavior: Clip.antiAlias,
        shape: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Color(0xFFffd400), width: 2.0),
        ),
        child: Container(
          color: Color.fromARGB(255, 43, 26, 92),
          padding: EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  "Destination",
                  style: TextStyle(fontSize: 10,fontWeight:FontWeight.bold , color: Color(0xFFffd400)),
                ),
              ),
              Center(
                child: Text(
                  "${stationDestination}",
                  style: TextStyle(fontSize: 10, color: Color(0xFFffd400)),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  ],
),

                  SizedBox(height: 5.0),
                  Center(
                    child: Text(
                      "Ligne : ${nomLigne ?? ''}",
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color : Color.fromARGB(255, 43, 26, 92), ),
                    ),
                  ),
                  Center(
                    child: Text(
                      "Temps d'arrivée de bus : 12min",
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color : Color.fromARGB(255, 43, 26, 92), ),
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
                  child: CircularProgressIndicator(
                    color: MyColors.blue,
                  ),
                ),
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
      margin: EdgeInsets.fromLTRB(0, 0, 8, 30),
      child: FloatingActionButton(
        backgroundColor: Color.fromARGB(255, 43, 26, 92),
        onPressed: _goToMyCurrentLocation,
        child: Icon(Icons.place, color: Color(0xFFffd400)),
      ),
    ),
    bottomNavigationBar: SizedBox(
      
        height: 360,
        child: Column(
          children: [
            Expanded(
              child: selectedStationsProvider.station1Id != null
                  ? displayBusDocuments(selectedStationsProvider.station1Id!)
                  : listBus(),
            ),
            SizedBox(height: 5,),
            MyCard(), // Add your MyCard widget here
          ],
        ),
      ),
  );
}

}