import 'package:solo_bus/data/composed_route.dart';
import 'package:solo_bus/data/route.dart';
import 'package:solo_bus/pages/show_routes_ab.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_map/flutter_map.dart';

class ComposedBusList extends StatefulWidget {
  var composed_bus_routes;

  final ScrollController scrollController ;
  final  Marker  marker ;
  final  Marker  marker_destiny ;
  ComposedBusList(this.marker, this.marker_destiny, this.composed_bus_routes, this.scrollController);

  @override
  State<StatefulWidget> createState() {
    return _ComposedBusListState();
  }
}

class _ComposedBusListState extends State<ComposedBusList> {




  SingleChildScrollView dataTable(List<ComposedRoute> composed_bus_routes) {
    return SingleChildScrollView(
      child: DataTable(  
        
        columns: [
          DataColumn(
            
             label: Text('Rutas Combinadas', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, decorationColor: Colors.white, ),),
            
          ),

        ],
        rows: composed_bus_routes
            .map(
              (composed_bus_route) => DataRow(cells: [
            DataCell(

              SizedBox.expand(

                child: Row(
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Icon(Icons.airport_shuttle,
                          color: Colors.black, ),
                        Icon(Icons.compare_arrows,
                          color: Colors.orangeAccent, ),],
                    ),
                    Text((composed_bus_route.name+"\n y \n"+composed_bus_route.name_b),style: TextStyle( color: Colors.white) ),

                  ],
                ),



              ),


              onTap: () {
                Navigator.of(context).push(MaterialPageRoute<Null>(
                    builder: (BuildContext context) {
                      return   ShowMapAB(title: composed_bus_route.name,   composed_bus_route: composed_bus_route,  passed_Location: {  "latitude": widget.marker.point.latitude,
                        'longitude': widget.marker.point.longitude},  passed_Location_destiny:{  "latitude": widget.marker_destiny.point.latitude,
                        'longitude': widget.marker_destiny.point.longitude}, );
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
    return FutureBuilder<List>(
      future: widget.composed_bus_routes,
      builder: (context, snapshot) {


        if (snapshot.hasData) {
          return dataTable(List<ComposedRoute>.from(snapshot.data!)   );
        }
        if (null == snapshot.data || snapshot.data!.length == 0) {
          return FlatButton(

              onPressed: () => {



              },
              color: Colors.indigo,
              child: Row(
                children: <Widget>[
                  Icon(Icons.departure_board,
                    color: Colors.white, ),
                  Text('Buscando' ,style: TextStyle( color: Colors.white) )
                ],
              ),shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(5.0))
          );
        }

        return FlatButton(

            onPressed: () => {},
            color: Colors.indigo,
            child: Row(
              children: <Widget>[
                Icon(Icons.departure_board,
                  color: Colors.white, ),
                Text('' ,style: TextStyle( color: Colors.white) )
              ],
            ),shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(5.0))
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(

      child: FutureBuilder<List>(
        future: widget.composed_bus_routes,
        builder: (context, snapshot) {
          if ( snapshot.data == null ) {
            return Row(
            );
          }

          else if (snapshot.data.toString()=='[]') {
            print('kiaubooooooooooooooooooooooooo');
            print(snapshot.data);
            return FlatButton(

                onPressed: () => {},
                color: Colors.indigo,
                child: Row(
                  children: <Widget>[
                    Icon(Icons.departure_board,
                      color: Colors.white, ),
                    Text('Ninguna combinacion de rutas encontrada :(' ,style: TextStyle( color: Colors.white) )
                  ],
                ),shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(5.0))
            );
          }
          else if (snapshot.hasData) {

            return dataTable(List<ComposedRoute>.from(snapshot.data!));
          }



          return FlatButton(

              onPressed: () => {},
              color: Colors.indigo,
              child: Row(
                children: <Widget>[
                  Icon(Icons.departure_board,
                    color: Colors.white, ),
                  Text('Buscando' ,style: TextStyle( color: Colors.white) )
                ],
              ),shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(5.0))
          );
        },
      ),
    );
  }
}
