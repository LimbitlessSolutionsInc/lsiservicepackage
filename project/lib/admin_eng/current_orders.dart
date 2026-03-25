import 'package:flutter/material.dart';
import '../css/css.dart';

import 'models/data.dart';
import 'package:service_package/admin_eng/services/order_service.dart';

ThemeData currentTheme = CSS.lightTheme;

class AdminServices extends StatefulWidget {
  const AdminServices({Key? key}) : super(key: key);

  @override
  AdminServicesState createState() => AdminServicesState();

  void switchTheme(LsiThemes theme) {
    
      currentTheme = CSS.changeTheme(theme);  
    
  }
}

class ProcessImage {
  final String processName;
  final String imagePath;

  ProcessImage({required this.processName, required this.imagePath});
}

class AdminServicesState extends State<AdminServices> {
  String sortBy = 'Date';
  bool showAllOrders = true; 
  List<NewOrder> orders = []; 
  List<NewOrder> filteredOrders = []; 
  List<bool> expandedState = []; 
  final double dayWidth = 5.0;
  final double weekWidth = 250.0; 
  final ScrollController _scrollController = ScrollController(); 
  DateTime graphStartDate = DateTime.now();
  
  DateTime _startOfDay(DateTime date) { // strips extra time (hours/minutes) in the day and starts day at midnight
    return DateTime(date.year, date.month, date.day);
  }

  Widget getProcessImage(String process) {
    switch (process) {
      case 'Thermoforming':
        return const Image(image: AssetImage('assets/icons/emb_thermoform_sm.png'));
      case '3D Printing':
        return const Image(image: AssetImage('assets/icons/emb_printer_3d_sm.png'));
      case 'Milling':
        return const Image(image: AssetImage('assets/icons/emb_mill_sm.png'));
      default:
        return const Image(image: AssetImage('assets/icons/default_icon.png')); 
    }
  }

  @override
  void initState() {
    super.initState();
    // We initialize the data, then process it
    _setupOrders();
  }

  Future<void> _setupOrders() async {
    await OrderService().init(); 
  
    // pull the orders 
    final loadedOrders = OrderService().orders;

    setState(() {
      orders = loadedOrders;
      expandedState = List<bool>.filled(orders.length, false);

      // filter and calculate dates after checking and confirming if there's data
      filteredOrders = orders.where((order) {
        return order.status != 'Completed';
      }).toList();

      if (filteredOrders.isNotEmpty) {
        graphStartDate = filteredOrders
          .map((order) {
            return DateTime.tryParse(order.dates['Submitted'] ?? '') ?? DateTime.now();
          })
          .reduce((a, b) => a.isBefore(b) ? a : b);
      } else {
        graphStartDate = DateTime.now();
      }
    });
  } 

  int calculateDiffinMonths(DateTime start, DateTime end) {
    int monDiff = ((end.year - start.year) * 12) + (end.month - start.month + 1);
    return monDiff;
  }

  DateTime subtractDateByMon(DateTime date, int monthdiff) {
    int newYear = date.year;
    int newMonth = (date.month - monthdiff) + 1;

    if (newMonth <= 0) {
      newYear--;
      newMonth = 12 + newMonth;
    }

    return DateTime(newYear, newMonth, 1);
  }

  List<Widget> chartHeader(BuildContext context) {
    DateTime now = DateTime.now();
    int totalWeeks = (now.difference(graphStartDate).inDays / 7).ceil();
    double weekWidth = 250.0;
    List<Widget> headerDates = [];

    for (int i = 0; i < totalWeeks; i++) {
      // start from current date and subtract weeks to go backwards in time
      DateTime weekStart = now.subtract(Duration(days: i * 7));
    
      int weekOfMonth = ((weekStart.day - 1) ~/ 7) + 1;
      String monthName = Month.getMonth(weekStart.month, weekStart.year).name;

      headerDates.add(
        SizedBox(
          width: weekWidth,
          child: Center(
            child: Text(
              "$monthName '${weekStart.year.toString().substring(2)} - Week $weekOfMonth",
              style: TextStyle(
                fontFamily: 'Klavika',
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
                color: Theme.of(context).secondaryHeaderColor,
              ),
            ),
          ),
        ),
      );
    }
    return headerDates;
  }

