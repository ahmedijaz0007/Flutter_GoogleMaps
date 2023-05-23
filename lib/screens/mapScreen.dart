import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/widgets/text_field.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';


const String googleApiKey = 'Enter your Google API Key here';

class MapWidget extends StatefulWidget {
  const MapWidget({super.key});

  @override
  State<StatefulWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  CameraPosition initialLocation = const CameraPosition(target: LatLng(0.0, 0.0));
  late List<Location> startPlacemark;
  late List<Location>
      destinationPlacemark; // = await locationFromAddress(_destinationAddress);
  Set<Marker> markers = {};
  var _currentAddress = "";
  var _startAddress = "";
  var _destinationAddress = "";
  late PolylinePoints polylinePoints;

// List of coordinates to join
  List<LatLng> polylineCoordinates = [];

// Map storing polylines created by connecting two points
  Map<PolylineId, Polyline> polylines = {};
  final startAddressFocusNode = FocusNode();
  final desrinationAddressFocusNode = FocusNode();
  late Position _currentPosition;
  final startAddressController = TextEditingController();
  final destinationAddressController = TextEditingController();
  late GoogleMapController mapController;
  @override
  void initState() {
    super.initState();
    getCurrentLocation();
  }

  // Create the polylines for showing the route between two places

  _createPolylines(
      double startLatitude,
      double startLongitude,
      double destinationLatitude,
      double destinationLongitude,
      ) async {
    // Initializing PolylinePoints
    polylinePoints = PolylinePoints();

    // Generating the list of coordinates to be used for
    // drawing the polylines
    print("I AM POLY");
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey, // Google Maps API Key
      PointLatLng(startLatitude, startLongitude),
      PointLatLng(destinationLatitude, destinationLongitude),
      travelMode: TravelMode.transit,
    );
   print(result.errorMessage);  //Enable Billing to access this API
    // Adding the coordinates to the list
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }
    else print('I am error poly');

    // Defining an ID
    PolylineId id = PolylineId('poly');

    // Initializing Polyline
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.red,
      points: polylineCoordinates,
      width: 3,
    );

    // Adding the polyline to the map
    polylines[id] = polyline;
  }



  _calculateDistance() async {
    // Retrieving placemarks from addresses
    print("I am DISTANCE");
    List<Location>? startPlacemark = await locationFromAddress(_startAddress);
    print("$_destinationAddress DestinationAddress");

    List<Location>? destinationPlacemark =
        await locationFromAddress(_destinationAddress);
    print("$_destinationAddress DestinationAddress");
    // Use the retrieved coordinates of the current position,
    // instead of the address if the start position is user's
    // current position, as it results in better accuracy.
    double startLatitude = _startAddress == _currentAddress
        ? _currentPosition.latitude
        : startPlacemark[0].latitude;

    double startLongitude = _startAddress == _currentAddress
        ? _currentPosition.longitude
        : startPlacemark[0].longitude;

    double destinationLatitude = destinationPlacemark[0].latitude;
    double destinationLongitude = destinationPlacemark[0].longitude;

    String startCoordinatesString = '($startLatitude, $startLongitude)';
    String destinationCoordinatesString =
        '($destinationLatitude, $destinationLongitude)';

    // Start Location Marker
    Marker startMarker = Marker(
      markerId: MarkerId(startCoordinatesString),
      position: LatLng(startLatitude, startLongitude),
      infoWindow: InfoWindow(
        title: 'Start $startCoordinatesString',
        snippet: _startAddress,
      ),
      icon: BitmapDescriptor.defaultMarker,
    );

    // Destination Location Marker
    Marker destinationMarker = Marker(
      markerId: MarkerId(destinationCoordinatesString),
      position: LatLng(destinationLatitude, destinationLongitude),
      infoWindow: InfoWindow(
        title: 'Destination $destinationCoordinatesString',
        snippet: _destinationAddress,
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
    );

    setState(() {
      markers.add(startMarker);
      markers.add(destinationMarker);
      // Adding the markers to the list
    });

    // Calculating to check that the position relative
// to the frame, and pan & zoom the camera accordingly.
    double miny = (startLatitude <= destinationLatitude)
        ? startLatitude
        : destinationLatitude;
    double minx = (startLongitude <= destinationLongitude)
        ? startLongitude
        : destinationLongitude;
    double maxy = (startLatitude <= destinationLatitude)
        ? destinationLatitude
        : startLatitude;
    double maxx = (startLongitude <= destinationLongitude)
        ? destinationLongitude
        : startLongitude;

    double southWestLatitude = miny;
    double southWestLongitude = minx;

    double northEastLatitude = maxy;
    double northEastLongitude = maxx;

// Accommodate the two locations within the
// camera view of the map
    mapController.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          northeast: LatLng(northEastLatitude, northEastLongitude),
          southwest: LatLng(southWestLatitude, southWestLongitude),
        ),
        100.0,
      ),
    );

    _createPolylines(startLatitude,startLongitude,destinationLatitude,destinationLongitude);


  }

