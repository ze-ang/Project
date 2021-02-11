import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:parentingland/mainscreen.dart';
import 'package:parentingland/registerscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:http/http.dart' as http;
import 'user.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emcontroller = TextEditingController();
  String _email = "";
  final TextEditingController _pscontroller = TextEditingController();
  String _password = "";
  bool _rememberMe = false;
  SharedPreferences prefs;
  double screenHeight, screenWidth;

  @override
  void initState() {
    loadpref();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        body: WillPopScope(
            onWillPop: () async {
              SystemNavigator.pop();
              print('Backpress');
              return Future.value(false);
            },
            child: Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage("assets/images/background.jpg"),
                        fit: BoxFit.cover)),
                child: Scaffold(
                    backgroundColor: Colors.transparent,
                    resizeToAvoidBottomPadding: false,
                    //appBar: AppBar(
                    //title: Text('Login'),
                    //centerTitle: true,
                    //),

                    body: new Container(
                      padding: EdgeInsets.only(left: 15, right: 15),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(height: screenHeight / 500),
                            Image.asset(
                              'assets/images/parentingland.png',
                              scale: 2.8,
                            ),
                            Card(
                              elevation: 10,
                              child: Padding(
                                  padding: EdgeInsets.fromLTRB(15, 10, 15, 15),
                                  child: Column(
                                    children: [
                                      TextField(
                                          controller: _emcontroller,
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          decoration: InputDecoration(
                                              labelText: 'Email',
                                              icon: Icon(Icons.email))),
                                      TextField(
                                        controller: _pscontroller,
                                        decoration: InputDecoration(
                                            labelText: 'Password',
                                            icon: Icon(Icons.lock)),
                                        obscureText: true,
                                      ),
                                      SizedBox(
                                        height: 12,
                                      ),
                                      MaterialButton(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20.0)),
                                        minWidth: 300,
                                        height: 50,
                                        child: Text('Login',
                                            style: TextStyle(fontSize: 16)),
                                        color: Colors.pinkAccent,
                                        textColor: Colors.white,
                                        elevation: 15,
                                        onPressed: _onLogin,
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        children: <Widget>[
                                          Checkbox(
                                            value: _rememberMe,
                                            onChanged: (bool value) {
                                              _onChange(value);
                                            },
                                          ),
                                          Text('Remember Me',
                                              style: TextStyle(fontSize: 16))
                                        ],
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      GestureDetector(
                                          onTap: _onRegister,
                                          child: Text('Register New Account',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.pink))),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      GestureDetector(
                                          onTap: _onForgot,
                                          child: Text('Forgot Account',
                                              style: TextStyle(fontSize: 15))),
                                    ],
                                  )),
                            )
                          ],
                        ),
                      ),
                    )))));
  }

  Future<void> _onLogin() async {
    _email = _emcontroller.text;
    _password = _pscontroller.text;
    ProgressDialog pr = new ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false);
    pr.style(message: "Login...");
    await pr.show();
    http.post(
        "http://struggling-capacity.000webhostapp.com/parentingland/php/login_user.php",
        body: {
          "email": _email,
          "password": _password,
        }).then((res) {
      print(res.body);
      List userdata = res.body.split(",");
      if (userdata[0] == "failed") {
        Toast.show(
          "Login failed",
          context,
          duration: Toast.LENGTH_LONG,
          gravity: Toast.TOP,
        );
      } else {
        Toast.show(
          "Login Success",
          context,
          duration: Toast.LENGTH_LONG,
          gravity: Toast.TOP,
        );
        User user = new User(
            email: _email,
            name: userdata[1],
            password: _password,
            phone: userdata[2],
            datereg: userdata[3]);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => MainScreen(user: user)));
      }
    }).catchError((err) {
      print(err);
    });
    await pr.hide();
  }

  void _onRegister() {
    Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext context) => RegisterScreen()));
  }

  void _onForgot() {
    print('Forgot');
  }

  void _onChange(bool value) {
    setState(() {
      _rememberMe = value;
      savepref(value);
    });
  }

  void loadpref() async {
    prefs = await SharedPreferences.getInstance();
    _email = (prefs.getString('email')) ?? '';
    _password = (prefs.getString('password')) ?? '';
    _rememberMe = (prefs.getBool('rememberme')) ?? false;
    if (_email.isNotEmpty) {
      setState(() {
        _emcontroller.text = _email;
        _pscontroller.text = _password;
        _rememberMe = _rememberMe;
      });
    }
  }

  void savepref(bool value) async {
    prefs = await SharedPreferences.getInstance();
    _email = _emcontroller.text;
    _password = _pscontroller.text;

    if (value) {
      if (_email.length < 5 && _password.length < 3) {
        print("EMAIL/PASSWORD EMPTY");
        _rememberMe = false;
        Toast.show(
          "Email/Password Empty",
          context,
          duration: Toast.LENGTH_LONG,
          gravity: Toast.BOTTOM,
        );
        return;
      } else {
        await prefs.setString('email', _email);
        await prefs.setString('password', _password);
        await prefs.setBool('rememberme', value);
        Toast.show(
          "Preferences saved",
          context,
          duration: Toast.LENGTH_LONG,
          gravity: Toast.BOTTOM,
        );
        print("SUCCESS");
      }
    } else {
      await prefs.setString('email', '');
      await prefs.setString('password', '');
      await prefs.setBool('rememberme', false);
      setState(() {
        _emcontroller.text = "";
        _pscontroller.text = "";
        _rememberMe = false;
      });
      Toast.show(
        "Preferences removed",
        context,
        duration: Toast.LENGTH_LONG,
        gravity: Toast.BOTTOM,
      );
    }
  }
}
