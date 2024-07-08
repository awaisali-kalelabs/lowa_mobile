import 'package:flutter/material.dart';
class OutletChannel{
  final int id;
  final String label;
  OutletChannel({
    this.id,
    this.label
  });

  Map<String, dynamic> toMap() {
    return {

      'id':id ,
      'label':label
    };
  }


  factory OutletChannel.fromJson(Map<String, dynamic> json){
    return OutletChannel(
        id:int.parse(json['ID']),
        label:json['ChannelLabel']
    );
  }
  @override
  String toString() {
    return 'OutletChannel{ id: $id , label: $label}';
  }


}