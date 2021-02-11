import 'package:flutter/material.dart';
import 'package:parentingland/brand.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'branddetails.dart';
import 'user.dart';
import 'package:parentingland/chat.dart';
import 'shoppingcartscreen.dart';
import 'package:toast/toast.dart';

class MainScreen extends StatefulWidget {
  final User user;

  const MainScreen({Key key, this.user}) : super(key: key);
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  GlobalKey<RefreshIndicatorState> refreshKey;

  List restList;
  double screenHeight, screenWidth;
  String titlecenter = "Loading...";
  var catList = {"Essentials", "Milk"};
  var ratingList = {"Highest", "Lowest"};
  bool _visible = false;
  String selectedCat = "Essentials";
  String selectedRating = "Highest";

  @override
  void initState() {
    super.initState();
    _loadRestaurant(selectedCat, selectedRating);
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    TextEditingController _foodnamecontroller = TextEditingController();

    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        //title: Text('Available Restaurants'),
        actions: <Widget>[
          Container(
              width: screenWidth / 2.2,
              padding: EdgeInsets.fromLTRB(3, 10, 1, 10),
              child: TextField(
                autofocus: false,
                controller: _foodnamecontroller,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: new OutlineInputBorder(
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(5.0),
                    ),
                  ),
                  prefixIcon: Icon(Icons.baby_changing_station),
                ),
              )),
          SizedBox(width: 5),
          Flexible(
            child: IconButton(
              icon: Icon(Icons.search),
              iconSize: 24,
              onPressed: () {
                _loadSearchFood(
                    selectedCat, selectedRating, _foodnamecontroller.text);
              },
            ),
          ),
          Flexible(
            child: IconButton(
              icon: Icon(Icons.restore),
              iconSize: 24,
              onPressed: () {
                _loadRestaurant(selectedCat, selectedRating);
              },
            ),
          ),
          IconButton(
            icon: _visible
                ? new Icon(Icons.expand_more)
                : new Icon(Icons.expand_less),
            onPressed: () {
              setState(() {
                if (_visible) {
                  _visible = false;
                } else {
                  _visible = true;
                }
              });
            },
          ),
        ],
      ),
      floatingActionButton: Stack(
        children: <Widget>[
          Positioned(
            bottom: 80.0,
            right: 10.0,
            child: FloatingActionButton(
              heroTag: 'cart',
              onPressed: () {
                _shoppinCartScreen();
              },
              child: Icon(Icons.add_shopping_cart),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
          Positioned(
            bottom: 10.0,
            right: 10.0,
            child: FloatingActionButton(
              heroTag: 'chat',
              onPressed: () {
                _chatScreen();
              },
              child: Icon(Icons.chat),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
        ],
      ),
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: () {
      //    _shoppinCartScreen();
      //     //_bookScreen();
      //  },
      //  icon: Icon(Icons.add_shopping_cart),
      //  label: Text("10"),
      // ),
      body: Column(
        children: [
          //Divider(color: Colors.grey),
          Visibility(
              visible: _visible,
              child: Container(
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("Select Category"),
                          Container(
                              height: 30,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.pinkAccent),
                                borderRadius: BorderRadius.all(Radius.circular(
                                        5.0) //                 <--- border radius here
                                    ),
                              ),
                              child: DropdownButton(
                                //sorting dropdownoption
                                hint: Text(
                                  'Select Catgory',
                                  style: TextStyle(
                                      //color: Color.fromRGBO(101, 255, 218, 50),
                                      ),
                                ), // Not necessary for Option 1
                                value: selectedCat,
                                onChanged: (newValue) {
                                  setState(() {
                                    selectedCat = newValue;
                                    print(selectedCat);
                                    _loadRestaurant(
                                        selectedCat, selectedRating);
                                  });
                                },
                                items: catList.map((selectedCat) {
                                  return DropdownMenuItem(
                                    child: new Text(selectedCat.toString(),
                                        style: TextStyle(color: Colors.black)),
                                    value: selectedCat,
                                  );
                                }).toList(),
                              )),
                        ],
                      ),

                      SizedBox(width: 10),
                      //dropdown for sort by
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("Rating"),
                          Container(
                            height: 30,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.pinkAccent),
                              borderRadius: BorderRadius.all(Radius.circular(
                                      5.0) //                 <--- border radius here
                                  ),
                            ),
                            child: DropdownButton(
                              //sorting dropdownoption
                              hint: Text(
                                'Rating',
                                style: TextStyle(
                                    //color: Color.fromRGBO(101, 255, 218, 50),
                                    ),
                              ), // Not necessary for Option 1
                              value: selectedRating,
                              onChanged: (newValue) {
                                setState(() {
                                  selectedRating = newValue;
                                  print(selectedRating);
                                  _loadRestaurant(selectedCat, selectedRating);
                                });
                              },
                              items: ratingList.map((selectedRating) {
                                return DropdownMenuItem(
                                  child: new Text(selectedRating.toString(),
                                      style: TextStyle(color: Colors.black)),
                                  value: selectedRating,
                                );
                              }).toList(),
                            ),
                          )
                        ],
                      ),
                    ],
                  ))),
          Divider(color: Colors.grey),
          restList == null
              ? Flexible(
                  child: Container(
                      child: Center(
                          child: Text(
                  titlecenter,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ))))
              : Flexible(
                  child: RefreshIndicator(
                      key: refreshKey,
                      color: Colors.pinkAccent,
                      onRefresh: () async {
                        _loadRestaurant(selectedCat, selectedRating);
                      },
                      child: GridView.count(
                        crossAxisCount: 2,
                        childAspectRatio: (screenWidth / screenHeight) / 0.6,
                        children: List.generate(restList.length, (index) {
                          return Padding(
                              padding: EdgeInsets.all(1),
                              child: Card(
                                  child: InkWell(
                                onTap: () => _loadRestaurantDetail(index),
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      Stack(
                                        children: [
                                          Container(
                                              height: screenHeight / 4.5,
                                              width: screenWidth / 1.2,
                                              child: CachedNetworkImage(
                                                imageUrl:
                                                    "http://struggling-capacity.000webhostapp.com/parentingland/images/brandimages/${restList[index]['restimage']}.jpg",
                                                fit: BoxFit.cover,
                                                placeholder: (context, url) =>
                                                    new CircularProgressIndicator(),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        new Icon(
                                                  Icons.broken_image,
                                                  size: screenWidth / 2,
                                                ),
                                              )),
                                          Positioned(
                                            child: Container(
                                                //color: Colors.white,
                                                margin: EdgeInsets.all(5),
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    border: Border.all(
                                                      color: Colors.white,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                8))),
                                                child: Row(
                                                  children: [
                                                    Text(
                                                        restList[index]
                                                            ['restrating'],
                                                        style: TextStyle(
                                                            color:
                                                                Colors.black)),
                                                    Icon(Icons.star,
                                                        color: Colors.black),
                                                  ],
                                                )),
                                            bottom: 10,
                                            right: 10,
                                          )
                                        ],
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        restList[index]['restname'],
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              )));
                        }),
                      )))
        ],
      ),
    ));
  }

  Future<void> _loadRestaurant(String loc, String rat) async {
    ProgressDialog pr = new ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false);
    pr.style(message: "Loading...");
    await pr.show();
    http.post(
        "http://struggling-capacity.000webhostapp.com/parentingland/php/load_brand.php",
        body: {
          "location": loc,
          "rating": rat,
        }).then((res) {
      print(res.body);
      if (res.body == "nodata") {
        restList = null;
        setState(() {
          titlecenter = "No Product Found";
        });
      } else {
        setState(() {
          var jsondata = json.decode(res.body);
          restList = jsondata["rest"];
        });
      }
    }).catchError((err) {
      print(err);
    });
    await pr.hide();
  }

  _loadRestaurantDetail(int index) {
    print(restList[index]['restname']);
    Restaurant restaurant = new Restaurant(
        restid: restList[index]['restid'],
        restname: restList[index]['restname'],
        restlocation: restList[index]['restlocation'],
        restphone: restList[index]['restphone'],
        restimage: restList[index]['restimage'],
        restradius: restList[index]['restradius'],
        restlatitude: restList[index]['restlatitude'],
        restlongitude: restList[index]['restlongitude'],
        restdelivery: restList[index]['restdelivery']);

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => RestScreenDetails(
                  rest: restaurant,
                  user: widget.user,
                )));
  }

  void _shoppinCartScreen() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) =>
                ShoppingCartScreen(user: widget.user)));
  }

  void _chatScreen() {
    Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext context) => ChatWindow()));
  }

  _loadSearchFood(String loc, String rat, String fname) async {
    ProgressDialog pr = new ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false);
    pr.style(message: "Loading...");
    await pr.show();
    http.post(
        "http://struggling-capacity.000webhostapp.com/parentingland/php/load_brand.php",
        body: {"location": loc, "rating": rat, "foodname": fname}).then((res) {
      print(res.body);
      if (res.body == "nodata") {
        restList = null;
        setState(() {
          titlecenter = "No Product Found";
        });
        Toast.show(
          "Search found no result",
          context,
          duration: Toast.LENGTH_LONG,
          gravity: Toast.TOP,
        );
      } else {
        setState(() {
          var jsondata = json.decode(res.body);
          restList = jsondata["rest"];
          Toast.show(
            "Product search found in the following brand/s",
            context,
            duration: Toast.LENGTH_LONG,
            gravity: Toast.TOP,
          );
        });
      }
    }).catchError((err) {
      print(err);
    });
    await pr.hide();
  }
}
