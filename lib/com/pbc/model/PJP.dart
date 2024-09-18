import 'package:flutter/material.dart';

class PJP{
  final String PJPID;
  final String PJPName;
  PJP({this.PJPID, this.PJPName});

  Map<String, dynamic> toMap() {
    return {
      'PJPID':PJPID,
      'PJPName':PJPName

    };
  }

  factory PJP.fromJson(Map<String, dynamic> json){
    return PJP(PJPID:json['PJPID'],PJPName:json['PJPName']);
  }

  @override
  String toString() {
    return 'PJPList{PJPID: $PJPID, PJPName: $PJPName}';
  }

}