import 'package:flutter/material.dart';
import 'package:parentingland/loginscreen.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:http/http.dart' as http;

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _namecontroller = TextEditingController();
  final TextEditingController _emcontroller = TextEditingController();
  final TextEditingController _pscontroller = TextEditingController();
  final TextEditingController _phcontroller = TextEditingController();

  String _email = "";
  String _password = "";
  String _name = "";
  String _phone = "";
  bool _passwordVisible = false;
  bool _rememberMe = false;
  bool _termsChecked = false;
  double screenHeight;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Registration'),
        ),
        body: Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/images/background.jpg"),
                    fit: BoxFit.cover)),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              resizeToAvoidBottomPadding: false,
              body: new Container(
                child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 5, 20, 10),
                    child: SingleChildScrollView(
                        child: Column(children: [
                      Image.asset(
                        'assets/images/parentingland.png',
                        scale: 2,
                      ),
                      Card(
                          elevation: 10,
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
                            child: Column(
                              children: [
                                TextField(
                                    controller: _namecontroller,
                                    keyboardType: TextInputType.name,
                                    decoration: InputDecoration(
                                        labelText: 'Name',
                                        icon: Icon(Icons.person))),
                                TextField(
                                    controller: _emcontroller,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: InputDecoration(
                                        labelText: 'Email',
                                        icon: Icon(Icons.email))),
                                TextField(
                                    controller: _phcontroller,
                                    keyboardType: TextInputType.phone,
                                    decoration: InputDecoration(
                                        labelText: 'Mobile',
                                        icon: Icon(Icons.phone))),
                                TextField(
                                  controller: _pscontroller,
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    icon: Icon(Icons.lock),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _passwordVisible
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        color:
                                            Theme.of(context).primaryColorDark,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _passwordVisible = !_passwordVisible;
                                        });
                                      },
                                    ),
                                  ),
                                  obscureText: !_passwordVisible,
                                ),
                                SizedBox(height: 5),
                                Row(children: <Widget>[
                                  Checkbox(
                                      value: _termsChecked,
                                      onChanged: (bool value) => setState(
                                          () => _termsChecked = value)),
                                  Flexible(
                                      child: GestureDetector(
                                          onTap: _showEULA,
                                          child: Text(
                                            'I Agree to Terms',
                                            style: TextStyle(
                                              color: Colors.grey[700],
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ))),
                                ]),
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
                                //SizedBox(height: 5),
                                MaterialButton(
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(20.0)),
                                  minWidth: 200,
                                  height: 50,
                                  child: Text('Register',
                                      style: TextStyle(fontSize: 16)),
                                  color: Colors.pinkAccent,
                                  textColor: Colors.white,
                                  elevation: 15,
                                  onPressed: newUserDialog,
                                ),
                                SizedBox(height: 10),
                                Text('Already Register?',
                                    style: TextStyle(fontSize: 15)),
                                GestureDetector(
                                    onTap: _onLogin,
                                    child: Text('Login',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.pink))),
                                SizedBox(height: 10),
                              ],
                            ),
                          ))
                    ]))),
              ),
            )));
  }

  bool isPasswordCompliant(String password, [int minLength = 6]) {
    if (password == null || password.isEmpty) {
      return false;
    }

//  bool hasUppercase = password.contains(new RegExp(r'[A-Z]'));
    bool hasDigits = password.contains(new RegExp(r'[0-9]'));
    bool hasLowercase = password.contains(new RegExp(r'[a-z]'));
    // bool hasSpecialCharacters = password.contains(new RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    bool hasMinLength = password.length > minLength;

    return hasDigits & hasLowercase & hasMinLength;
  }

  void newUserDialog() {
    _name = _namecontroller.text;
    _email = _emcontroller.text;
    _phone = _phcontroller.text;
    _password = _pscontroller.text;
    if (_name.length < 5) {
      Toast.show("Name too short", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      return;
    }
    bool emailValid = RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(_email);
    if (!emailValid) {
      Toast.show("Invalid Email", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      return;
    }
    if (!isPasswordCompliant(_password)) {
      Toast.show(
          "Password must be 7 characters minimum and contain lowercases and numbers",
          context,
          duration: Toast.LENGTH_LONG,
          gravity: Toast.BOTTOM);
      return;
    }
    if (_phone.length < 10) {
      Toast.show("Provide valid phone number", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      return;
    }
    //if (_image == null) {
    //Toast.show("Please take your profile picture", context,
    //duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    //return;
    //}
    if (!_termsChecked) {
      Toast.show(
          "You must agree to the terms before creating a new account.", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: new Text(
            "Register?",
            style: TextStyle(
              color: Colors.black,
            ),
          ),
          content:
              new Text("Are you sure?", style: TextStyle(color: Colors.black)),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text(
                "Yes",
                style: TextStyle(
                  color: Colors.pink,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _onRegister();
              },
            ),
            new FlatButton(
              child: new Text(
                "No",
                style: TextStyle(
                  color: Colors.pink,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _onRegister() async {
    _name = _namecontroller.text;
    _email = _emcontroller.text;
    _password = _pscontroller.text;
    _phone = _phcontroller.text;
    if (_name.isEmpty ||
        _email.isEmpty ||
        _password.isEmpty ||
        _phone.isEmpty) {
      Toast.show(
        "Please check your input",
        context,
        duration: Toast.LENGTH_LONG,
        gravity: Toast.TOP,
      );
      return;
    }
    if (!validateEmail(_email) && !validatePassword(_password)) {
      Toast.show(
        "Check your email/password",
        context,
        duration: Toast.LENGTH_LONG,
        gravity: Toast.TOP,
      );
      return;
    }
    ProgressDialog pr = new ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false);
    pr.style(message: "Registration...");
    await pr.show();
    http.post(
        "http://struggling-capacity.000webhostapp.com/parentingland/php/register_user.php",
        body: {
          "name": _name,
          "email": _email,
          "password": _password,
          "phone": _phone,
        }).then((res) {
      print(res.body);
      if (res.body == "failed") {
        Toast.show(
          "Registration failed",
          context,
          duration: Toast.LENGTH_LONG,
          gravity: Toast.TOP,
        );
      } else {
        Toast.show(
          "Registration success. An email has been sent to .$_email. Please check your email for OTP verification. Also check in your spam folder.",
          context,
          duration: Toast.LENGTH_LONG,
          gravity: Toast.TOP,
        );
        if (_rememberMe) {
          savepref();
        }
        _onLogin();
      }
    }).catchError((err) {
      print(err);
    });
    await pr.hide();
  }

  void _showEULA() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(
            "EULA",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          content: new Container(
            //height: screenHeight / 2,
            child: Column(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: new SingleChildScrollView(
                    child: RichText(
                        softWrap: true,
                        textAlign: TextAlign.justify,
                        text: TextSpan(
                            style: TextStyle(
                              color: Colors.black,
                              //fontWeight: FontWeight.w500,
                              fontSize: 12.0,
                            ),
                            text:
                                "This End-User License Agreement is a legal agreement between you and our company. This EULA agreement governs your acquisition and use of our ParentingLand software (Software) directly from our company or indirectly through a Company authorized reseller or distributor (a Reseller).Please read this EULA agreement carefully before completing the installation process and using the ParentingLand software. It provides a license to use the ParentingLand software and contains warranty information and liability disclaimers. If you register for a free trial of the ParentingLand software, this EULA agreement will also govern that trial. By clicking accept or installing and/or using the ParentingLand software, you are confirming your acceptance of the Software and agreeing to become bound by the terms of this EULA agreement. If you are entering into this EULA agreement on behalf of a company or other legal entity, you represent that you have the authority to bind such entity and its affiliates to these terms and conditions. If you do not have such authority or if you do not agree with the terms and conditions of this EULA agreement, do not install or use the Software, and you must not accept this EULA agreement.This EULA agreement shall apply only to the Software supplied by Company herewith regardless of whether other software is referred to or described herein. The terms also apply to any Company updates, supplements, Internet-based services, and support services for the Software, unless other terms accompany those items on delivery. If so, those terms apply. This EULA was created by EULA Template for ParentingLand. Company shall at all times retain ownership of the Software as originally downloaded by you and all subsequent downloads of the Software by you. The Software (and the copyright, and other intellectual property rights of whatever nature in the Software, including any modifications made thereto) are and shall remain the property of Company. Company reserves the right to grant licences to use the Software to third parties"
                            //children: getSpan(),
                            )),
                  ),
                )
              ],
            ),
          ),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  void _onLogin() {
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (BuildContext context) => LoginScreen()));
  }

  void _onChange(bool value) {
    setState(() {
      _rememberMe = value;
    });
  }

  void savepref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _email = _emcontroller.text;
    _password = _pscontroller.text;
    await prefs.setString('email', _email);
    await prefs.setString('password', _password);
    await prefs.setBool('rememberme', true);
  }

  bool validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    return (!regex.hasMatch(value)) ? false : true;
  }

  bool validatePassword(String value) {
    String pattern = r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{8,}$';
    RegExp regExp = new RegExp(pattern);
    return regExp.hasMatch(value);
  }
}
