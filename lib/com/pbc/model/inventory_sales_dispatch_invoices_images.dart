import 'package:flutter/material.dart';
class InventorySalesDispatchInvoicesImages{


  final int mobile_id;
  final int id;
  final int sales_id;
  final String outlet_image;
  final String outlet_signature;
  final String mobile_timestamp;


  InventorySalesDispatchInvoicesImages({this.mobile_id, this.id, this.sales_id,
       this.outlet_image,
      this.outlet_signature, this.mobile_timestamp});

  Map<String, dynamic> toMap() {
    return {
      'mobile_id':mobile_id,
      'id':id,
      'sales_id':sales_id,
      
      'outlet_image':outlet_image,
      'outlet_signature':outlet_signature,
      'mobile_timestamp':mobile_timestamp

    };
  }

  factory InventorySalesDispatchInvoicesImages.fromJson(Map<String, dynamic> json){
    return InventorySalesDispatchInvoicesImages(
        mobile_id:json['mobile_id'],
        id:json['id'],
        sales_id:json['sales_id'],
        
        outlet_image:json['outlet_image'],
        outlet_signature:json['outlet_signature'],
        mobile_timestamp:json['mobile_timestamp']);
  }

  @override
  String toString() {
    return 'InventorySalesDispatchInvoicesImages{mobile_id: $mobile_id, id: $id, sales_id: $sales_id, outlet_image: $outlet_image, outlet_signature: $outlet_signature, mobile_timestamp: $mobile_timestamp}';
  }


}