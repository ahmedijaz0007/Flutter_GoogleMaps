import 'package:geolocator/geolocator.dart';

class GoogleServices{

  _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    return position;
  }

}