import 'package:flutter/material.dart';
class OutletProductsAlternativePrices{


  final int product_id;
  final int package_id ;
  final String package_label;
  final int brand_id;
  final String brand_label ;
  final double raw_case_price;
  final double unit_price;
  final double liquid_in_ml;


  OutletProductsAlternativePrices({
    this.product_id,this.package_id,this.package_label,this.brand_id, this.brand_label,this.raw_case_price,this.unit_price,this.liquid_in_ml
  });

  Map<String, dynamic> toMap() {
    return {

      'product_id':product_id,'package_id':package_id,'package_label':package_label,'brand_id':brand_id,'brand_label':brand_label,'raw_case_price':raw_case_price,'unit_price':unit_price,'liquid_in_ml':liquid_in_ml

    };
  }



  factory OutletProductsAlternativePrices.fromJson(Map<String, dynamic> json){
    return OutletProductsAlternativePrices(
        product_id:int.parse(json['ProductID']),package_id:int.parse(json['PackageID']),package_label:(json['PackageLabel']),brand_id:int.parse(json['BrandID']),brand_label:json['BrandLabel'],raw_case_price:double.parse(json['RawCasePrice']),unit_price:double.parse(json['UnitPrice']),liquid_in_ml:double.parse(json['LiquidInML'])
    );
  }
  @override
  String toString() {
    return 'OutletProductsPrices{ product_id: $product_id, package_id: $package_id, package_label: $package_label, brand_id: $brand_id,  brand_label: $brand_label ,raw_case_price:$raw_case_price,unit_price:$unit_price,liquid_in_ml:$liquid_in_ml}';
  }


}