// Method for retrieving the address

  _getAddress() async {
    try {
      // Places are retrieved using the coordinates
      print("address address");
      List<Placemark> p = await placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);

      // Taking the most probable result
      Placemark place = p[0];
      print("I AM ADDRESS");
      setState(() {
        // Structuring the address
        _currentAddress =
            "${place.name}, ${place.locality}, ${place.postalCode}, ${place.country}";

        print("$_currentAddress Current Address");
        // Update the text of the TextField
        startAddressController.text = _currentAddress;

        // Setting the user's present location as the starting address
        _startAddress = _currentAddress;
      });
    } catch (e) {
      print("ERROR ADDRESS $e");
    }
  }

  getCurrentLocation() async {
    print("I am here");
    var status = await Permission.location.status;
    var permissionGranted = false;
    print("$status LocationStatus");
    permissionGranted = status.isGranted;
    if (!permissionGranted) {
      // We didn't ask for permission yet or the permission has been denied before but not permanently.
      permissionGranted = await Permission.location.request().isGranted;
    }
    if (permissionGranted) {
      if (await Permission.locationWhenInUse.serviceStatus.isEnabled) {
        // Use location.
        await Geolocator.getCurrentPosition(
                desiredAccuracy: LocationAccuracy.high)
            .then((Position position) async {
          setState(() {
            // Store the position in the variable
            _currentPosition = position;

            print('CURRENT POS: $_currentPosition');

            // For moving the camera to current location
            mapController.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(
                  target: LatLng(position.latitude, position.longitude),
                  zoom: 18.0,
                ),
              ),
            );
          });
          await _getAddress();
        }).catchError((e) {
          print(e);
        });
      }
    } else {
      print("Enable Location services to continue using it");
    }
  }

  // Test if location services are enabled.

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Container(
      height: height,
      width: width,
      child: Scaffold(
        body: Stack(
          children: [
            GoogleMap(
              polylines: Set<Polyline>.of(polylines.values),
              markers: Set<Marker>.from(markers),
              initialCameraPosition: initialLocation,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              mapType: MapType.normal,
              zoomGesturesEnabled: true,
              zoomControlsEnabled: false,
              onMapCreated: (GoogleMapController controller) {
                mapController = controller;
              },
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      textField(
                          label: 'Start',
                          hint: 'Choose starting point',
                          prefixIcon: const Icon(Icons.looks_one),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.my_location),
                            onPressed: () {
                              startAddressController.text = _currentAddress;
                              _startAddress = _currentAddress;
                            },
                          ),
                          controller: startAddressController,
                          focusNode: startAddressFocusNode,
                          width: width,
                          locationCallback: (String value) {
                            setState(() {
                              _startAddress = value;
                            });
                          }),
                      const SizedBox(height: 10),
                      textField(
                          label: 'Destination',
                          hint: 'Choose destination',
                          prefixIcon: const Icon(Icons.looks_two),
                          controller: destinationAddressController,
                          focusNode: desrinationAddressFocusNode,
                          width: width,
                          locationCallback: (String value) {
                            setState(() {
                              _destinationAddress = value;
                            });
                          }),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed:   (
    _startAddress != '' &&
    _destinationAddress != '')
    ? () async {
                          startAddressFocusNode.unfocus();
                          desrinationAddressFocusNode.unfocus();
                          setState(() {
                            if (markers.isNotEmpty) markers.clear();
                            _calculateDistance();
                          },

                          );
                        } : (){
                          if (kDebugMode) {
                            print("Invalid Address");
                          }
                        },

                        child: const Text("Find route"),
                      )
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ClipOval(
                      child: Material(
                        color: Colors.blue.shade100, // button color
                        child: InkWell(
                          splashColor: Colors.blue, // inkwell color
                          child: const SizedBox(
                            width: 50,
                            height: 50,
                            child: Icon(Icons.add),
                          ),
                          onTap: () {
                            mapController.animateCamera(
                              CameraUpdate.zoomIn(),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ClipOval(
                      child: Material(
                        color: Colors.blue.shade100, // button color
                        child: InkWell(
                          splashColor: Colors.blue, // inkwell color
                          child: const SizedBox(
                            width: 50,
                            height: 50,
                            child: Icon(Icons.remove),
                          ),
                          onTap: () {
                            mapController.animateCamera(
                              CameraUpdate.zoomOut(),
                            );
                          },
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 10.0, bottom: 10.0),
                  child: ClipOval(
                    child: Material(
                      color: Colors.orange.shade100, // button color
                      child: InkWell(
                        splashColor: Colors.orange, // inkwell color
                        child: const SizedBox(
                          width: 56,
                          height: 56,
                          child: Icon(Icons.my_location),
                        ),
                        onTap: () {
                          mapController.animateCamera(
                            CameraUpdate.newCameraPosition(
                              CameraPosition(
                                target: LatLng(
                                  _currentPosition.latitude,
                                  _currentPosition.longitude,
                                ),
                                zoom: 18.0,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
