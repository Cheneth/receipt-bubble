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

class ConfirmHelper {
  static printText(VisionText visionText){

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
    for(WordBox box in mergedLines){
          print(box.text);
          print(box.vertices);
          print(box.boundingBox);
          // print(box.lineNum);
          // print(box.match);
    }
    print('-------------------------');
    combineBoundingPolygon(mergedLines);

    var finalLines = constructLineWithBoundingPolygon(mergedLines);

    for(String line in finalLines){
          print(line);
    }
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
      num threshold = h;
      print('HEIGHT:');
      print(h);
      points.add(mergedLines[i].vertices[1]);
      points.add(mergedLines[i].vertices[0]);
      List<num> topLine = getLineMesh(points, avgHeight, true);

      points = new List();

      points.add(mergedLines[i].vertices[2]);
      points.add(mergedLines[i].vertices[3]);
      List<num> bottomLine = getLineMesh(points, avgHeight, false);

      mergedLines[i].setBox([[topLine[0], topLine[2]-threshold], [topLine[1], topLine[3]-threshold], [bottomLine[1], bottomLine[3]+threshold], [bottomLine[0], bottomLine[2]+threshold]]);//top left corner, then clockwise
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