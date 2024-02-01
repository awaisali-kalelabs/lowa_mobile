import 'package:flutter/material.dart';
class ProductSubCategories{

  final int id;
  final String label;


  ProductSubCategories({
    this.id,this.label
  });

  Map<String, dynamic> toMap() {
    return {

      'id':id,'label':label
    };
  }


  factory ProductSubCategories.fromJson(Map<String, dynamic> json){
    return ProductSubCategories(
        id:json['ID'],label:json['Label']
    );
  }
  @override
  String toString() {
    return 'ProductSubCategories{ id: $id, label: $label}';
  }


}