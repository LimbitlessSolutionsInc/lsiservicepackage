import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'dart:typed_data';

import 'package:service_package/main.dart';
import 'package:service_package/admin_eng/models/data.dart';
import 'package:service_package/admin_eng/services/order_service.dart';

class CreateOrderPage extends StatefulWidget{
  const CreateOrderPage( { super.key }) ;

  @override
  CreateOrderPageState createState() => CreateOrderPageState();
}

class CreateOrderPageState extends State<CreateOrderPage>{
  final currentOrders = OrderService().orders;

  static const List<List<String>> acceptedExt = 
  [
    ['f3d', 'obj', 'stl', 'stp', 'step'],
    ['f3d', 'stp', 'step']
  ];

  String? _filePath;
  Uint8List? _fileBytes;
  String? _fileName;
  String _selectedProcess = 'Thermoforming';
  String _selectedUnit = 'mm';
  String _selectedType = 'Aluminum';
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _journalNumController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  final String _journalTransferNumber = '';
  final String _department = '';
  final String _dateSubmitted = '';
  final double _volume = 100.0;
  double _rate = 0.0;
  int _quantity = 1;
  List<dynamic> rates = [];

  void _loadRates() 
  {
    String jsonString = '''
    [
        {"rate": 2.4, "unit": "mm", "mtl": "Aluminum"},
        {"rate": 2.4, "unit": "cm", "mtl": "Aluminum"},
        {"rate": 2.4, "unit": "inches", "mtl": "Aluminum"},
        {"rate": 1.2, "unit": "mm", "mtl": "Steel"},
        {"rate": 1.2, "unit": "cm", "mtl": "Steel"},
        {"rate": 1.2, "unit": "inches", "mtl": "Steel"},
        {"rate": 4.7, "unit": "mm", "mtl": "Brass"},
        {"rate": 4.7, "unit": "cm", "mtl": "Brass"},
        {"rate": 4.7, "unit": "inches", "mtl": "Brass"}
    ]
    ''';

    rates = jsonDecode( jsonString );
  }

  void _calculateRate() 
  {
    for (var rate in rates) 
    {
      if (rate['unit'] == _selectedUnit && rate['mtl'] == _selectedType) 
      {
        setState( () {  _rate = rate[ 'rate' ]; } );
        return;
      }
    }
  }

