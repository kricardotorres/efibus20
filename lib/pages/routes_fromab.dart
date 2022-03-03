import 'package:latlong2/latlong.dart';
import 'package:solo_bus/data/composed_route.dart';
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
import 'fromab_results.dart';
import 'package:positioned_tap_detector_2/positioned_tap_detector_2.dart';

 
class MapRouteAB extends StatefulWidget {
  final String title;
  final   Map<String, double> passed_Location;
  MapRouteAB({ required this.title, required this.passed_Location})  ;

  @override
  State<StatefulWidget> createState() { 
    return _MapRouteABPageState();
  }
}
class _MapRouteABPageState extends State<MapRouteAB>   with TickerProviderStateMixin {

  late Future<List<Place?>> places ;
  List<Place?> _places = [];
  Future<List<BusRoute?>>  ?  bus_routes;


  List<BusRoute?> _bus_routes = [];
  Future<List<ComposedRoute?>>  ?  composed_routes;


  List<ComposedRoute?> _composed_routes = [];
  Location location = Location();
  var json_o;
  var json_composed_routes;
  var currentLocation;
  late Marker  marker ;
  late Marker  marker_destiny ;

  TextEditingController controller_name = TextEditingController();
  TextEditingController controller_destiny = TextEditingController();
  Future<List<Place?>> getPlaces(String name) async {

    Api.getGeoPlace_search(name).then((response) {
      setState(() {
        _places.clear();
        json_o = json.decode(response.body);
        if (json_o["candidates"].length > 0) {
          for (int i = 0; i < json_o['candidates'].length; i++) {
            _places.add(Place.fromJson(json_o['candidates'][i]));
          }
        }
      });
    });

    return _places;
  }

  @override
  void initState() {
    super.initState();

    mapController = MapController();

    location.onLocationChanged.listen((value) {
      setState(() {
        currentLocation = value;
      });
    });


    marker = Marker(
      width: 90.0,
      height: 90.0,
      point: LatLng(widget.passed_Location!["latitude"]!,widget.passed_Location!["longitude"]!),
      builder: (ctx) =>
          Container(
            child: Icon(Icons.person_pin_circle,),
          ),
    );
    marker_destiny = Marker(
      width: 90.0,
      height: 90.0,
      point: LatLng(0, 0),
      builder: (ctx) =>
          Container(
            child: Icon(Icons.person_pin_circle,),
          ),
    );
    getPlaces_from_latlng(LatLng(widget.passed_Location!["latitude"]!,widget.passed_Location!["longitude"]!));


  }
  Future<List<Place?>> getPlaces_from_latlng(LatLng latLng) async  {

    Api.getGeoPlace_from_latlng(latLng.latitude.toString(),latLng.longitude.toString()).then((response) {
      setState(() {

        json_o = json.decode(response.body);

        controller_name.text = (json_o['results'][0]['formatted_address']);
      });
    });

    return _places;
  }

  Future<List<Place?>> getPlaces_from_latlng_dest(LatLng latLng) async  {

    Api.getGeoPlace_from_latlng(latLng.latitude.toString(),latLng.longitude.toString()).then((response) {
      setState(() {

        json_o = json.decode(response.body);

        controller_destiny.text = (json_o['results'][0]['formatted_address']);
      });
    });

    return _places;
  }

  late MapController mapController;
  @override
  void dispose() {
    super.dispose();
  }


  Future  getBusRoutesasync(LatLng latLng, LatLng latLngb) async {

    Api.get_best_routes(latLng.latitude.toString(),latLng.longitude.toString(),latLngb.latitude.toString(),latLngb.longitude.toString()).then((response) {
      setState(() {
        json_composed_routes = json.decode(response.body);
        _composed_routes.clear();
        composed_routes = getBusComposedRoutes();
        _bus_routes.clear();


        bus_routes = getBusRoutes( );


      });
    });

  }

