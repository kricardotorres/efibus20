import 'package:latlong2/latlong.dart';
class BusRoute {
  int   id;
  String   name;
  var points = <LatLng>[];


  BusRoute( {required this.id,
    required this.name,
    required this.points} );


  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'name': name,
      'points': points,
    };
    return map;
  }



  factory  BusRoute.fromJson(Map<String, dynamic> parsedJson) {
    Map json = parsedJson ;

    var current_points = json['bus_route_points'];
    print("devolvio algo??");
    print(parsedJson);
    var temp_points = <LatLng>[];


    current_points.forEach((object)=> temp_points.add(LatLng(double.parse(object['lat']),double.parse(object['long']))))  ;

    return BusRoute(

        id : json['id'],
        name : json['name'],
        points:   temp_points
    );
  }


  factory  BusRoute.frofromMapNoPointsmJson(Map<String, dynamic> parsedJson) {
    Map json = parsedJson ;

    var temp_points = <LatLng>[];
    return BusRoute(

        id : json['id_a'],
        name : json['name_a'],
        points:   temp_points
    );
  }




}