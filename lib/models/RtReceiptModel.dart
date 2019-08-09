import 'package:firebase_auth/firebase_auth.dart';
import 'package:receipt_bubble/models/RtItemModel.dart';

class RtReceipt {
  String key;
  // List<UserInfo> users;
  int groupID;
  // List items;
  num total;
  num tax;

  RtReceipt(items, total, tax){
    // List newItemList = [];
    // for(int i = 0; i < items.length; i++){
    //   newItemList.add(new RtItem(items[i].name, items[i].totalCost, items[i].unitCost, items[i].quantity));
    // }
    // this.items = newItemList;
    this.total = total;
    this.tax = tax;
  }

  RtReceipt.fromSnapshot(DataSnapshot snapshot) :
    key = snapshot.key,
    total = snapshot.value["total"],
    tax = snapshot.value["tax"],
    groupID = snapshot.value["groupID"];

  toJson() {
    return {
      "groupID": groupID,
      "tax": tax,
      "total": total,
    };
  }
}