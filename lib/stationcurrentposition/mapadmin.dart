import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/componenents/custombuttonauth.dart';
import 'package:flutter_app/mapwidget/business_logic/cubit/maps/maps_cubit.dart';
import 'package:flutter_app/mapwidget/constnats/my_colors.dart';
import 'package:flutter_app/mapwidget/data/models/Place_suggestion.dart';
import 'package:flutter_app/mapwidget/data/models/place.dart';
import 'package:flutter_app/mapwidget/data/models/place_directions.dart';
import 'package:flutter_app/mapwidget/helpers/location_helper.dart';
import 'package:flutter_app/mapwidget/presentation/widgets/distance_and_time.dart';
import 'package:flutter_app/mapwidget/presentation/widgets/my_drawer.dart';
import 'package:flutter_app/mapwidget/presentation/widgets/place_item.dart';
import 'package:flutter_app/view/dashboard/dashboard_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:material_floating_search_bar_2/material_floating_search_bar_2.dart';
import 'package:uuid/uuid.dart';

class MapAdmin extends StatefulWidget {
  const MapAdmin({super.key});

  @override
  State<MapAdmin> createState() => _MapAdminState();
}

class _MapAdminState extends State<MapAdmin> {
 
  
 
  List<PlaceSuggestion> places = [];
  FloatingSearchBarController controller = FloatingSearchBarController();
  static Position? position;
  Completer<GoogleMapController> _mapController = Completer();

  static final CameraPosition _myCurrentLocationCameraPosition =
      CameraPosition(
    bearing: 0.0,
    target: LatLng(position!.latitude, position!.longitude),
    tilt: 0.0,
    zoom: 17,
  );

  TextEditingController nomstation = TextEditingController();
  TextEditingController currentposition = TextEditingController();

  Set<Marker> markers = Set();
  late PlaceSuggestion placeSuggestion;
  late Place selectedPlace;
  late Marker searchedPlaceMarker;
  late Marker currentLocationMarker;
  late CameraPosition goToSearchedForPlace;
  late final Timer _debounce;
  String selectedStation = '';
  List<String> stationNames = [];
  final FocusNode locationFocusNode = FocusNode();
  FocusNode destinationLocationFocusNode = FocusNode();

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

  void onSubmitStationName(String stationName) {
    addCurrentPositionAndStationToFirestore(stationName);
  }

  void onTapIcon() {
    String stationName = nomstation.text;
    if (stationName.isNotEmpty) {
      addCurrentPositionAndStationToFirestore(stationName);
      nomstation.clear();
      nomstation.text = stationName;
    }
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
  Map<PolylineId, Polyline> polylines = {};

  @override
  initState() {
    super.initState();
    getMyCurrentLocation();
    _goToMyCurrentLocation();
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

 /* void toggleAdditionalTextFieldVisibility() {
    setState(() {
      showAdditionalTextField = !showAdditionalTextField;
    });
  }*/

  Future<void> addCurrentPositionAndStationToFirestore(
      String stationName) async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final DocumentReference stationRef =
          FirebaseFirestore.instance.collection('station').doc();

      await stationRef.set({
        'nomstation': stationName,
        'latitude': position.latitude,
        'longtude': position.longitude,
      });

      print('Station added to Firestore: $stationName');
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => DashboardScreen(
          initialTabIndex: 3,
        ),
      ));
    } catch (error) {
      print('Error adding station to Firestore: $error');
    }
  }

  @override
  void dispose() {
    super.dispose();
    nomstation.dispose();
  }

  /*void markStationOnMap(String stationId) async {
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
        CameraPosition newPosition = CameraPosition(
          bearing: 0.0,
          tilt: 0.0,
          target: LatLng(latitude, longitude),
          zoom: 13,
        );

        final GoogleMapController controller =
            await _mapController.future;
        controller.animateCamera(
            CameraUpdate.newCameraPosition(newPosition));

        addMarker(latitude, longitude);

        drawPolyline(LatLng(position!.latitude, position!.longitude),
            LatLng(latitude, longitude));
      }
    } catch (error) {
      print("Error fetching destination location: $error");
    }
  }*/

  /*void drawPolyline(LatLng from, LatLng to) {
    PolylineId id = PolylineId("poly");
    List<LatLng> points = [from, to];
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.blue,
      points: points,
      width: 3,
    );

    setState(() {
      polylines[id] = polyline;
    });
  }
*/
  /*Widget buildDiretionsBloc() {
    return BlocListener<MapsCubit, MapsState>(
      listener: (context, state) {
        if (state is DirectionsLoaded) {
          placeDirections = (state).placeDirections;

          getPolylinePoints();
        }
      },
      child: Container(),
    );
  }*/

 /* void addMarker(double lat, double lng) {
    Marker marker = Marker(
      markerId: MarkerId('$lat-$lng'),
      position: LatLng(lat, lng),
      infoWindow: InfoWindow(title: 'Station'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
    );
    addMarkerToMarkersAndUpdateUI(marker);
  }*/

 /* void getPolylinePoints() {
    polylinePoints = placeDirections!.polylinePoints
        .map((e) => LatLng(e.latitude, e.longitude))
        .toList();
  }*/

  /*Widget buildSelectedPlaceLocationBloc() {
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
  }*/

 /* void getDirections() {
    BlocProvider.of<MapsCubit>(context).emitPlaceDirections(
      LatLng(position!.latitude, position!.longitude),
      LatLng(selectedPlace.result.geometry.location.lat,
          selectedPlace.result.geometry.location.lng),
    );
  }*/

