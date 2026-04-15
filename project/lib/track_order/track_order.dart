import 'package:flutter/material.dart';

import 'package:service_package/admin_eng/models/data.dart';
import 'package:service_package/admin_eng/services/order_service.dart';
import '/css/css.dart';

ThemeData currentTheme = CSS.lightTheme;

class TrackOrderPage extends StatefulWidget {
  const TrackOrderPage({super.key});

  @override
  TrackOrderPageState createState() => TrackOrderPageState();
}

class TrackOrderPageState extends State<TrackOrderPage> {
  final currentOrders = OrderService().orders;
  final TextEditingController _orderIdController = TextEditingController();
  NewOrder? order;

  bool _isTracking = false;
  bool _validate = false;

  @override
  void dispose() {
    _orderIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    bool isHalloween = theme.brightness == Brightness.dark && theme.secondaryHeaderColor == CSS.hallowTheme.secondaryHeaderColor;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Track Your Order',
          style: TextStyle(
            color: Theme.of(context).secondaryHeaderColor,
            fontFamily: 'Klavika',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).cardColor,
      ),

      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isMobile = constraints.maxWidth < 600.0;

          return Container(
            padding: const EdgeInsets.all(16.0),
            color: Theme.of(context).canvasColor,
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            
            child: 
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const SizedBox(height: 16.0),

                    // If not tracking, show the input field and track button; otherwise, show order details and status
                    if (!_isTracking) ...[
                      TextField(
                        controller: _orderIdController,
                        decoration: InputDecoration(
                          labelText: 'Enter Order ID',
                          border: const OutlineInputBorder(),
                          labelStyle: TextStyle(
                            color: isHalloween 
                              ? theme.primaryColorDark 
                              : (theme.brightness == Brightness.dark 
                                ? theme.primaryColorLight 
                                : theme.primaryColorDark),
                            fontFamily: 'Klavika',
                            fontWeight: FontWeight.normal,
                          ),
                          errorText: _validate ? 'Order ID not found' : null,
                        ),
                        style: TextStyle(color: Theme.of(context).unselectedWidgetColor),
                      ),

                      const SizedBox(height: 16.0),
                    
                      ElevatedButton(
                        onPressed:() {
                          final inputId = _orderIdController.text;

                          if(inputId.isEmpty) {
                            setState(() {
                              _validate = inputId.isEmpty;
                            });
                          } else {
                            final foundOrder = OrderService().orders.cast<NewOrder?>().firstWhere((o) => o?.orderNumber.trim() == inputId.trim(), orElse: () => null,);

                            if(foundOrder != null) {
                              // if order exists
                              setState(() {
                                _validate = false;
                                _isTracking = true;
                                order = foundOrder;
                              });
                            } else {
                              // if order does not exist
                              setState(() {
                                _validate = true;
                                _isTracking = false;
                              });
                            }
                          }
                        },

                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(Theme.of(context).secondaryHeaderColor),
                          side: WidgetStateProperty.all(
                            BorderSide(width: 2.0, color: Theme.of(context).secondaryHeaderColor),
                          ),

                          shape: WidgetStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                        ),

                        child: Text(
                          'TRACK',
                          style: TextStyle(
                            color: Theme.of(context).primaryColorLight,
                            fontFamily: 'Klavika',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ] else ...[
                      Text(
                        'Hi, ${order?.name}',
                        style: TextStyle(
                          color:
                            currentTheme == 
                            CSS.lsiTheme
                            ? Theme.of(context).cardColor
                            : Theme.of(context).secondaryHeaderColor,
                          fontFamily: 'Klavika',
                          fontWeight: FontWeight.bold,
                          fontSize: 24.0,
                        ),
                      ),

                      const SizedBox(height: 16.0),

                      if (isMobile)
                        Column(
                          children: [
                            _buildOrderDetails(),
                            const SizedBox(height: 16.0),
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColorLight,
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: _buildOrderStatus(),
                            ),
                          ],
                        )
                      else
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildOrderDetails(),
                            ),

                            const SizedBox(width: 16.0),
            
                            Expanded(
                              child: Container(
                                height: 400,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColorLight,
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: _buildOrderStatus(),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ],
                ),
              ),
          );
        },
      ),
    );
  }

  // Builds the order details section with a responsive layout
  Widget _buildOrderDetails() {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = constraints.maxWidth < 600.0;
        final theme = Theme.of(context);
        bool isHalloween = theme.brightness == Brightness.dark && theme.secondaryHeaderColor == CSS.hallowTheme.secondaryHeaderColor;
        return Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Theme.of(context).splashColor, 
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor,
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(1, 1,),
              ),
            ],
          ),

          width: constraints.maxWidth,  
          height: isMobile ? null : 400, 
          
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ORDER DETAILS',
                style: TextStyle(
                  color: Theme.of(context).secondaryHeaderColor, 
                  fontFamily: 'Klavika',
                  fontWeight: FontWeight.normal,
                  fontSize: 18.0,
                ),
              ),

              const SizedBox(height: 16.0),

              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor, 
                  borderRadius: BorderRadius.circular(8.0),
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Order Number:',
                            style: TextStyle(
                              color: isHalloween 
                              ? theme.hoverColor 
                              : (theme.brightness == Brightness.dark 
                                ? theme.primaryColorLight 
                                : theme.primaryColorDark),
                              fontFamily: 'Klavika',
                              fontWeight: FontWeight.normal,
                              fontSize: 16.0,
                            ),
                          ),

                          Expanded(
                            child: Text(
                              order!.orderNumber,
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                color: Theme.of(context).secondaryHeaderColor, 
                                fontFamily: 'Klavika',
                                fontWeight: FontWeight.normal,
                                fontSize: 16.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Name:',
                            style: TextStyle(
                              color: isHalloween 
                              ? theme.hoverColor 
                              : (theme.brightness == Brightness.dark 
                                ? theme.primaryColorLight 
                                : theme.primaryColorDark),
                              fontFamily: 'Klavika',
                              fontWeight: FontWeight.normal,
                              fontSize: 16.0,
                            ),
                          ),

                          Expanded(
                            child: Text(
                              '${order?.name}',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                color: Theme.of(context).secondaryHeaderColor, 
                                fontFamily: 'Klavika',
                                fontWeight: FontWeight.normal,
                                fontSize: 16.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Process:',
                            style: TextStyle(
                              color: isHalloween 
                                ? theme.hoverColor 
                                : (theme.brightness == Brightness.dark 
                                  ? theme.primaryColorLight 
                                  : theme.primaryColorDark),
                              fontFamily: 'Klavika',
                              fontWeight: FontWeight.normal,
                              fontSize: 16.0,
                            ),
                          ),

                          Expanded(
                            child: Text(
                              '${order?.process}',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                color: Theme.of(context).secondaryHeaderColor, 
                                fontFamily: 'Klavika',
                                fontWeight: FontWeight.normal,
                                fontSize: 16.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Unit:',
                            style: TextStyle(
                              color: isHalloween 
                                ? theme.hoverColor 
                                : (theme.brightness == Brightness.dark 
                                  ? theme.primaryColorLight 
                                  : theme.primaryColorDark),
                              fontFamily: 'Klavika',
                              fontWeight: FontWeight.normal,
                              fontSize: 16.0,
                            ),
                          ),

                          Expanded(
                            child: Text(
                              order!.unit,
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                color: Theme.of(context).secondaryHeaderColor, 
                                fontFamily: 'Klavika',
                                fontWeight: FontWeight.normal,
                                fontSize: 16.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Type:',
                            style: TextStyle(
                              color: isHalloween 
                                ? theme.hoverColor 
                                : (theme.brightness == Brightness.dark 
                                  ? theme.primaryColorLight 
                                  : theme.primaryColorDark),
                              fontFamily: 'Klavika',
                              fontWeight: FontWeight.normal,
                              fontSize: 16.0,
                            ),
                          ),

                          Expanded(
                            child: Text(
                              '${order?.type}',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                color: Theme.of(context).secondaryHeaderColor, 
                                fontFamily: 'Klavika',
                                fontWeight: FontWeight.normal,
                                fontSize: 16.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Quantity:',
                            style: TextStyle(
                              color: isHalloween 
                                ? theme.hoverColor 
                                : (theme.brightness == Brightness.dark 
                                  ? theme.primaryColorLight 
                                  : theme.primaryColorDark) ,
                              fontFamily: 'Klavika',
                              fontWeight: FontWeight.normal,
                              fontSize: 16.0,
                            ),
                          ),

                          Expanded(
                            child: Text(
                              order!.quantity.toString(),
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                color: Theme.of(context).secondaryHeaderColor,
                                fontFamily: 'Klavika',
                                fontWeight: FontWeight.normal,
                                fontSize: 16.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Rate:',
                            style: TextStyle(
                              color: isHalloween 
                                ? theme.hoverColor 
                                : (theme.brightness == Brightness.dark 
                                  ? theme.primaryColorLight 
                                  : theme.primaryColorDark),
                              fontFamily: 'Klavika',
                              fontWeight: FontWeight.normal,
                              fontSize: 16.0,
                            ),
                          ),

                          Expanded(
                            child: Text(
                              '${order?.rate} per cubic unit',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                color: Theme.of(context).secondaryHeaderColor, 
                                fontFamily: 'Klavika',
                                fontWeight: FontWeight.normal,
                                fontSize: 16.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Estimated Price:',
                            style: TextStyle(
                              color: isHalloween 
                                ? theme.hoverColor 
                                : (theme.brightness == Brightness.dark 
                                  ? theme.primaryColorLight 
                                  : theme.primaryColorDark) ,
                              fontFamily: 'Klavika',
                              fontWeight: FontWeight.normal,
                              fontSize: 16.0,
                            ),
                          ),

                          Expanded(
                            child: Text(
                              '\$${order?.estimatedPrice.toStringAsFixed(2)}',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                color: Theme.of(context).secondaryHeaderColor,
                                fontFamily: 'Klavika',
                                fontWeight: FontWeight.normal,
                                fontSize: 16.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox( height: 18.0),
              Align(
                alignment: Alignment.bottomLeft,
                child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Order Cancellation Request"),
                          content: const Text("Are you sure you want to cancel your order?"),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(); 
                              },
                              child: const Text("No"),
                            ),

                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(); 
                                _cancelOrder(context); 
                              },
                              child: const Text("Yes"),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(Theme.of(context).secondaryHeaderColor),
                    side: WidgetStateProperty.all(
                      BorderSide(width: 2.0, color: Theme.of(context).secondaryHeaderColor),
                    ),
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                  child: Text(
                    'REQUEST CANCELLATION',
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
        );
      },
    );
  }

  // Handles the order cancellation process, including updating the order status and providing user feedback
  void _cancelOrder(BuildContext context) async {
    if (order == null) return;

    final String orderNumber = order!.orderNumber;
    
    try {
    await OrderService().requestCancellation(orderNumber);
    await OrderService().updateOrder(order!); 

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order #$orderNumber cancellation requested.'),
          duration: const Duration(seconds: 3),
        ),
      );
    }

    Future.delayed(const Duration(seconds: 1), () {
      if (context.mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    });
    } catch (e) {
      setState(() {
        order!.cancelRequested = false;
      });
    
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to request cancellation. Please try again.')),
        );
      }
    }
  }
  
  // Builds the order status section with a visual representation of the order's progress through different stages
  Widget _buildOrderStatus() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).splashColor,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor,
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(1, 1), 
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ORDER STATUS',
            style: TextStyle(
              color: Theme.of(context).secondaryHeaderColor,
              fontFamily: 'Klavika',
              fontWeight: FontWeight.normal,
              fontSize: 18.0,
            ),
          ),

          const SizedBox(height: 16.0),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor, 
              borderRadius: BorderRadius.circular(10.0),
            ),

            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if(order!.status == 'Received') ...[
                  _buildStatusContainer('Received', true, isLarge: false),
                  _buildStatusDivider(false),
                  _buildStatusContainer('In Progress', false, isLarge: false),
                  _buildStatusDivider(false),
                  _buildStatusContainer('Delivered', false, isLarge: false),
                  _buildStatusDivider(false),
                  _buildStatusContainer('Completed', false, isLarge: false),
                ],
                
                if(order!.status == 'In Progress') ...[
                  _buildStatusContainer('Received', true, isLarge: false),
                  _buildStatusDivider(true),
                  _buildStatusContainer('In Progress', true, isLarge: false),
                  _buildStatusDivider(false),
                  _buildStatusContainer('Delivered', false, isLarge: false),
                  _buildStatusDivider(false),
                  _buildStatusContainer('Completed', false, isLarge: false),
                ],

                if(order!.status == 'Delivered') ...[
                  _buildStatusContainer('Received', true, isLarge: false),
                  _buildStatusDivider(true),
                  _buildStatusContainer('In Progress', true, isLarge: false),
                  _buildStatusDivider(true),
                  _buildStatusContainer('Delivered', true, isLarge: false),
                  _buildStatusDivider(false),
                  _buildStatusContainer('Completed', false, isLarge: false),
                ],

                if(order!.status == 'Completed') ...[
                  _buildStatusContainer('Received', true, isLarge: false),
                  _buildStatusDivider(true),
                  _buildStatusContainer('In Progress', true, isLarge: false),
                  _buildStatusDivider(true),
                  _buildStatusContainer('Delivered', true, isLarge: false),
                  _buildStatusDivider(true),
                  _buildStatusContainer('Completed', true, isLarge: false),
                ],

                if(order!.status == 'Cancelled') ...[
                  _buildStatusContainer('Cancelled', true, isLarge: false),
                  _buildStatusDivider(false),
                  _buildStatusContainer('In Progress', false, isLarge: false),
                  _buildStatusDivider(false),
                  _buildStatusContainer('Delivered', false, isLarge: false),
                  _buildStatusDivider(false),
                  _buildStatusContainer('Completed', false, isLarge: false),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Builds a status container with dynamic styling based on completion status and size preference
  Widget _buildStatusContainer(String title, bool isCompleted, {bool isLarge = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      constraints: const BoxConstraints(
        maxWidth: 220, 
        minHeight: 50.0, 
      ),

      decoration: BoxDecoration(
        color: isCompleted ? Theme.of(context).secondaryHeaderColor: Theme.of(context).hoverColor,
        borderRadius: BorderRadius.circular(10),
      ),
      
      child: Center(
        child: Text(
          title,
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).primaryColorLight : Theme.of(context).splashColor,
            fontSize: 16.0, 
            fontFamily: 'Klavika',
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
    );
  }

  // Builds a divider widget that visually connects status containers, with dynamic styling based on completion status
  Widget _buildStatusDivider(bool isCompleted) {
    return Container(
      height: 10,
      width: 2,
      color: isCompleted 
        ? (Theme.of(context).secondaryHeaderColor)  
        : ( Theme.of(context).hoverColor), 
    );
  }
}