  @override
  void initState() 
  {
    super.initState();
    _loadRates();
    _calculateRate();
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: acceptedExt.expand((x) => x).toList(),
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _fileBytes = result.files.first.bytes; 
        _fileName = result.files.first.name;   
      });
    }
  }

  void _submitOrder(BuildContext context) async {
    if (_formKey.currentState?.validate() ?? false) {

      String formattedOrderNumber = orderNumber.toString().padLeft(3, '0');
      double estimatedPrice = _volume * _rate * _quantity;

      String? displayPath = _filePath;
      if (_filePath != null && _fileBytes != null) {
        displayPath = _fileName; 
      }

      final newOrder = NewOrder(
        orderNumber: formattedOrderNumber,
        name: _nameController.text,
        process: _selectedProcess,
        unit: _selectedUnit,
        type: _selectedType,
        quantity: _quantity,
        rate: _rate,
        estimatedPrice: estimatedPrice,
        filePath: displayPath ?? '',
        dates: {'Submitted': _dateSubmitted},
        journalTransferNumber: _journalTransferNumber,
        department: _department,
        status: 'Received',
        comment: [],
      );

      await OrderService().addOrder(newOrder);
      orderNumber++;

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CreateSubmitPage()),
      );
    }
  }

  Widget _buildForm(bool isMobile) {
    return Form(
      key: _formKey, 
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 80.0,
                    padding: const EdgeInsets.all(5.0),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).tabBarTheme.indicatorColor : Theme.of(context).splashColor,
                    borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'John S',
                      hintStyle: TextStyle(color: Theme.of(context).hintColor),
                      labelText: 'Name',
                      labelStyle: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).secondaryHeaderColor : Theme.of(context).highlightColor,
                        fontFamily: 'Klavika',
                        fontWeight: FontWeight.normal,
                        fontSize: 12.0,
                      ),
                      
                    ),
                    style: TextStyle(color: Theme.of(context).secondaryHeaderColor),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a name field!';
                      }
                      return null;
                    },
                  ),
                ),

                const SizedBox(height: 16.0),
                Container(
                  height: 80.0,
                    padding: const EdgeInsets.all(5.0),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).tabBarTheme.indicatorColor : Theme.of(context).splashColor,
                    borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: TextFormField(
                    controller: _journalNumController,
                    decoration: InputDecoration(
                      labelText: 'Journal Transfer Number',
                      labelStyle: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).secondaryHeaderColor : Theme.of(context).highlightColor,
                        fontFamily: 'Klavika',
                        fontWeight: FontWeight.normal,
                        fontSize: 12.0,
                      ),
                    ),
                    style: TextStyle(color: Theme.of(context).secondaryHeaderColor),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a journal transfer number!';
                      }
                      return null;
                    },
                  ),
                ),

                const SizedBox(height: 16.0),

                Container(
                  height: 80.0,
                    padding: const EdgeInsets.all(5.0),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).cardColor : Theme.of(context).splashColor,
                    borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: TextFormField(
                    controller: _departmentController,
                    decoration: InputDecoration(
                      labelText: 'Department',
                      labelStyle: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).secondaryHeaderColor : Theme.of(context).highlightColor,
                        fontFamily: 'Klavika',
                        fontWeight: FontWeight.normal,
                        fontSize: 12.0,
                      ),
                    ),
                    style: TextStyle(color: Theme.of(context).secondaryHeaderColor),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a department!';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: Container(
                    height: 80.0,
                    padding: const EdgeInsets.all(5.0),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).tabBarTheme.indicatorColor : Theme.of(context).splashColor,
                    borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        labelStyle: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).secondaryHeaderColor : Theme.of(context).highlightColor,
                          fontFamily: 'Klavika',
                          fontWeight: FontWeight.normal,
                          fontSize: 12.0,
                        ),
                      ),
                      style: TextStyle(color: Theme.of(context).secondaryHeaderColor),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a name!';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: Container(
                    height: 80.0,
                    padding: const EdgeInsets.all(5.0),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).tabBarTheme.indicatorColor : Theme.of(context).splashColor,
                    borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: TextFormField(
                      controller: _journalNumController,
                      decoration: InputDecoration(
                        labelText: 'Journal Transfer Number',
                        labelStyle: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).secondaryHeaderColor : Theme.of(context).highlightColor,
                          fontFamily: 'Klavika',
                          fontWeight: FontWeight.normal,
                          fontSize: 12.0,
                        ),
                      ),
                      style:  TextStyle(color: Theme.of(context).secondaryHeaderColor),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a journal transfer number!';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: Container(
                    height: 80.0,
                    padding: const EdgeInsets.all(5.0),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).tabBarTheme.indicatorColor : Theme.of(context).splashColor,
                    borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: TextFormField(
                      controller: _departmentController,
                      decoration: InputDecoration(
                        labelText: 'Department',
                        labelStyle: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).secondaryHeaderColor : Theme.of(context).highlightColor,
                          fontFamily: 'Klavika',
                          fontWeight: FontWeight.normal,
                          fontSize: 12.0,
                        ),
                      ),
                      style: TextStyle(color: Theme.of(context).secondaryHeaderColor),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a department!';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildFilePicker() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: _pickFile,
          style: ButtonStyle(
            padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0)),
            backgroundColor: WidgetStateProperty.all(Theme.of(context).secondaryHeaderColor),
            side: WidgetStateProperty.all(BorderSide(width: 2.0, color: Theme.of(context).secondaryHeaderColor)),
            minimumSize: WidgetStateProperty.all(const Size(100, 36)),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
          child: Text(
            'PICK A FILE',
            style: TextStyle(
              fontSize: 14.0,
              fontFamily: 'Klavika',
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).primaryColorLight : Theme.of(context).primaryColorLight,
            ),
          ),
        ),

        const SizedBox(width: 10), 

        if (_fileName != null)
          Expanded(
            child: Text(
              _fileName!, 
              style: TextStyle(color: Theme.of(context).secondaryHeaderColor, fontSize: 12.0),
              overflow: TextOverflow.ellipsis, // Truncate if too long
            ),
          ),
      ],
    );
  }

  Widget _buildSelection() {
  return Container
  (
    width: double.infinity,
    padding: const EdgeInsets.all(16.0),
    decoration: BoxDecoration(
      color: Theme.of(context).cardColor,
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
      child: 
      Column
      (
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            initialValue: _selectedProcess,
            decoration: InputDecoration(
              labelText: 'Select Process',
              labelStyle: TextStyle(
                fontSize: 16.0,
                color: Theme.of(context).secondaryHeaderColor,
                fontFamily: 'Klavika',
                fontWeight: FontWeight.bold,
              ),
            ),
            style: TextStyle(
              fontSize: 15.0,
              color: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).secondaryHeaderColor : Theme.of(context).secondaryHeaderColor,
              fontFamily: 'Klavika',
              fontWeight: FontWeight.normal,
            ),
            items: ['Thermoforming', '3D Printing', 'Milling'].map(
              (String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              },
            ).toList(),
            onChanged: (newValue) {
              setState(() {
                _selectedProcess = newValue!;
                _calculateRate();
              });
            },
          ),
          DropdownButtonFormField<String>(
            initialValue: _selectedUnit,
            decoration: InputDecoration(
              labelText: 'Select Unit',
              labelStyle: TextStyle(
                fontSize: 16.0,
                color: Theme.of(context).secondaryHeaderColor,
                fontFamily: 'Klavika',
                fontWeight: FontWeight.bold,
              ),
            ),
            style: TextStyle(
              fontSize: 15.0,
              color: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).secondaryHeaderColor : Theme.of(context).secondaryHeaderColor,
              fontFamily: 'Klavika',
              fontWeight: FontWeight.normal,
            ),
            items: ['mm', 'cm', 'inches'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                _selectedUnit = newValue!;
                _calculateRate();
              });
            },
          ),
          DropdownButtonFormField<String>(
            initialValue: _selectedType,
            decoration: InputDecoration(
              labelText: 'Select Type',
              labelStyle: TextStyle(
                fontSize: 16.0,
                color: Theme.of(context).secondaryHeaderColor,
                fontFamily: 'Klavika',
                fontWeight: FontWeight.bold,
              ),
            ),
            style: TextStyle(
              fontSize: 15.0,
              color: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).secondaryHeaderColor : Theme.of(context).secondaryHeaderColor,
              fontFamily: 'Klavika',
              fontWeight: FontWeight.normal,
            ),
            items: ['Aluminum', 'Steel', 'Brass'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                _selectedType = newValue!;
                _calculateRate();
              });
            },
          ),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Enter Quantity',
              labelStyle: TextStyle(
                fontSize: 16.0,
                color: Theme.of(context).secondaryHeaderColor,
                fontFamily: 'Klavika',
                fontWeight: FontWeight.bold,
              ),
            ),
            keyboardType: TextInputType.number,
            initialValue: '1',
            style: TextStyle(
              fontSize: 14.0,
              color: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).secondaryHeaderColor : Theme.of(context).secondaryHeaderColor,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a quantity';
              }
              return null;
            },
            onChanged: (value) {
              setState(() {
                _quantity = int.tryParse(value) ?? 1;
              });
            },
          ),
          const SizedBox(height: 20),
          Text(
            'Rate: $_rate per cubic unit',
            style: TextStyle(
              fontSize: 16.0,
              color: Theme.of(context).secondaryHeaderColor,
              fontFamily: 'Klavika',
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuote() {
    return 
    Container
    (
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
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
      child: 
      Column
      (
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Process: $_selectedProcess',
            style: TextStyle(
              fontSize: 20.0,
              color: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).secondaryHeaderColor : Theme.of(context).secondaryHeaderColor,
              fontFamily: 'Klavika',
              fontWeight: FontWeight.normal,
            ),
          ),
          Text(
            'Unit: $_selectedUnit',
            style: TextStyle(
              fontSize: 20.0,
              color: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).secondaryHeaderColor : Theme.of(context).secondaryHeaderColor,
              fontFamily: 'Klavika',
              fontWeight: FontWeight.normal,
            ),
          ),
          Text(
            'Type: $_selectedType',
            style: TextStyle(
              fontSize: 20.0,
              color: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).secondaryHeaderColor : Theme.of(context).secondaryHeaderColor,
              fontFamily: 'Klavika',
              fontWeight: FontWeight.normal,
            ),
          ),
          Text(
            'Quantity: $_quantity',
            style: TextStyle(
              fontSize: 20.0,
              color: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).secondaryHeaderColor : Theme.of(context).secondaryHeaderColor,
              fontFamily: 'Klavika',
              fontWeight: FontWeight.normal,
            ),
          ),
          Text(
            'Rate: $_rate per cubic unit',
            style: TextStyle(
              fontSize: 20.0,
              color: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).secondaryHeaderColor : Theme.of(context).secondaryHeaderColor,
              fontFamily: 'Klavika',
              fontWeight: FontWeight.normal,
            ),
          ),
          Text(
            'Estimated Price: \$${(_volume * _rate * _quantity).toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 20.0,
              color: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).secondaryHeaderColor : Theme.of(context).secondaryHeaderColor,
              fontFamily: 'Klavika',
              fontWeight: FontWeight.normal,
            ),
          ),
          Text(
            'Estimated Delivery:',
            style: TextStyle(
              fontSize: 20.0,
              color:Theme.of(context).brightness == Brightness.dark ? Theme.of(context).secondaryHeaderColor : Theme.of(context).secondaryHeaderColor,
              fontFamily: 'Klavika',
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitOrder() {
  return Center(
    child: ElevatedButton(
      onPressed: () {
        _submitOrder(context);
      },
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(Theme.of(context).secondaryHeaderColor),
        side: WidgetStateProperty.all(BorderSide(width: 2.0, color: Theme.of(context).secondaryHeaderColor)),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
      child: Text(
        'SUBMIT ORDER',
        style: TextStyle(
          fontFamily: 'Klavika',
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColorLight,
        ),
      ),
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create an Order',
          style: TextStyle(
            color: Theme.of(context).secondaryHeaderColor,
            fontFamily: 'Klavika',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).cardColor
      ),
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height, 
          ),
          child: Container(
            color: Theme.of(context).canvasColor,
            padding: const EdgeInsets.all(16.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                bool isMobile = constraints.maxWidth < 600;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildForm(isMobile),

                    const SizedBox(height: 30.0),

                    _buildFilePicker(),

                    const SizedBox(height: 30.0),

                    if (isMobile)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildSelection(),
                          const SizedBox(height: 30.0),
                          _buildQuote(),
                        ],
                      )
                    else
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildSelection()),
                          const SizedBox(width: 20.0),
                          Expanded(child: _buildQuote()),
                        ],
                      ),

                    const SizedBox(height: 60.0),

                    _buildSubmitOrder(),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class CreateSubmitPage extends StatefulWidget {
  const CreateSubmitPage({super.key});

  @override
  CreateSubmitPageState createState() => CreateSubmitPageState();
}

