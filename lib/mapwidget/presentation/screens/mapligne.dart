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
             markers.last;
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
  
Widget MyCard(String selectedBusDocumentId) {
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
        String? nombus = snapshot.data!.get('nombus');
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
                      "Ligne : ${nombus ?? ''}",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 5.0),
                  Center(
                    child: Text(
                      "Temps d'arriver au station : 15h30",
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
void selectStation(String selectedStationId) {
    setState(() {
      stationId = selectedStationId;
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
                color: Colors.black,
                width: 2,
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

  Widget buildFloatingSearchBar() {
  
  final selectedBusProvider = Provider.of<SelectedBusDocumentIdProvider>(context); 
  final isPortrait =
      MediaQuery.of(context).orientation == Orientation.portrait;

  return FloatingSearchBar(
    controller: controller,
    elevation: 6,
    hintStyle: TextStyle(fontSize: 15, color: Color.fromARGB(255, 106, 120, 131)),
    queryStyle: TextStyle(fontSize: 15),
    hint: 'Current Location',
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
  return ClipRRect(
    borderRadius: BorderRadius.circular(8),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        buildSuggestionsBloc(),
        buildSelectedPlaceLocationBloc(),
        buildDirectionsBloc(),

        SizedBox(height: 10),
        TextField(
          controller: locationController,
          focusNode: locationFocusNode,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.only(left: 20.0,bottom: 8.0,top: 15.0,),
            hintText: '  Select a station For Current Position',
            hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
           // contentPadding: EdgeInsets.only(left: 25.0, bottom: 8.0, top: 15.0,),
            filled: true,
            fillColor: Color.fromARGB(255, 226, 222, 222),
            border: OutlineInputBorder(
              
              borderRadius: BorderRadius.circular(50),
              borderSide: BorderSide(color: Color.fromARGB(255, 92, 226, 74)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50),
              borderSide: BorderSide(color: Colors.grey),
            ),
            suffixIcon: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                .collection('bus')
                .doc(Provider.of<SelectedBusDocumentIdProvider>(context).selectedBusDocumentId)
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
                List<DropdownMenuItem<String>> items = [];
                nomstations.forEach((nomstation) {
                  items.add(DropdownMenuItem(
                    child: Text(nomstation),
                    value: nomstation, // Use the station name as the value
                  ));
                });
                return DropdownButtonFormField(
                  items: items,
                  onChanged: (value) async {
                    if (value != null) {
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
                         // addMarker(latitude, longitude);
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
    ),
  );
},

  );
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
    addMarker(latitude, longitude);
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
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
    );
    addMarkerToMarkersAndUpdateUI(marker);
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
    bottomNavigationBar: SizedBox(
      height: 150,
      width: 50,
      child: MyCard( selectedBusProvider.selectedBusDocumentId)
    ), 
  );
}


}