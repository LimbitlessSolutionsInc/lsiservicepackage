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

  List<NewOrder> completedOrders = [];
  List<NewOrder> archivedOrders = [];

  Widget getProcessImage(String? process) {
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

  // loads the orders from the OrderService and initializes the completed and archived order lists as well as the expansion state list
  void loadOrders() {
    final List<NewOrder> loadedOrders = OrderService().orders;
    setState(() {
      orders = loadedOrders;
   
      completedOrders = orders.where((o) => o.status == "Completed").toList();
      archivedOrders = orders.where((o) => o.status == "Cancelled" || o.status == "Archived").toList();
    
      expandedState = List<bool>.filled(orders.length, false);
    });
  }

  void _applySortAndFilter() { // sorts list of current orders by the different 'sort by' criteria 
    setState(() {
      filteredOrders = orders.where((order) => order.status == "Completed" || order.status == "Cancelled" || order.status == "Archived").toList();

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

  // Helper method to build a row of order information with a label and value
  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(label, style: TextStyle(color: Theme.of(context).secondaryHeaderColor, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          Text(value ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 16)),
        ],
      ),
    );
  }

  // Helper method to build a container for each order status in the timeline with the status title and date
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

  // Helper method to build a vertical divider between status containers in the timeline
  Widget _buildStatusDivider() {
    return Container(
      height: 15,
      width: 5,
      color: (Theme.of(context).secondaryHeaderColor),
    );
  }

  // Helper method to build the list view of orders for both the completed and archived tabs, showing the order name, process image, and completion date or status
  Widget _buildOrderListView(List<NewOrder> ordersToList) {
    if (ordersToList.isEmpty) {
      return const Center(child: Text("No orders found"));
    }

    return ListView.builder(
      itemCount: ordersToList.length,
      itemBuilder: (context, index) {
        NewOrder order = ordersToList[index];
        return GestureDetector(
          onTap: () => setState(() => selectedOrder = order),

          child: Card(
            color: Theme.of(context).cardColor,
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
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
                          order.dates['Completed'] ?? "Status: ${order.status}",
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
    );
  }

  // Helper method to build the detailed view of a selected order, showing all relevant information and comments in a card layout with a timeline of order status updates on the side (or below on mobile)
  Widget _buildOrderDetailView(NewOrder currentOrder) {
    bool isMobile = MediaQuery.of(context).size.width < 800;

    Widget detailsCard = Card(
      color: Theme.of(context).cardColor,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Order Details: ${currentOrder.name}',
              style: TextStyle(
                fontSize: 25, 
                fontWeight: FontWeight.bold, 
                fontFamily: 'Klavika'
              ),
            ),

            const SizedBox(height: 4),

            ColoredBox(
              color: Theme.of(context).primaryColor,
              child: const SizedBox(height: 2, width: 300),
            ),

            const SizedBox(height: 24),

            _buildInfoRow('Order #:', currentOrder.orderNumber),
            _buildInfoRow('Journal Transfer:', currentOrder.journalTransferNumber),
            _buildInfoRow('Department:', currentOrder.department),
            _buildInfoRow('Process:', currentOrder.process),
            _buildInfoRow('Unit:', currentOrder.unit),
            _buildInfoRow('Type:', currentOrder.type),
            _buildInfoRow('Quantity:', currentOrder.quantity.toString()),
            _buildInfoRow('Price:', "\$${currentOrder.estimatedPrice.toStringAsFixed(2)}"),

            const SizedBox(height: 30),

            const Text(
              'Comments', 
              style: TextStyle(
                fontWeight: FontWeight.bold, 
                fontSize: 18, 
                fontFamily: 'Klavika'
              ),
            ),

            const Divider(),

            _buildCommentsList(currentOrder.comment),
          ],
        ),
      ),
    );

  // Timeline card that shows the order status updates in a vertical layout with dividers between each status, and adapts to a horizontal layout on mobile screens
  Widget timelineCard = Card(
    color: Theme.of(context).cardColor,
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text(
            'Order Timeline', 
            style: TextStyle(
              fontSize: 22, 
              fontWeight: FontWeight.bold, 
              fontFamily: 'Klavika'
            ),
          ),

          const SizedBox(height: 4),

          ColoredBox(
            color: Theme.of(context).primaryColor,
            child: const SizedBox(height: 2, width: 175),
          ),

          const SizedBox(height: 10),

          if(currentOrder.status == "Completed") ...[
            _buildStatusContainer('Received', currentOrder.dates['Submitted'] ?? 'N/A'),
            _buildStatusDivider(),
            _buildStatusContainer('In Progress', currentOrder.dates['In Progress'] ?? 'N/A'),
            _buildStatusDivider(),
            _buildStatusContainer('Delivered', currentOrder.dates['Delivered'] ?? 'N/A'),
            _buildStatusDivider(),
            _buildStatusContainer('Completed', currentOrder.dates['Completed'] ?? 'N/A'),
          ] else ...[
            _buildStatusContainer('Received', currentOrder.dates['Submitted'] ?? 'N/A'),
            _buildStatusDivider(),
            _buildStatusContainer(currentOrder.status, currentOrder.dates[currentOrder.status] ?? 'N/A'),
          ]
        ],
      ),
    ),
  );

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        if (isMobile)
          Column(
            children: [
              detailsCard,
              const SizedBox(height: 20),
              timelineCard,
            ],
          )
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: detailsCard),
              const SizedBox(width: 20),
              Expanded(flex: 2, child: timelineCard),
            ],
          ),
      ],
    );
  }

  // Helper method to build the list of comments for the selected order, showing the commenter's name, date, and comment text in a scrollable list view
  Widget _buildCommentsList(List<dynamic> comments) {
    if (comments.isEmpty) return const Text("No comments available.");
  
    return SizedBox(
      height: 200,
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: comments.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final item = comments[index];
          return ListTile(
            title: Text("${item['name']} - ${item['date']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            subtitle: Text("${item['text']}"),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Filter the orders to get the completed and archived lists based on their status
    List<NewOrder> completedOrders = orders.where((o) => o.status == 'Completed').toList();
    List<NewOrder> archivedOrders = orders.where((o) => o.status == 'Archived' || o.status == 'Cancelled').toList();

    final theme = Theme.of(context);
    bool isHalloween = theme.brightness == Brightness.dark && theme.secondaryHeaderColor == CSS.hallowTheme.secondaryHeaderColor;

    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 800;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          leading: (isMobile && selectedOrder != null)
            ? IconButton(
                icon: Icon(Icons.arrow_back, color: Theme.of(context).primaryColorDark),
                onPressed: () => setState(() => selectedOrder = null),
              )
            : null,
          title: Text(
            'Order History', 
            style: TextStyle(
              color: Theme.of(context).secondaryHeaderColor, 
              fontFamily: 'Klavika',
              fontWeight: FontWeight.bold,
            ),
          ),
          bottom: (isMobile && selectedOrder != null)
            ? null 
            : TabBar(
              labelColor: isHalloween 
                ? theme.hoverColor 
                : (theme.brightness == Brightness.dark 
                  ? theme.primaryColorLight 
                  : theme.primaryColorDark),
              labelStyle: TextStyle(fontFamily: 'Klavika'),          
                tabs: [Tab(text: 'Completed',), Tab(text: 'Archived')],
                indicatorColor: Theme.of(context).secondaryHeaderColor,
              ),
              
          backgroundColor: Theme.of(context).cardColor,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: Row(
                children: [
                  Padding(
                    padding:EdgeInsetsGeometry.symmetric(horizontal: isMobile ? 8.0 : 16.0),
                    child: SizedBox(
                      width: isMobile ? 160 : 250, 
                      height: 40,

                      // SearchAnchor provides the search functionality for filtering orders by name, and updates the filteredOrders list based on the search keyword entered by the user
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

                        // The suggestionsBuilder is called whenever the search view is opened or the search query changes, and it filters the orders based on the search keyword and returns a list of ListTile widgets for each matching order, which are displayed in the search suggestions dropdown
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
                  
                  // DropdownButton for selecting the sorting criteria for the orders, which updates the sortBy variable and calls the _applySortAndFilter method to re-sort the list of orders based on the selected criteria
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
        body: Container(
          color: Theme.of(context).splashColor,
        child: Row(
          children: [
            if (!isMobile || (isMobile && selectedOrder == null))
              Container(
                width: isMobile ? screenWidth : 300,
                decoration: BoxDecoration(
                  color: Theme.of(context).canvasColor,
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
                ),
                child: TabBarView(
                  children: [
                    _buildOrderListView(completedOrders),
                    _buildOrderListView(archivedOrders),
                  ],
                ),
              ),

            if (selectedOrder != null)
              Expanded(
                child: Stack(
                  children: [
                    _buildOrderDetailView(selectedOrder!),
                  
                    if (isMobile)
                      Positioned(
                        top: 10,
                        left: 10,
                        child: CircleAvatar(
                          backgroundColor: Colors.white70,
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () => setState(() => selectedOrder = null),
                          ),
                        ),
                      ),
                  ],
                ),
              )
            else if (!isMobile)
              const Expanded(child: Center(child: Text("Select an order to view details"))),
          ],
        ),
      ),
      ),
    );
  }
}