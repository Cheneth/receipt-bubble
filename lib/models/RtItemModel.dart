import 'package:firebase_auth/firebase_auth.dart';

class RtItem {
  String name;
  num totalCost;
  num unitCost;
  int quantity;
  List<String> userEmails;
  

  RtItem(String name, num totalCost, num unitCost, int quantity){
    this.name = name;
    this.totalCost = totalCost;
    this.unitCost = unitCost;
    this.quantity = quantity;
  }
}