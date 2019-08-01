import 'dart:collection';
import 'dart:io';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'dart:math';
import 'package:poly/poly.dart';

import 'package:flutter/gestures.dart';

// import 'package:flutter/gestures.dart';


class WordBox{
  String text;
  List<List<num>> vertices;
  List<List<num>> boundingBox;
  num lineNum;
  List match = [];
  bool matched = false;


  WordBox(String text, List<List<num>> vertices){
    this.text = text;
    this.vertices = vertices;
  }

  setBox(List<List<num>> boundingBox){
    this.boundingBox = boundingBox;
  }
  pushMatch(HashMap<String, int> match){
    this.match.add(match);
    // print('ADDED');
  }
  setlineNum(num lineNum){
    this.lineNum = lineNum;
  }
  setMatched(bool matched){
    this.matched = matched;
  }
}

class Item {
  String name;
  num totalCost;
  num unitCost;
  int quantity;

  Item(String name, num totalCost, num unitCost, int quantity){
    this.name = name;
    this.totalCost = totalCost;
    this.unitCost = unitCost;
    this.quantity = quantity;
  }
}
class ReceiptInfo {
  List items;
  num finalTotal;
  num finalTax;

  ReceiptInfo(List items, num finalTotal, num finalTax){
    this.items = items;
    this.finalTotal = finalTotal;
    this.finalTax = finalTax;
  }
}

class ConfirmHelper {

  static num findSubtotal(List lines){

    RegExp subtotalExp = new RegExp(r"[Ss][Uu][Bb]\s?[Tt][Oo][Tt][Aa][Ll]");
     RegExp moneyExp = new RegExp(r"([0-9]{1,3}\.[0-9]{2})");


    for(int i = lines.length-1; i >= 0; i--){
        if(subtotalExp.hasMatch(lines[i]) && moneyExp.hasMatch(lines[i])){
            num lineCost = num.parse(moneyExp.stringMatch(lines[i]).toString());
            return lineCost;
        }
    }
    return -1;
  }

  static getItems(List lines){
    //variables to fill
    num scanTotal = 0;
    num subtotal = 0;
    num calcTax = 0;
    num scanTax = 0;
    List items = new List();
    num calcTotal = 0;
    //final variables
    num finalTotal = 0;
    num finalTax = 0;

    //REGEX
    RegExp moneyExp = new RegExp(r"([0-9]{1,3}\.[0-9]{2})");
    RegExp totalExp = new RegExp(r"([Tt][Oo][Tt][Aa][Ll])");
    RegExp taxExp = new RegExp(r"([Tt][Aa][Xx])|([Hh][Ss][Tt])|([Gg][Ss][Tt])");
    RegExp quantityExp = new RegExp(r"^([0-9]){1,3}\s|[(]([0-9]){1,3}");
   
    // RegExp totalExp = new RegExp(r"([Tt][Oo][Tt][Aa][Ll])");


    //1. GET TOTAL (largest number)
    num totalLine = 0;

    for(int i = 0; i < lines.length; i++){
            if(moneyExp.hasMatch(lines[i])){
                num lineCost = num.parse(moneyExp.stringMatch(lines[i]).toString());
                // console.log(lineCost)
                if(lineCost > scanTotal){
                    totalLine = i;
                    scanTotal = lineCost;
                }
        }
    }
    print('SCAN TOTAL: ' + scanTotal.toString());
    while(lines.length > totalLine+1){
            lines.removeLast();
    }

    //2. GET SUBTOTAL
    subtotal = findSubtotal(lines);

    //remove lines with the word total in them (both total and subtotal)
    for(int i = lines.length-1; i >= 0; i--){
        if(totalExp.hasMatch(lines[i])){
            lines.removeAt(i);
        }
    }
    //3. FIND TAX/TIP if subtotal is less than the total
    //  FIND TAX from scanning the text and
    if(subtotal != -1 && subtotal < scanTotal){
            calcTax = scanTotal-subtotal;
    }
    //  FIND TAX from scanning the text and remove lines with tax in them
    for(int i = lines.length-1; i >= 0; i--){
        if(taxExp.hasMatch(lines[i]) && moneyExp.hasMatch(lines[i])){
            num lineCost = num.parse(moneyExp.stringMatch(lines[i]).toString());
            scanTax += lineCost;
            lines.removeAt(i);
        }
    }

    //4.FIND ITEMS AND QUANTITY
    for(int i = 0; i < lines.length; i++){
      int quantity = 0;
        if(moneyExp.hasMatch(lines[i]) && num.parse(moneyExp.stringMatch(lines[i]).toString()) < scanTotal){
            var rawCost = moneyExp.stringMatch(lines[i]).toString();
            var lineCost = num.parse(rawCost);
            String scannedQuantity = quantityExp.stringMatch(lines[i]);
            // console.log(lines[i], ' ' , quantity)
            if(scannedQuantity != null){
                RegExp subQuantityExp = new RegExp(r"([0-9]){1,3}");
                String parseQuantity = subQuantityExp.stringMatch(scannedQuantity);//in case quanitity has bracket ex. (3)
                quantity = int.parse(parseQuantity);
                if(quantity > 1){
                    lineCost /= quantity;
                }
            }else{
                quantity = 1;
            }
            
            if(calcTotal + lineCost <= scanTotal){
                calcTotal += lineCost;
                lines[i] = lines[i].replaceAll(rawCost, ''); // remove cost from line
                // lines[i] = lines[i].replaceAll(quantity, '')
                lines[i] = lines[i].trim();
                items.add(new Item(lines[i], lineCost, lineCost/quantity, quantity));
            }
      
            
            
        }
    }

    //finding which final values to use
    finalTotal = scanTotal;
    finalTax = scanTax;
    // if(scanTotal == (subtotal + scanTax)){
    //         finalTax = scanTax;
    //         finalTotal = scanTotal;
    //     }else if(calcTotal == (subtotal + scanTax)){
    //         finalTax = scanTax;
    //         finalTotal = calcTotal;
    //     }else if(calcTotal == (subtotal + calcTax)){
    //         finalTax = calcTax;
    //         finalTotal = calcTotal;
    //     }else{
    //         finalTax = calcTax;
    //         finalTotal = scanTotal;
    //     } 
     return (new ReceiptInfo(items, finalTotal, finalTax));
  }

