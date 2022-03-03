import 'package:latlong2/latlong.dart';
import 'package:solo_bus/data/composed_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'dart:async';
import 'dart:convert';
import 'package:solo_bus/api/api.dart';
import 'package:solo_bus/data/route.dart';
import 'package:flutter_map/flutter_map.dart'; 

import 'bus_list.dart';
import 'composed_bus_list.dart';


class FromABResult extends StatefulWidget {
  final String title ;

  final   Marker  marker ;
  final Marker  marker_destiny ;
  FromABResult( {required this.title, required this.marker, required this.marker_destiny})  ;

  @override
  State<StatefulWidget> createState() {
    return _FromABResultPageState();
  }
}
class _FromABResultPageState extends State<FromABResult>   with TickerProviderStateMixin {

  Future<List<BusRoute?>>  ?  bus_routes;


  List<BusRoute?> _bus_routes = [];


  Future<List<ComposedRoute?>>  ?  composed_routes;


  List<ComposedRoute?> _composed_routes = [];
  var json_o;
  var json_composed_routes;
  var currentLocation;

  TextEditingController controller_name = TextEditingController();
  TextEditingController controller_destiny = TextEditingController();

  @override
  void initState() {
    super.initState();

setState(() {
  getBusRoutesasync(widget.marker.point, widget.marker_destiny.point);

});


  }


 late MapController mapController;
  @override
  void dispose() {
    super.dispose();
  }


  Future  getBusRoutesasync(LatLng latLng, LatLng latLngb) async {
    print(latLng);
    print(latLngb);

    Api.get_best_routes(latLng.latitude.toString(),latLng.longitude.toString(),latLngb.latitude.toString(),latLngb.longitude.toString()).then((response) {
      setState(() {
        json_composed_routes = json.decode(response.body);
        print("rutas compuestasss??");
        print(json_composed_routes);
        _composed_routes.clear();
        composed_routes = getBusComposedRoutes();
        _bus_routes.clear();


        bus_routes = getBusRoutes( );


      });
    });

  }

  Future<List<ComposedRoute?>> getBusComposedRoutes( ) async {

    setState(() {
      if (json_composed_routes['bus_routes_b'].length > 0) {
        print("longitud de busroutes b"+json_composed_routes['bus_routes_b'].length.toString());
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

        print("longitud de busroutes b"+json_composed_routes['bus_routes_a'].length.toString());
        for (int i = 0; i < json_composed_routes['bus_routes_a'].length; i++) {
          _bus_routes.add(BusRoute.frofromMapNoPointsmJson(json_composed_routes['bus_routes_a'][i]));
        }
      }
    });


    return _bus_routes;
  }


  @override
  Widget build(BuildContext context) {
    return new Scaffold(

        appBar: new AppBar(
          title: new Text('Obteniendo resultados...'),
        ),
        body: Container(

        color: Colors.black54,
          child:
          new
          Column(

            children: <Widget>[
                  
                  
                  BusList(widget.marker,bus_routes, _scrollController, widget.marker_destiny),
              

              ComposedBusList( widget.marker,  widget.marker_destiny,  composed_routes, _scrollController)





            ],
          ),


        )


    );
  }

  ScrollController _scrollController = new ScrollController();
}