  void render_dialog(LatLng latLng, LatLng latLngb) async {

    await getBusRoutesasync(latLng, latLngb);

   // showAlertDialog(context);

  }

  Future<List<ComposedRoute?>> getBusComposedRoutes( ) async {

      setState(() {
        if (json_composed_routes['bus_routes_b'].length > 0) {
          for (int i = 0; i < json_composed_routes['bus_routes_b'].length; i++) {
            _composed_routes.add(ComposedRoute.fromJson(json_composed_routes['bus_routes_b'][i]));
          }
        }
      });


    return _composed_routes;
  }
  Future<List<BusRoute?>> getBusRoutes( ) async {

    setState(() {
      if (json_composed_routes['bus_routes_a'].length > 0) {
        for (int i = 0; i < json_composed_routes['bus_routes_a'].length; i++) {
          _bus_routes.add(BusRoute.frofromMapNoPointsmJson(json_composed_routes['bus_routes_a'][i]));
        }
      }
    });


    return _bus_routes;
  }
  void _handleTap(TapPosition tapPosition, LatLng latlng) {

    _set_marker_on_map(latlng,"a");

   getPlaces_from_latlng(latlng);




  }
  _set_place_on_map(Place place, String origin){
    _set_marker_on_map(place.ubication,origin);
  }
  _set_marker_on_map(LatLng latlng, String origin ){



    if(origin=='a'){
      Marker _marker = Marker(
        width: 90.0,
        height: 90.0,
        point: (latlng==null ? LatLng(20.966791, -89.623675):latlng),
        builder: (ctx) =>
            Container(
              child: Icon(Icons.person_pin_circle,),
            ),
      );
      setState(() {
        marker = _marker;
      });
    }
    if(origin=='b'){
      Marker _marker = Marker(
        width: 90.0,
        height: 90.0,
        point: (latlng==null ? LatLng(20.966791, -89.623675):latlng),
        builder: (ctx) =>
            Container(
              child: Icon(Icons.flag,),
            ),
      );
      setState(() {
        marker_destiny = _marker;
      });
    }
    _animatedMapMove(latlng, 16.0);

  }


