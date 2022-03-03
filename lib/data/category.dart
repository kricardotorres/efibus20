class Category {
  int id;
  String name;
  String description;
  String UrlImagen;

  Category({
    required this.id,
    required this.name,
    required this.description,
    required this.UrlImagen,
  });

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id_categoria': id,
      'nombreCategoria': name,
      'descripcionCategoria': description,
      'UrlImagen': UrlImagen,
    };
    return map;
  }
  factory  Category.fromJson(Map<String, dynamic> parsedJson) {
    Map json = parsedJson ;


    return Category(

        id : json['id_categoria'],
        name  : json['nombreCategoria'],
      description  : json['descripcionCategoria'],
      UrlImagen  : json['UrlImagen']==null ? "": json['UrlImagen']  ,
    );
  }





}