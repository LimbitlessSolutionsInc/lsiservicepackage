import 'package:flutter/material.dart';

import '../css/css.dart';
import 'models/data.dart';
import 'package:service_package/admin_eng/services/order_service.dart';

ThemeData currentTheme = CSS.lightTheme;

class CompleteOrdersPage extends StatefulWidget {
  const CompleteOrdersPage({super.key});

  @override
  CompleteOrdersPageState createState() => CompleteOrdersPageState();
}

class CompleteOrdersPageState extends State<CompleteOrdersPage> {
  String sortBy = 'Date';
  List<NewOrder> orders = []; 
  List<bool> expandedState = []; 
  List<NewOrder> filteredOrders = []; 

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

    loadOrders();
  }

  void loadOrders() {
    final List<NewOrder> loadedOrders = OrderService().orders;

    setState(() {
      orders = loadedOrders;

      expandedState = List<bool>.filled(orders.length, false);
    });
  }

  @override
  Widget build(BuildContext context) {

    // goes through order list and filters completed orders into new list
    List<NewOrder> filteredOrders = orders.where((order) {
      if (order.status == "Completed") {
        return true;
      } else {
        return false;
      }
    }).toList(); 
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Completed Orders',
          style: TextStyle(
            fontFamily: 'Klavika',
            fontWeight: FontWeight.bold,
            color: Theme.of(context).secondaryHeaderColor,
          ),
        ),
        backgroundColor: Theme.of(context).cardColor,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Row(
              children: [
                Text(
                  'Sort By:',
                  style: TextStyle(
                    fontFamily: 'Klavika',
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).secondaryHeaderColor,
                  ),
                ),

                const SizedBox(width: 4),

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
                  items: <String>['Date', 'Process'].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      sortBy = newValue!;
                    });
                  },
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                SearchAnchor(
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
                    return List<ListTile>.generate(5, (int index) {
                      final String item = 'item $index';
                      return ListTile(
                        title: Text(item),
                        onTap: () {
                          setState(() {
                            controller.closeView(item);
                          });
                        },
                      );
                    });
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
            decoration: BoxDecoration(
              color: Theme.of(context).canvasColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 10,
                  offset: const Offset(0, 10),
                ),
              ]
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                              builder: (context) => CompleteOrdersDetailPage(order: order, index: index),
                            ),
                          );

                          if (result != null && result is NewOrder) {
                            setState(() {
                              orders[index] = result; 
                            });

                            filteredOrders = orders.where((order) {
                              if (order.status != "Completed") {
                                return false;
                              } else {
                                return true;
                              }
                            }).toList();
                          }
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
        ],
      ),
    );
  }
}

class CompleteOrdersDetailPage extends StatefulWidget {
  final NewOrder order;
  final int index;

  const CompleteOrdersDetailPage({Key? key, required this.order, required this.index}) : super(key: key);

  @override
  CompleteDetailPageState createState() => CompleteDetailPageState();
}

class CompleteDetailPageState extends State<CompleteOrdersDetailPage> {


  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        children: <Widget> [
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 10,
                    offset: const Offset(7, 7),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'Order Details',
                    style: TextStyle(
                      fontFamily: 'Klavika',
                      fontWeight: FontWeight.bold,
                      fontSize: 24.0,
                    ),
                  ),

                  Text(
                    'Order Number: ${widget.order.orderNumber}',

                  ),
                ],
              ),
            ),
          ),

          Expanded(
            flex: 1,
            child: Container(

            ),
          ),
        ],
      ),
    );
  }
}