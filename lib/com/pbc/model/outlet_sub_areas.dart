import 'package:flutter/material.dart';
class OutletSubAreas{

  final int id;
  final String label;
  final int area_id;


  OutletSubAreas({
    this.id,this.label,this.area_id
  });

  Map<String, dynamic> toMap() {
    return {

      'id':id,'label':label,'area_id':area_id
    };
  }


  factory OutletSubAreas.fromJson(Map<String, dynamic> json){
    return OutletSubAreas(
        id:json['ID'],label:json['Label'],area_id:json['AreaID']
    );
  }
  @override
  String toString() {
    return 'OutletSubAreas{ id: $id, label: $label,area_id: $area_id}';
  }


}