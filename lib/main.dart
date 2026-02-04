import 'dart:math';

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
  GoogleMapController? _googleMapController;
  final Set<Marker> _markers = {
    Marker(
      markerId: MarkerId("rajshahi"),
      position: LatLng(24.3746, 88.6004),
      infoWindow: InfoWindow(title: "home town"),
    ),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
        actions: [
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
          PopupMenuButton<String>(
            icon: Icon(Icons.ac_unit_rounded),
            onSelected: (v) {
              name = v;
              setState(() {});
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'Microsoft', child: Text("Microsoft")),
              PopupMenuItem(value: 'Facebook', child: Text("Facebook")),
              PopupMenuItem(value: 'Youtube', child: Text("Youtube")),
            ],
          ),
        ],
      ),
      body: GoogleMap(
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
        onTap: (LatLng position) async {
          try {
            List<Placemark> coordinates = await placemarkFromCoordinates(
              position.latitude,
              position.longitude,
            );
            Placemark place = coordinates.reversed.last;

            String address =
                "${place.subLocality}, ${place.locality}, ${place.country},";
            List<Location> locations = await locationFromAddress(address);
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
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
          _googleMapController?.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(target: LatLng(24.7413, 88.2912),zoom:16),
            ),
          );
        },
      ),
    );
  }

  Future<Position> getCurrentLocation() async {
    var location = await Geolocator.requestPermission();
    return await Geolocator.getCurrentPosition();
  }
}
