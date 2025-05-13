import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nursery/Model/User-model.dart';


class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> signUp(UserAuthModel user) async {
    try {
      UserCredential userCredential =
      await _auth.createUserWithEmailAndPassword(
        email: user.email,
        password: user.password,
      );
      await _firestore
          .collection('SignUp')
          .doc(userCredential.user!.uid)
          .set(user.toMap());
      return userCredential.user;
    } catch (e) {
      print("User is already Exits");
    }
  }

  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password:password,
      );
      return userCredential.user;
    } catch (e) {
      print("Login Again");
    }
  }
}
