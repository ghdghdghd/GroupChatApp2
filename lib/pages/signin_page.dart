import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:group_chat_app/helper/helper_functions.dart';
import 'package:group_chat_app/pages/home_page.dart';
import 'package:group_chat_app/services/auth_service.dart';
import 'package:group_chat_app/services/database_service.dart';
import 'package:group_chat_app/shared/constants.dart';
import 'package:group_chat_app/shared/loading.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';


class SignInPage extends StatefulWidget {
  final Function toggleView;
  SignInPage({this.toggleView});

  @override
  _SignInPageState createState() => _SignInPageState();
}


class _SignInPageState extends State<SignInPage> {

  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // text field state
  String email = '';
  String password = '';
  String error = '';

  Future<Position> getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    return position;
  }
  _onSignIn() async {
    print("로그인 클릭시 동작 하는 함수 _onSignIn");
    var gps = await getCurrentLocation();
    List<Placemark> mCityInfo = await placemarkFromCoordinates(gps.latitude, gps.longitude); //좌표값으로 도시정보 가져오기
    print("위치정보");
    print(mCityInfo);
    var mCityArea = mCityInfo[0].administrativeArea.toString();

    print(_formKey.currentState.validate());
    if (_formKey.currentState.validate()) {
      setState(() {
        _isLoading = true;
      });

      await _auth.signInWithEmailAndPassword(email, password, mCityArea).then((result) async {//이메일 패쓰워드검증
        print("result 검증");
        print(result);
        if (result != null) {
          QuerySnapshot userInfoSnapshot = await DatabaseService().getUserData(email);

          await HelperFunctions.saveUserLoggedInSharedPreference(true);
          await HelperFunctions.saveUserEmailSharedPreference(email);
          await HelperFunctions.saveUserNameSharedPreference(
            userInfoSnapshot.docs[0].get('fullName') // 검증요 data['fullName']
          );

          print("Signed In");
          await HelperFunctions.getUserLoggedInSharedPreference().then((value) {
            print("Logged in: $value");
          });
          await HelperFunctions.getUserEmailSharedPreference().then((value) {
            print("Email: $value");
          });
          await HelperFunctions.getUserNameSharedPreference().then((value) {
            print("Full Name: $value");
          });

          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomePage()));
        }
        else {
          setState(() {
            error = 'Error signing in!';
            _isLoading = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading ? Loading() : Scaffold(
      body: Form(
        key: _formKey,
        child: Container(
          color: Colors.black,
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 80.0),
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text("Create or Join Groups", style: TextStyle(color: Colors.white, fontSize: 40.0, fontWeight: FontWeight.bold)),
                
                  SizedBox(height: 30.0),
                
                  Text("Sign In", style: TextStyle(color: Colors.white, fontSize: 25.0)),

                  SizedBox(height: 20.0),
                
                  TextFormField(
                    style: TextStyle(color: Colors.white),
                    decoration: textInputDecoration.copyWith(labelText: 'Email'),
                    validator: (val) {
                      return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(val) ? null : "Please enter a valid email";
                    },
                  
                    onChanged: (val) {
                      setState(() {
                        email = val;
                      });
                    },
                  ),
                
                  SizedBox(height: 15.0),
                
                  TextFormField(
                    style: TextStyle(color: Colors.white),
                    decoration: textInputDecoration.copyWith(labelText: 'Password'),
                    validator: (val) => val.length < 6 ? 'Password not strong enough' : null,
                    obscureText: true,
                    onChanged: (val) {
                      setState(() {
                        password = val;
                      });
                    },
                  ),
                
                  SizedBox(height: 20.0),
                
                  SizedBox(
                    width: double.infinity,
                    height: 50.0,
                    child: ElevatedButton(
                      // elevation: 0.0,
                      // color: Colors.blue,
                      // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                      child: Text('Sign In', style: TextStyle(color: Colors.white, fontSize: 16.0)),
                      onPressed: () {
                        _onSignIn();
                      }
                    ),
                  ),
                
                  SizedBox(height: 10.0),
                  
                  Text.rich(
                    TextSpan(
                      text: "Don't have an account? ",
                      style: TextStyle(color: Colors.white, fontSize: 14.0),
                      children: <TextSpan>[
                        TextSpan(
                          text: 'Register here',
                          style: TextStyle(
                            color: Colors.white,
                            decoration: TextDecoration.underline
                          ),
                          recognizer: TapGestureRecognizer()..onTap = () {
                            widget.toggleView();
                          },
                        ),
                      ],
                    ),
                  ),
                
                  SizedBox(height: 10.0),
                
                  Text(error, style: TextStyle(color: Colors.red, fontSize: 14.0)),
                ],
              ),
            ],
          ),
        ),
      )
    );
  }
}
