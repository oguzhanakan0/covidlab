import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';
import 'package:covidlab/services/requests.dart';
import 'package:covidlab/variables/urls.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

enum Status {
  Uninitialized,
  Authenticated,
  Authenticating,
  Unauthenticated,
  ConnectionFailure
}

class UserRepository with ChangeNotifier {
  FirebaseAuth? _auth;
  User? _user;
  Status? _status = Status.Uninitialized;
  Map? _dbUser;
  String? _dbToken;
  dynamic _appointments = [];
  dynamic _notifs = [];

  UserRepository.instance() : _auth = FirebaseAuth.instance {
    _auth!.authStateChanges().listen(_onAuthStateChanged);
  }

  Status? get status => _status;
  User? get user => _user;
  Map? get dbUser => _dbUser;
  String? get dbToken => _dbToken;
  dynamic get appointments => _appointments;
  dynamic get notifs => _notifs;

  set appointments(dynamic a) {
    _appointments = a;
    notifyListeners();
  }

  set notifs(dynamic a) {
    _notifs = a;
    notifyListeners();
  }

  GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
    ],
  );

  Future<dynamic> signinWithGoogle() async {
    try {
      _status = Status.Authenticating;
      notifyListeners();
      final GoogleSignInAccount googleUser = (await _googleSignIn.signIn())!;
      // print('sign in with GOOGLE success');
      // print(googleUser.displayName);
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential =
          GoogleAuthProvider.credential(accessToken: googleAuth.accessToken);
      await _auth!.signInWithCredential(credential);
      // final idToken = await _user!.getIdToken();
      // // print(idToken);
      // log(idToken);
      // return true; // TODO: DISABLE LATER
    } catch (error) {
      print(error);
      _status = Status.Unauthenticated;
      notifyListeners();
      return {"success": false};
    }
  }

  Future<bool> signinWithFacebook() async {
    try {
      _status = Status.Authenticating;
      notifyListeners();
      final LoginResult result = await FacebookAuth.instance.login();
      if (result.status == LoginStatus.success) {
        // logged in
        AccessToken accessToken = result.accessToken!;
        AuthCredential credential =
            FacebookAuthProvider.credential(accessToken.token);
        await _auth!.signInWithCredential(credential);
        // return verifyToken(); // TODO: ENABLE LATER
        return true; // TODO: DISABLE LATER
        // TODO: BASKA PLATFORM TARAFINDAN SIGN IN YAPMISSA EXCEPTION VERIYOR. HANDLE EDILMESI LAZIM.
      }
      // something went wrong
      return false;
    } catch (error) {
      print(error);
      _status = Status.Unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithApple() async {
    // TODO: NOT TESTED. NEEDS APPLE DEVELOPER USER.
    // ONCE YOU GET THE USER, FOLLOW THIS LINK:
    // https://firebase.google.com/docs/auth/ios/apple?authuser=2
    try {
      _status = Status.Authenticating;
      notifyListeners();
      AuthorizationCredentialAppleID credentialApple =
          await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      OAuthProvider oAuthProvider = OAuthProvider("apple.com");
      AuthCredential credential = oAuthProvider.credential(
        idToken: credentialApple.identityToken,
        accessToken: credentialApple.authorizationCode,
      );
      await _auth!.signInWithCredential(credential);
      // return verifyToken(); // TODO: ENABLE LATER
      return true; // TODO: DISABLE LATER
    } catch (error) {
      print(error);
      _status = Status.Unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signIn(String email, String password) async {
    try {
      print("signing in with $email and $password");
      _status = Status.Authenticating;
      notifyListeners();
      await _auth!.signInWithEmailAndPassword(email: email, password: password);
      // return verifyToken(); // TODO: ENABLE LATER
      return true; // TODO: DISABLE LATER
    } catch (e) {
      print("email signin error: " + e.toString());
      _status = Status.Unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp(String email, String password) async {
    try {
      _status = Status.Authenticating;
      notifyListeners();
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      print(userCredential);
      return true;
    } on FirebaseAuthException catch (e) {
      _status = Status.Unauthenticated;
      notifyListeners();
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
      return false;
    } catch (e) {
      _status = Status.Unauthenticated;
      notifyListeners();
      print(e);
      return false;
    }
  }

  Future<Map> dbSignIn() async {
    final idToken = await _user!.getIdToken();
    Response r = await sendPost(url: SIGN_IN_URL, body: {"token": idToken});
    print("response received.");
    print(json.decode(r.body)); // Debug
    return json.decode(r.body);
  }

  Future signOut() async {
    _auth!.signOut();
    _status = Status.Unauthenticated;
    notifyListeners();
    return Future.delayed(Duration.zero);
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    await Future.delayed(const Duration(seconds: 3));
    if (firebaseUser == null) {
      _status = Status.Unauthenticated;
    } else {
      _user = firebaseUser;
      _status = Status.Authenticating;
      notifyListeners();
      try {
        final _response = await dbSignIn();
        if (_response["success"]) {
          _dbUser = _response["user"];
          _dbToken = _response["token"];
          _status = Status.Authenticated;
        } else
          _status = Status.Unauthenticated;
      } catch (e) {
        print(e.toString());
        _status = Status.ConnectionFailure;
      }
    }
    notifyListeners();
  }

  // set setdbUser(dynamic user) => dbUser;
  void setdbUser(dynamic user) {
    _dbUser = user;
    notifyListeners();
  }
}

// Future<dynamic> signInWithEmailAndPassword(String email, String password) async {
//   dynamic credentials = {};
//   try{
//   final AuthResult res = (await _auth.signInWithEmailAndPassword(
//     email: email,
//     password: password,
//   ));
//   IdTokenResult token=await res.user.getIdToken();
//   credentials['googleUserID'] = res.user.uid;
//   credentials['token'] = token.token;
//   credentials['email']=res.user.email;
//   return credentials;
//   } catch(e){
//     String msg ='';
//     switch (e.code) {
//       case 'ERROR_WRONG_PASSWORD':
//         msg = 'Hata: Girdiğiniz şifre yanlış. Lütfen tekrar deneyin.';break;
//       case 'ERROR_INVALID_EMAIL':
//         msg = 'Hata: Email adresi geçersiz.';break;
//       case 'ERROR_USER_NOT_FOUND':
//         msg = 'Hata: Kullanıcı bulunamadı.';break;
//       default:
//         msg = 'Bir hata oluştu. Lütfen tekrar deneyin.';break;
//     }
//     showSimpleNotification(
//       Text(msg),
//     );
//     return null;
//   }
// }
