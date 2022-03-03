
import 'product.dart';

class Restaurant {
int id_negocio;
String Nombres, Direccion, Telefono,
UrlImagen ;


var productos   ;

Restaurant({
  required this.id_negocio,
required this.Nombres,
required  this.Direccion,
required  this.Telefono,
required  this.UrlImagen,
    required  this.productos,
});

Map<String, dynamic> toMap() {
var map = <String, dynamic>{
"id_negocio": id_negocio,
"Nombres": Nombres,
"Direccion": Direccion,
"Telefono": Telefono,
"UrlImagen": UrlImagen,
    "productos": productos,
};
return map;
}
factory  Restaurant.fromJson(Map<String, dynamic> parsedJson) {
Map json = parsedJson ;


return Restaurant(

    id_negocio : json['id_negocio'],
    Nombres : json['Nombres'],
    Direccion : json['Direccion'],
    Telefono : json['Telefono'].toString(),
    UrlImagen : json['UrlImagen'],
    productos:   json['ListaProductos']
);
}

factory  Restaurant.fromJson2(Map<String, dynamic> parsedJson) {
  Map json = parsedJson ;


  return Restaurant(

      id_negocio : json['id_negocio'],
      Nombres : json['NombreNegocio'],
      Direccion : "",
      Telefono : "",
      UrlImagen : json['UrlImagen'],
      productos:   json['ListaProductos']
  );
}




}
