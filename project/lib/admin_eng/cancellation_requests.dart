import 'package:flutter/material.dart';
import '../css/css.dart';

import 'models/data.dart';
import 'package:service_package/admin_eng/services/order_service.dart';

ThemeData currentTheme = CSS.lightTheme;

class CancellationRequestsPage extends StatefulWidget {
  const CancellationRequestsPage({super.key});

  @override
  CancellationRequestsPageState createState() => CancellationRequestsPageState();
}

class CancellationRequestsPageState extends State<CancellationRequestsPage> {
  String sortBy = 'Date';
  List<NewOrder> orders = []; 
  List<bool> expandedState = []; 
  List<NewOrder> filteredOrders = []; 
  NewOrder? selectedOrder;
  final List<bool> _isSelected = [false, false];

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
                //await OrderService().deleteOrder(widget.orders.orderNumber); // deletes order from the JSON

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

  @override
  Widget build(BuildContext context) { 

    List<NewOrder> filteredOrders = orders.where((order) {
      if (order.cancelRequested == true) {
        return true;
      } else {
        return false;
      }
    }).toList(); 

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Cancellation Requests',
          style: TextStyle(
            fontFamily: 'Klavika',
            fontWeight: FontWeight.bold,
            color: Theme.of(context).secondaryHeaderColor,
          ),
        ),
        backgroundColor: Theme.of(context).cardColor,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
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

                            filteredOrders = orders.where((order) => order.cancelRequested == true && order.name.toLowerCase().contains(keyword)).toList();

                            return filteredOrders.map((order) {
                              return ListTile(
                                title: Text(order.name),
                                subtitle: Text("Order #: ${order.orderNumber}"),
                                onTap: () async {
                                  controller.closeView(order.name);

                                  setState(() {
                                    selectedOrder = order;
                                  });

                                  //_applySortAndFilter();
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

          if(selectedOrder != null) 
            Expanded(
               child: ListView(
                children:[
                  Padding(
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
                                'Cancellation Requested: ${selectedOrder!.name}',
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Klavika',
                                ),
                              ),

                              const SizedBox(height: 4),

                              ColoredBox(
                                color: Theme.of(context).primaryColor,
                                child: const SizedBox(height: 2, width: 400),
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
                    
                              const SizedBox(width: 350.0),

                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 25, vertical: 25),
                                margin: EdgeInsets.symmetric(horizontal: 250, vertical: 25),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).secondaryHeaderColor,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      'Accept Cancellation Request?',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Klavika',
                                      ),
                                    ),

                                    
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        ToggleButtons(
                                          renderBorder: false, 
                                          fillColor: Colors.transparent,
                                          splashColor: Colors.transparent,
                                          hoverColor: Colors.transparent,

                                          isSelected: _isSelected,
                                          onPressed: (int index) {
                                            setState(() {
                                              for (int i = 0; i < _isSelected.length; i++) {
                                                _isSelected[i] = i == index;
                                              }
                                            });
                                          },
                                          children: [
                                            Container(
                                              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                              padding: EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                color: _isSelected[0] ? Colors.redAccent : Theme.of(context).splashColor,
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                'Reject',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: 'Klavika',
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),

                                            Container(
                                              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                              padding: EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                color: _isSelected[1] ? Colors.greenAccent : Theme.of(context).splashColor,
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                'Accept',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: 'Klavika',
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),

                                    Container(
                                      margin: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: ColoredBox(
                                      color: Theme.of(context).primaryColorLight,
                                      child: SizedBox(
                                        width: 300, height: 100,
                                      ),
                                    ),
                                    ),

                                    const SizedBox(height: 15),

                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Theme.of(context).splashColor,
                                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                      ),
                                      onPressed: () {
                                        
                                      },
                                      child: Text(
                                        'SUBMIT',
                                        style: TextStyle(
                                          color: Theme.of(context).primaryColorDark,
                                          fontFamily: 'Klavika',
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

      
                  ],
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