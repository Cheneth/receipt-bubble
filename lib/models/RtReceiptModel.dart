import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
import 'package:receipt_bubble/models/RtItemModel.dart';

class RtReceipt {
  
  List<String> users;
  String groupID;
  List items;
  num total;
  num tax;
  var dateCreated;

  RtReceipt(items, total, tax, userEmail, groupID){
    List newItemList = [];
    List<String> userEmailList = [userEmail];
    for(int i = 0; i < items.length; i++){
      newItemList.add(new RtItem(items[i].name, items[i].totalCost, items[i].unitCost, items[i].quantity));
    }
    this.items = newItemList;
    this.total = total;
    this.tax = tax;
    this.groupID = groupID;
    this.users = userEmailList;
    this.dateCreated = new DateTime.now();
  }

  // RtReceipt.fromSnapshot(DataSnapshot snapshot) :
  //   key = snapshot.key,
  //   total = snapshot.value["total"],
  //   tax = snapshot.value["tax"],
  //   groupID = snapshot.value["groupID"];
  // RtReceipt.fromJson(Map<String,dynamic> json)
  //   : groupID = json['groupID'],
  //     total=json['total'],
  //     tax=json['tax'],
  //     dateCreated=json['dateCreated'];



  Map<String, dynamic> toJson() {
    List jsonItems = items.map((item) {
      // print('hi');
      return item.toJson();
    }).toList();
    // print(getPrettyJSONString(jsonItems));
    // jsonItems = [items[0].toJson(), items[1].toJson()];
    return {
      "dateCreated": dateCreated,
      "groupID": groupID,
      "users": users,
      "tax": tax,
      "total": total,
      "items": jsonItems,
    };
  }

  String getPrettyJSONString(jsonObject){
    var encoder = new JsonEncoder.withIndent("     ");
    return encoder.convert(jsonObject);
  }
}