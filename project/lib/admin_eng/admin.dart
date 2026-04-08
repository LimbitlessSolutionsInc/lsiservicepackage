import 'package:flutter/material.dart';
import 'package:service_package/admin_eng/cancellation_requests.dart';
import '../css/css.dart';

import 'completed_orders.dart';
import 'current_orders.dart';
import 'package:service_package/admin_eng/services/order_service.dart';

ThemeData currentTheme = CSS.lightTheme;

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  AdminPageState createState() => AdminPageState();
}

class AdminPageState extends State<AdminPage> {
  int get cancellationCount {
    return OrderService().orders.where((o) => o.cancelRequested == true).length;
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Admin Page',
          style: TextStyle(
            fontFamily: 'Klavika',
            fontWeight: FontWeight.bold,
            fontSize: 22.0,
            color: Theme.of(context).secondaryHeaderColor,
          ),
        ),
        backgroundColor: Theme.of(context).cardColor,
      ),

      body: Stack(
        children: <Widget> [
          Container(
            color: Theme.of(context).canvasColor,
            child: Center(
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget> [
                        Container(
                          height: screenHeight - kToolbarHeight,
                          decoration: BoxDecoration(
                            image: const DecorationImage(
                              image: AssetImage('assets/images/armwbluebackground.png'),
                              fit: BoxFit.cover,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.5),
                                blurRadius: 10,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 50,
                          width: 170,

                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const AdminServices()), // Button to go current orders
                              );
                            },

                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(Theme.of(context).secondaryHeaderColor),
                              side: WidgetStateProperty.all( BorderSide(width: 2.0, color: Theme.of(context).secondaryHeaderColor)),
                              shape: WidgetStateProperty.all(RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              )),
                            ),

                            child: Text(
                              'CURRENT ORDERS',
                              style: TextStyle(
                                color: Theme.of(context).primaryColorLight,
                                fontFamily: 'Klavika',
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        SizedBox(
                          height: 50,
                          width: 180,

                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const CompleteOrdersPage()), // Button to go completed orders
                              );
                            }, 

                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(Theme.of(context).secondaryHeaderColor),
                              side: WidgetStateProperty.all( BorderSide(width: 2.0, color: Theme.of(context).secondaryHeaderColor)),
                              shape: WidgetStateProperty.all(RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              )),
                            ),

                            child: Text(
                              'ORDER HISTORY',
                              style: TextStyle(
                                color: Theme.of(context).primaryColorLight,
                                fontFamily: 'Klavika',
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        SizedBox(
                          height: 50,
                          width: 240, 
                          
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const CancellationRequestsPage()),
                              ).then((_) {
                                setState(() {});
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).secondaryHeaderColor,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'CANCELLATION REQUESTS',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Klavika',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(width: 10),

                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: cancellationCount > 0 ? Colors.red : Colors.grey,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '$cancellationCount',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
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
        ],
      ),
    );
  }
}