  _MapRouteABPageState() {
    controller_name.addListener(() {
      if (controller_name.text.isEmpty) {

      } else {

        setState(() {

          _places.clear();

          places = getPlaces(controller_name.text);
        });
      }
    });

    controller_destiny.addListener(() {
      if (controller_destiny.text.isEmpty) {

      } else {

        setState(() {

          _places.clear();

          places = getPlaces(controller_destiny.text);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {

          if(currentLocation!=null){

            _set_marker_on_map(LatLng(
                currentLocation["latitude"], currentLocation["longitude"]),'a');

            getPlaces_from_latlng(LatLng(
                currentLocation["latitude"], currentLocation["longitude"]),);

          }
        },
        child: Icon(Icons.location_on,),
      ),
      backgroundColor: Colors.transparent,
      body: Container(

        color: Colors.black45,
        child: new Column(
          children: <Widget>[
            Container(

              color: Colors.black54,
              child: Column(
                children: <Widget>[

                  Padding(
                    padding: EdgeInsets.all(5.0),
                    child:
                    TypeAheadField(
                      textFieldConfiguration: TextFieldConfiguration(
                        controller:   controller_name,

                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w300, decorationColor: Colors.white, ),
                        decoration: InputDecoration(
                            suffixIcon: IconButton(
                                icon: Icon(Icons.backspace,
                                  color: Colors.orange,),
                                onPressed: () {
                                  controller_name.text='';
                                }) ,
                            prefixIcon:  Icon(Icons.person_pin_circle,
                              color: Colors.orange,),
                            border: OutlineInputBorder(),
                            labelText: 'Origen',
                            labelStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.w300, decorationColor: Colors.white, ),
                        ),
                      ),
                      suggestionsCallback: (pattern) async {


                        return Future.delayed(
                          const Duration(seconds: 2),
                              () => places,
                        );
                        // ;
                      },
                      itemBuilder: (context, suggestion) {
                        return ListTile(
                          leading: Icon(Icons.location_on),
                          title: Text((suggestion as Place).place_name),
                          subtitle: Text(suggestion.address),
                        );
                      },
                      onSuggestionSelected: (suggestion) {
                        controller_name.text= (suggestion as Place).place_name;
                        _set_place_on_map((suggestion as Place) , 'a');

                      },
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.all(5.0),
                    child:
                    TypeAheadField(
                      textFieldConfiguration: TextFieldConfiguration(
                        controller:   controller_destiny,

                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w300, decorationColor: Colors.white, ),
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                              icon: Icon(Icons.backspace,
                                color: Colors.orange,),
                              onPressed: () {
                                controller_destiny.text='';
                              }) ,
                          prefixIcon:  Icon(Icons.flag,
                            color: Colors.orange,),
                          border: OutlineInputBorder(),
                          labelText: 'Destino',
                          labelStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.w300, decorationColor: Colors.white, ),
                        ),
                      ),
                      suggestionsCallback: (pattern) async {


                        return Future.delayed(
                          Duration(seconds: 1),
                              () => places,
                        );
                        // ;
                      },
                      itemBuilder: (context, suggestion) {
                        return ListTile(
                          leading: Icon(Icons.location_on),
                          title: Text((suggestion as Place).place_name),
                          subtitle: Text((suggestion as Place).address),
                        );
                      },
                      onSuggestionSelected: (suggestion) {
                        controller_destiny.text= (suggestion as Place).place_name;
                        _set_place_on_map(suggestion, 'b');

                      },
                    ),
                  ),
                  RaisedButton(

                      onPressed: validate,
                      color: Colors.green,

                      child:  Icon(Icons.search,
                        color: Colors.white, ),shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(20.0))
                  )
                ],
              )

            ),


            Flexible(

              child:   new FlutterMap(

                mapController: mapController,
                options: MapOptions(
                  center: LatLng(widget.passed_Location!["latitude"]!,widget.passed_Location!["longitude"]!),
                  zoom: 16.0,
                  onTap: (_handleTap)  ,
                ),

                layers: [
                  TileLayerOptions(
                    urlTemplate: "https://api.mapbox.com/styles/v1/kricardotorres/ck2u1c1ip5w7g1cnw3nvvgkgl/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1Ijoia3JpY2FyZG90b3JyZXMiLCJhIjoiY2syYnp4cGxnMDF1YjNtcWNmcnZ4eTZtZCJ9.L8IZ8wU9-he3bXIJmAbYTQ",
                    additionalOptions: {
                      'accessToken': 'pk.eyJ1Ijoia3JpY2FyZG90b3JyZXMiLCJhIjoiY2syYnp4cGxnMDF1YjNtcWNmcnZ4eTZtZCJ9.L8IZ8wU9-he3bXIJmAbYTQ',
                      'id': 'mapbox.streets',
                    },
                  ),

                  MarkerLayerOptions(

                      markers:
                      <Marker>[marker,marker_destiny ]),
                ],
              ),
            ),

          ],
        ),

      )
    );
  }
  validate(){

                        if((controller_name.text!=""&&controller_destiny.text!="")&&(marker.point!=null&&marker_destiny.point!=null)){
                          setState(() {
                            Navigator.of(context).push(MaterialPageRoute<Null>(
                                builder: (BuildContext context) {
                                  return new FromABResult(title: 'results',
                                      marker: marker,
                                      marker_destiny : marker_destiny );
                                }));
                          });
                        } 
  }
  void _animatedMapMove(LatLng destLocation, double destZoom)  {
    final _latTween = Tween<double>(
        begin: mapController.center.latitude, end: destLocation.latitude);
    final _lngTween = Tween<double>(
        begin: mapController.center.longitude, end: destLocation.longitude);
    final _zoomTween = Tween<double>(begin: mapController.zoom, end: destZoom);

    var controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);

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

}