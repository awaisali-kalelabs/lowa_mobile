import 'package:flutter/material.dart';
class InventorySalesDispatchAdjustedProducts{


  final int dispatch_id ;
  final int outlet_id ;
  final String product_id;
  final String raw_cases;
  final String units;
  final int total_units;
  final int liquid_in_ml;
  final int invoice_id ;
  final int is_promotion ;
  final int promotion_id ;
  final int mobile_id;
  final String units_per_sku;
  final String raw_cases_original;
  final String units_original;

  InventorySalesDispatchAdjustedProducts({this.units_per_sku, this.dispatch_id, this.outlet_id,
      this.product_id, this.raw_cases, this.units, this.total_units,
      this.liquid_in_ml, this.invoice_id, this.is_promotion, this.promotion_id,this.mobile_id,this.raw_cases_original,this.units_original});

  Map<String, dynamic> toMap() {
    return {
      'dispatch_id':dispatch_id,
      'outlet_id':outlet_id,
      'product_id':product_id,
      'raw_cases':raw_cases,
      'units':units,
      'total_units':total_units,
      'liquid_in_ml':liquid_in_ml,
      'invoice_id':invoice_id,
      'is_promotion':is_promotion,
      'promotion_id':promotion_id,
      'mobile_id':mobile_id,
      'raw_cases_original':raw_cases_original,
      'units_original':units_original,
      'units_per_sku':units_per_sku
    };
  }

  factory InventorySalesDispatchAdjustedProducts.fromJson(Map<String, dynamic> json){
    return InventorySalesDispatchAdjustedProducts(
        dispatch_id:json['dispatch_id'],
        outlet_id:json['outlet_id'],
        product_id:json['product_id'],
        raw_cases:json['raw_cases'],
        units:json['units'],
        total_units:json['total_units'],
        liquid_in_ml:json['liquid_in_ml'],
        invoice_id:json['invoice_id'],
        is_promotion:json['is_promotion'],
        promotion_id:json['promotion_id'],
        mobile_id:json['mobile_id'],
        raw_cases_original:json['raw_cases_original'],
        units_original:json['units_original'],
        units_per_sku:json['units_per_sku']
    );
  }

  @override
  String toString() {
    return 'InventorySalesDispatchAdjustedProducts{dispatch_id: $dispatch_id, outlet_id: $outlet_id, product_id: $product_id, raw_cases: $raw_cases, units: $units, total_units: $total_units, liquid_in_ml: $liquid_in_ml, invoice_id: $invoice_id, is_promotion: $is_promotion, promotion_id: $promotion_id, mobile_id: $mobile_id,units_per_sku:$units_per_sku}';
  }


}