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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
            //lat long to places
            List<Placemark> placemark = await placemarkFromCoordinates(
              position.latitude,
              position.longitude,
            );
            Placemark place = placemark.reversed.last;

            String address =
                "${place.subLocality}, ${place.locality}, ${place.country},";
            //place to lat long
            List<Location> locations = await locationFromAddress(address);
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
              CameraPosition(target: LatLng(24.7413, 88.2912),zoom:16),
            ),
          );
        },
      ),
    );
  }
//Location Permission and get current location lat long
  Future<Position> getCurrentLocation() async {
    var location = await Geolocator.requestPermission();
    return await Geolocator.getCurrentPosition();
  }
}
