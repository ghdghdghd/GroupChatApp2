import 'package:firebase_auth/firebase_auth.dart';
import 'package:group_chat_app/helper/helper_functions.dart';
import 'package:group_chat_app/models/users.dart';
import 'package:group_chat_app/services/database_service.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';


class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;


  // create user object based on FirebaseUser
  Users _userFromFirebaseUser(User user) {
    return (user != null) ? Users(uid: user.uid) : null;
  }


  // sign in with email and password
  Future signInWithEmailAndPassword(String email, String password, String mCityArea) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      User user = result.user;

      await DatabaseService(uid: user.uid).updateLocation(mCityArea); //위치 업데이트

      return _userFromFirebaseUser(user);
    } catch(e) {
      print(e.toString());
      return null;
    }
  }


  // // 로그인시 위치 정보 업데이트
  // Future signInWithLocation(String mCityArea) async {
  //   print("로그인시 위치정보 업데이트");
  //   try {
  //     UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
  //     print("로그인시 위치정보 업데이트2");
  //     print(result);
  //     User user = result.user;
  //     print("로그인시 위치정보 업데이트3");
  //
  //
  //     // Create a new document for the user with uid
  //     await DatabaseService(uid: user.uid).updateUserData(fullName, email, password, mCityArea);
  //     return _userFromFirebaseUser(user);
  //   } catch(e) {
  //     print("걍 에러@!!!!");
  //     print(e.toString());
  //     return null;
  //   }
  // }


  // register with email and password
  Future registerWithEmailAndPassword(String fullName, String email, String password, String mCityArea) async {
    print("12341234123412341243");
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      print("4444444444445444444");
      print(result);
      User user = result.user;
      print("6666666666666666");

      // Create a new document for the user with uid
      await DatabaseService(uid: user.uid).updateUserData(fullName, email, password, mCityArea);
      return _userFromFirebaseUser(user);
    } catch(e) {
      print("걍 에러@!!!!");
      print(e.toString());
      return null;
    }
  }

  //sign out
  Future signOut() async {
    try {
      await HelperFunctions.saveUserLoggedInSharedPreference(false);
      await HelperFunctions.saveUserEmailSharedPreference('');
      await HelperFunctions.saveUserNameSharedPreference('');

      return await _auth.signOut().whenComplete(() async {
        print("Logged out");
        await HelperFunctions.getUserLoggedInSharedPreference().then((value) {
          print("Logged in: $value");
        });
        await HelperFunctions.getUserEmailSharedPreference().then((value) {
          print("Email: $value");
        });
        await HelperFunctions.getUserNameSharedPreference().then((value) {
          print("Full Name: $value");
        });
      });
    } catch(e) {
      print(e.toString());
      return null;
    }
  }
}