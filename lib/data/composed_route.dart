
class ComposedRoute {
  int id;
  String name;

  int id_b;
  String name_b;

  ComposedRoute(
      { required this.id,
        required this.name,
        required this.id_b,
        required this.name_b,}
      );


  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id_a': id,
      'name_a': name,
      'id_b': id_b,
      'name_b': name_b,
    };
    return map;
  }


  factory  ComposedRoute.fromJson(Map<String, dynamic> parsedJson) {
    Map json = parsedJson ;
    var id = json['id_a'] ;
    var name = json['name_a'] ;
    var id_b = json['id_b'] ;
    var name_b = json['name_b'] ;

    return ComposedRoute(

      id : id,
      name : name,
      id_b : id_b,
      name_b : name_b,
    );
  }



}