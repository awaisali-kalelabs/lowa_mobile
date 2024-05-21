import 'package:flutter/material.dart';
class PreSellOutlets{

  final int outlet_id;
  final String outlet_name;
  final int day_number;
  final String owner;
  final String address;
  final String telephone;
  final String nfc_tag_id;
  final int visit_type;
  final String lat;
  final String lng;//accuracy
  final String accuracy;//accuracy
  final String area_label;
  final String sub_area_label;
  final int is_alternate_visible;
  final String pic_channel_id;
  final String channel_label;
  final String order_created_on_date;
  final String common_outlets_vpo_classifications;
  final String Visit;
  final String purchaser_name;
  final String purchaser_mobile_no;
  final String cache_contact_nic;
  final int IsGeoFence;
  final int Radius;
//				                                                                                                                                                                                                                                                                                                                   	/co.purchaser_name,co.purchaser_mobile_no,co.cache_contact_nic,

  PreSellOutlets( {this.outlet_id, this.outlet_name, this.day_number, this.owner,
      this.address, this.telephone, this.nfc_tag_id, this.visit_type, this.lat, this.lng, this.accuracy, this.area_label,
    this.sub_area_label, this.is_alternate_visible, this.pic_channel_id,this.channel_label,this.order_created_on_date,this.common_outlets_vpo_classifications,this.Visit,this.purchaser_name,this.purchaser_mobile_no,this.cache_contact_nic,   this.IsGeoFence,
    this.Radius,
      });

  Map<String, dynamic> toMap() {
    return {
      'outlet_id':outlet_id,
      'outlet_name':outlet_name,
      'day_number':day_number,
      'owner':owner,
      'address':address,
      'telephone':telephone,
      'nfc_tag_id':nfc_tag_id,
      'visit_type':visit_type,
      'lat':lat,
      'lng':lng,
      'area_label':area_label,
      'sub_area_label':sub_area_label,
      'is_alternate_visible':is_alternate_visible,
      'pic_channel_id':pic_channel_id,
      'channel_label':channel_label,
      'order_created_on_date':order_created_on_date,
      'common_outlets_vpo_classifications':common_outlets_vpo_classifications,
      'Visit':Visit,
      'purchaser_name':purchaser_name,
      'purchaser_mobile_no':purchaser_mobile_no,
      'cache_contact_nic':cache_contact_nic,
      'IsGeoFence': IsGeoFence,
      'Radius' : Radius,
      'accuracy' : accuracy,

    };
  }

  factory PreSellOutlets.fromJson(Map<String, dynamic> json){
    return PreSellOutlets(outlet_id:int.parse(json['OutletID']),outlet_name:json['OutletName'],address:json['Address'],
        day_number:int.parse(json['DayNumber']),owner:json['Owner'],telephone:json['Telepohone'],nfc_tag_id:json['NFCTagID'],visit_type:json['visit_type'],lat:json['lat'],lng:json['lng']
        ,area_label:json['AreaLabel'],sub_area_label:json['SubAreaLabel'], is_alternate_visible: json['is_alternate_visible'] , pic_channel_id: json['SUBChannelID'] , channel_label: json['SUBChannelLabel'], order_created_on_date: json['order_created_on_date'],common_outlets_vpo_classifications:json['common_outlets_vpo_classifications'],Visit:json['Visit'],purchaser_name:json['purchaser_name'],purchaser_mobile_no:json['purchaser_mobile_no'],cache_contact_nic:json['cache_contact_nic'],IsGeoFence: json['IsGeoFence'],
        Radius : json['Radius'], accuracy : json['accuracy'] );
  }

  @override
  String toString() {
   // return 'PreSellOutlets{outlet_id: $outlet_id, name: $name, address: $address, lat: $lat, lng: $lng, cache_contact_number: $cache_contact_number, net_amount: $net_amount, sale_invoice_id: $sale_invoice_id,dispatch_id:$dispatch_id,is_delivered:$is_delivered}';
  }


}