class CreateSubmitPageState extends State<CreateSubmitPage> {
  final currentOrders = OrderService().orders;

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label, 
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).secondaryHeaderColor : Theme.of(context).secondaryHeaderColor,
              fontFamily: 'Klavika',
              fontWeight: FontWeight.bold,
            ),
          ),

          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).primaryColorLight : Theme.of(context).primaryColorDark,
              fontFamily: 'Klavika',
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final recentOrder = currentOrders.last;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Order Confirmation',
          style: TextStyle(
            color: Theme.of(context).secondaryHeaderColor,
            fontFamily: 'Klavika',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).cardColor,
      ),
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: Container(
            color: Theme.of(context).canvasColor,
            padding: const EdgeInsets.all(20),
            
            child: Center(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(15),
              width: 400,

              child: Column(
                children: <Widget> [
                  Text(
                    'Order Submitted!',
                    style: TextStyle(
                      fontSize: 40,
                      color: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).secondaryHeaderColor : Theme.of(context).secondaryHeaderColor,
                      fontFamily: 'Klavika',
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Text(
                    'Order #${recentOrder.orderNumber}',
                    style: TextStyle(
                      fontSize: 24,
                      color: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).secondaryHeaderColor : Theme.of(context).secondaryHeaderColor,
                      fontFamily: 'Klavika',
                      fontWeight: FontWeight.normal,
                      decoration: TextDecoration.underline,
                    ),
                  ),

                  Text(
                    'Details:',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 20,
                      color: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).secondaryHeaderColor : Theme.of(context).secondaryHeaderColor,
                      fontFamily: 'Klavika',
                      fontWeight: FontWeight.normal,
                    ),
                  ),

                  const Divider(),

                  _buildDetailRow('Customer', recentOrder.name),
                  _buildDetailRow('Type', recentOrder.type),
                  _buildDetailRow('Process', recentOrder.process),
                  _buildDetailRow('Unit', recentOrder.unit),
                  _buildDetailRow('Quantity', "${recentOrder.quantity}"),
                  _buildDetailRow('Rate', "\$${recentOrder.rate.toStringAsFixed(2)}"),

                  const Divider(),

                  _buildDetailRow("Total", "\$${recentOrder.estimatedPrice.toStringAsFixed(2)}", isBold: true),
                ],
              ),
            ),
            ),
          ),
        ),
      ),
    );
  }
}