import 'package:latlong2/latlong.dart';
import 'package:solo_bus/data/place.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'dart:async';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'dart:convert';
import 'package:solo_bus/api/api.dart';
import 'package:solo_bus/data/route.dart';
import 'package:flutter_map/flutter_map.dart';

import 'package:location/location.dart';

import 'package:positioned_tap_detector_2/positioned_tap_detector_2.dart';
import 'package:solo_bus/data/u_address.dart';
import 'package:solo_bus/pages/index.dart';
import 'package:solo_bus/pages/nearest_location.dart';
import 'package:solo_bus/pages/routes_fromab.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  build(context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Solo en Bus',
        theme: ThemeData(
            primarySwatch: Colors.orange,
            secondaryHeaderColor: Colors.orangeAccent
        ),
        home: new MyPage(title:"hola")
      //new GeoIndex(title: 'Flutter Demo Home Page'),
      // new AnimatedMapControllerPage( ),
      //new MapIndex(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyPage extends StatefulWidget {
  final String title;

  MyPage({required this.title})  ;

  @override
  createState() => _MyPage();
}
class _MyPage extends State<MyPage>{

  var currentLocation;



  @override
  void initState() {
    super.initState();

    location.onLocationChanged.listen((value) {
      setState(() {
        currentLocation = value;
      });
    });

  }
  Location location = Location();

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('hola'),
      ),
      body: _children[_currentIndex], // new
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped, // new
        currentIndex: _currentIndex, // new
        items: [
          new BottomNavigationBarItem(
            icon: Icon(Icons.departure_board),
            title: Text('Buscar'),
          ),
          new BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            title: Text('Por ubicación'),
          ),
          new BottomNavigationBarItem(
              icon: Icon(Icons.repeat),
              title: Text('De A a B')
          )
        ],
      ),
    );
  }

  int _currentIndex = 0;
  final List<Widget> _children = [
    MapIndex(title: 'Rutas'),
    MapNearest(title: 'Ruta cercana', passed_Location : ({  "latitude": 20.966791,   'longitude': -89.623675})) ,
    MapRouteAB(title: 'De A a B', passed_Location : ({  "latitude": 20.966791,   'longitude': -89.623675})) ,
  ];
}

class PlaceholderWidget extends StatelessWidget {
  final Color color;

  PlaceholderWidget(this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
    );
  }
}