import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../buyer_and_seller/navigatoin_seller_screen.dart';
import '../navigation/navigation_screen.dart';

class LoginProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final formKey = GlobalKey<FormState>();

  String _email = '';
  String _password = '';
  bool _isLoading = false;
  String? _errorMessage;
  bool isPasswordVisible = false;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void setEmail(String value) {
    _email = value.trim();
    notifyListeners();
  }

  void setPassword(String value) {
    _password = value;
    notifyListeners();
  }

  void togglePassword() {
    isPasswordVisible = !isPasswordVisible;
    notifyListeners();
  }

  void resetState() {
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> navigateBasedOnRole(BuildContext context, String userId) async {
    if (!context.mounted) return;

    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (!userDoc.exists || !context.mounted) {
        _errorMessage = 'User data not found';
        resetState();
        return;
      }

      final userData = userDoc.data();
      if (userData == null) {
        _errorMessage = 'User data is empty';
        resetState();
        return;
      }

      final userRole = userData['role'] as String?;
      if (userRole == null || (userRole != 'buyer' && userRole != 'seller')) {
        _errorMessage = 'Invalid user role';
        resetState();
        return;
      }

      // Navigate and reset state
      if (context.mounted) {
        await Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => userRole == 'buyer'
                ? const NavigationScreen()
                : const NavigationSellerScreen(),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      _errorMessage = 'Error fetching user role: $e';
      resetState();
    }
  }

  Future<bool> login(BuildContext context) async {
    if (!context.mounted) return false;

    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Validate form first
      if (!formKey.currentState!.validate()) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Please fill in all fields correctly';
        });
        return false;
      }

      // Clear any existing sessions
      await _auth.signOut();

      // Attempt login
      final credential = await _auth.signInWithEmailAndPassword(
        email: _email,
        password: _password,
      );

      final user = credential.user;
      if (user == null) {
        setState(() {
          _errorMessage = 'No user returned after login';
          _isLoading = false;
        });
        return false;
      }

      if (!context.mounted) {
        resetState();
        return false;
      }

      await navigateBasedOnRole(context, user.uid);
      return true;
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = switch (e.code) {
          'user-not-found' => 'No user found with this email',
          'wrong-password' => 'Incorrect password',
          'invalid-email' => 'Invalid email address',
          'user-disabled' => 'This account has been disabled',
          _ => 'Authentication error: ${e.message}',
        };
        _isLoading = false;
      });
      return false;
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred';
        _isLoading = false;
      });
      return false;
    }
  }

  void setState(Function() fn) {
    fn();
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
