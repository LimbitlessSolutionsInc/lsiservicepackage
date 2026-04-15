import 'package:json_annotation/json_annotation.dart';

part 'data.g.dart'; 

/*
  This file uses serialization, so any changes made to it you need to run an update in the terminal 
  to update the data.g.dart file. 

  Once changes are made and the data.dart file is saved, run 
  this -> 'dart run build_runner build --delete-conflicting-outputs'

  it will update all the models and then you can continue without worrying :)
*/

@JsonSerializable()
class NewOrder {
  final String orderNumber;
  final String name;
  final String process;
  final String unit;
  final String type;
  final int quantity;
  final double rate;
  final double estimatedPrice;
  String filePath;
  String? fileData;
  final Map<String, dynamic> dates;
  final String journalTransferNumber;
  final String department;
  final String? imagePath;
  String status;
  final List<Map<String, dynamic>> comment;
  String? successMessage;
  bool cancelRequested;

  NewOrder({
    required this.orderNumber,
    required this.name,
    required this.process,
    required this.unit,
    required this.type,
    required this.quantity,
    required this.rate,
    required this.estimatedPrice,
    required this.filePath,
    this.fileData,
    required this.dates,
    required this.journalTransferNumber,
    required this.department,
    required this.status,
    required this.comment,
    this.successMessage,
    this.imagePath,
    required this.cancelRequested,
  });

  factory NewOrder.fromJson(Map<String, dynamic> json) => _$NewOrderFromJson(json); 
  Map<String, dynamic> toJson() => _$NewOrderToJson(this);

  int daysSinceSubmitted() {
    final date = DateTime.parse(dates['Submitted']);
    final now = DateTime.now();
    return now.difference(date).inDays;
  }

  // function to add data to the Map after it's creation
  void addDates(String key, dynamic value) {
    dates[key] = value;
  }
}

class Month {
  Month({
    required this.name,
    required this.days,
  });
  
  String name;
  int days;

    static Month getMonth(int monthNum, int year){
    Month thisMonth;
    if(monthNum == 0){monthNum = 12;}

    switch (monthNum) {
        case 1:
          thisMonth = Month(name: "Jan", days: 30); //31);
          break;
        case 2:
          thisMonth = Month(name: "Feb", days: (year%4 == 0)?29:28);
          break;
        case 3:
          thisMonth = Month(name: "Mar", days: 30); //31);
          break;
        case 4:
          thisMonth = Month(name: "Apr", days: 30);
          break;
        case 5:
          thisMonth = Month(name: "May", days: 30); //31);
          break;
        case 6:
          thisMonth = Month(name: "Jun", days: 30);
          break;
        case 7:
          thisMonth = Month(name: "Jul", days: 30); //31);
          break;
        case 8:
          thisMonth = Month(name: "Aug", days: 30); //31);
          break;
        case 9:
          thisMonth = Month(name: "Sep", days: 30);
          break;
        case 10:
          thisMonth = Month(name: "Oct", days: 30); //31);
          break;
        case 11:
          thisMonth = Month(name: "Nov", days: 30);
          break;
        case 12:
          thisMonth = Month(name: "Dec", days: 30); //31);
          break;
        default:
          thisMonth = Month(name: "", days: 1);
      }

    return thisMonth;
  }
}

