class Dog {
  int id;
  String name;
  String age;

  Dog({this.id, this.name, this.age});

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'name': name,
      'age': age,
    };
    return map;
  }

  Dog.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    name = map['name'];
    age = map['age'];
  }
}
