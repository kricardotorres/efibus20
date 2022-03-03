import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';

import 'dart:convert';
import 'package:solo_bus/api/api.dart';
import 'package:solo_bus/data/route.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:location/location.dart';

import 'bus_list.dart';
import 'bus_list2.dart';
 
class MapIndex extends StatefulWidget {
  final String title;

  MapIndex({ required  this.title})  ;

  @override
  createState() => _MapIndexPageState();
}

class _MapIndexPageState extends State<MapIndex> {
  //
  Future<List<BusRoute?>>  ?  bus_routes;


  List<BusRoute?> _bus_routes = [];
  Location location = Location();
  var json_o;
  var currentLocation;
  ScrollController _scrollController = new ScrollController();
  int current_page=1;

  BusRoute ?  currentBusRoute_new;



  @override
  void initState() { 
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        current_page++;
        currentBusRoute_new!.name==null ? _getRoutes(current_page): _getRoutes_search(currentBusRoute_new!.name) ;

      }
    });
    location.onLocationChanged.listen((value) {
      setState(() {
        currentLocation = value;
      });
    }); 
    _getRoutes(1); 
    currentBusRoute_new = BusRoute(id: 0,name: "",points: [] );
    controller_name.text=currentBusRoute_new!.name;
  }
  Future<List<BusRoute?>> getBusRoutes(int pagination) async {

    Api.getRoutes(pagination).then((response) {
      setState(() {
         json_o = json.decode(response.body); 
        if (json_o['bus_routes'].length > 0) {
          for (int i = 0; i < json_o['bus_routes'].length; i++) {
            _bus_routes.add(BusRoute.fromJson(json_o['bus_routes'][i]));
          }
        } 
      });
    }); 
    return _bus_routes;
  }

  Future<List<BusRoute?>> getBusRoutes_search(String name,int pagination) async {
    Api.getRoutes_search(name,pagination).then((response) { 
      setState(() { 
        json_o = json.decode(response.body); 
        if (json_o['bus_routes'].length > 0) {
          for (int i = 0; i < json_o['bus_routes'].length; i++) {
            _bus_routes.add(BusRoute.fromJson(json_o['bus_routes'][i]));
          }
        } 
      });
    }); 
    return _bus_routes;
  }

  _getRoutes(int pagination) async {
    setState(() {
      bus_routes= getBusRoutes(pagination);

    });


  }

  _getRoutes_search(String name) {

    setState(() {
      bus_routes=null;
      bus_routes = getBusRoutes_search(name,current_page);

    });


  }

   
  final formKey = new GlobalKey<FormState>();
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  validate() {
    formKey.currentState!.save();
    {
      current_page=1;
      _bus_routes.clear();
      _getRoutes_search(currentBusRoute_new!.name);

    }
  }
  TextEditingController controller_name = TextEditingController();
  form  (){



    return  Container(
      color: Colors.black54,
      child: Row(
        children: <Widget>[
          Expanded(
            child:  Form(
              key: formKey,
              child: Padding(
                    padding: EdgeInsets.all(5.0),
                child: Column(
                  children: <Widget>[
                    TextFormField( 
                      decoration: InputDecoration( 
                          suffixIcon: IconButton(
                              icon: Icon(Icons.backspace,
                                color: Colors.orange,),
                              onPressed: () {
                                controller_name.text='';
                              }),
                          prefixIcon: Icon(Icons.directions_bus,
                            color: Colors.orange,)
                          ,
                          border: OutlineInputBorder(),
                          hintText: 'Buscar una ruta',
                        hintStyle: TextStyle(color: Colors.white,  decorationColor: Colors.white,),

                      ),
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w300, decorationColor: Colors.white, ),


                      controller: controller_name,
                      keyboardType: TextInputType.text,
                      validator: (val) => val!.length == 0 ? 'Enter Name' : null,
                      onSaved: (val) =>  currentBusRoute_new!.name = val!,
                    ), 
                    RaisedButton(

                      onPressed: validate,
                      color: Colors.green,

                      child:  Icon(Icons.search,
                        color: Colors.white, ),shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(20.0))
                  )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
      Marker marker = Marker(
      width: 90.0,
      height: 90.0,
      point: LatLng( 20.967248, -89.623716 ),
      builder: (ctx) =>
          Container(
            child: Icon(Icons.person_pin_circle,),
          ),
    );

    return new Scaffold(


      body: new Container(

        color: Colors.black45,
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          verticalDirection: VerticalDirection.down,
          children: <Widget>[

            form(),
            new  BusList2( marker,  bus_routes, _scrollController),

          ],
        ),
      ),
    );
  }
}