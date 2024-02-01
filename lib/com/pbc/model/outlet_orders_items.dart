import 'package:flutter/material.dart';


class OutletOrdersItems{

  final int order_id;
  final int product_id;
  final String product_label;
  final double discount;
  final int quantity;
  final double amount;
  final String created_on;
  final double rate;

  OutletOrdersItems({
    this.order_id,this.product_id,this.discount,this.quantity, this.amount,this.created_on,this.rate,this.product_label
  });

  /*Map<String, dynamic> toMap() {
    return {

      'id':id,'outlet_id':outlet_id,'is_completed':is_completed,'is_uploaded':is_uploaded,'total_amount':total_amount,'uuid':uuid,'created_on':created_on

    };
  }

  factory OutletOrders.fromMap(Map<String, dynamic> map) {

  }*/
  @override
  String toString() {
    return 'OutletOrdersItems{ order_id: $order_id, product_id: $product_id, discount: $discount, quantity: $quantity,  amount: $amount,created_on:$created_on,rate:$rate,product_label:$product_label}';
  }


}