  static getText(VisionText visionText){

    List<WordBox> mergedLines = [];
    for(TextBlock block in visionText.blocks){
      for(TextLine line in block.lines){
        List<List<num>> tempVertices=[];
        String words = "";
        // print(line.cornerPoints[0].dx);
        for(Offset offset in line.cornerPoints){
          tempVertices.add([offset.dx, offset.dy]);
        }
        for(TextElement element in line.elements){
          words = words + " " + element.text;
        }
        mergedLines.add(new WordBox(words, tempVertices));
        
      }
    }

    getBoundingPolygon(mergedLines);
    // for(WordBox box in mergedLines){
    //       print(box.text);
    //       print(box.vertices);
    //       print(box.boundingBox);
    //       // print(box.lineNum);
    //       // print(box.match);
    // }
    print('-------------------------');
    combineBoundingPolygon(mergedLines);

    var finalLines = constructLineWithBoundingPolygon(mergedLines);

    for(String line in finalLines){
          print(line);
    }

    return finalLines;
    //
    // getBoundingPolygon(mergedLines);
  }

  static constructLineWithBoundingPolygon(List<WordBox> mergedLines){
    var finalLines = new List();
    // var unmatchedLines = new List();


    for(int i = 0; i < mergedLines.length; i++){
      if(mergedLines[i].matched == false){
        if(mergedLines[i].match.length == 0){
          finalLines.add(mergedLines[i].text);
        }else{
          finalLines.add(arrangeWordsInOrder(mergedLines, i));
        }
      }
    }
    // print('hello');
    // print(finalLines);

    return finalLines;
  }
  static String arrangeWordsInOrder(List<WordBox> mergedLines, int i){
    String mergedLine = '';
    var line = mergedLines[i].match;
    for(int j = 0; j < line.length; j++){
      int index = line[j]['matchLineNum'];
      String matchedWordForLine = mergedLines[index].text;
      //order by top left x vertex
      num mainX = mergedLines[i].vertices[0][0];
      num compareX = mergedLines[index].vertices[0][0];
      if(compareX > mainX){
        mergedLine = mergedLines[i].text + ' ' + matchedWordForLine;
      }else{
        mergedLine = matchedWordForLine + ' ' + mergedLines[i].text;
      }
      
    }
    return mergedLine;

  }