  List<Widget> timelineBars(BuildContext context) {
    DateTime now = DateTime.now();
    int totalWeeks = (now.difference(graphStartDate).inDays / 7).ceil();
    double weekWidth = 250.0;

    return [
      SizedBox(
        width: totalWeeks * weekWidth, // matches timeline bars to header 
        child: Stack(
          children: [
            // for loops for the background grids
            for (int i = 0; i <= totalWeeks; i++)
              Positioned(
                left: i * weekWidth,
                top: 0,
                bottom: 0,
                child: Container(width: 1, color: Colors.black12),
              ),

            ...filteredOrders.asMap().entries.map((entry) {
              int index = entry.key;
              var order = entry.value;
              DateTime submittedDate = DateTime.tryParse(order.dates['Submitted'] ?? '') ?? now;

              return Positioned(
                top: index * 70.0 + 10,
                left: 10, // slight padding off the side
                child: Container(
                  width: calculateBarWidth(submittedDate, weekWidth),
                  height: 40.0,
                  decoration: BoxDecoration(
                    color: Theme.of(context).secondaryHeaderColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    ];
  }

  int calculateDiffinWeeks(DateTime startDate, DateTime endDate) {
    return endDate.difference(startDate).inDays ~/ 7 + 1;
  }

  double calculateBarWidth(DateTime startDate, double weekWidth) {
    DateTime now = _startOfDay(DateTime.now()); // starts the day at midnight so new orders will show immediately
    DateTime start = _startOfDay(startDate);

    int daysDifference = now.difference(start).inDays.abs();
  
    return ((daysDifference + 1) / 7) * weekWidth;
  }

  double calculateTotalWidth(List<NewOrder> orders, double weekWidth) {
    if (orders.isEmpty) return weekWidth;
  
    // Safely parse the date
    DateTime? earliestDate = DateTime.tryParse(orders.first.dates['Submitted'] ?? '');
  
    // Fallback to now if parsing fails
    earliestDate ??= DateTime.now();
  
    DateTime latestDate = DateTime.now();
    int totalWeeks = latestDate.difference(earliestDate).inDays ~/ 7;
    return (totalWeeks + 1) * weekWidth;
  }

  void _applySortAndFilter() { // sorts list of current orders by the different 'sort by' criteria 
    setState(() {
      filteredOrders = orders.where((order) => order.status != "Completed").toList();

      filteredOrders.sort((a, b) {
        switch (sortBy) {
          case 'Status':
            return a.status.toLowerCase().compareTo(b.status.toLowerCase());
          case 'Process':
            return a.process.toLowerCase().compareTo(b.process.toLowerCase());
          case 'Name':
            return a.name.toLowerCase().compareTo(b.name.toLowerCase());
          case 'Date':
          default:
            return (a.dates['Submitted']).compareTo(b.dates['Submitted']);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {

    if (orders.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Current Orders',
          style: TextStyle(
            fontFamily: 'Klavika',
            fontWeight: FontWeight.bold,
            fontSize: 22.0,
            color: Theme.of(context).secondaryHeaderColor,
          ),
        ),
        backgroundColor: Theme.of(context).cardColor,
        actions: [

          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 250,
                        child: SearchAnchor(
                          builder: (BuildContext context, SearchController controller) {
                            return SearchBar(
                              controller: controller,
                              padding: const WidgetStatePropertyAll<EdgeInsets>(EdgeInsets.symmetric(horizontal: 16)),
                              onTap: () {
                                controller.openView();
                              },
                              onChanged: (_) {
                                controller.openView();
                              },
                              leading: const Icon(Icons.search),

                            );
                          },
                          suggestionsBuilder: (BuildContext context, SearchController controller) async {
                            final String keyword = controller.value.text.toLowerCase();

                            filteredOrders = orders.where((order) => order.status != "Completed" && order.name.toLowerCase().contains(keyword)).toList();

                            return filteredOrders.map((order) {
                              return ListTile(
                                title: Text(order.name),
                                subtitle: Text("Order #: ${order.orderNumber}"),
                                onTap: () async {
                                  controller.closeView(order.name);

                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => OrderDetailsPage(order: order),
                                    ),
                                  );

                                  _applySortAndFilter();
                                },
                              );
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(width: 5),

                Text(
                  'Sort By:',
                  style: TextStyle(
                    fontFamily: 'Klavika',
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).secondaryHeaderColor,
                  ),
                ),

                const SizedBox(width: 5.0),

                DropdownButton<String>(
                  value: sortBy,
                  icon: Icon(Icons.arrow_drop_down, color: Theme.of(context).secondaryHeaderColor),
                  dropdownColor: Theme.of(context).cardColor,
                  underline: Container(),
                  style: TextStyle(
                    fontFamily: 'Klavika',
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).secondaryHeaderColor,
                  ),
                  items: <String>['Date', 'Status', 'Process', 'Name'].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      sortBy = newValue!;
                    });
                    _applySortAndFilter(); // re-sorts the list
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      body: Row(
        children: [
          Container(
            width: 300,
            padding: const EdgeInsets.all(8.0),
            color: Theme.of(context).canvasColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 25,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      DateTime.now().year.toString(),
                      style: TextStyle(
                        fontFamily: 'Klavika',
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                        color: Theme.of(context).secondaryHeaderColor,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredOrders.length,
                    itemBuilder: (context, index) {
                      NewOrder order = filteredOrders[index];
                      return GestureDetector(
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OrderDetailsPage(order: order),
                            ),
                          );

                          if(result == 'deleted') {
                            setState(() {
                              orders = OrderService().orders; 
                              _applySortAndFilter();
                            });
                          } else if (result != null && result is NewOrder) {
                            setState(() {
                              orders = OrderService().orders; 
                              _applySortAndFilter();
                            });

                            filteredOrders = orders.where((order) {
                              if (order.status == "Completed") {
                                return false;
                              }
                              return true;
                            }).toList();

                          }

                          _applySortAndFilter();
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Flexible(
                                  child: SizedBox(
                                    width: 40,
                                    child: getProcessImage(order.process),
                                  ),
                                ),
                                const SizedBox(width: 8.0),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        order.name,
                                        style: const TextStyle(
                                          fontFamily: 'Klavika',
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        'Status: ${order.status}',
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontFamily: 'Klavika',
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 2,
            color: Colors.black54,
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController, 
              scrollDirection: Axis.horizontal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    color: Theme.of(context).cardColor,
                    height: 43.0, 
                    child: Row(
                      children: chartHeader(context), 
                    ),
                  ),
                  Expanded(
                    child: Container(
                      color: Theme.of(context).canvasColor, 
                      child: Row(
                        children: timelineBars(context), 
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OrderDetailsPage extends StatefulWidget {
  final NewOrder order;

  const OrderDetailsPage({Key? key, required this.order}) : super(key: key);

  @override
  OrderDetailsPageState createState() => OrderDetailsPageState();
}

class OrderDetailsPageState extends State<OrderDetailsPage> {
  final loadedOrders = OrderService().orders;
  String? updatedStatusMessage; 
  String selectedStatus = ''; 
  String comments = ''; 
  final TextEditingController _commentsController = TextEditingController() ;
  final TextEditingController _nameController = TextEditingController();
  List<String> savedComments = []; 
  final List<String> statuses = ['Received', 'In Progress', 'Delivered', 'Completed']; 

  @override
  void initState() {
    super.initState();

    selectedStatus = widget.order.status; 
  }

  void deleteOrder(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this order?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await OrderService().deleteOrder(widget.order.orderNumber); // deletes order from the JSON

                Navigator.pop(context);
                Navigator.pop(context, 'delete'); 
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void updateStatus(String newStatus) async {
    setState(() {
      widget.order.status = newStatus;
      selectedStatus = newStatus;
      widget.order.dates[newStatus] = DateTime.now().toString().split(' ')[0];
      updatedStatusMessage = "Status updated to: $newStatus";
    });

    await OrderService().updateOrder(widget.order); // updates status and dates in the JSON
  }

  @override
  void dispose() {
    _commentsController.dispose();
    _nameController.dispose();

    super.dispose();
  }

  void saveComment(BuildContext context) async {
    // won't save if fields are empty
    if (_nameController.text.trim().isEmpty || _commentsController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both a name and a comment.')),
      );
      return; 
    }

    final Map<String, dynamic> newEntry = {
      'name': _nameController.text.trim(),
      'date': DateTime.now().toString().split(' ')[0], 
      'text': _commentsController.text.trim(),
    };

    // updates the UI and data
    setState(() {
      widget.order.comment.add(newEntry);
    
      _nameController.clear();
      _commentsController.clear();
    });

    // updates the JSON and then shows comfirmation message
    try {
      await OrderService().updateOrder(widget.order);
    
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Comment saved successfully!')),
        );
      }
    } catch (e) {
      print("Error saving comment: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close), 
          onPressed: () => Navigator.pop(context), 
        ),
        backgroundColor: Theme.of(context).cardColor,
      ),

      body: Center(
        child: Container(
          color: Theme.of(context).canvasColor,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center, 
                crossAxisAlignment: CrossAxisAlignment.start, 
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Theme.of(context).primaryColorLight),
                        color: Theme.of(context).cardColor,
                      ),
                      constraints: const BoxConstraints(
                        maxHeight: 400,
                      ),

                      padding: const EdgeInsets.all(12.0),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Order Details',
                            style: TextStyle(
                              fontFamily: 'Klavika',
                              fontWeight: FontWeight.bold,
                              fontSize: 24.0,
                            ),
                          ),

                          ColoredBox(
                            color: Theme.of(context).secondaryHeaderColor,
                            child: SizedBox(width: 145, height: 2),
                          ),

                          const SizedBox(height: 8.0),

                          Expanded(
                            child: ListView(
                              padding: EdgeInsets.zero,
                              children: [
                                Text(
                                  'Name: ${widget.order.name}',
                                  style: const TextStyle(
                                    fontFamily: 'Klavika',
                                    fontWeight: FontWeight.normal,
                                    fontSize: 17.0
                                  ),
                                ),

                                Text(
                                  'Process: ${widget.order.process}',
                                  style: const TextStyle(
                                    fontFamily: 'Klavika',
                                    fontWeight: FontWeight.normal,
                                    fontSize: 17.0
                                  ),
                                ),

                                Text(
                                  'Order Number: ${widget.order.orderNumber}',
                                  style: const TextStyle(
                                    fontFamily: 'Klavika',
                                    fontWeight: FontWeight.normal,
                                    fontSize: 17.0                                        
                                  ),
                                ),

                                Text(
                                  'Unit: ${widget.order.unit}',
                                  style: const TextStyle(
                                    fontFamily: 'Klavika',
                                    fontWeight: FontWeight.normal,
                                    fontSize: 17.0
                                  ),
                                ),

                                Text(
                                  'Type: ${widget.order.type}',
                                  style: const TextStyle(
                                    fontFamily: 'Klavika',
                                    fontWeight: FontWeight.normal,
                                    fontSize: 17.0
                                  ),
                                ),

                                Text(
                                  'Quantity: ${widget.order.quantity}',
                                  style: const TextStyle(
                                    fontFamily: 'Klavika',
                                    fontWeight: FontWeight.normal,
                                    fontSize: 17.0
                                  ),
                                ),

                                Text(
                                  'Rate: \$${widget.order.rate.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontFamily: 'Klavika',
                                    fontWeight: FontWeight.normal,
                                    fontSize: 17.0
                                  ),
                                ),

                                Text(
                                  'Date Submitted: ${widget.order.dates['Submitted']}',
                                  style: const TextStyle(
                                    fontFamily: 'Klavika',
                                    fontWeight: FontWeight.normal,
                                    fontSize: 17.0
                                  ),
                                ),

                                Text(
                                  'Department: ${widget.order.department}',
                                  style: const TextStyle(
                                    fontFamily: 'Klavika',
                                    fontWeight: FontWeight.normal,
                                    fontSize: 17.0
                                  ),
                                ),

                                Text(
                                  'Status: ${widget.order.status}',
                                  style: const TextStyle(
                                    fontFamily: 'Klavika',
                                    fontWeight: FontWeight.normal,
                                    fontSize: 17.0
                                  ),
                                ),

                                if (updatedStatusMessage != null) ...[
                                  const SizedBox(height: 8.0),
                                  Text(
                                    updatedStatusMessage!,
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontFamily: 'Klavika',
                                      fontSize: 17.0
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),

                            const SizedBox(height: 16.0),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              DropdownButton<String>(
                                value: selectedStatus,
                                items: statuses.map((status) {
                                  final isDisabled = statuses.indexOf(status) <= statuses.indexOf(selectedStatus);
                                  return DropdownMenuItem<String>(
                                    value: status,
                                    enabled: !isDisabled,
                                    child: Text(
                                      status,
                                      style: TextStyle(
                                        color: isDisabled ? Colors.grey : Colors.black,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    updateStatus(value);
                                  }
                                },
                                dropdownColor: Theme.of(context).cardColor,
                                style: const TextStyle(fontFamily: 'Klavika', fontWeight: FontWeight.normal),
                              ),

                              const SizedBox(width: 20.0),

                              ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                                onPressed: () => deleteOrder(context),
                                child: const Text(
                                  'DELETE ORDER',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Klavika',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 16.0),
                
                  Expanded(
                    flex: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Theme.of(context).primaryColorLight),
                        color: Theme.of(context).cardColor,
                      ),
                      constraints: const BoxConstraints(maxHeight: 400),
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Comments',
                            style: TextStyle(
                              fontFamily: 'Klavika',
                              fontWeight: FontWeight.bold,
                              fontSize: 24.0,
                            ),
                          ),

                          ColoredBox(
                            color: Theme.of(context).secondaryHeaderColor,
                            child: SizedBox(width: 120, height: 2),
                          ),

                          const SizedBox(height: 8.0),

                          // list of existing comments
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Theme.of(context).primaryColorLight.withValues(alpha: 0.3)),
                                color: Theme.of(context).canvasColor,
                              ),
                              child: ListView.separated(
                                padding: const EdgeInsets.all(8.0),
                                itemCount: widget.order.comment.length,
                                separatorBuilder: (context, index) => const Divider(),
                                itemBuilder: (context, index) {
                                  final item = widget.order.comment[index];
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${item['name']} - ${item['date']}",
                                        style: const TextStyle(fontFamily: 'Klavika', fontWeight: FontWeight.bold, fontSize: 12),
                                      ),
                                      Text(
                                        "${item['text']}",
                                        style: const TextStyle(fontFamily: 'Klavika', fontSize: 14),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),

                          const SizedBox(height: 16.0),

        
                          const Text("Add a Comment", style: TextStyle(fontFamily: 'Klavika', fontSize: 12, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
        
                          // name input
                          TextField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              hintText: 'ex. John S',
                              isDense: true,
                              border: OutlineInputBorder(),
                              hintStyle: TextStyle(fontFamily: 'Klavika'),
                            ),
                          ),
                          
                          const SizedBox(height: 8),

                          // comment Input
                          TextField(
                            controller: _commentsController,
                            maxLines: 2,
                            decoration: InputDecoration(
                              hintText: 'Type your comment here...',
                              isDense: true,
                              border: OutlineInputBorder(),
                              hintStyle: TextStyle(fontFamily: 'Klavika'),
                            ),
                          ),

                          const SizedBox(height: 8.0),

                          Align(
                            alignment: Alignment.bottomRight,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).secondaryHeaderColor,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                              ),
                              onPressed: () => saveComment(context),
                              child: Text(
                                'SAVE',
                                style: TextStyle(
                                  color: Theme.of(context).primaryColorLight,
                                  fontFamily: 'Klavika',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      )
    );
  }
}