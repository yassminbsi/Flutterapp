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
  
  String _station1Name = "";
 

  String get station1Name => _station1Name;
 

  void setStation1(String id, String name) {
    station1Id = id;
    _station1Name = name;
    notifyListeners();
  }

 

  void setStations(String id1, String name1,) {
    station1Id = id1;
    _station1Name = name1;
    
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
  static Position? positionStation;
  Completer<GoogleMapController> _mapController = Completer();

  static final CameraPosition _myCurrentLocationCameraPosition = CameraPosition(
    bearing: 0.0,
    target: LatLng(position!.latitude, position!.longitude),
    tilt: 0.0,
    zoom: 17,
  );
 
   String? station1Id;
   String station1Name="";

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
        markLocationOnMap(document.id);
        addMarker(stationLatitude, stationLongitude);
       drawPolylineBetweenLocationAndDocument(stationLatitude, stationLongitude);
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
    return Consumer<SelectedBusDocumentIdProvider>(
      builder: (context, provider, _) {
        return GridView.builder(
           gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisExtent: 60,
            ),
          itemCount: data.length,
          itemBuilder: (context, i) {
            return Card(
              child: Container(
                padding: EdgeInsets.all(10),
                color: Color.fromARGB(255, 235, 235, 235),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("L${i+1}: ${data[i]['nombus']}",
                          style: TextStyle(fontSize: 10)),
                      ],
                    ),
                    MaterialButton(
                      child: Icon(Icons.directions,color: MyColors.blue, size: 30),
                      onPressed: () async {
                        provider.selectedBusDocumentId = data[i].id;
                        Navigator.of(context).pushNamed("/MapLigne");
                      },
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
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
    findNearestStation();
    
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

 Widget buildMap() {
  Set<Marker> selectedMarkers = {};

  if (selectedStation1 != null) {
    selectedMarkers.add(Marker(
      markerId: MarkerId('station1'),
      position: selectedStation1!,
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

 Widget buildFloatingSearchBar(SelectedStationsProvider selectedStationsProvider) {
  final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
  return FloatingSearchBar(
    controller: controller,
    elevation: 6,
    hintStyle: TextStyle(fontSize: 18),
    queryStyle: TextStyle(fontSize: 18),
    hint: '',
    borderRadius: BorderRadius.circular(24),
    margins: EdgeInsets.fromLTRB(20, 70, 20, 0),
    padding: EdgeInsets.fromLTRB(2, 0, 2, 0),
    height: 50,
    backgroundColor: Color.fromARGB(255, 226, 222, 222),
    iconColor: MyColors.blue,
    scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),
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
          icon: Icon(Icons.search, color: Colors.transparent),
          onPressed: () {
            controller.query = 'Current Location';
            locationController.text = '';
            toggleAdditionalTextFieldVisibility();
            FocusScope.of(context).requestFocus(locationFocusNode);
          },
        ),
      ),
      FloatingSearchBarAction(
        showIfOpened: false,
        child: CircularButton(
          icon: Icon(Icons.arrow_drop_down, size: 40,
              color: MyColors.blue),
          onPressed: () async {
            QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('station').get();
            List<DocumentSnapshot> documents = querySnapshot.docs;
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Center(child: Text('Liste des stations')),
                  content: Container(
                    width: double.maxFinite,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            await findNearestStation;
                            Navigator.of(context).pop();
                          },
                           style: ElevatedButton.styleFrom(
                            backgroundColor: MyColors.blue, // Set the primary color of the button
                          ),
                          child: Text('Chercher la station la plus proche', style: TextStyle(color: Colors.white, fontSize: 12),),
                        ),
                        Expanded(
                          child: ListView.builder(
                            
                            shrinkWrap: true,
                            itemCount: documents.length,
                            itemBuilder: (BuildContext context, int index) {
                              DocumentSnapshot document = documents[index];
                              String nomstation = document.get('nomstation');
                              
                              return ListTile(
                                title: Text(nomstation),
                               /* onTap: () {
                                  double stationLatitude = double.tryParse(document['latitude'] ?? '') ?? 0.0;
                                  double stationLongitude = double.tryParse(document['longtude'] ?? '') ?? 0.0;
                                  controller.query = nomstation;
                                  markLocationOnMap(document.id);
                                  selectedStationsProvider.setStation1(document.id, nomstation);
                                  addMarker(stationLatitude, stationLongitude);
                                  drawPolylineBetweenLocationAndDocument(stationLatitude, stationLongitude);
                                  Navigator.of(context).pop(); 
                                },*/
                                onTap: () {
  double stationLatitude = double.tryParse(document['latitude'] ?? '') ?? 0.0;
  double stationLongitude = double.tryParse(document['longtude'] ?? '') ?? 0.0;
  controller.query = nomstation;
  markLocationOnMap(document.id);
  selectedStationsProvider.setStation1(document.id, nomstation);

  // Update the selected station
  updateSelectedStations(
    LatLng(stationLatitude, stationLongitude),
    selectedStation1 ?? LatLng(0.0, 0.0), // Pass the existing second station or a default value
  );
  Navigator.of(context).pop();
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
            );
          },
        ),
      ),
    ],
builder: (context, Transition) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              buildSuggestionsBloc(),
              buildSelectedPlaceLocationBloc(),
              buildDiretionsBloc(),
              SizedBox(height: 10),
              
           /*   TextField(
                controller: locationController,
                focusNode: locationFocusNode,
                decoration: InputDecoration(
                  hintText: 'Select a station',
                  hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 8, horizontal: 25),
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
                  suffixIcon: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('station')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return CircularProgressIndicator();
                      }
                      List<DropdownMenuItem> items = [];
                      snapshot.data!.docs.forEach((doc) {
                        items.add(DropdownMenuItem(
                          child: Text(doc['nomstation']),
                          value: doc.id,
                        ));
                       
                          station2Name = doc['nomstation'];
                        
                      });
                return DropdownButtonFormField(
                  items: items,
                  /*onChanged: (value) async {
                    markStationOnMap(value);
                    selectedStationsProvider.setStation2(value, station2Name);

                  },*/
  onChanged: (value) async {
  // Get the station details from the selected value
  var document = snapshot.data!.docs.firstWhere((doc) => doc.id == value);
  double stationLatitude = double.tryParse(document['latitude'] ?? '') ?? 0.0;
  double stationLongitude = double.tryParse(document['longtude'] ?? '') ?? 0.0;
  markStationOnMap(value);
  selectedStationsProvider.setStation2(value, station2Name);

  // Update the selected station
updateSelectedStations(
  selectedStation2 ?? LatLng(0.0, 0.0), // Pass the existing first station or a default value
  LatLng(stationLatitude, stationLongitude),
   );
},

                  
                );
              },
            ),
          ),
        ), */
 
   
      ],
    ),
  );
},
);
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
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Center(
                  child: Text(
                    'Liste des lignes passant par la station $stationName:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
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
                    return Card(
                      child: InkWell(
                        onTap: () {
                          // Handle bus line tap action
                          print('Selected bus line: $busName');
                        },
                        child: Container(
                          padding: EdgeInsets.all(10),
                          color: Color.fromARGB(255, 235, 235, 235),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "L${index + 1}: $busName",
                                    style: TextStyle(fontSize: 10),
                                  ),
                                ],
                              ),
                              MaterialButton(
                                child: Icon(Icons.directions, color: MyColors.blue, size: 30),
                                onPressed: () {
                                   provider.selectedBusDocumentId = data[index].id;
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
    _documentLatitude = double.tryParse(stationDoc['latitude'] ?? '');
    _documentLongitude = double.tryParse(stationDoc['longtude'] ?? '');

    if (_documentLatitude != null && _documentLongitude != null) {
      LatLng stationLatLng = LatLng(_documentLatitude!, _documentLongitude!);  
    }
  } catch (error) {
    print("Error fetching station location: $error");
  }
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
        

       drawPolylineBetweenLocationAndDocument(latitude, longitude);
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
    void addMarker(double latitude, double longitude) {
    markers.add(
      Marker(
        markerId: MarkerId(latitude.toString() + longitude.toString()),
        position: LatLng(latitude, longitude),
      ),
    );
  }

  // Method to update the selected station locations and add markers
  void updateSelectedStations(LatLng station1, LatLng station2) {
    setState(() {
      selectedStation1 = station1;
      selectedStation2 = station2;

      // Clear existing markers and add only selected station markers
      markers.clear();
      addMarker(station1.latitude, station1.longitude);
      addMarker(station2.latitude, station2.longitude);
    });
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
        buildFloatingSearchBar(selectedStationsProvider),
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
    bottomNavigationBar: SizedBox(
      height: 200,
      width: 50,
      child: selectedStationsProvider.station1Id != null
          ? displayBusDocuments(selectedStationsProvider.station1Id!)
          : listBus(),
    ),
  );
}

}