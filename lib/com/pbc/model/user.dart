import 'package:flutter/material.dart';
class User{


  final int user_id;
  final String display_name;
  final String designation;
  final String department;
  final int distributor_employee_id;
  final String password;
  final String created_on;
  final String IsOutletLocationUpdate;


  User({this.user_id, this.display_name, this.designation, this.department,
      this.distributor_employee_id, this.password,this.created_on,this.IsOutletLocationUpdate});

  Map<String, dynamic> toMap() {
    return {
      'user_id':user_id,
      'display_name':display_name,
      'designation':designation,
      'department':department,
      'distributor_employee_id':distributor_employee_id,
      'password':password,
      'created_on':created_on,
      'IsOutletLocationUpdate':IsOutletLocationUpdate

    };
  }

  factory User.fromJson(Map<String, dynamic> json){
    return User(user_id:json['user_id'],display_name:json['display_name'],designation:json['designation'],
        department:json['department'],distributor_employee_id:json['distributor_employee_id'],password:json['password'],created_on:json['created_on'],IsOutletLocationUpdate:json['IsOutletLocationUpdate']);
  }

  @override
  String toString() {
    return 'PreSellOutlets{user_id: $user_id, display_name: $display_name, designation: $designation, department: $department, distributor_employee_id: $distributor_employee_id, password: $password, IsOutletLocationUpdate: $IsOutletLocationUpdate}';
  }


}