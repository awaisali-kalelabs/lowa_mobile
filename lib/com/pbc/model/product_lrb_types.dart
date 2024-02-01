import 'package:flutter/material.dart';
class ProductsLrbTypes{

  final int id;
  final String label;


  ProductsLrbTypes({
    this.id,this.label
  });

  Map<String, dynamic> toMap() {
    return {

      'id':id,'label':label
    };
  }


  factory ProductsLrbTypes.fromJson(Map<String, dynamic> json){
    return ProductsLrbTypes(
        id:json['ID'],label:json['Label']
    );
  }
  @override
  String toString() {
    return 'ProductsLrbTypes{ id: $id, label: $label}';
  }


}