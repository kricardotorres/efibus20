import 'dart:convert';

import 'package:solo_bus/api/api.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:location/location.dart';
import 'package:solo_bus/data/composed_route.dart';
import 'package:solo_bus/data/route.dart';
BusRoute ? currentBusRoute_show;

Map<String, double> ? user_Location;

class ShowMapAB extends StatefulWidget {
  final String title;
  final ComposedRoute composed_bus_route;
  final   Map<String, double> passed_Location;
  final   Map<String, double> passed_Location_destiny;
  ShowMapAB( {required  this.title,required this.composed_bus_route,required this.passed_Location,required this.passed_Location_destiny })  ;

  @override
  State<StatefulWidget> createState() {
    user_Location = passed_Location;
    return _ShowMapABPageState();
  }
}

class _ShowMapABPageState extends State<ShowMapAB>   with TickerProviderStateMixin{
  //
  Location location = Location();

  var currentLocation;

  final formKey = new GlobalKey<FormState>();
  late Marker  marker ;
  late Marker  des_marker ;
  late Polyline first;
  late Polyline second  ;
  var json_o;
  Future<List<BusRoute?>>  ?  bus_routes;


  List<BusRoute?> _bus_routes = [];
  late MapController mapController;

  Future<List<BusRoute?>>  get_routes(id) async  {
    Api.get_one_route(id).then((response) {
      setState(() {
      json_o = json.decode(response.body);
      print(json_o );
      _bus_routes!.add(BusRoute.fromJson(json_o));
      if(_bus_routes!.length==1){

        first=Polyline(
            points: _bus_routes[0]!.points,
            strokeWidth: 2.0,
            color: Colors.orangeAccent);
      }else{
        second=Polyline(
            points: _bus_routes[1]!.points,
            strokeWidth: 2.0,
            color: Colors.black);
      }
      print(_bus_routes);
      });
    });

    return _bus_routes;

  }

  @override
  void initState() {
    super.initState();
    var points = <LatLng>[
      LatLng(51.5, -0.09),
      LatLng(53.3498, -6.2603),
    ];

    first=Polyline(
        points: points,
        strokeWidth: 2.0,
        color: Colors.orangeAccent);
   second=
       Polyline(
           points: points,
           strokeWidth: 2.0,
           color: Colors.black);

    mapController = MapController();
     get_routes(widget.composed_bus_route.id);

    get_routes(widget.composed_bus_route.id_b);


    marker = Marker(
      width: 90.0,
      height: 90.0,
      point: LatLng(user_Location!["latitude"]!, user_Location!["longitude"]!),
      builder: (ctx) =>
          Container(
            child: Icon(Icons.person_pin_circle,
              color: Colors.black,),
          ),
    );

    des_marker = Marker(
      width: 90.0,
      height: 90.0,
      point: LatLng(widget.passed_Location_destiny!["latitude"]!, widget.passed_Location_destiny!["longitude"]!),
      builder: (ctx) =>
          Container(
            child: Icon(Icons.flag,
              color: Colors.red,),
          ),
    );
    //_timer = Timer.periodic(Duration(seconds: 1), (_) {

    // });
  }
  void _animatedMapMove(LatLng destLocation, double destZoom)  {
    // Create some tweens. These serve to split up the transition from one location to another.
    // In our case, we want to split the transition be<tween> our current map center and the destination.
    final _latTween = Tween<double>(
        begin: mapController.center.latitude, end: destLocation.latitude);
    final _lngTween = Tween<double>(
        begin: mapController.center.longitude, end: destLocation.longitude);
    final _zoomTween = Tween<double>(begin: mapController.zoom, end: destZoom);

    // Create a animation controller that has a duration and a TickerProvider.
    var controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    // The animation determines what path the animation will take. You can try different Curves values, although I found
    // fastOutSlowIn to be my favorite.
    Animation<double> animation =
    CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);

    controller.addListener(() {
      mapController.move(
          LatLng(_latTween.evaluate(animation), _lngTween.evaluate(animation)),
          _zoomTween.evaluate(animation));
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
      } else if (status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });

    controller.forward();
  }

  @override
  void dispose() {
    super.dispose();
    //_timer.cancel();
  }


  @override
  Widget build(BuildContext context) {


    return new Scaffold(

      floatingActionButton: FloatingActionButton(
        onPressed: () {

          location.onLocationChanged.listen((value) {
            setState(() {

              currentLocation = value as Map<String, double>?;

            });


            Marker _marker = Marker(
              width: 90.0,
              height: 90.0,
              point: LatLng(
                  currentLocation.latitude, currentLocation.longitude),
              builder: (ctx) =>
                  Container(
                    child: Icon(Icons.person_pin_circle,),
                  ),
            );

            setState(() {

              marker = _marker;
            });


            _animatedMapMove( LatLng(
                currentLocation.latitude, currentLocation.longitude), 15.0);
          });

        },
        child: Icon(Icons.location_on,),
      ),
      appBar: new AppBar(
        title: new Text('Hola'),
      ),
      body: new Container(

        child: new FlutterMap(
          mapController: mapController,
          options: new MapOptions(
            center:  LatLng(20.966791, -89.623675),
            zoom: 13.0,
          ),
          layers: [
            new TileLayerOptions(
              urlTemplate: "https://api.mapbox.com/styles/v1/kricardotorres/ck2u1c1ip5w7g1cnw3nvvgkgl/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1Ijoia3JpY2FyZG90b3JyZXMiLCJhIjoiY2syYnp4cGxnMDF1YjNtcWNmcnZ4eTZtZCJ9.L8IZ8wU9-he3bXIJmAbYTQ",
              additionalOptions: {
                'accessToken': 'pk.eyJ1Ijoia3JpY2FyZG90b3JyZXMiLCJhIjoiY2syYnp4cGxnMDF1YjNtcWNmcnZ4eTZtZCJ9.L8IZ8wU9-he3bXIJmAbYTQ',
                'id': 'mapbox.streets',
              },
            ),
            PolylineLayerOptions(
              polylines: [
               first, second,
              ],
            ),
            MarkerLayerOptions(

                markers:
                <Marker>[marker,des_marker , ])
          ],
        ),
      ),
    );
  }
}