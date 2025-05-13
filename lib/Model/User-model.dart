import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserAuthModel {
  String fullName;
  String email;
  String phone_number;
  String password;
  String confirm_password;
  UserAuthModel(
      {required this.fullName,
        required this.email,
        required this.phone_number,
        required this.password,
        required this.confirm_password});

//convert the userProfile into the map
  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'email': email,
      'phone_number': phone_number,
      'password': password,
      'confirm_password': confirm_password,
    };
  }

  //Make the UserProfile From Map
  factory UserAuthModel.fromMap(Map<String, dynamic> map) {
    return UserAuthModel(
      fullName: map['fullName'],
      email: map['email'],
      phone_number: map['phone_number'],
      password: map['password'],
      confirm_password: map['confirm_password'],
    );
  }
}
