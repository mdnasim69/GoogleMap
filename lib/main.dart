import 'dart:collection';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  MapType _mapType = MapType.normal;
  String name = "GoogleMap";

  //Map controller
  GoogleMapController? _googleMapController;

  // Marker set
  final Set<Marker> _markers = {
    Marker(
      markerId: MarkerId("rajshahi"),
      position: LatLng(24.3746, 88.6004),
      infoWindow: InfoWindow(title: "home town"),
    ),
  };

  final TextEditingController _searchController = TextEditingController();

  //searched places list
  List<dynamic> _suggestions = [];

  // Search places Api get request and Get places List
  String apiKey = "AIzaSyBpD1p4hQ3su-aayuiQ226ZDXQRqK1cIok";

  Future<List<dynamic>> placeAutocomplete(String query) async {
    final url =
        "https://maps.googleapis.com/maps/api/place/autocomplete/json"
        "?input=$query"
        "&key=$apiKey"
        "&components=country:bd";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['predictions'];
    } else {
      return [];
    }
  }

  //Add polygon
  Set<Polygon> polygon = HashSet<Polygon>();
  List<LatLng> points = [
    LatLng(24.372011, 88.600794),
    LatLng(24.373173, 88.600964),
    LatLng(24.372958, 88.602259),
    LatLng(24.372011, 88.600794),
  ];

  //polyline
  Set<Polyline> polyline = {};
  List<LatLng> PLpoints = [
    LatLng(24.374177, 88.603429),
    LatLng(24.375020, 88.602736),
    LatLng(24.374107, 88.600623),
  ];

  @override
  void initState() {
    //
    polygon.add(
      Polygon(
        polygonId: PolygonId('1'),
        geodesic: true,
        strokeWidth: 1,
        strokeColor: Colors.transparent,
        points: points,
        fillColor: Colors.deepOrange.shade200,
      ),
    );
    //
    polyline.add(
      Polyline(
        polylineId: PolylineId("1"),
        color: Colors.yellow,
        width: 3,
        points: PLpoints,
      ),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        toolbarHeight: 30,
        title: Text(name),
        actions: [
          //Map Layer
          PopupMenuButton<MapType>(
            icon: const Icon(Icons.layers),
            onSelected: (MapType type) {
              setState(() {
                _mapType = type;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: MapType.normal, child: Text("Normal")),
              const PopupMenuItem(
                value: MapType.satellite,
                child: Text("Satellite"),
              ),
              const PopupMenuItem(value: MapType.hybrid, child: Text("Hybrid")),
              const PopupMenuItem(
                value: MapType.terrain,
                child: Text("Terrain"),
              ),
            ],
          ),
        ],
      ),
      //Show Map
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: "Search place",
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) async {
                if (value.isNotEmpty) {
                  _suggestions = await placeAutocomplete(value);
                  setState(() {});
                } else {
                  _suggestions.clear();
                  setState(() {});
                }
              },
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  mapType: _mapType,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(24.3746, 88.6004),
                    zoom: 16,
                  ),
                  onMapCreated: (GoogleMapController controller) {
                    _googleMapController = controller;
                  },
                  trafficEnabled: true,
                  markers: _markers,
                  polygons: polygon,
                  polylines: polyline,
                  onTap: (LatLng position) async {
                    try {
                      //lat long to places
                      List<Placemark> placemark =
                          await placemarkFromCoordinates(
                            position.latitude,
                            position.longitude,
                          );
                      Placemark place = placemark.reversed.last;

                      String address =
                          "${place.subLocality}, ${place.locality}, ${place.country},";
                      //place to lat long
                      List<Location> locations = await locationFromAddress(
                        address,
                      );
                      //add marker to markers set
                      _markers.add(
                        Marker(
                          position: position,
                          infoWindow: InfoWindow(
                            title:
                                "${locations.first.latitude} , ${locations.first.longitude} , $address",
                          ),
                          markerId: MarkerId(position.toString()),
                        ),
                      );
                      setState(() {});
                    } catch (e) {
                      print(e.toString());
                    }
                  },
                ),
                //Searched places List View
                if (_suggestions.isNotEmpty)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      color: Colors.black54,
                      height: 200,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _suggestions.length,
                        itemBuilder: (context, index) {
                          return Card(
                            color: Colors.black54,
                            child: ListTile(
                              title: Text(
                                _suggestions[index]['description'],
                                style: TextStyle(color: Colors.white),
                              ),
                              onTap: () {
                                // print(_suggestions[index]['place_id']);
                                _suggestions.clear();
                                setState(() {});
                                _googleMapController?.animateCamera(
                                  CameraUpdate.newCameraPosition(
                                    CameraPosition(
                                      zoom: 16,
                                      target: LatLng(24.7413, 88.2912),
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // // Navigate to current Location
          // await getCurrentLocation().then((v) {
          //   _markers.add(
          //     Marker(
          //       infoWindow: InfoWindow(title: "Current Location"),
          //       position: LatLng(v.latitude, v.longitude),
          //       markerId: MarkerId(v.toString()),
          //     ),
          //   );
          //   CameraPosition cameraPosition = CameraPosition(
          //     target: LatLng(v.latitude, v.longitude),
          //   );
          //   _googleMapController?.animateCamera(
          //     CameraUpdate.newCameraPosition(cameraPosition),
          //   );
          //   setState(() {
          //   });
          // });
          // // navigate to place using lat long
          _googleMapController?.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(target: LatLng(24.7413, 88.2912), zoom: 16),
            ),
          );
        },
        backgroundColor: Colors.yellow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Icon(Icons.location_on_outlined),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }

  //Location Permission and get current location lat long
  Future<Position> getCurrentLocation() async {
    var location = await Geolocator.requestPermission();
    return await Geolocator.getCurrentPosition();
  }
}
