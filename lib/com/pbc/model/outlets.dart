import 'package:flutter/material.dart';

class Outlets {
  final int id;
  final String name;
  final int type_id;
  final String address;
  final int region_id;
  final int distributor_id;
  final double lat;
  final double lng;
  final int is_active;
  final String created_on;
  final int created_by;
  final String deactivated_on;
  final int deactivated_by;
  final int channel_id;
  final int category_id;
  final String updated_on;
  final int updated_by;
  final int nfc_tag_id;
  final int cache_distributor_id;
  final String cache_distributor_name;
  final String cache_contact_name;
  final String cache_contact_number;
  final String cache_contact_nic;
  final int cache_snd_id;
  final int cache_rsm_id;
  final int cache_tdm_id;
  final int cache_orderbooker_id;
  final int cache_beat_plan_id;
  final int sap_customer_id;
  final int segment_id;
  final double agreed_daily_average_sales;
  final int vpo_classifications_id;
  final int kpo_request_id;
  final String account_number_bank_alfalah;
  final int discount_disbursement_id;
  final int pic_channel_id;
  final double accuracy;
  final int census_sub_channel_id;
  final int wallet_id_bank_alfalah;

  Outlets(
      {this.id,
      this.name,
      this.type_id,
      this.address,
      this.region_id,
      this.distributor_id,
      this.lat,
      this.lng,
      this.is_active,
      this.created_on,
      this.created_by,
      this.deactivated_on,
      this.deactivated_by,
      this.channel_id,
      this.category_id,
      this.updated_on,
      this.updated_by,
      this.nfc_tag_id,
      this.cache_distributor_id,
      this.cache_distributor_name,
      this.cache_contact_name,
      this.cache_contact_number,
      this.cache_contact_nic,
      this.cache_snd_id,
      this.cache_rsm_id,
      this.cache_tdm_id,
      this.cache_orderbooker_id,
      this.cache_beat_plan_id,
      this.sap_customer_id,
      this.segment_id,
      this.agreed_daily_average_sales,
      this.vpo_classifications_id,
      this.kpo_request_id,
      this.account_number_bank_alfalah,
      this.discount_disbursement_id,
      this.pic_channel_id,
      this.accuracy,
      this.census_sub_channel_id,
      this.wallet_id_bank_alfalah});

  Map<String, dynamic> toMap() {
    return {
    'id':id,
    'name':name,
    'type_id':type_id,
    'address':address,
    'region_id':region_id,
    'distributor_id':distributor_id,
    'lat':lat,
    'lng':lng,
    'is_active':is_active,
    'created_on':created_on,
    'created_by':created_by,
    'deactivated_on':deactivated_on,
    'deactivated_by':deactivated_by,
    'channel_id':channel_id,
    'category_id':category_id,
    'updated_on':updated_on,
    'updated_by':updated_by,
    'nfc_tag_id':nfc_tag_id,
    'cache_distributor_id':cache_distributor_id,
    'cache_distributor_name':cache_distributor_name,
    'cache_contact_name':cache_contact_name,
    'cache_contact_number':cache_contact_number,
    'cache_contact_nic':cache_contact_nic,
    'cache_snd_id':cache_snd_id,
    'cache_rsm_id':cache_rsm_id,
    'cache_tdm_id':cache_tdm_id,
    'cache_orderbooker_id':cache_orderbooker_id,
    'cache_beat_plan_id':cache_beat_plan_id,
    'sap_customer_id':sap_customer_id,
    'segment_id':segment_id,
    'agreed_daily_average_sales':agreed_daily_average_sales,
    'vpo_classifications_id':vpo_classifications_id,
    'kpo_request_id':kpo_request_id,
    'account_number_bank_alfalah':account_number_bank_alfalah,
    'discount_disbursement_id':discount_disbursement_id,
    'pic_channel_id':pic_channel_id,
    'accuracy':accuracy,
    'census_sub_channel_id':census_sub_channel_id,
    'wallet_id_bank_alfalah':wallet_id_bank_alfalah
    };
  }

  factory Outlets.fromJson(Map<String, dynamic> json) {
    return Outlets(
        id:json['id'],
        name:json['name'],
        type_id:json['type_id'],
        address:json['address'],
        region_id:json['region_id'],
        distributor_id:json['distributor_id'],
        lat:json['lat'],
        lng:json['lng'],
        is_active:json['is_active'],
        created_on:json['created_on'],
        created_by:json['created_by'],
        deactivated_on:json['deactivated_on'],
        deactivated_by:json['deactivated_by'],
        channel_id:json['channel_id'],
        category_id:json['category_id'],
        updated_on:json['updated_on'],
        updated_by:json['updated_by'],
        nfc_tag_id:json['nfc_tag_id'],
        cache_distributor_id:json['cache_distributor_id'],
        cache_distributor_name:json['cache_distributor_name'],
        cache_contact_name:json['cache_contact_name'],
        cache_contact_number:json['cache_contact_number'],
        cache_contact_nic:json['cache_contact_nic'],
        cache_snd_id:json['cache_snd_id'],
        cache_rsm_id:json['cache_rsm_id'],
        cache_tdm_id:json['cache_tdm_id'],
        cache_orderbooker_id:json['cache_orderbooker_id'],
        cache_beat_plan_id:json['cache_beat_plan_id'],
        sap_customer_id:json['sap_customer_id'],
        segment_id:json['segment_id'],
        agreed_daily_average_sales:json['agreed_daily_average_sales'],
        vpo_classifications_id:json['vpo_classifications_id'],
        kpo_request_id:json['kpo_request_id'],
        account_number_bank_alfalah:json['account_number_bank_alfalah'],
        discount_disbursement_id:json['discount_disbursement_id'],
        pic_channel_id:json['pic_channel_id'],
        accuracy:json['accuracy'],
        census_sub_channel_id:json['census_sub_channel_id'],
        wallet_id_bank_alfalah:json['wallet_id_bank_alfalah']);
  }

  @override
  String toString() {
    return 'Outlets{id: $id, name: $name, type_id: $type_id, address: $address, region_id: $region_id, distributor_id: $distributor_id, lat: $lat, lng: $lng, is_active: $is_active, created_on: $created_on, created_by: $created_by, deactivated_on: $deactivated_on, deactivated_by: $deactivated_by, channel_id: $channel_id, category_id: $category_id, updated_on: $updated_on, updated_by: $updated_by, nfc_tag_id: $nfc_tag_id, cache_distributor_id: $cache_distributor_id, cache_distributor_name: $cache_distributor_name, cache_contact_name: $cache_contact_name, cache_contact_number: $cache_contact_number, cache_contact_nic: $cache_contact_nic, cache_snd_id: $cache_snd_id, cache_rsm_id: $cache_rsm_id, cache_tdm_id: $cache_tdm_id, cache_orderbooker_id: $cache_orderbooker_id, cache_beat_plan_id: $cache_beat_plan_id, sap_customer_id: $sap_customer_id, segment_id: $segment_id, agreed_daily_average_sales: $agreed_daily_average_sales, vpo_classifications_id: $vpo_classifications_id, kpo_request_id: $kpo_request_id, account_number_bank_alfalah: $account_number_bank_alfalah, discount_disbursement_id: $discount_disbursement_id, pic_channel_id: $pic_channel_id, accuracy: $accuracy, census_sub_channel_id: $census_sub_channel_id, wallet_id_bank_alfalah: $wallet_id_bank_alfalah}';
  }

}