  static getBoundingPolygon(List<WordBox> mergedLines){
    for(int i = 0; i < mergedLines.length; i++){
      //List<List<num>> points;
      var points = new List();

      num h1 = (mergedLines[i].vertices[0][1] - mergedLines[i].vertices[3][1]).abs();
      num h2 = (mergedLines[i].vertices[1][1] - mergedLines[i].vertices[2][1]).abs();
      
      num h = max(h1, h2);
      num avgHeight = h*0.6;
      num threshold = h*1;
      // print('HEIGHT:');
      // print(h);
      points.add(mergedLines[i].vertices[1]);
      points.add(mergedLines[i].vertices[0]);
      List<num> topLine = getLineMesh(points, avgHeight, true);

      points = new List();

      points.add(mergedLines[i].vertices[2]);
      points.add(mergedLines[i].vertices[3]);
      List<num> bottomLine = getLineMesh(points, avgHeight, false);

      mergedLines[i].setBox([[topLine[0], topLine[2]-threshold], [topLine[1], topLine[3]-threshold], [bottomLine[1], bottomLine[3]+threshold], [bottomLine[0], bottomLine[2]+threshold]]);//top left corner, then clockwise
      // mergedLines[i].setBox([[topLine[0], topLine[2]], [topLine[1], topLine[3]], [bottomLine[1], bottomLine[3]], [bottomLine[0], bottomLine[2]]]);//top left corner, then clockwise

      mergedLines[i].setlineNum(i);
      
    }
  }

  static combineBoundingPolygon(List<WordBox> mergedLines){
      for(int i = 0; i < mergedLines.length; i++){
        // var boundingBox = mergedLines[i].boundingBox;
        for(int k = i; k < mergedLines.length; k++){
          if(k != i && mergedLines[k].matched == false){
            int insideCount = 0;
            for(int j = 0; j < 4; j++){
              var coordinate = mergedLines[k].vertices[j];
              
              Polygon box = toPolyFromListOfList(mergedLines[i].boundingBox);
              // toPoint(coordinate);
              // print('COORDINATE:');
              // print(coordinate);
              // print('BOX');
              // print(mergedLines[i].boundingBox);
              if(box.contains(coordinate[0], coordinate[1])){
                // print('INSIDE');
                insideCount++;
              }
            }
            // print('OUTSIDE');
            if(insideCount == 4){//all vertices are inside the bounding box
            // print('inside');
              //match array
              //first element is matchCount
              //second element is matchLineNum
              print('MATCH');
              print(mergedLines[i].text);
              print(mergedLines[k].text);
              print('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
              var match = new HashMap<String, int>();
              match['matchCount'] = insideCount;
              match['matchLineNum'] = k;
              mergedLines[i].pushMatch(match);
              mergedLines[k].setMatched(true);
            }
          }
        }
      }
  }
  

  static List<num> getLineMesh(List p, avgHeight, bool isTopLine){
    if(isTopLine){//expand the boundingBox
      p[1][1] += avgHeight;
      p[0][1] += avgHeight;
    }else{
      p[1][1] -= avgHeight;
      p[0][1] -= avgHeight;
    }
    num xDiff = (p[1][0] - p[0][0]);
    num yDiff = (p[1][1] - p[0][1]);
    
    num gradient = yDiff / xDiff;//if gradient is 0, the line is flat
    // print('GRADIENT:');
    // print(xDiff);
    // print(yDiff);
    // print(gradient);
    num xThreshMin = 1; //min width of the image
    num xThreshMax = 3000;

    num yMin = 0;
    num yMax = 0;

    if(gradient == 0){//if line is flat
      //line will be flat
      // print('FLAT');
      yMin = p[0][1];
      yMax = p[0][1];
    }else{//there will be variance in y
      yMin = p[0][1] - (gradient*(p[0][0] - xThreshMin));
      yMax = p[0][1] + (gradient*(p[0][0] + xThreshMax));
    }
      // print([xThreshMin, xThreshMax, yMin, yMax]);
    return [xThreshMin, xThreshMax, yMin, yMax];
    
  }
}