import 'package:flutter/material.dart';

 String id = 'todo';
 String outlet_id = '_id';
 String is_completed = 'title';
 String is_uploaded = 'done';
 String total_amount = 'done';
 String uuid = 'done';
 String created_on = 'done';
class OutletOrders{

  final int id;
  final int outlet_id;
  final int is_completed;
  final int is_uploaded;
  final double total_amount;
  final String uuid;
  final String created_on;
  final double lat;
  final double lng;
  final double accuracy;

  OutletOrders({
    this.id,this.outlet_id,this.is_completed,this.is_uploaded, this.total_amount,this.uuid,this.created_on, this.lat, this.lng, this.accuracy
  });

  Map<String, dynamic> toMap() {
    return {

      'id':id,'outlet_id':outlet_id,'is_completed':is_completed,'is_uploaded':is_uploaded,'total_amount':total_amount,'uuid':uuid,'created_on':created_on
      ,'lat':lat,'lng':lng,'accuracy':accuracy

    };
  }

  factory  OutletOrders.fromMap(Map<String, dynamic> map) {
    return OutletOrders(id:int.parse(map['id']),outlet_id:int.parse(map['outletId']),is_completed:int.parse(map['isCompleted']),
        is_uploaded:int.parse(map['isUploaded']),total_amount:double.parse(map['totalAmount']),uuid:map['uuid'],created_on:map['createdOn']);
  }
  @override
  String toString() {
    return 'OutletOrders{ id: $id, outlet_id: $outlet_id, is_completed: $is_completed, is_uploaded: $is_uploaded,  total_amount: $total_amount,uuid:$uuid,created_on:$created_on}';
  }


}