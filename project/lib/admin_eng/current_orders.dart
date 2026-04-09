import 'package:flutter/material.dart';
import '../css/css.dart';
import 'package:url_launcher/url_launcher.dart';

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

    _setupOrders();
  }

  // initializes the orders and sets up the filtered list and graph start date based on the order data
  Future<void> _setupOrders() async {
    await OrderService().init(); 
  
    // pull the orders 
    final loadedOrders = OrderService().orders;

    setState(() {
      orders = loadedOrders;
      expandedState = List<bool>.filled(orders.length, false);

      // filter and calculate dates after checking and confirming if there's data
      filteredOrders = orders.where((order) {
        return order.status != 'Completed' && order.status != 'Cancelled';
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

    // shows dialog if there are no current orders to display
    if (filteredOrders.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("No Orders Found"),
          content: Text("There are no current orders to display."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK"),
            ),
          ],
        ),
      );
    }
  } 

  // calculates the difference in months between two dates, used for the timeline graph to determine how many months to show based on the earliest order date and current date
  int calculateDiffinMonths(DateTime start, DateTime end) {
    int monDiff = ((end.year - start.year) * 12) + (end.month - start.month + 1);
    return monDiff;
  }

  // subtracts a given number of months from a date, used to calculate the start date for the timeline graph based on the earliest order date and current date
  DateTime subtractDateByMon(DateTime date, int monthdiff) {
    int newYear = date.year;
    int newMonth = (date.month - monthdiff) + 1;

    if (newMonth <= 0) {
      newYear--;
      newMonth = 12 + newMonth;
    }

    return DateTime(newYear, newMonth, 1);
  }

  // generates the header for the timeline graph, which includes the month and year for each week displayed in the graph. It calculates the total number of weeks to display based on the difference between the current date and the graph start date, and formats the header text accordingly.
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

  // generates the timeline bars for the graph, which visually represent the duration of each order from its submission date to the current date. It calculates the width of each bar based on the number of weeks that have passed since the order was submitted, and positions the bars accordingly on the graph.
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

  // calculates the difference in weeks between two dates, used to determine the width of the timeline bars based on how many weeks have passed since the order was submitted
  int calculateDiffinWeeks(DateTime startDate, DateTime endDate) {
    return endDate.difference(startDate).inDays ~/ 7 + 1;
  }

  // calculates the width of the timeline bar for an order based on the number of weeks that have passed since the order was submitted. It uses the calculateDiffinWeeks function to determine the number of weeks and multiplies it by a predefined week width to get the final width of the bar.
  double calculateBarWidth(DateTime startDate, double weekWidth) {
    DateTime now = _startOfDay(DateTime.now()); // starts the day at midnight so new orders will show immediately
    DateTime start = _startOfDay(startDate);

    int daysDifference = now.difference(start).inDays.abs();
  
    return ((daysDifference + 1) / 7) * weekWidth;
  }

  // calculates the total width needed for the timeline graph based on the earliest order date and the current date. It determines the total number of weeks that need to be displayed on the graph and multiplies it by the predefined week width to get the total width required for the graph.
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
      filteredOrders = orders.where((order) => order.status != "Completed" && order.status != "Cancelled" && order.status != "Archived").toList();

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
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 800;

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
                      Padding(
                        padding:EdgeInsetsGeometry.symmetric(horizontal: isMobile ? 8.0 : 16.0),
                        child: SizedBox(
                          width: isMobile ? 160 : 250, 
                          height: 40,

                          // SearchAnchor provides the search functionality for the orders, allowing the user to search for specific orders by name. It uses a SearchBar for input and displays suggestions based on the search query. When a suggestion is tapped, it navigates to the OrderDetailsPage for that order.
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
                              filteredOrders = orders.where((order) => order.cancelRequested == true && order.name.toLowerCase().contains(keyword)).toList();

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

                // DropdownButton allows the user to select the criteria by which the orders are sorted. The options include sorting by date, status, process, or name. When a new sorting option is selected, it updates the sortBy variable and calls the _applySortAndFilter function to re-sort the list of orders based on the selected criteria.
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
                              if (order.status == "Completed" && order.status == "Cancelled" && order.status == "Archived") {
                                return false;
                              }
                              return true;
                            }).toList();

                          }

                          _applySortAndFilter();
                        },
                        child: Card(
                          color: Theme.of(context).cardColor,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center, 
                              children: [
                                SizedBox(
                                  width: 40,
                                  child: getProcessImage(order.process),
                                ),

                                const SizedBox(width: 12.0),

                                Expanded(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
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
                                        style: const TextStyle(fontFamily: 'Klavika'),
                                      ),
                                    ],
                                  ),
                                ),

                                // shows warning icon next to orders that have a cancellation request, either pending or already requested by the user. This provides a visual indicator to the admin that there is a cancellation request associated with the order, allowing them to quickly identify and address these orders as needed.
                                if (order.status == 'Cancellation Pending' || order.cancelRequested == true)
                                  const Padding(
                                    padding: EdgeInsets.only(left: 16.0), 
                                    child: Tooltip(
                                      message: 'User requested cancellation',
                                      child: Icon(
                                        Icons.warning_amber_rounded, 
                                        color: Colors.orange,
                                        size: 24,
                                      ),
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

          // timeline graph section, which includes the header with the month and week labels and the bars representing the duration of each order. It uses a SingleChildScrollView to allow horizontal scrolling of the graph, and a Stack to overlay the timeline bars on top of the background grid lines.
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
  final List<String> statuses = ['Received', 'In Progress', 'Delivered', 'Completed', 'Cancellation Pending']; 

  @override
  void initState() {
    super.initState();

    selectedStatus = widget.order.status; 
  }

  // shows a confirmation dialog when the admin attempts to delete an order. If the admin confirms the deletion, it updates the order's status to 'Archived' and sets the archived date in the order's dates. It then calls the OrderService to update the order in the JSON data, and finally pops the current page and returns a 'delete' result to indicate that an order was deleted.
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
                setState(() {
                  widget.order.status = 'Archived';
                  widget.order.dates['Archived'] = DateTime.now().toString().split(' ')[0];
                });

                await OrderService().updateOrder(widget.order); // updates status and dates in the JSON

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

  // updates the status of the order when the admin selects a new status from the dropdown. It sets the new status and updates the corresponding date in the order's dates. It then calls the OrderService to update the order in the JSON data, ensuring that the changes are saved and reflected in the order details.
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

  // saves a new comment for the order when the admin submits a comment. It first checks if both the name and comment fields are filled out, and if not, it shows a snackbar message prompting the admin to enter both fields. If the fields are valid, it creates a new comment entry with the name, current date, and comment text, and adds it to the order's comments list. It then clears the input fields and calls the OrderService to update the order in the JSON data, ensuring that the new comment is saved and reflected in the order details.
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

  // opens the file attached to the order when the admin clicks the "Open File for Printing" button. It uses the url_launcher package to attempt to open the file using the default application on the device. If the file cannot be opened (e.g., if the path is invalid), it shows a snackbar message indicating that the file could not be opened and prompts the admin to check the file path.
  Future<void> _openFile(String path) async {
    final Uri url = Uri.parse(path);
  
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open the file. Check the path.')),
        );
      }
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

                                const SizedBox(height: 16.0),
                                const Text(
                                  'File Attachment:',
                                  style: TextStyle(
                                    fontFamily: 'Klavika',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0,
                                  ),
                                ),

                                const SizedBox(height: 8.0),

                                // shows the "Open File for Printing" button if there is a file path attached to the order. When clicked, it calls the _openFile function to attempt to open the file. If there is no file attached (i.e., the file path is empty), it displays a message indicating that no file is attached.
                                if (widget.order.filePath.isNotEmpty)
                                  ElevatedButton.icon(
                                    onPressed: () => _openFile(widget.order.filePath),
                                    icon: const Icon(Icons.file_present, color: Colors.white),
                                    label: Text(
                                      'OPEN FILE FOR PRINTING',
                                      style: TextStyle(color: Colors.white, fontFamily: 'Klavika'),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blueGrey,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                  )
                                else
                                  const Text(
                                    'No file attached',
                                    style: TextStyle(fontFamily: 'Klavika', color: Colors.grey, fontStyle: FontStyle.italic),
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

        
                          const Text(
                            "Add a Comment", 
                            style: TextStyle( 
                              fontFamily: 'Klavika', 
                              fontSize: 12, 
                              fontWeight: FontWeight.bold
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