import 'package:flutter/material.dart';
class Products{

  final int product_id;
  final String product_label;
  final int package_id ;
  final String package_label;
  final int brand_id;
  final String brand_label ;
  final int sort_order;
  final int unit_per_case;
  final int lrb_type_id;

  Products({
    this.product_id,this.product_label, this.package_id, this.package_label,
      this.sort_order,
      this.brand_id, this.brand_label,  this.unit_per_case,this.lrb_type_id});

  Map<String, dynamic> toMap() {
    return {

      'product_id':product_id,'product_label':product_label,'package_id':package_id,'package_label':package_label,'sort_order':sort_order,
      'brand_id':brand_id,'brand_label':brand_label,'unit_per_case':unit_per_case,'lrb_type_id':lrb_type_id
    };
  }


  factory Products.fromJson(Map<String, dynamic> json){
    return Products(
        product_id:int.parse(json['ProductID']),product_label:json['Package']+" - "+json['Brand'],package_id:int.parse(json['PackageID']),package_label:json['Package'],
        sort_order:int.parse(json['SortOrder']), brand_id:int.parse(json['BrandID']),brand_label:json['Brand'],unit_per_case:int.parse(json['UnitPerCase']),lrb_type_id:int.parse(json['LrbTypeID'])
    );
  }
  @override
  String toString() {
    return 'Products{ product_id: $product_id, package_id: $package_id, package_label: $package_label, sort_order: $sort_order,  brand_id: $brand_id, brand_label: $brand_label, unit_per_case: $unit_per_case , lrb_type_id:$lrb_type_id';
  }


}