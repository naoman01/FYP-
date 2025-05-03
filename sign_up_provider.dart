import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:plant_project/screens/seller/seller_home_screen.dart';
import 'package:plant_project/screens/buyer/buyer_screen.dart';
import '../../core/model/user_model.dart';
import '../navigation/navigation_screen.dart';

class SignUpProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  String _email = '';
  String _password = '';
  String _confirmPassword = '';
  int selectedIndex = 0; // 0 for Buyer, 1 for Seller
  String? _errorMessage;
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get userRole => selectedIndex == 0 ? 'buyer' : 'seller';

  void togglePassword() {
    isPasswordVisible = !isPasswordVisible; // Fixed: use = instead of !=
    notifyListeners();
  }

  void toggleConfirmPassword() {
    isConfirmPasswordVisible =
        !isConfirmPasswordVisible; // Fixed: use = instead of !=
    notifyListeners();
  }

  void setEmail(String value) {
    _email = value.trim();
    notifyListeners();
  }

  void setPassword(String value) {
    _password = value;
    notifyListeners();
  }

  void setConfirmPassword(String value) {
    _confirmPassword = value;
    notifyListeners();
  }

  void selectRole(int index) {
    selectedIndex = index;
    notifyListeners();
  }

  Future<bool> signUp() async {
    if (_password != _confirmPassword) {
      _errorMessage = 'Passwords do not match';
      notifyListeners();
      return false;
    }

    try {
      _isLoading = true;
      notifyListeners();

      // Create user in Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: _email,
        password: _password,
      );

      // Create user model
      final user = UserModel(
        uid: userCredential.user!.uid,
        email: _email,
        role: userRole,
      );

      // Save user data to Firestore
      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(user.toMap());

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      _errorMessage = e.message;
      notifyListeners();
      return false;
    }
  }

  void navigateBasedOnRole(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => userRole == 'buyer'
            ? const NavigationScreen()
            : const SellerHomeScreen(),
      ),
    );
  }
}
