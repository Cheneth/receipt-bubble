
import 'package:firebase_database/firebase_database.dart';

class TestModel{
  String key;
  int testNumber;
  String userId;

  TestModel(this.testNumber, this.userId);

  TestModel.fromSnapShot(DataSnapshot snapshot) :
    key = snapshot.key,
    testNumber = snapshot.value["testNumber"],
    userId = snapshot.value["userId"];
  
  toJson() {
    return {
      "testNumber": testNumber,
      "userId": userId,
    };
  }

}