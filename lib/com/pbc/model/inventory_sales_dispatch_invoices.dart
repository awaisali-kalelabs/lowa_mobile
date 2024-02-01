import 'package:flutter/material.dart';
class InventorySalesDispatchInvoices{


  final int mobile_id;
  final int id;
  final int sales_id;
  final double cash_recieved;
  final int reciept_type_id;
  final int is_delivered;
  final int delivery_type_id;
  final String delivered_on;
  final int delivered_by;
  final String lat;
  final String lng;
  final int accuracy;
  final String uuid;
  final String outlet_image;
  final String outlet_signature;
  final String mobile_timestamp;


  InventorySalesDispatchInvoices({this.mobile_id, this.id, this.sales_id,
      this.cash_recieved, this.reciept_type_id, this.is_delivered,
      this.delivery_type_id, this.delivered_on, this.delivered_by, this.lat,
      this.lng, this.accuracy, this.uuid, this.outlet_image,
      this.outlet_signature, this.mobile_timestamp});

  Map<String, dynamic> toMap() {
    return {
      'mobile_id':mobile_id,
      'id':id,
      'sales_id':sales_id,
      'cash_recieved':cash_recieved,
      'reciept_type_id':reciept_type_id,
      'is_delivered':is_delivered,
      'delivery_type_id':delivery_type_id,
      'delivered_on':delivered_on,
      'delivered_by':delivered_by,
      'lat':lat,
      'lng':lng,
      'accuracy':accuracy,
      'uuid':uuid,
      'outlet_image':outlet_image,
      'outlet_signature':outlet_signature,
      'mobile_timestamp':mobile_timestamp

    };
  }

  factory InventorySalesDispatchInvoices.fromJson(Map<String, dynamic> json){
    return InventorySalesDispatchInvoices(
        mobile_id:json['mobile_id'],
        id:json['id'],
        sales_id:json['sales_id'],
        cash_recieved:json['cash_recieved'],
        reciept_type_id:json['reciept_type_id'],
        is_delivered:json['is_delivered'],
        delivery_type_id:json['delivery_type_id'],
        delivered_on:json['delivered_on'],
        delivered_by:json['delivered_by'],
        lat:json['lat'],
        lng:json['lng'],
        accuracy:json['accuracy'],
        uuid:json['uuid'],
        outlet_image:json['outlet_image'],
        outlet_signature:json['outlet_signature'],
        mobile_timestamp:json['mobile_timestamp']);
  }

  @override
  String toString() {
    return 'InventorySalesDispatchInvoices{mobile_id: $mobile_id, id: $id, sales_id: $sales_id, cash_recieved: $cash_recieved, reciept_type_id: $reciept_type_id, is_delivered: $is_delivered, delivery_type_id: $delivery_type_id, delivered_on: $delivered_on, delivered_by: $delivered_by, lat: $lat, lng: $lng, accuracy: $accuracy, uuid: $uuid, outlet_image: $outlet_image, outlet_signature: $outlet_signature, mobile_timestamp: $mobile_timestamp}';
  }


}