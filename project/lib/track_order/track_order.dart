import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:service_package/admin_eng/data.dart';
import '/css/css.dart';

ThemeData currentTheme = CSS.lightTheme;

class TrackOrderPage extends StatefulWidget {
  const TrackOrderPage({super.key});

  @override
  TrackOrderPageState createState() => TrackOrderPageState();
}

class TrackOrderPageState extends State<TrackOrderPage> {
  final List<dynamic> orders = jsonDecode(orderJson);
  final TextEditingController _orderIdController = TextEditingController();
  final double _volume = 100.0;
  var order;

  bool _isTracking = false;
  bool _validate = false;

  @override
  void dispose() {
    _orderIdController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
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
                  if (!_isTracking) ...[
                    TextField(
                      controller: _orderIdController,
                      decoration: InputDecoration(
                        labelText: 'Enter Order ID',
                        border: const OutlineInputBorder(),
                        labelStyle: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).primaryColorLight : Theme.of(context).shadowColor,
                          fontFamily: 'Klavika',
                          fontWeight: FontWeight.normal,
                        ),
                        errorText: _validate ? 'Order ID not found' : null,
                      ),
                      style: TextStyle(color: Theme.of(context).unselectedWidgetColor),
                    ),

                    const SizedBox(height: 16.0),
                    
                    ElevatedButton(
                      onPressed: () {
                        if(_orderIdController.text.isEmpty) {
                          setState(() {
                            _validate = _orderIdController.text.isEmpty;
                          });
                        }
                        else if(!orders.any((item) => item['orderNumber'] == _orderIdController.text)) {
                          setState(() {
                            _validate = true;
                          });
                        }
                        else {
                          setState(() {
                            _validate = false;
                            _isTracking = true;
                            order = orders.firstWhere((item) => item['orderNumber'] == _orderIdController.text, orElse: () => null); // finds the index for matching value
                          });
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
                      'Hi, ${order['name']}',
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
      )
    );
  }

  Widget _buildOrderDetails() {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = constraints.maxWidth < 600.0;
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
                decoration: BoxDecoration
                (
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
                              color: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).primaryColorDark : Theme.of(context).primaryColorDark,
                              fontFamily: 'Klavika',
                              fontWeight: FontWeight.normal,
                              fontSize: 16.0,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              order['orderNumber'],
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
                              color: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).primaryColorDark : Theme.of(context).primaryColorDark,
                              fontFamily: 'Klavika',
                              fontWeight: FontWeight.normal,
                              fontSize: 16.0,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              '${order['name']}',
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
                              color: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).primaryColorDark : Theme.of(context).primaryColorDark,
                              fontFamily: 'Klavika',
                              fontWeight: FontWeight.normal,
                              fontSize: 16.0,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              '${order['process']}',
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
                              color: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).primaryColorDark : Theme.of(context).primaryColorDark,
                              fontFamily: 'Klavika',
                              fontWeight: FontWeight.normal,
                              fontSize: 16.0,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              order['unit'],
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
                              color: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).primaryColorDark : Theme.of(context).primaryColorDark,
                              fontFamily: 'Klavika',
                              fontWeight: FontWeight.normal,
                              fontSize: 16.0,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              '${order['type']}',
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
                              color: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).primaryColorDark : Theme.of(context).primaryColorDark,
                              fontFamily: 'Klavika',
                              fontWeight: FontWeight.normal,
                              fontSize: 16.0,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              order['quantity'].toString(),
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
                              color: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).primaryColorDark : Theme.of(context).primaryColorDark,
                              fontFamily: 'Klavika',
                              fontWeight: FontWeight.normal,
                              fontSize: 16.0,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              '${order['rate']} per cubic unit',
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
                              color: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).primaryColorDark : Theme.of(context).primaryColorDark,
                              fontFamily: 'Klavika',
                              fontWeight: FontWeight.normal,
                              fontSize: 16.0,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              '\$${order['estimatedPrice'].toStringAsFixed(2)}',
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

  void _cancelOrder(BuildContext context) {
  final String orderNumber = order['orderNumber'];

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Order #$orderNumber cancellation requested.'),
      duration: const Duration(seconds: 3),
    ),
  );
  Future.delayed(const Duration(seconds: 1), () {
    Navigator.of(context).pushReplacementNamed('/home'); 
  });
}

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
                _buildStatusContainer('Received', true, isLarge: false),
                _buildStatusDivider(true),
                _buildStatusContainer('In progress', false, isLarge: false),
                _buildStatusDivider(false),
                _buildStatusContainer('Delivered', false, isLarge: false),
                _buildStatusDivider(false),
                _buildStatusContainer('Completed', false, isLarge: false),
              ],
            ),
          ),
        ],
      ),
    );
  }

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
