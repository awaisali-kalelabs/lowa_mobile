import 'package:flutter/material.dart';
class OutletAreas{

  final int id;
  final String label;


  OutletAreas({
    this.id,this.label
  });

  Map<String, dynamic> toMap() {
    return {

      'id':id,'label':label
    };
  }


  factory OutletAreas.fromJson(Map<String, dynamic> json){
    return OutletAreas(
        id:json['ID'],label:json['Label']
    );
  }
  @override
  String toString() {
    return 'OutletAreas{ id: $id, label: $label}';
  }


}