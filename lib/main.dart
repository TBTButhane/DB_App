import 'package:flutter/material.dart';
import 'package:hello_world/services/db_helper.dart';

import 'models/dog.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eventor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Eventor'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<List<Dog>> dogs;
  TextEditingController nameController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  String name;
  String age;
  int curUserId;

  final formKey = new GlobalKey<FormState>();
  var dbHelper;
  bool isUpdating;

  @override
  void initState() {
    super.initState();
    dbHelper = DBHelper();
    isUpdating = false;
    refreshList();
  }

  clearName() {
    nameController.text = '';
    ageController.text = '';
  }

  validate() {
    if (formKey.currentState.validate()) {
      formKey.currentState.save();
      if (isUpdating) {
        Dog d = Dog(id: curUserId, name: name, age: age);
        dbHelper.update(d);
        setState(() {
          isUpdating = false;
        });
      } else {
        Dog d = Dog(id: null, name: name, age: age);
        dbHelper.save(d);
      }
      clearName();
      refreshList();
    }
  }

  form() {
    return Form(
        key: formKey,
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            verticalDirection: VerticalDirection.down,
            children: [
              TextFormField(
                controller: nameController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (val) =>
                    val.length == 0 ? 'Enter Name Please' : null,
                onSaved: (val) => name = val,
              ),
              TextFormField(
                controller: ageController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Age'),
                validator: (val) => val.length == 0 ? 'Enter Age Please' : null,
                onSaved: (val) {
                  age = val;
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FlatButton(
                    onPressed: validate,
                    child: Text(isUpdating ? 'UPDATE' : 'ADD'),
                  ),
                  FlatButton(
                    onPressed: () {
                      setState(() {
                        isUpdating = false;
                      });
                      clearName();
                    },
                    child: Text('CANCEL'),
                  )
                ],
              )
            ],
          ),
        ));
  }

  SingleChildScrollView dataTable(List<Dog> dogs) {
    return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: DataTable(
          columns: [
            DataColumn(
              label: Text("Name"),
            ),
            DataColumn(
              label: Text("Age"),
            ),
            DataColumn(
              label: Text("Remove"),
            ),
          ],
          rows: dogs
              .map((dog) => DataRow(cells: [
                    DataCell(Text(dog.name)),
                    DataCell(Text(dog.age)),
                    DataCell(IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        dbHelper.delete(dog.id);
                        refreshList();
                      },
                    ))
                  ]))
              .toList(),
        ));
  }

  list() {
    return Expanded(
        child: FutureBuilder(
            future: dogs,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return dataTable(snapshot.data);
              }

              if (null == snapshot.data || snapshot.data.length == 0) {
                return Text("No Data Found");
              }

              return CircularProgressIndicator();
            }));
  }

  refreshList() {
    setState(() {
      dogs = dbHelper.getDogs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert),
            color: Colors.white,
            onPressed: null,
          ),
        ],
      ),
      body: Container(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        verticalDirection: VerticalDirection.down,
        children: [
          form(),
          list(),
        ],
      )),
    );
  }
}
