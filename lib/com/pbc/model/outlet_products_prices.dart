import 'package:flutter/material.dart';
class OutletProductsPrices{

  final int price_id;
  final int outlet_id;
  final int product_id;
  final double raw_case;
  final String unit;


  OutletProductsPrices({
    this.price_id,this.outlet_id,this.product_id,this.raw_case, this.unit
  });

  Map<String, dynamic> toMap() {
    return {

      'price_id':price_id,'outlet_id':outlet_id,'product_id':product_id,'raw_case':raw_case,'unit':unit

    };
  }


  factory OutletProductsPrices.fromJson(Map<String, dynamic> json){
    return OutletProductsPrices(
        price_id:int.parse(json['PriceListID']),outlet_id:int.parse(json['OutletID']),product_id:int.parse(json['ProductID']),raw_case:double.parse(json['RawCase']),unit:json['Unit']
    );
  }
  @override
  String toString() {
    return 'OutletProductsPrices{ price_id: $price_id, outlet_id: $outlet_id, product_id: $product_id, raw_case: $raw_case,  unit: $unit }';
  }


}