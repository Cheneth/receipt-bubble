import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:receipt_bubble/models/RtReceiptModel.dart';
import 'package:receipt_bubble/screens/scanning/confirm_scan_screen.dart';

class ReceiptSplit extends StatefulWidget {
  ReceiptSplit({Key key, this.userEmail, this.groupID}) : super(key: key);

  final String userEmail;
  final String groupID;
  _ReceiptSplitState createState() => _ReceiptSplitState();
}

class _ReceiptSplitState extends State<ReceiptSplit> {
  
  final formatCurrency = new NumberFormat.simpleCurrency();
  final db = Firestore.instance;
  RtReceipt receipt;

  getReceiptByGroup() async {
    var query = db.collection("receipts").where('groupID', isEqualTo: widget.groupID);
    QuerySnapshot snapshot = await query.getDocuments();
    try{
      print(getPrettyJSONString(snapshot.documents[0].data));
    }catch(err){
      print(err);
      print('Database error');
    }
  }

  String getPrettyJSONString(jsonObject){
    var encoder = new JsonEncoder.withIndent("     ");
    return encoder.convert(jsonObject);
  }

  @override
  void initState() { 
    super.initState();
    // getReceiptByGroup();
  }

  num _calcYourTotal(List items){
    num total = 0;
    String email = widget.userEmail;
    for(var i in items){
      if(i['userEmails'] != null && i['userEmails'].contains(email)){
        total+=(i['totalCost']/i['userEmails'].length);
      }
    }
    return total;
  }

  String _userArrayToString(List list){
    String display = "";
    if(list == null || list.length == 0){
      return "";
    }
    for(int i = 0; i < list.length; i++){
      if(i == 0){//first one
        display = display + list[i];
      }else{
        display = display + ", " + list[i];
      } 
    }
    return display;
  }

  Widget _buildListItem(BuildContext context, item, DocumentSnapshot document, int index){
    // print('hi');
    // print(document.data['items']);
    return Card(
            child: ListTile(
            title: Text('${item['name'] != '' ? item['name'] : 'Unknown Item'}'),
            subtitle: Text('${_userArrayToString(item['userEmails'])}'),
            trailing: Text('${formatCurrency.format(item['totalCost'])}'),
            onTap: (){
              Firestore.instance.runTransaction((transaction) async {
                DocumentSnapshot freshSnap =
                  await transaction.get(document.reference);
                // List items = ['ethan190c@gmail.com'];
                List items = freshSnap.data['items'];
                var itemEmails = new List.from(items[index]['userEmails'] != null ? items[index]['userEmails'] : []);
                if(itemEmails == null){
                  itemEmails = [widget.userEmail];
                }else if(itemEmails.contains(widget.userEmail)){
                  itemEmails.remove(widget.userEmail);
                }else{
                  itemEmails.add(widget.userEmail);
                }
                items[index]['userEmails'] = itemEmails;
                 
                await transaction.update(freshSnap.reference, {
                    'items' : items,
                });
              });  
            },
          ),
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: StreamBuilder(
        stream: Firestore.instance.collection('receipts').where('groupID', isEqualTo: widget.groupID).snapshots(),
        builder: (context, snapshot){
          if(!snapshot.hasData) return const Text('Loading...');
          var receiptDoc = snapshot.data.documents[0].data;
          List receiptItems = receiptDoc['items'];
          num receiptTotal = receiptDoc['total'];
          num receiptTax = receiptDoc['tax'];
          print(receiptDoc);
          print(receiptItems);
          // return Text('yes');
          return Column(children: [
            Container(
              color: Colors.grey[100],
                child: ListTile(
                title: Text('Group ID'),
                trailing: Text('${widget.groupID}'),
              ),
            ),
              Expanded(child: ListView.builder(
                padding: const EdgeInsets.all(3.0),
                itemCount: receiptDoc['items'].length,
                itemBuilder: (BuildContext context, int i) {
                  return _buildListItem(context, receiptItems[i], snapshot.data.documents[0], i);
                  
                } 
              ),
            ),
            // Divider(color: Colors.grey,),
            Container(
              height: 50,
              color: Colors.grey[300],
              child: ListTile(
                title: Text('Tax'),
                trailing: Text('${formatCurrency.format(receiptTax)}'),
              ),
            ),
            Container(
              height: 50,
              color: Colors.grey[300],
                child: ListTile(
                title: Text('Total'),
                trailing: Text('${formatCurrency.format(receiptTotal)}'),
              ),
            ),
            Container(
              height: 50,
              color: Colors.grey[300],
                child: ListTile(
                title: Text('Your Total'),
                trailing: Text('${formatCurrency.format(_calcYourTotal(receiptItems))}'),
              ),
            ),
            Center(
              child: RaisedButton(
                color: Colors.green,
                onPressed: () {},
                child: Text(
                  'Confirm'
                ),
              ),
            ),
            Container(
              height: 10.0,
            ),
              

            ],);
        },
      
      )
    
    );
  }
}