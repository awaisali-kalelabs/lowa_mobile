import 'package:flutter/material.dart';
class PCISubAreas{

  final int id;
  final String label;
  final int parent_channel_id;


  PCISubAreas({
    this.id,this.label,this.parent_channel_id
  });

  Map<String, dynamic> toMap() {
    return {

      'id':id,'label':label,'parent_channel_id':parent_channel_id
    };
  }


  factory PCISubAreas.fromJson(Map<String, dynamic> json){
    return PCISubAreas(
        id:json['ID'],label:json['Label'],parent_channel_id:json['ParentChannelID']
    );
  }
  @override
  String toString() {
    return 'PCISubAreas{ id: $id, label: $label,parent_channel_id: $parent_channel_id}';
  }


}