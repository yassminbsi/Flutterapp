
import 'package:geolocator/geolocator.dart';
import './requestAssistant.dart';
import './mapconfig.dart';

class AssistantMethods {
  static Future<String> searchCoordinateAddress(Position position, context) async{
    String placeAddress = "";
    String url = "https://maps.googleapis.com/maps/api/geocode/json?"
        "latlng=${position.latitude},${position.longitude}&key=$GOOGLE_MAPS_API_KEY";

    var response = await RequestAssistant.getRequest(url);

    placeAddress = response["results"][0]["formatted_address"];

    print("kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk");

    print("This is your address:: $placeAddress");

    return placeAddress;

  }
}