/*Future<void> goToMySearchedForLocation() async {
    buildCameraNewPosition();
    final GoogleMapController controller = await _mapController.future;
    controller
        .animateCamera(CameraUpdate.newCameraPosition(goToSearchedForPlace));
    buildSearchedPlaceMarker();
  }*/

 /* void buildSearchedPlaceMarker() {
    searchedPlaceMarker = Marker(
      position: goToSearchedForPlace.target,
      markerId: MarkerId('1'),
      onTap: () {
        buildCurrentLocationMarker();
        setState(() {
          isSearchedPlaceMarkerClicked = true;
          isTimeAndDistanceVisible = true;
        });
      },
      infoWindow: InfoWindow(title: "${placeSuggestion.description}"),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );

    addMarkerToMarkersAndUpdateUI(searchedPlaceMarker);
  }*/

 /* void buildCurrentLocationMarker() {
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
  }*/

 /* void getPlacesSuggestions(String query) {
    final sessionToken = Uuid().v4();
    BlocProvider.of<MapsCubit>(context)
        .emitPlaceSuggestions(query, sessionToken);
  }*/

 /* Widget buildSuggestionsBloc() {
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
  }*/

 /* Widget buildPlacesList() {
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
  }*/

 /* void removeAllMarkersAndUpdateUI() {
    setState(() {
      markers.clear();
    });
  }*/

 /* void getSelectedPlaceLocation() {
    final sessionToken = Uuid().v4();
    BlocProvider.of<MapsCubit>(context)
        .emitPlaceLocation(placeSuggestion.placeId, sessionToken);
  }*/

 @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      //drawer: MyDrawer(),
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
          buildFloatingSearchBar(), // Appel à la méthode pour construire la barre de recherche flottante
     
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
    );
  }
   Widget buildFloatingSearchBar() {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return FloatingSearchBar(
      controller: controller,
      elevation: 6,
      hintStyle: TextStyle(fontSize: 18),
      queryStyle: TextStyle(fontSize: 18),
      hint: 'current location..',
      borderRadius: BorderRadius.circular(24),
      margins: EdgeInsets.fromLTRB(20, 70, 20, 0),
      padding: EdgeInsets.fromLTRB(2, 0, 2, 0),
      height: 60,
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
      onFocusChanged: (_) {
        // hide distance and time row
        setState(() {
          isTimeAndDistanceVisible = false;
        });
      },
      transition: CircularFloatingSearchBarTransition(),
      builder: (context, transition) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
             // buildSuggestionsBloc(),
             // buildSelectedPlaceLocationBloc(),
             // buildDiretionsBloc(),
              SizedBox(height: 10),
              SizedBox(
                height: 60,
                child: TextFormField(
                  cursorColor: Colors.blue,
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color.fromARGB(255, 226, 222, 222)),
                      borderRadius: BorderRadius.circular(24)),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color.fromARGB(255, 226, 222, 222)),
                      borderRadius: BorderRadius.circular(24)), 
                      fillColor: Color.fromARGB(255, 226, 222, 222), // Set the background color to white
                    filled: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(24),),
                    labelText: "Nom de station",
                    labelStyle: TextStyle(color: Colors.black),
                  ),
                  
                  controller: nomstation,
                  validator: (val) {
                    if (val == "") {
                      return "Ne peut pas être vide";
                    }
                    return null; 
                  },
                ),
              ),
           SizedBox(height: 20,),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomButtonAuth(
                    title: "Sauvegarder Station",
                    onPressed: (){
                      onTapIcon();
                      ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                content: Text('La station a été ajoutée avec succès', style: TextStyle(color: Colors.black), 
                                ),
                                backgroundColor: const Color.fromARGB(255, 197, 197, 197),
                                duration: Duration(seconds: 2),
                      ),
                    );
                    },),
                ],
              )
            ],
          ),
        );
      },
    );
  }
}
