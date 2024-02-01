import 'package:flutter/material.dart';
class Products{
  final int category_id;
  final String category_label;
  final int sap_code ;
  final int product_id;
  final int package_id ;
  final String package_label;
  final int package_sort_order;
  final int liquid_in_ml  ;
  final String conversion_rate_in_ml  ;
  final int brand_id;
  final String brand_label ;
  final int unit_per_sku ;
  final int is_visible ;
  final int type_id ;
  final int ssrb_type_id ;
  final int lrb_type_id ;
  final int is_other_brand;

  Products({this.category_id, this.category_label, this.sap_code,
      this.product_id, this.package_id, this.package_label,
      this.package_sort_order, this.liquid_in_ml, this.conversion_rate_in_ml,
      this.brand_id, this.brand_label, this.unit_per_sku, this.is_visible,
      this.type_id, this.ssrb_type_id, this.lrb_type_id, this.is_other_brand});

  Map<String, dynamic> toMap() {
    return {
      'category_id':category_id,'category_label':category_label,'sap_code':sap_code,
      'product_id':product_id,'package_id':package_id,'package_label':package_label,
      'package_sort_order':package_sort_order,'liquid_in_ml':liquid_in_ml,'conversion_rate_in_ml':conversion_rate_in_ml,
      'brand_id':brand_id,'brand_label':brand_label,'unit_per_sku':unit_per_sku,'is_visible':is_visible,
      'type_id':type_id,'ssrb_type_id':ssrb_type_id,'lrb_type_id':lrb_type_id,'is_other_brand':is_other_brand
    };
  }

  factory Products.fromJson(Map<String, dynamic> json){
    return Products(category_id:json['category_id'],category_label:json['category_label'],sap_code:json['sap_code'],
        product_id:json['product_id'],package_id:json['package_id'],package_label:json['package_label'],
        package_sort_order:json['package_sort_order'],liquid_in_ml:json['liquid_in_ml'],conversion_rate_in_ml:json['conversion_rate_in_ml'],
        brand_id:json['brand_id'],brand_label:json['brand_label'],unit_per_sku:json['unit_per_sku'],is_visible:json['is_visible'],
        type_id:json['type_id'],ssrb_type_id:json['ssrb_type_id'],lrb_type_id:json['lrb_type_id'],is_other_brand:json['is_other_brand']
    );
  }
  @override
  String toString() {
    return 'Products{category_id: $category_id, category_label: $category_label, sap_code: $sap_code, product_id: $product_id, package_id: $package_id, package_label: $package_label, package_sort_order: $package_sort_order, liquid_in_ml: $liquid_in_ml, conversion_rate_in_ml: $conversion_rate_in_ml, brand_id: $brand_id, brand_label: $brand_label, unit_per_sku: $unit_per_sku, is_visible: $is_visible, type_id: $type_id, ssrb_type_id: $ssrb_type_id, lrb_type_id: $lrb_type_id, is_other_brand: $is_other_brand}';
  }


}