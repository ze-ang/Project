import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'product.dart';
import 'brand.dart';
import 'package:http/http.dart' as http;
import 'productscreen.dart';
import 'shoppingcartscreen.dart';
import 'user.dart';

class RestScreenDetails extends StatefulWidget {
  final Restaurant rest;
  final User user;

  const RestScreenDetails({Key key, this.rest, this.user}) : super(key: key);

  @override
  _RestScreenDetailsState createState() => _RestScreenDetailsState();
}

class _RestScreenDetailsState extends State<RestScreenDetails> {
  double screenHeight, screenWidth;
  List foodList;
  String titlecenter = "Loading Products...";
  String type = "Moms";
  GlobalKey<RefreshIndicatorState> refreshKey;

  @override
  void initState() {
    super.initState();
    _loadFoods(type);
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.rest.restname),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.shopping_cart,
              color: Colors.white,
            ),
            onPressed: () {
              _shoppinCartScreen();
            },
          )
        ],
      ),
      body: Column(children: [
        Container(
            height: screenHeight / 4.8,
            width: screenWidth / 0.3,
            child: CachedNetworkImage(
              imageUrl:
                  "http://struggling-capacity.000webhostapp.com/parentingland/images/brandimages/${widget.rest.restimage}.jpg",
              fit: BoxFit.cover,
              placeholder: (context, url) => new CircularProgressIndicator(),
              errorWidget: (context, url, error) => new Icon(
                Icons.broken_image,
                size: screenWidth / 2,
              ),
            )),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.pregnant_woman),
                  iconSize: 32,
                  onPressed: () {
                    setState(() {
                      type = "Moms";
                      _loadFoods(type);
                    });
                  },
                ),
                Text(
                  "Moms",
                  style: TextStyle(fontSize: 10),
                )
              ],
            ),
            Flexible(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.child_care),
                        iconSize: 32,
                        onPressed: () {
                          setState(() {
                            type = "Kids";
                            _loadFoods(type);
                          });
                        },
                      ),
                      Text(
                        "Kids",
                        style: TextStyle(fontSize: 10),
                      )
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
        Text("List for $type "),
        Divider(
          color: Colors.grey,
        ),
        foodList == null
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
                    color: Colors.red,
                    onRefresh: () async {
                      _loadFoods(type);
                    },
                    child: GridView.count(
                      crossAxisCount: 2,
                      childAspectRatio: (screenWidth / screenHeight) / 0.8,
                      children: List.generate(foodList.length, (index) {
                        return Padding(
                            padding: EdgeInsets.all(2),
                            child: Card(
                                child: InkWell(
                              onTap: () => _loadFoodDetails(index),
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    Container(
                                        height: screenHeight / 3.9,
                                        width: screenWidth / 1.2,
                                        child: CachedNetworkImage(
                                          imageUrl:
                                              "http://struggling-capacity.000webhostapp.com/parentingland/images/productimages/${foodList[index]['imgname']}.jpg",
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) =>
                                              new CircularProgressIndicator(),
                                          errorWidget: (context, url, error) =>
                                              new Icon(
                                            Icons.broken_image,
                                            size: screenWidth / 2,
                                          ),
                                        )),
                                    SizedBox(height: 5),
                                    Text(
                                      foodList[index]['foodname'],
                                      style: TextStyle(
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 5),
                                    Text("RM " +
                                        foodList[index]['foodprice'] +
                                        " | Qty: " +
                                        foodList[index]['foodqty']),
                                  ],
                                ),
                              ),
                            )));
                      }),
                    )),
              )
      ]),
    );
  }

  void _shoppinCartScreen() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) =>
                ShoppingCartScreen(user: widget.user)));
  }

  Future<void> _loadFoods(String ftype) async {
    ProgressDialog pr = new ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false);
    pr.style(message: "Loading...");
    await pr.show();
    http.post(
        "http://struggling-capacity.000webhostapp.com/parentingland/php/load_product.php",
        body: {
          "restid": widget.rest.restid,
          "type": ftype,
        }).then((res) {
      print(res.body);
      if (res.body == "nodata") {
        foodList = null;
        setState(() {
          titlecenter = "No $type Available";
        });
      } else {
        setState(() {
          var jsondata = json.decode(res.body);
          foodList = jsondata["foods"];
        });
      }
    }).catchError((err) {
      print(err);
    });
    await pr.hide();
  }

  _loadFoodDetails(int index) {
    Food curfood = new Food(
        foodid: foodList[index]['foodid'],
        foodname: foodList[index]['foodname'],
        foodprice: foodList[index]['foodprice'],
        foodqty: foodList[index]['foodqty'],
        foodimg: foodList[index]['imgname'],
        foodcurqty: "1",
        restid: widget.rest.restid);

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => ProductScreenDetails(
                  food: curfood,
                  user: widget.user,
                )));
  }
}
