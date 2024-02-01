import 'package:flutter/material.dart';
class PreSellRoutes{
  final int dispatch_id;
  final String created_on;
  final int vehicle_id;
  final String vehicle_no;
  final int raw_cases;
  final int outlets;
  final int delivered_outlets;

  PreSellRoutes({this.dispatch_id, this.created_on, this.vehicle_id,
      this.vehicle_no, this.raw_cases,this.outlets,this.delivered_outlets});

  Map<String, dynamic> toMap() {
    return {
      'dispatch_id':dispatch_id,
      'created_on':created_on,
      'vehicle_id':vehicle_id,
      'vehicle_no':vehicle_no,
      'raw_cases':raw_cases,
      'outlets':outlets
      ,
      'delivered_outlets':delivered_outlets
    };
  }

  factory PreSellRoutes.fromJson(Map<String, dynamic> json){
    return PreSellRoutes(dispatch_id:json['dispatch_id'],created_on:json['created_on'],vehicle_id:json['vehicle_id'],
        vehicle_no:json['vehicle_no'],raw_cases:json['raw_cases'],outlets:json['outlets'],delivered_outlets:json['delivered_outlets']);
  }

  @override
  String toString() {
    return 'PreSellRoutes{dispatch_id: $dispatch_id, created_on: $created_on, vehicle_id: $vehicle_id, vehicle_no: $vehicle_no, raw_cases: $raw_cases,outlets:$outlets,delivered_outlets:$delivered_outlets}';
  }


}