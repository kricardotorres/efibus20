import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';
import 'package:solo_bus/api/api.dart';
import 'package:solo_bus/data/place.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'dart:async';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'dart:convert';
import 'package:flutter_map/flutter_map.dart';

import 'package:location/location.dart';

import 'package:positioned_tap_detector_2/positioned_tap_detector_2.dart';
import 'package:solo_bus/data/route.dart';
import 'package:solo_bus/data/u_address.dart';
import 'bus_list.dart';


class MapNearest extends StatefulWidget {
    String title;
      Map<String, double> passed_Location;
  MapNearest( {   required this.title,  required this.passed_Location })  ;

  @override
  State<StatefulWidget> createState() {
    return _MapNearestPageState();
  }


}
class _MapNearestPageState extends State<MapNearest>   with TickerProviderStateMixin {
  late Future<List<Place?>> places ;
  List<Place?> _places = [];
   Future<List<BusRoute?>>  ?  bus_routes;


  List<BusRoute?> _bus_routes = [];
  Future<List<UAddress?>>  ?  uaddress;


  List<UAddress?> _uaddress = [];


  Location location = Location();
  var json_o;
  var currentLocation;
  late Marker  marker ;

  ScrollController _scrollController = new ScrollController();
  Future<List<Place?>> getPlaces(String name) async {

    Api.getGeoPlace_search(name).then((response) {
      setState(() {
        _places!.clear();
        json_o = json.decode(response.body);
        if (json_o["candidates"].length > 0) {
          for (int i = 0; i < json_o['candidates'].length; i++) {
            _places!.add(Place.fromJson(json_o['candidates'][i]));
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
        currentLocation = value  ;
        _bus_routes = [];
        bus_routes =  getBusRoutes((widget.passed_Location==null ? LatLng(20.966791, -89.623675):LatLng(widget.passed_Location!["latitude"]!, widget.passed_Location!["longitude"]!)))    ;

      });
    });



    marker = Marker(
      width: 90.0,
      height: 90.0,
      point: LatLng(widget.passed_Location!["latitude"]!, widget.passed_Location!["longitude"]!),
      builder: (ctx) =>
          Container(
            child: const Icon(Icons.person_pin_circle,),
          ),
    );

    getPlaces_from_latlng(LatLng(widget.passed_Location!["latitude"]!, widget.passed_Location!["longitude"]!));


  }
  Future<List<Place?>> getPlaces_from_latlng(LatLng latLng) async  {

    Api.getGeoPlace_from_latlng(latLng.latitude.toString(),latLng.longitude.toString()).then((response) {
      setState(() {

        json_o = json.decode(response.body);
        print(json_o);
        controller_direccion.text = (json_o['results'][0]['formatted_address']);

        for (int i = 0; i < json_o['results'][0]['address_components'].length; i++) {

          if( json_o['results'][0]['address_components'][i]['types'].toString()== '[route]' )
            {controller_calle.text = (json_o['results'][0]['address_components'][i]['long_name']);break;}else{
            controller_calle.text="";
          }


        }
        for (int i = 0; i < json_o['results'][0]['address_components'].length; i++) {


          if( json_o['results'][0]['address_components'][i]['types'].toString()== '[political, sublocality, sublocality_level_1]' )
          {controller_colonia.text = (json_o['results'][0]['address_components'][i]['long_name']);
          break;
          }else{
            controller_colonia.text="";
          }

        }
        for (int i = 0; i < json_o['results'][0]['address_components'].length; i++) {


          if( json_o['results'][0]['address_components'][i]['types'].toString()== '[street_number]' )
          {controller_numInteriro.text = (json_o['results'][0]['address_components'][i]['long_name']);break;
          }else{
            controller_numInteriro.text="";
          }


        }

        controller_latitud.text = latLng.latitude.toString();
        controller_longitud.text = latLng.longitude.toString();
      });
    });

    return _places;
  }


  late MapController mapController;
  @override
  void dispose() {
    super.dispose();
  }



  Future<List<BusRoute?>> getBusRoutes(LatLng latLng) async {

    Api.getnearest_routes(latLng.latitude.toString(),latLng.longitude.toString()).then((response) {
      setState(() {
        json_o = json.decode(response.body);
        if (json_o.length > 0) {
          for (int i = 0; i < json_o.length; i++) {
            _bus_routes!.add(BusRoute.fromJson(json_o[i]));
          }
        }
      });
    });

    return _bus_routes;
  }


  Future<List<UAddress?>> postDireccion(UAddress ? uaddress) async {

    Api.postAddres(uaddress).then((response) {
      setState(() {
        json_o = json.decode(response.body);
        print('respuests del post');
        print(json_o);


         if (json_o.length > 0) {
          for (int i = 0; i < json_o.length; i++) {
            _bus_routes!.add(BusRoute.fromJson(json_o[i]));
       }
        }
      });
    });

    return _uaddress;
  }



  void _handleTap(TapPosition tapPosition, LatLng latlng) {

    _set_marker_on_map(latlng);

    getPlaces_from_latlng(latlng);

    setState(() {
      _bus_routes!.clear();
     bus_routes =  getBusRoutes(latlng)  ;

    });


  }
  _set_place_on_map(Place ? place){
    _set_marker_on_map(place!.ubication);
  }
  _set_marker_on_map(LatLng latlng){

    Marker _marker = Marker(
      width: 90.0,
      height: 90.0,
      point: (latlng),
      builder: (ctx) =>
          Container(
            child: const Icon(Icons.person_pin_circle,),
          ),
    );
    setState(() {
      marker = _marker;
    });

    _animatedMapMove(latlng, 16.0);

  }
  TextEditingController controller_direccion = TextEditingController();
  TextEditingController controller_calle = TextEditingController();
  TextEditingController controller_colonia = TextEditingController();
  TextEditingController controller_referencia = TextEditingController();
  TextEditingController controller_numExterior = TextEditingController();
  TextEditingController controller_numInteriro = TextEditingController();
  TextEditingController controller_latitud = TextEditingController();
  TextEditingController controller_longitud = TextEditingController();


  _MapNearestPageState() {
    controller_direccion.addListener(() {
      if (controller_direccion.text.isEmpty) {
        places = getPlaces("" );
      } else {

        setState(() {

          _places!.clear();

          places =  getPlaces(controller_direccion.text)  ;
        });
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    String defaultFontFamily = 'EBGaramond-Regular.ttf';
    double defaultFontSize = 14;
    double defaultIconSize = 17;
    return Scaffold(

      appBar: AppBar(
        backgroundColor: Color(0xFFFAFAFA),
        elevation: 0,
        title: Text(
          "De 'A' a 'B'",
          style: TextStyle(
              color: Color(0xFF3a3737),
              fontSize: 16,
              fontWeight: FontWeight.w500),
        ),
        brightness: Brightness.light,
        actions: <Widget>[

        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if(currentLocation!=null){

            _set_marker_on_map(LatLng(
                currentLocation.latitude, currentLocation.longitude));

            getPlaces_from_latlng(LatLng(
                currentLocation.latitude, currentLocation.longitude));
            setState(() {
               _bus_routes!.clear();
              bus_routes =  getBusRoutes(LatLng(
                  currentLocation.latitude, currentLocation.longitude))  ;
            });
          }
        },
        child: const Icon(Icons.location_on,),
      ),
      body: Container(

        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          verticalDirection: VerticalDirection.down,
          children: <Widget>[

            Flexible(

              child:   FlutterMap(

                mapController: mapController,
                options: MapOptions(
                  center: LatLng(widget.passed_Location!["latitude"]!, widget.passed_Location!["longitude"]!),

                  maxZoom: 17.0,
                  zoom: 16.0,
                  minZoom: 14.0,
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
                      <Marker>[marker ]),
                ],
              ),
            ),

            Container(

              child:       Padding(
                padding: EdgeInsets.all(5.0),
                child:
                TypeAheadField(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller:   controller_direccion,
                    decoration: InputDecoration(

                      suffixIcon: IconButton(
                          icon: const Icon(Icons.backspace,
                            color: Colors.orange,),
                          onPressed: () {
                            controller_direccion.text='';
                          }),
                      prefixIcon: const Icon(Icons.location_on,
                        color: Colors.orange,)
                      ,
                      border: const OutlineInputBorder(),
                      hintText: 'Buscar ubicación',
                      hintStyle:const TextStyle(    fontFamily: "EBGaramond"),

                    ),
                    style:const TextStyle(  fontWeight: FontWeight.w300,      fontFamily: "EBGaramond" ),

                  ),
                  suggestionsCallback: (pattern) async {


                    return Future.delayed(
                      const Duration(seconds: 2),
                          () => places,
                    );

                  },
                  itemBuilder: (context, suggestion) {
                    return ListTile(
                      leading: const Icon(Icons.location_on),
                      title: Text((suggestion as Place).place_name,style: const TextStyle(   fontFamily: "EBGaramond" ),),
                      subtitle: Text((suggestion as Place).address,style: const TextStyle(    fontFamily: "EBGaramond" ),),
                    );
                  },
                  onSuggestionSelected: (suggestion) {
                    controller_direccion.text= (suggestion as Place).address;
                    _set_place_on_map(suggestion);
                    setState(() {
                    _bus_routes!.clear();
                    bus_routes =  getBusRoutes((suggestion as Place).ubication) ;

                    });
                  },
                ),
              ),
            ),

            BusList( marker,  bus_routes, _scrollController, marker),

          ],
        ),
      ),
    );
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