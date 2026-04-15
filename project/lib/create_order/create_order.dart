import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'dart:typed_data';

import 'package:service_package/main.dart';
import 'package:service_package/admin_eng/models/data.dart';
import 'package:service_package/admin_eng/services/order_service.dart';
import '../css/css.dart';

ThemeData currentTheme = CSS.lightTheme;

class CreateOrderPage extends StatefulWidget{
  const CreateOrderPage({ super.key }) ;

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

  Uint8List? _fileBytes;
  String? _fileName;
  String _selectedProcess = 'Thermoforming';
  String _selectedUnit = 'mm';
  String _selectedType = 'Aluminum';
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _journalNumController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  final double _volume = 10.0;
  double _rate = 0.0;
  int _quantity = 1;
  List<dynamic> rates = [];
  int nextOrderNumber = orderLength + 1;
  String? _fileBase64;

  // This function loads the rates from a hardcoded JSON string and decodes it into a list of maps. Each map contains the rate, unit, and material type. The decoded data is stored in the rates variable for later use in calculating the rate based on user selections.
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

  // This function calculates the rate based on the selected unit and type by iterating through the rates list and finding the matching entry. Once a match is found, it updates the _rate state variable accordingly.
  void _calculateRate() {
    for (var rate in rates) {
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

  // This function allows the user to pick a file using the file_picker package. It filters the files based on the accepted extensions defined in the acceptedExt variable. If a file is selected, it updates the state with the file's bytes and name for later use in the order submission process.
  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['f3d', 'obj', 'stl', 'stp', 'step'],
      withData: true, 
    );

    if (result != null) {
      setState(() {
        _fileBytes = result.files.first.bytes;
        _fileName = result.files.first.name;
        _fileBase64 = base64Encode(_fileBytes!);
      });
    }
  }

  // This function is responsible for submitting the order. It first validates the form inputs, then formats the order number and calculates the estimated price based on the volume, rate, and quantity. It also prepares the file path for display. Finally, it creates a new order object and adds it to the order service before navigating to the order confirmation page.
  void _submitOrder(BuildContext context) async {
    if (_formKey.currentState?.validate() ?? false) {

      String formattedOrderNumber = nextOrderNumber.toString().padLeft(3, '0');
      double estimatedPrice = _volume * _rate * _quantity;

      // Create a new order object with the collected data and add it to the order service
      final newOrder = NewOrder(
        orderNumber: formattedOrderNumber,
        name: _nameController.text.trim(),
        process: _selectedProcess,
        unit: _selectedUnit,
        type: _selectedType,
        quantity: _quantity,
        rate: _rate,
        estimatedPrice: estimatedPrice,
        filePath: _fileName ?? '',
        fileData: _fileBase64,
        dates: {'Submitted': DateTime.now().toString().split(' ')[0]},
        journalTransferNumber: _journalNumController.text.trim(),
        department: _departmentController.text.trim(),
        status: 'Received',
        comment: [],
        cancelRequested: false
      );

      await OrderService().addOrder(newOrder);
      setState(() {
        orderLength++;
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => CreateSubmitPage()),
      );
    }
  }

