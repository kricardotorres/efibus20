import 'dart:convert';

import 'package:solo_bus/api/api.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:solo_bus/data/route.dart';
import 'package:solo_bus/pages/show.dart';
import 'package:flutter_map/flutter_map.dart';

class BusList extends StatefulWidget {
   var bus_routes;


   late final ScrollController scrollController ;
  final  Marker  marker ;
  final  Marker  marker_destiny ;
  BusList(this.marker,this.bus_routes, this.scrollController, this.marker_destiny);

  @override
  State<StatefulWidget> createState() {

    return _MyListState();
  }
}

class _MyListState extends State<BusList> {

  BusRoute ? current;
  get_routes(id)    {
    Api.get_one_route(id).then((response) {
      setState(() {
        var json_o = json.decode(response.body);
        current = BusRoute.fromJson(json_o);

      });
    });

  }



  SingleChildScrollView dataTable(List<BusRoute> bus_routes) {
    return SingleChildScrollView(
      child: DataTable(

        columns: [
          DataColumn(

            label: Text('Rutas', style: TextStyle(  fontWeight: FontWeight.w500, decorationColor: Colors.white, ),),

          ),

        ],
        rows: bus_routes
            .map(
              (bus_route) => DataRow(cells: [
            DataCell(

              Row(
                children: <Widget>[
                  Icon(Icons.departure_board,
                    color: Colors.orangeAccent, ),
                  Text(bus_route.name  )
                ],
              ) ,
              onTap: () {

                Navigator.of(context).push(MaterialPageRoute<Null>(
                    builder: (BuildContext context) {
                      return new ShowMap(title: bus_route.name,
                        currentBusRoute: bus_route,

                        passed_Location :  widget.marker_destiny==null ? {  "latitude": 0,
                          'longitude': 0}:{  "latitude": widget.marker_destiny.point.latitude,
                          'longitude': widget.marker_destiny.point.longitude},
                        origin_passed:  widget.marker==null ? {  "latitude": 0,
                          'longitude': 0}:{  "latitude": widget.marker.point.latitude,
                          'longitude': widget.marker.point.longitude},
                      );
                    }));


              },

            ),

          ]),

        )
            .toList(),
      ),


      controller: widget.scrollController,

    );
  }


  list() {
    return  FutureBuilder<List>(
      future: widget.bus_routes,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {

          return Text("...");
        }
        if (snapshot.hasData) {
          return dataTable(List<BusRoute>.from(snapshot.data!)   );
        }


        return Text("...");
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Expanded(

      child: list(),
    );
  }
}