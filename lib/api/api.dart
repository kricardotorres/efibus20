import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:solo_bus/data/u_address.dart';

const baseUrl = "https://conmanoizquierda.com";

class Api {


  static Future postAddres(UAddress ? uaddress ) {
    var url = baseUrl + "/Negocio/ObtenerCategorias" ;


    return http.post(Uri.parse(url), body: uaddress!.toMap());
  }


  static Future get_best_routes(String lat_a, String lng_a,String lat_b, String lng_b   ) {
    var url = baseUrl +
        "/bus_routes/get_neares_route_from_a_b.json?[q][lat_a]="+lat_a+
        "&[q][long_a]="+lng_a+
        "&[q][lat_b]="+lat_b+
        "&[q][long_b]="+lng_b ;

    return http.get(Uri.parse(url));
  }
  static Future get_one_route(int id) {
    var url = baseUrl + "/bus_routes/"+id.toString()+".json";
    print(url );
    return http.get(Uri.parse(url));
  }

  static Future getRoutes(int pagination) {
    var url = baseUrl + "/bus_routes.json?page="+pagination.toString();
    return http.get(Uri.parse(url));
  }

  static Future getnearest_routes(String lat, String lng ) {
    var url = baseUrl + "/bus_routes/get_neares_route.json?[q][lat]="+lat+"&[q][long]="+lng  ;

    return http.get(Uri.parse(url));
  }
  static Future getRoutes_search(String name,int pagination ) {
    var url = baseUrl + "/bus_routes.json?page="+pagination.toString()+"&q[name_cont]="+name;
    return http.get(Uri.parse(url));
  }

  static Future getGeoPlace_search(String name   ) {
    //   "https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input="+name+"&inputtype=textquery&fields=formatted_address,name,geometry&key=%20AIzaSyDLPnAwVK_9jOFO1ijDSgTV04ScZX8RNSo"
    var url = "https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input="+name+"&inputtype=textquery&fields=formatted_address,name,geometry&key=%20AIzaSyDLPnAwVK_9jOFO1ijDSgTV04ScZX8RNSo";

    return http.get(Uri.parse(url));
  }

  static Future getGeoPlace_from_latlng(String lat, String lng   ) {
    var url =  "https://maps.googleapis.com/maps/api/geocode/json?latlng="+lat+","+lng+"&key=%20AIzaSyDLPnAwVK_9jOFO1ijDSgTV04ScZX8RNSo";

    return http.get(Uri.parse(url));
  }
 
}