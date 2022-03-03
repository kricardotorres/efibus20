import 'package:latlong2/latlong.dart';
class Place  {
  String place_name;
  String address;
  LatLng ubication;

  Place(
  { required this.place_name,
    required this.ubication,
    required this.address}
      );


  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'place_name': place_name,
      'ubication': ubication,
      'address': address
    };
    return map;
  }



  factory  Place.fromJson(Map<String, dynamic> parsedJson) {
    Map json = parsedJson ;
    var place_name = json['name'] ;
    var address = json['formatted_address'];
    var ubication =  LatLng(json['geometry']['location']['lat'].toDouble(), json['geometry']['location']['lng'].toDouble() );
    print('asi viene la direccion de google:');
    print(json);
    return Place(

        place_name : place_name,
        address : address,
        ubication:   ubication
    );
  }



}