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
  final TextEditingController _commentsController = TextEditingController();
  bool _dialogShown = false;

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

  @override
  void dispose() {
    _commentsController.dispose();

    super.dispose();
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: TextStyle(color: Theme.of(context).secondaryHeaderColor, fontWeight: FontWeight.bold, fontSize: 16)),
          SizedBox(width: 25),
          Text(value, style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 16)),
        ],
      ),
    );
  }

  void _submitResponse(BuildContext context, NewOrder currentOrder) async {
    if (_commentsController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a comment.')),
      );
      return;
    }

    if (_isSelected[0] || _isSelected[1]) {
      final Map<String, dynamic> newEntry = {
        'name': 'Cancellation Response',
        'date': DateTime.now().toString().split(' ')[0],
        'text': _commentsController.text.trim(),
      };

      try {
        currentOrder.cancelRequested = false;
        if (_isSelected[1]) {
          currentOrder.status = 'Cancelled';
        }
        currentOrder.comment.add(newEntry);

        await OrderService().updateOrder(currentOrder);

        setState(() {
          selectedOrder = null; 
          _commentsController.clear();
          _isSelected[0] = false;
          _isSelected[1] = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Response submitted successfully!')),
          );
        }
      } catch (e) {
        debugPrint("Error saving comment: $e");
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please pick a response (Reject or Accept).')),
      );
    }
  }

  void _showNoOrdersDialog() {
    if (_dialogShown) return;
    _dialogShown = true;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('No Orders'),
        content: const Text('There are currently no cancellation requests to process.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    ).then((_) => _dialogShown = false);
  }

  Widget _buildOrderListView(List<NewOrder> filteredOrders) {
    return ListView.builder(
      itemCount: filteredOrders.length,
      itemBuilder: (context, index) {
        NewOrder order = filteredOrders[index];
        return GestureDetector(
          onTap: () => setState(() => selectedOrder = order),
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 4.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                   Flexible(child: SizedBox(width: 40, child: getProcessImage(order.process))),
                   const SizedBox(width: 8.0),
                   Expanded(child: Text(order.name, style: const TextStyle(fontFamily: 'Klavika', fontSize: 16, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOrderDetailView(NewOrder currentOrder) {
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text('Cancellation Requested: ${currentOrder.name}', 
                    style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold, fontFamily: 'Klavika')),
                  const SizedBox(height: 4),
                  ColoredBox(color: Theme.of(context).primaryColor, child: const SizedBox(height: 2, width: 400)),
                  
                  _buildInfoRow('Order #:', currentOrder.orderNumber),
                  _buildInfoRow('Name:', currentOrder.name),
                  _buildInfoRow('Journal Transfer #:', currentOrder.journalTransferNumber),
                  _buildInfoRow('Status:', currentOrder.status),
                  _buildInfoRow('Process:', currentOrder.process),
                  _buildInfoRow('Unit:', currentOrder.unit),
                  _buildInfoRow('Type:', currentOrder.type),
                  _buildInfoRow('Quantity:', currentOrder.quantity.toString()),
                  _buildInfoRow('Price:', '\$${currentOrder.estimatedPrice.toStringAsFixed(2)}'),
                  
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 25),
                    margin: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width > 1200 ? 250 : 10, 
                      vertical: 25
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).secondaryHeaderColor,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      children: [
                        const Text('Accept Cancellation Request?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Klavika')),
                        
                        ToggleButtons(
                          renderBorder: false,
                          fillColor: Colors.transparent,
                          isSelected: _isSelected,
                          onPressed: (int index) {
                            setState(() {
                              for (int i = 0; i < _isSelected.length; i++) _isSelected[i] = i == index;
                            });
                          },
                          children: [
                            _buildToggleTab('Reject', 0),
                            _buildToggleTab('Accept', 1),
                          ],
                        ),

                        TextField(
                          controller: _commentsController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: 'Type your comment here...',
                            filled: true,
                            fillColor: Theme.of(context).primaryColorLight,
                            border: const OutlineInputBorder(),
                          ),
                        ),

                        const SizedBox(height: 15),

                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).splashColor),
                          onPressed: () => _submitResponse(context, currentOrder),
                          child: const Text('SUBMIT', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Klavika')),
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
    );
  }

  Widget _buildToggleTab(String label, int index) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _isSelected[index] 
            ? (index == 0 ? Colors.redAccent : Colors.greenAccent) 
            : Theme.of(context).splashColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Klavika', color: Colors.black)),
    );
  }

  @override
  Widget build(BuildContext context) { 
    List<NewOrder> filteredOrders = orders.where((order) => order.cancelRequested == true).toList(); 

    if (filteredOrders.isEmpty) {
      Future.microtask(() => _showNoOrdersDialog());
    }

    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 800; 

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Cancellation Requests', 
          style: TextStyle(
            fontFamily: 'Klavika', 
            fontWeight: FontWeight.bold, 
            color: Theme.of(context).secondaryHeaderColor
          ),
        ),
        backgroundColor: Theme.of(context).cardColor,
        actions: [
          SizedBox(
            width: isMobile ? 160 : 250, 
            height: 40,
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
                    },
                  );
                });
               },
            ),
          ), 
        ],
      ),
      body: Row(
        children: [
          if (!isMobile || (isMobile && selectedOrder == null))
            Container(
              width: isMobile ? screenWidth : 300, 
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
              child: _buildOrderListView(filteredOrders), 
            ),

          if (selectedOrder != null) 
            Expanded(
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                children: [
                  _buildOrderDetailView(selectedOrder!),

                  if (isMobile)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => setState(() => selectedOrder = null),
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