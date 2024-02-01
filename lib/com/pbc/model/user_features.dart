import 'package:flutter/material.dart';
class UserFeatures{
  final int id;
  UserFeatures({
    this.id
  });

  Map<String, dynamic> toMap() {
    return {

      'id':id
    };
  }


  factory UserFeatures.fromJson(Map<String, dynamic> json){
    return UserFeatures(
        id:int.parse(json['FeatureID'])
    );
  }
  @override
  String toString() {
    return 'UserFeatures{ id: $id}';
  }


}