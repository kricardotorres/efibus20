import 'dart:convert';

import 'package:solo_bus/api/api.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:location/location.dart';
import 'package:solo_bus/data/route.dart';
BusRoute ? currentBusRoute_show;

Map<String, double> ? user_Location;

class ShowMap extends StatefulWidget {
  String title;
  BusRoute currentBusRoute;
  Map<String, double> ?passed_Location;
  Map<String, double> ?origin_passed;

  ShowMap( {required this.title,required this.currentBusRoute, required this.passed_Location, required this.origin_passed});

  @override
  State<StatefulWidget> createState() {
    currentBusRoute_show = currentBusRoute;
    user_Location = passed_Location;
    return _ShowMapPageState();
  }
}

class _ShowMapPageState extends State<ShowMap>   with TickerProviderStateMixin{
  //
  Location location = Location();

  Map<String, double> ? currentLocation;

  final formKey = new GlobalKey<FormState>();
  late Marker  marker ;

  late Marker  origin_marker ;
  late Marker des_marker ;
  late Marker  bus_stop;
  late MapController  mapController;


  late Polyline  first;
  BusRoute ? current;
  get_routes(id)    {
    Api.get_one_route(id).then((response) {
      setState(() {
        var json_o = json.decode(response.body);
        current = BusRoute.fromJson(json_o);

        first=Polyline(
            points: current!.points,
            strokeWidth: 2.0,
            color: Colors.orangeAccent);
      });

      bus_stop = new Marker(
        width: 80.0,
        height: 80.0,
        point: LatLng(current!.points[0].latitude,current!.points[0].longitude),
        builder: (ctx) =>
        new Container(
          child: Icon(Icons.departure_board,
            color: Colors.blue.shade400,),
        ),
      );
    });

  } //


  @override
  void initState() {
    super.initState();
    var _points = <LatLng>[
      LatLng(51.5, -0.09),
      LatLng(53.3498, -6.2603),
    ];
    first=Polyline(
        points: _points,
        strokeWidth: 2.0,
        color: Colors.orangeAccent);
    mapController = MapController();

    bus_stop = new Marker(
      width: 80.0,
      height: 80.0,
      point: LatLng(0,0),
      builder: (ctx) =>
      new Container(
        child: Icon(Icons.departure_board,
          color: Colors.blue.shade400,),
      ),
    );

    origin_marker =   Marker(
      width: 80.0,
      height: 80.0,
      point: (widget.origin_passed!=null ?  (LatLng(widget.origin_passed!["latitude"]!, widget.origin_passed!["longitude"]!)):(LatLng(0,0))) ,
      builder: (ctx) =>
      new Container(
        child: Icon(Icons.location_on,
          color: Colors.black,),
      ),
    );
    marker = Marker(
      width: 90.0,
      height: 90.0,
      point: LatLng(0, 0),
      builder: (ctx) =>
          Container(
            child: Icon(Icons.person_pin_circle,
              color: Colors.blue.shade400,),
          ),
    );

    des_marker = Marker(
      width: 90.0,
      height: 90.0,
      point: LatLng(user_Location!["latitude"]!, user_Location!["longitude"]!),
      builder: (ctx) =>
          Container(
            child: Icon(Icons.flag,
              color: Colors.red,),
          ),
    );
    setState(() {

      get_routes(currentBusRoute_show!.id);


    });
    //_timer = Timer.periodic(Duration(seconds: 1), (_) {

    // });
  }
  void _animatedMapMove(LatLng destLocation, double destZoom)  {
    // Create some tweens. These serve to split up the transition from one location to another.
    // In our case, we want to split the transition be<tween> our current map center and the destination.
    final _latTween = Tween<double>(
        begin: mapController!.center.latitude, end: destLocation.latitude);
    final _lngTween = Tween<double>(
        begin: mapController!.center.longitude, end: destLocation.longitude);
    final _zoomTween = Tween<double>(begin: mapController!.zoom, end: destZoom);

    // Create a animation controller that has a duration and a TickerProvider.
    var controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    // The animation determines what path the animation will take. You can try different Curves values, although I found
    // fastOutSlowIn to be my favorite.
    Animation<double> animation =
    CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);

    controller.addListener(() {
      mapController!.move(
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

  var points;
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
                  currentLocation!["latitude"]!, currentLocation!["longitude"]!),
              builder: (ctx) =>
                  Container(
                    child: Icon(Icons.person_pin_circle,),
                  ),
            );

            setState(() {

              marker = _marker;
            });


            _animatedMapMove( LatLng(
                currentLocation!["latitude"]!, currentLocation!["longitude"]!), 15.0);
          });

        },
        child: Icon(Icons.location_on,),
      ),
      appBar: new AppBar(
        title: new Text(currentBusRoute_show!.name),
      ),
      body: new Container(

        child: new FlutterMap(
          mapController: mapController,
          options: new MapOptions(
            center: LatLng(20.966791, -89.623675),
            zoom: 13.0,
          ),
          layers: [
            new TileLayerOptions(

                urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: ['a', 'b', 'c']
            ),
            PolylineLayerOptions(
              polylines: [first

              ],
            ),
            MarkerLayerOptions(

                markers:
                <Marker>[marker,des_marker ,bus_stop,origin_marker])
          ],
        ),
      ),
    );
  }
}