  // This function builds the form for user input. It adapts its layout based on whether the device is mobile or not. For mobile devices, it uses a column layout, while for larger screens, it uses a row layout to display the input fields side by side. Each input field is wrapped in a container with styling that changes based on the current theme (dark or light mode).
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
                    color: Theme.of(context).cardColor,
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
                    color: Theme.of(context).cardColor,
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
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(8.0),
                  ),

                  child: TextFormField(
                    controller: _departmentController,
                    decoration: InputDecoration(
                      labelText: 'Department',
                      labelStyle: TextStyle(
                        color: Theme.of(context).secondaryHeaderColor,
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
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        labelStyle: TextStyle(
                          color: Theme.of(context).secondaryHeaderColor,
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
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(8.0),
                    ),

                    child: TextFormField(
                      controller: _journalNumController,
                      decoration: InputDecoration(
                        labelText: 'Journal Transfer Number',
                        labelStyle: TextStyle(
                          color: Theme.of(context).secondaryHeaderColor,
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
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(8.0),
                    ),

                    child: TextFormField(
                      controller: _departmentController,
                      decoration: InputDecoration(
                        labelText: 'Department',
                        labelStyle: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).secondaryHeaderColor : Theme.of(context).secondaryHeaderColor,
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

  // This function builds the file picker section of the UI. It includes an elevated button that triggers the file picking process when pressed. If a file has been selected, it also displays the file name next to the button. The styling of the button and text adapts to the current theme (dark or light mode) for better visual consistency.
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
              color: Theme.of(context).primaryColorLight,
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

  // This function builds the selection section of the UI, which includes dropdown menus for selecting the process, unit, and material type, as well as a text field for entering the quantity. It also displays the calculated rate based on the user's selections. The layout and styling of this section adapt to the current theme (dark or light mode) for better visual consistency.
  Widget _buildSelection() {
    return Container(
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

      child: Column(
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

  // This function builds the quote section of the UI, which displays a summary of the user's selections and the calculated estimated price. It includes details such as the selected process, unit, type, quantity, rate, and estimated delivery. The layout and styling of this section adapt to the current theme (dark or light mode) for better visual consistency.
  Widget _buildQuote() {
    return 
    Container(
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
      child: Column(
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

  // This function builds the submit order button. When pressed, it triggers the _submitOrder function to validate the form and submit the order. The button is styled with an elevated design and adapts its colors based on the current theme (dark or light mode) for better visual consistency.
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

  // This is the main build function for the CreateOrderPage widget. It constructs the overall layout of the page, including the app bar, form, file picker, selection and quote sections, and the submit button. The layout adapts to different screen sizes by using a LayoutBuilder to determine if the device is mobile or not, and adjusts the arrangement of the widgets accordingly. The styling throughout the page is consistent with the current theme (dark or light mode) for a cohesive user experience.
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

  // This function builds a row for displaying order details in the order confirmation page. It takes a label and a value as parameters, and an optional isBold parameter to determine if the value should be displayed in bold font. The row is styled with padding and colors that adapt to the current theme (dark or light mode) for better visual consistency.
  Widget _buildDetailRow(String label, String value, {bool isBold = false, required ThemeData theme, required bool isHalloween}) {
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
              color: isHalloween 
                ? theme.hoverColor 
                : (theme.brightness == Brightness.dark 
                  ? theme.primaryColorLight 
                  : theme.primaryColorDark),
              fontFamily: 'Klavika',
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  // This is the main build function for the CreateSubmitPage widget. It retrieves the most recent order from the order service and displays its details in a structured format. The page includes an app bar with the title "Order Confirmation" and a body that shows the order number, customer name, process, unit, type, quantity, rate, and total estimated price. The layout is designed to be visually appealing and consistent with the current theme (dark or light mode) for a cohesive user experience. Additionally, it uses a PopScope to prevent users from navigating back to the previous page, ensuring they stay on the confirmation page until they choose to return to the home screen.
  @override
  Widget build(BuildContext context) {
    final recentOrder = currentOrders.last;
    final theme = Theme.of(context);
    bool isHalloween = theme.brightness == Brightness.dark && theme.secondaryHeaderColor == CSS.hallowTheme.secondaryHeaderColor;

    String displayNum = recentOrder.orderNumber.padLeft(3, '0');

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        Navigator.of(context).popUntil((route) => route.isFirst);
      },

      child: Scaffold(
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
                    'Order #$displayNum',
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

                  _buildDetailRow('Customer', recentOrder.name, theme: theme, isHalloween: isHalloween),
                  _buildDetailRow('Type', recentOrder.type, theme: theme, isHalloween: isHalloween),
                  _buildDetailRow('Process', recentOrder.process, theme: theme, isHalloween: isHalloween),
                  _buildDetailRow('Unit', recentOrder.unit, theme: theme, isHalloween: isHalloween),
                  _buildDetailRow('Quantity', "${recentOrder.quantity}", theme: theme, isHalloween: isHalloween),
                  _buildDetailRow('Rate', "\$${recentOrder.rate.toStringAsFixed(2)}", theme: theme, isHalloween: isHalloween),

                  const Divider(),

                  _buildDetailRow("Total", "\$${recentOrder.estimatedPrice.toStringAsFixed(2)}", isBold: true, theme: theme, isHalloween: isHalloween),
                ],
              ),
            ),
            ),
          ),
        ),
      ),
      ),
    );
  }
}