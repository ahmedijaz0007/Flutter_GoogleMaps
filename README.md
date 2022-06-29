Test Project to integrate Google Maps API using Flutter.

The code is mostly self explanatory but I will soon include step by step guide. You need to configure Google map apis from Google cloud platform.

Features:

Current location detection.
Start and Destination address marking on google map.
Route Calcuator using Google Direction Api (Note: you have to enable billing to use it). To be implemented:
Distance Calculator.
The project was implemented using Flutter version 3.0.3 Android Configs:

flutter.minSdkVersion=20
flutter.compileSdkVersion=33
flutter.targetSdkVersion=31
Library used

google_maps_flutter: ^2.1.8
geolocator: ^8.2.1
permission_handler: ^10.0.0
flutter_polyline_points: ^1.0.0
geocoding: ^2.0.4
