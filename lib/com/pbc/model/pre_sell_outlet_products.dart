import 'package:flutter/material.dart';
class PreSellOutletProducts{

  final String package_label;
  final String brand_label;
  final int raw_cases;
  final int units;
  final double rate_raw_cases;
  final double rate_units;
  final double amount_raw_cases;
  final double amount_units;
  final double wh_tax_amount;
  final double net_amount;
  final int product_id;
  final int unit_per_sku;
  final int sale_invoice_id;



  PreSellOutletProducts({this.package_label, this.brand_label, this.raw_cases,
      this.units, this.rate_raw_cases, this.rate_units, this.amount_raw_cases,
      this.amount_units, this.wh_tax_amount, this.net_amount, this.product_id,
      this.unit_per_sku,this.sale_invoice_id});

  Map<String, dynamic> toMap() {
    return {
      'package_label':package_label,
      'brand_label':brand_label,

      'raw_cases':raw_cases,
      'units':units,
      'rate_raw_cases':rate_raw_cases,
      'rate_units':rate_units,
      'amount_raw_cases':amount_raw_cases,
      'amount_units':amount_units,
      'wh_tax_amount':wh_tax_amount,
      'net_amount':net_amount,
      'product_id':product_id,
      'unit_per_sku':unit_per_sku,
      'sale_invoice_id':sale_invoice_id
    };
  }

  factory PreSellOutletProducts.fromJson(Map<String, dynamic> json){
    return PreSellOutletProducts(package_label:json['package_label'],
        brand_label:json['brand_label'],

        raw_cases:json['raw_cases'],
        units:json['units'],
        rate_raw_cases:json['rate_raw_cases'],
        rate_units:json['rate_units'],
        amount_raw_cases:json['amount_raw_cases'],
        amount_units:json['amount_units'],
        wh_tax_amount:json['wh_tax_amount'],
        net_amount:json['net_amount'],
        product_id:json['product_id'],
        unit_per_sku:json['unit_per_sku'],
        sale_invoice_id:json['sale_invoice_id']);
  }

  @override
  String toString() {
    return 'PreSellOutletProducts{package_label: $package_label, brand_label: $brand_label, raw_cases: $raw_cases, units: $units, rate_raw_cases: $rate_raw_cases, rate_units: $rate_units, amount_raw_cases: $amount_raw_cases, amount_units: $amount_units, wh_tax_amount: $wh_tax_amount, net_amount: $net_amount, product_id: $product_id, unit_per_sku: $unit_per_sku,sale_invoice_id:$sale_invoice_id}';
  }


}