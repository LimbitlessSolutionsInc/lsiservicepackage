class NewOrder {
  final String orderNumber;
  final String name;
  final String process;
  final String unit;
  final String type;
  final int quantity;
  final double rate;
  final double estimatedPrice;
  final String filePath;
  final String dateSubmitted;
  final String journalTransferNumber;
  final String department;
  final String? imagePath;
  String status;
  String comment;
  String? successMessage;

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
    required this.dateSubmitted,
    required this.journalTransferNumber,
    required this.department,
    required this.status,
    required this.comment,
    this.successMessage,
    this.imagePath,
  });

  factory NewOrder.fromJson(Map<String, dynamic> json) {
    return NewOrder(
      orderNumber: json['orderNumber'],
      name: json['name'],
      process: json['process'],
      unit: json['unit'],
      type: json['type'],
      quantity: json['quantity'],
      rate: (json['rate'] as num).toDouble(),
      estimatedPrice: (json['estimatedPrice'] as num).toDouble(),
      filePath: json['filePath'],
      dateSubmitted: json['dateSubmitted'],
      journalTransferNumber: json['journalTransferNumber'],
      department: json['department'],
      status: json['status'],
      comment: json['comment'] ?? '', 

    );
  }
  int daysSinceSubmitted() {
    final date = DateTime.parse(dateSubmitted);
    final now = DateTime.now();
    return now.difference(date).inDays;
  }

  Map<String, dynamic> toJson() {
    return {
      'orderNumber': orderNumber,
      'name': name,
      'process': process,
      'unit': unit,
      'type': type,
      'quantity': quantity,
      'rate': rate,
      'estimatedPrice': estimatedPrice,
      'filePath': filePath,
      'dateSubmitted': dateSubmitted,
      'journalTransferNumber': journalTransferNumber,
      'department': department,
      'status': status,
      'comment': comment,
      'imagePath': imagePath,
    };
  }
}


const String orderJson = '''
[
  {
    "orderNumber": "001",
    "name": "Jhanel F",
    "process": "Thermoforming",
    "unit": "mm",
    "type": "Aluminum",
    "quantity": 10,
    "rate": 2.5,
    "estimatedPrice": 25.0,
    "filePath": "path/to/file1.stl",
    "dateSubmitted": "2024-06-20",
    "journalTransferNumber": "JT001",
    "department": "Computer Science",
    "status": "Completed",
    "comment": "Add comment" 
  },
  {
    "orderNumber": "002",
    "name": "Nadia W",
    "process": "3D Printing",
    "unit": "cm",
    "type": "Steel",
    "quantity": 5,
    "rate": 4.7,
    "estimatedPrice": 23.5,
    "filePath": "path/to/file2.obj",
    "dateSubmitted": "2024-08-21",
    "journalTransferNumber": "JT002",
    "department": "Engineering",
    "status": "In Progress",
    "comment": "Add comment" 

  }
]
''';

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

