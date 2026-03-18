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
  NewOrder? selectedOrder;

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

  Widget _buildInfoRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          width: 150,
          child: Text(label, style: TextStyle(color: Theme.of(context).secondaryHeaderColor, fontWeight: FontWeight.bold, fontSize: 16)),
        ),
        Text(value, style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 16)),
      ],
    ),
  );
}

  Widget _buildStatusContainer(String title, String date) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      constraints: const BoxConstraints(
        maxWidth: 270, 
        minHeight: 85, 
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).secondaryHeaderColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).primaryColorLight : Theme.of(context).splashColor,
                fontSize: 22.0, 
                fontFamily: 'Klavika',
                fontWeight: FontWeight.bold,
              ),
            ),

            Text(
              date,
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).primaryColorLight : Theme.of(context).splashColor,
                fontSize: 16,
                fontFamily: 'Klavika',
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusDivider() {
    return Container(
      height: 15,
      width: 5,
      color: (Theme.of(context).secondaryHeaderColor),
    );
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

                            filteredOrders = orders
                              .where((order) => order.name.toLowerCase().contains(keyword))
                              .toList();

                            return filteredOrders.map((order) {
                              return ListTile(
                                title: Text(order.name),
                                subtitle: Text("Order #: ${order.orderNumber}"),
                                onTap: () async {
                                  controller.closeView(order.name);

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
                          setState(() {
                            selectedOrder = order; 
                          });
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
                                        order.dates['Completed'],
                                        style: const TextStyle(
                                          fontFamily: 'Klavika',
                                          fontWeight: FontWeight.normal,
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

          if (selectedOrder != null)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24), 
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center, 
                  children: [
                    Expanded(
                      flex: 3,
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Order Details',
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Klavika',
                                ),
                              ),

                              const SizedBox(height: 4),

                              ColoredBox(
                                color: Theme.of(context).primaryColor,
                                child: const SizedBox(height: 2, width: 200),
                              ),

                              const SizedBox(height: 24),
                    
                              _buildInfoRow('Order #:', selectedOrder!.orderNumber),
                              _buildInfoRow('Name:', selectedOrder!.name),
                              _buildInfoRow('Department:', selectedOrder!.department),
                              _buildInfoRow('Process:', selectedOrder!.process),
                              _buildInfoRow('Unit:', selectedOrder!.unit),
                              _buildInfoRow('Type:', selectedOrder!.type),
                              _buildInfoRow('Quantity:', selectedOrder!.quantity.toString()),
                              _buildInfoRow('Price:', "\$${selectedOrder!.estimatedPrice.toStringAsFixed(2)}"),
                    
                              const SizedBox(height: 20), 

                              Text(
                                'Comments:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold, 
                                  fontSize: 16
                                ),
                              ),

                              ColoredBox(
                                color: Theme.of(context).secondaryHeaderColor,
                                child: const SizedBox(height: 2, width: 200),
                              ),

                              SizedBox(height: 24),

                              SizedBox(
                                width: 100,
                                height: 100,
                                child: Text(
                                  selectedOrder!.comment,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.normal, 
                                    fontSize: 16
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 20), 

                    Expanded(
                      flex: 2,
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                'Order Timeline',
                                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, fontFamily: 'Klavika'),
                              ),

                              const SizedBox(height: 4),

                              ColoredBox(
                                color: Theme.of(context).primaryColor,
                                child: const SizedBox(height: 2, width: 200),
                              ),

                              const SizedBox(height: 20),
                    
                              _buildStatusContainer('Received', selectedOrder!.dates['Submitted']),
                              _buildStatusDivider(),
                              _buildStatusContainer('In Progress', selectedOrder!.dates['In Progress']),
                              _buildStatusDivider(),
                              _buildStatusContainer('Delivered', selectedOrder!.dates['Delivered']),
                              _buildStatusDivider(),
                              _buildStatusContainer('Completed', selectedOrder!.dates['Completed']),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            const Expanded(
              child: Center(
                child: Text("Select an order from the list to view details", 
                style: TextStyle(color: Colors.grey)),
              ),
            ),
        ],
      ),
    );
  }
}