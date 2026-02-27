import 'package:flutter/material.dart';
//import 'dart:convert'; 
import '../css/css.dart';

ThemeData currentTheme = CSS.lightTheme;

class CompleteOrdersPage extends StatefulWidget {
  const CompleteOrdersPage({super.key});

  @override
  CompleteOrdersPageState createState() => CompleteOrdersPageState();
}

class CompleteOrdersPageState extends State<CompleteOrdersPage> {

  @override
  Widget build(BuildContext context) {
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
      ),

      body: Stack(
        children: <Widget> [
          Container(
            color: Theme.of(context).canvasColor,
            child: Center(
              child: Row(
                children: [
                  SingleChildScrollView(
                    child: Column(
                      children: [

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