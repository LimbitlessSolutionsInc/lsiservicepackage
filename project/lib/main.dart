
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'admin_eng/admin.dart';
import 'css/css.dart';

ThemeData currentTheme = CSS.lightTheme;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> 
{

  ThemeData currentTheme = CSS.lightTheme;

  void switchTheme(LsiThemes theme) {
    setState(() {
      currentTheme = CSS.changeTheme(theme);  
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Limbitless Team Services',
      theme: currentTheme,  
      home: MyHomePage(onThemeChanged: switchTheme), 
      debugShowCheckedModeBanner: false,  
    );
  }
}

class MyHomePage extends StatefulWidget {
  final Function(LsiThemes) onThemeChanged;

  const MyHomePage({super.key, required this.onThemeChanged});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isSettingsOpen = false;
  final ScrollController _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Limbitless Services:',
          style: TextStyle(
            fontFamily: 'Klavika',
            fontWeight: FontWeight.bold,
            color: Theme.of(context).secondaryHeaderColor,
          ),
        ),
        backgroundColor: Theme.of(context).cardColor,
        actions: <Widget>[
          // Settings Button
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              setState(() {
                isSettingsOpen = true;
              });
            },
          ),

          const SizedBox(width: 10), // adds a gap off the side of the screen
        ],
      ),
      body: Stack(
        children: <Widget> [
          Container(
            color: Theme.of(context).canvasColor,
            child: Center(
              child: Row(
                children: [
                  SizedBox( // left side of the home screen
                    height: screenHeight - kToolbarHeight,
                    width: screenWidth / 3,
                    child: SingleChildScrollView(
                      child: SizedBox(
                        height: screenHeight - kToolbarHeight,
                        child: Container( // container for the color on the side of the screen
                          decoration: BoxDecoration(
                            color: Theme.of(context).secondaryHeaderColor,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.5),
                                blurRadius: 10,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                        
                          height: 200,
                          child: const Column( // all info for the machines
                            children: [
                              HoverImageTile( // class for the machine info cards
                                assetPath: 'assets/images/emb_printer_3d_lg.png',
                                desc: 'this is a test desc for 3d printing',
                              ),

                              HoverImageTile(
                                assetPath: 'assets/images/emb_mill_lg.png',
                                desc: 'this is a test desc for milling'
                              ),

                              HoverImageTile(
                                assetPath: 'assets/images/emb_thermoform_lg.png',
                                desc: 'this is a test desc for thermoforming',
                              ),

                            ],
                          ),
                        ),
                      ),
                    ),
                    
                  ),
                  Expanded( // right side of the homepage
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 45, 
                          width: 145,

                          child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const CreateOrderPage()),
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
                            'CREATE ORDER',
                            style: TextStyle(
                              color: Theme.of(context).primaryColorLight,
                              fontFamily: 'Klavika',
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                        ),

                        const SizedBox(height: 16.0), 

                        SizedBox(
                          height: 45,
                          width: 140,

                          child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const TrackOrderPage()),
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
                            'TRACK ORDER',
                            style: TextStyle(
                              color: Theme.of(context).primaryColorLight,
                              fontFamily: 'Klavika',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        ),

                        const SizedBox(height: 16.0),

                        SizedBox(
                          height: 45,
                          width: 140,

                          child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const AdminServices()), // Navigate to AdminServices
                            );
                          },
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(Theme.of(context).secondaryHeaderColor),
                            side: WidgetStateProperty.all(BorderSide(width: 2.0, color: Theme.of(context).secondaryHeaderColor)),
                            shape: WidgetStateProperty.all(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            )),
                          ),
                          child: Text(
                            'ADMIN PAGE', // Button text
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
                  ),
                ],
              ),
            ),
          ),
          if (isSettingsOpen)
            AppSettingsDrawer(
              onThemeChanged: widget.onThemeChanged,
              onClose: () => setState(() => isSettingsOpen = false), // closes settings
          ),
        ],
      ),
    );
  }
}

class AppSettingsDrawer extends StatelessWidget{
  final Function(LsiThemes) onThemeChanged;
  final VoidCallback onClose;

  const AppSettingsDrawer({Key? key, required this.onThemeChanged, required this.onClose}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: FractionallySizedBox(
        widthFactor: 0.3,
        heightFactor: 1.0,
        child: Material(
          elevation: 16,
          color:Theme.of(context).canvasColor,
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                ),
                child: Text(
                  'App Settings',
                  style: TextStyle(
                    color: Theme.of(context).secondaryHeaderColor,
                    fontSize: 24,
                  ),
                ),
              ),
              ListTile(
                title: const Text('Theme'),
                trailing: DropdownButton<LsiThemes>(
                  value: LsiThemes.light,  
                  items: LsiThemes.values.map((LsiThemes theme) {
                    return DropdownMenuItem<LsiThemes>(
                      value: theme,
                      child: Text(theme.name),
                    );
                  }).toList(),
                  onChanged: (LsiThemes? newTheme) {
                    if (newTheme != null) {
                      onThemeChanged(newTheme);  
                    }
                  },                
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.close),
                title: const Text('Close Settings'),
                onTap: onClose,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HoverImageTile extends StatefulWidget {
  final String assetPath;
  final String desc;

  const HoverImageTile({super.key, required this.assetPath, required this.desc});

  @override
  State<HoverImageTile> createState() => _HoverImageTileState();
}

class _HoverImageTileState extends State<HoverImageTile> {
  
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Stack(
        children: [
          Container( // function for the cards with info in them
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 5,
                  offset: const Offset(7, 7),
                ),
              ],
            ),

            height: 250,
            width: 300,
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.all(10),
           
            child: Column(
              children: <Widget>[
                Image.asset(widget.assetPath, width: 175, height: 175),

                Text(
                  widget.desc,
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).primaryColorLight : Theme.of(context).primaryColorDark,
                    fontSize: 15,
                    fontFamily: 'Klavika',
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

class NewOrder {
  final String process;
  final String unit;
  final String type;
  final int quantity;
  final double rate;
  final double estimatedPrice;
  String filePath; 
  final String dateSubmitted; 
  final String journalTransferNumber; 
  final String department; 

  NewOrder
  (
    {
      required this.process,
      required this.unit,
      required this.type,
      required this.quantity,
      required this.rate,
      required this.estimatedPrice,
      required this.filePath,
      required this.dateSubmitted, 
      required this.journalTransferNumber, 
      required this.department,
    }
  );
}

class CreateOrderPage extends StatefulWidget{
  const CreateOrderPage( { super.key }) ;

  @override
  CreateOrderPageState createState() => CreateOrderPageState();
}

class CreateOrderPageState extends State<CreateOrderPage>{
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

  int orderNumber = 1;

  void _submitOrder(BuildContext context) async {
    if (_formKey.currentState?.validate() ?? false) {

      String formattedOrderNumber = orderNumber.toString().padLeft(3, '0');

      double estimatedPrice = _volume * _rate * _quantity;
      NewOrder newOrder = NewOrder(
        process: _selectedProcess,
        unit: _selectedUnit,
        type: _selectedType,
        quantity: _quantity,
        rate: _rate,
        estimatedPrice: estimatedPrice,
        filePath: '',
        dateSubmitted: _dateSubmitted,
        journalTransferNumber: _journalTransferNumber,
        department: _department
      );

      if (_filePath != null && _fileBytes != null) {
        newOrder.filePath = _fileName!;    
      }
      globalOrderDetails = OrderDetails()
        ..orderNumber = formattedOrderNumber
        ..userName = _nameController.text
        ..rate = _rate
        ..type = _selectedType
        ..quantity = _quantity
        ..process = _selectedProcess
        ..unit = _selectedUnit;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order submitted! Your Order ID is $formattedOrderNumber')),
      );

      setState(() {
        orderNumber++;
      });
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
                    color:
                      currentTheme == CSS.hallowTheme
                      ? Theme.of(context).cardColor
                      : currentTheme == CSS.darkTheme
                      ? Theme.of(context).unselectedWidgetColor
                      : currentTheme == CSS.mintTheme
                      ? Theme.of(context).tabBarTheme.indicatorColor
                      : currentTheme == CSS.lsiTheme
                      ? Theme.of(context).splashColor
                      : currentTheme == CSS.pinkTheme
                      ? Theme.of(context).tabBarTheme.indicatorColor
                      : Theme.of(context).splashColor,
                    borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      labelStyle: TextStyle(
                        color:
                              currentTheme == CSS.hallowTheme
                              ? Theme.of(context).secondaryHeaderColor
                              : currentTheme == CSS.darkTheme
                              ? Theme.of(context).secondaryHeaderColor
                              : currentTheme == CSS.mintTheme
                              ? Theme.of(context).secondaryHeaderColor
                              : currentTheme == CSS.lsiTheme
                              ? Theme.of(context).secondaryHeaderColor
                              : currentTheme == CSS.pinkTheme
                              ? Theme.of(context).secondaryHeaderColor
                              : Theme.of(context).highlightColor,
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
                    color:
                      currentTheme == CSS.hallowTheme
                      ? Theme.of(context).cardColor
                      : currentTheme == CSS.darkTheme
                      ? Theme.of(context).unselectedWidgetColor
                      : currentTheme == CSS.mintTheme
                      ? Theme.of(context).tabBarTheme.indicatorColor
                      : currentTheme == CSS.lsiTheme
                      ? Theme.of(context).splashColor
                      : currentTheme == CSS.pinkTheme
                      ? Theme.of(context).tabBarTheme.indicatorColor
                      : Theme.of(context).splashColor,
                    borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: TextFormField(
                    controller: _journalNumController,
                    decoration: InputDecoration(
                      labelText: 'Journal Transfer Number',
                      labelStyle: TextStyle(
                        color:
                              currentTheme == CSS.hallowTheme
                              ? Theme.of(context).secondaryHeaderColor
                              : currentTheme == CSS.darkTheme
                              ? Theme.of(context).secondaryHeaderColor
                              : currentTheme == CSS.mintTheme
                              ? Theme.of(context).secondaryHeaderColor
                              : currentTheme == CSS.lsiTheme
                              ? Theme.of(context).secondaryHeaderColor
                              : currentTheme == CSS.pinkTheme
                              ? Theme.of(context).secondaryHeaderColor
                              : Theme.of(context).highlightColor,
                        fontFamily: 'Klavika',
                        fontWeight: FontWeight.normal,
                        fontSize: 12.0,
                      ),
                    ),
                    style: TextStyle(color: Theme.of(context).secondaryHeaderColor),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a journal transfer number';
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
                    color:
                      currentTheme == CSS.hallowTheme
                      ? Theme.of(context).cardColor
                      : currentTheme == CSS.darkTheme
                      ? Theme.of(context).unselectedWidgetColor
                      : currentTheme == CSS.mintTheme
                      ? Theme.of(context).tabBarTheme.indicatorColor
                      : currentTheme == CSS.lsiTheme
                      ? Theme.of(context).splashColor
                      : currentTheme == CSS.pinkTheme
                      ? Theme.of(context).tabBarTheme.indicatorColor
                      : Theme.of(context).splashColor,
                    borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: TextFormField(
                    controller: _departmentController,
                    decoration: InputDecoration(
                      labelText: 'Department',
                      labelStyle: TextStyle(
                        color:
                              currentTheme == CSS.hallowTheme
                              ? Theme.of(context).secondaryHeaderColor
                              : currentTheme == CSS.darkTheme
                              ? Theme.of(context).secondaryHeaderColor
                              : currentTheme == CSS.mintTheme
                              ? Theme.of(context).secondaryHeaderColor
                              : currentTheme == CSS.lsiTheme
                              ? Theme.of(context).secondaryHeaderColor
                              : currentTheme == CSS.pinkTheme
                              ? Theme.of(context).secondaryHeaderColor
                              : Theme.of(context).highlightColor,
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
                    color:
                      currentTheme == CSS.hallowTheme
                      ? Theme.of(context).cardColor
                      : currentTheme == CSS.darkTheme
                      ? Theme.of(context).unselectedWidgetColor
                      : currentTheme == CSS.mintTheme
                      ? Theme.of(context).tabBarTheme.indicatorColor
                      : currentTheme == CSS.lsiTheme
                      ? Theme.of(context).splashColor
                      : currentTheme == CSS.pinkTheme
                      ? Theme.of(context).tabBarTheme.indicatorColor
                      : Theme.of(context).splashColor,
                    borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        labelStyle: TextStyle(
                          color:
                            currentTheme == CSS.hallowTheme
                            ? Theme.of(context).secondaryHeaderColor
                            : currentTheme == CSS.darkTheme
                            ? Theme.of(context).secondaryHeaderColor
                            : currentTheme == CSS.mintTheme
                            ? Theme.of(context).secondaryHeaderColor
                            : currentTheme == CSS.lsiTheme
                            ? Theme.of(context).secondaryHeaderColor
                            : currentTheme == CSS.pinkTheme
                            ? Theme.of(context).secondaryHeaderColor
                            : Theme.of(context).highlightColor, // Default Light theme
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
                      color:
                      currentTheme == CSS.hallowTheme
                      ? Theme.of(context).cardColor
                      : currentTheme == CSS.darkTheme
                      ? Theme.of(context).unselectedWidgetColor
                      : currentTheme == CSS.mintTheme
                      ? Theme.of(context).tabBarTheme.indicatorColor
                      : currentTheme == CSS.lsiTheme
                      ? Theme.of(context).splashColor
                      : currentTheme == CSS.pinkTheme
                      ? Theme.of(context).tabBarTheme.indicatorColor
                      : Theme.of(context).splashColor,
                    borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: TextFormField(
                      controller: _journalNumController,
                      decoration: InputDecoration(
                        labelText: 'Journal Transfer Number',
                        labelStyle: TextStyle(
                          color:
                            currentTheme == CSS.hallowTheme
                            ? Theme.of(context).secondaryHeaderColor
                            : currentTheme == CSS.darkTheme
                            ? Theme.of(context).secondaryHeaderColor
                            : currentTheme == CSS.mintTheme
                            ? Theme.of(context).secondaryHeaderColor
                            : currentTheme == CSS.lsiTheme
                            ? Theme.of(context).secondaryHeaderColor
                            : currentTheme == CSS.pinkTheme
                            ? Theme.of(context).secondaryHeaderColor
                            : Theme.of(context).highlightColor,
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
                      color:
                      currentTheme == CSS.hallowTheme
                      ? Theme.of(context).cardColor
                      : currentTheme == CSS.darkTheme
                      ? Theme.of(context).unselectedWidgetColor
                      : currentTheme == CSS.mintTheme
                      ? Theme.of(context).tabBarTheme.indicatorColor
                      : currentTheme == CSS.lsiTheme
                      ? Theme.of(context).splashColor
                      : currentTheme == CSS.pinkTheme
                      ? Theme.of(context).tabBarTheme.indicatorColor
                      : Theme.of(context).splashColor,
                    borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: TextFormField(
                      controller: _departmentController,
                      decoration: InputDecoration(
                        labelText: 'Department',
                        labelStyle: TextStyle(
                          color:
                            currentTheme == CSS.hallowTheme
                            ? Theme.of(context).secondaryHeaderColor
                            : currentTheme == CSS.darkTheme
                            ? Theme.of(context).secondaryHeaderColor
                            : currentTheme == CSS.mintTheme
                            ? Theme.of(context).secondaryHeaderColor
                            : currentTheme == CSS.lsiTheme
                            ? Theme.of(context).secondaryHeaderColor
                            : currentTheme == CSS.pinkTheme
                            ? Theme.of(context).secondaryHeaderColor
                            : Theme.of(context).highlightColor,
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
              color:
                  currentTheme == CSS.hallowTheme
                  ? Theme.of(context).primaryColorLight
                  : currentTheme == CSS.darkTheme
                  ? Theme.of(context).primaryColorLight
                  : currentTheme == CSS.mintTheme
                  ? Theme.of(context).primaryColorLight
                  : currentTheme == CSS.lsiTheme
                  ? Theme.of(context).primaryColorLight // MAKE WHITE
                  : currentTheme == CSS.pinkTheme
                  ? Theme.of(context).primaryColorLight
                  : Theme.of(context).primaryColorLight,
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
              color:
                  currentTheme == CSS.hallowTheme
                  ? Theme.of(context).secondaryHeaderColor
                  : currentTheme == CSS.darkTheme
                  ? Theme.of(context).secondaryHeaderColor
                  : currentTheme == CSS.mintTheme
                  ? Theme.of(context).shadowColor
                  : currentTheme == CSS.lsiTheme
                  ? Theme.of(context).shadowColor
                  : currentTheme == CSS.pinkTheme
                  ? Theme.of(context).shadowColor
                  : Theme.of(context).secondaryHeaderColor,
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
              color:
                  currentTheme == CSS.hallowTheme
                  ? Theme.of(context).secondaryHeaderColor
                  : currentTheme == CSS.darkTheme
                  ? Theme.of(context).secondaryHeaderColor
                  : currentTheme == CSS.mintTheme
                  ? Theme.of(context).shadowColor
                  : currentTheme == CSS.lsiTheme
                  ? Theme.of(context).shadowColor
                  : currentTheme == CSS.pinkTheme
                  ? Theme.of(context).shadowColor
                  : Theme.of(context).secondaryHeaderColor,
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
              color:
                  currentTheme == CSS.hallowTheme
                  ? Theme.of(context).secondaryHeaderColor
                  : currentTheme == CSS.darkTheme
                  ? Theme.of(context).secondaryHeaderColor
                  : currentTheme == CSS.mintTheme
                  ? Theme.of(context).shadowColor
                  : currentTheme == CSS.lsiTheme
                  ? Theme.of(context).shadowColor
                  : currentTheme == CSS.pinkTheme
                  ? Theme.of(context).shadowColor
                  : Theme.of(context).secondaryHeaderColor,
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
              color:
                  currentTheme == CSS.hallowTheme
                  ? Theme.of(context).secondaryHeaderColor
                  : currentTheme == CSS.darkTheme
                  ? Theme.of(context).secondaryHeaderColor
                  : currentTheme == CSS.mintTheme
                  ? Theme.of(context).secondaryHeaderColor
                  : currentTheme == CSS.lsiTheme
                  ? Theme.of(context).secondaryHeaderColor
                  : currentTheme == CSS.pinkTheme
                  ? Theme.of(context).secondaryHeaderColor
                  : Theme.of(context).secondaryHeaderColor,
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
              color:
                  currentTheme == CSS.hallowTheme
                  ? Theme.of(context).secondaryHeaderColor
                  : currentTheme == CSS.darkTheme
                  ? Theme.of(context).secondaryHeaderColor
                  : currentTheme == CSS.mintTheme
                  ? Theme.of(context).shadowColor
                  : currentTheme == CSS.lsiTheme
                  ? Theme.of(context).shadowColor
                  : currentTheme == CSS.pinkTheme
                  ? Theme.of(context).shadowColor
                  : Theme.of(context).secondaryHeaderColor,
              fontFamily: 'Klavika',
              fontWeight: FontWeight.normal,
            ),
          ),
          Text(
            'Unit: $_selectedUnit',
            style: TextStyle(
              fontSize: 20.0,
              color:
                  currentTheme == CSS.hallowTheme
                  ? Theme.of(context).secondaryHeaderColor
                  : currentTheme == CSS.darkTheme
                  ? Theme.of(context).secondaryHeaderColor
                  : currentTheme == CSS.mintTheme
                  ? Theme.of(context).shadowColor
                  : currentTheme == CSS.lsiTheme
                  ? Theme.of(context).shadowColor
                  : currentTheme == CSS.pinkTheme
                  ? Theme.of(context).shadowColor
                  : Theme.of(context).secondaryHeaderColor,
              fontFamily: 'Klavika',
              fontWeight: FontWeight.normal,
            ),
          ),
          Text(
            'Type: $_selectedType',
            style: TextStyle(
              fontSize: 20.0,
              color:
                  currentTheme == CSS.hallowTheme
                  ? Theme.of(context).secondaryHeaderColor
                  : currentTheme == CSS.darkTheme
                  ? Theme.of(context).secondaryHeaderColor
                  : currentTheme == CSS.mintTheme
                  ? Theme.of(context).shadowColor
                  : currentTheme == CSS.lsiTheme
                  ? Theme.of(context).shadowColor
                  : currentTheme == CSS.pinkTheme
                  ? Theme.of(context).shadowColor
                  : Theme.of(context).secondaryHeaderColor,
              fontFamily: 'Klavika',
              fontWeight: FontWeight.normal,
            ),
          ),
          Text(
            'Quantity: $_quantity',
            style: TextStyle(
              fontSize: 20.0,
              color:
                  currentTheme == CSS.hallowTheme
                  ? Theme.of(context).secondaryHeaderColor
                  : currentTheme == CSS.darkTheme
                  ? Theme.of(context).secondaryHeaderColor
                  : currentTheme == CSS.mintTheme
                  ? Theme.of(context).shadowColor
                  : currentTheme == CSS.lsiTheme
                  ? Theme.of(context).shadowColor
                  : currentTheme == CSS.pinkTheme
                  ? Theme.of(context).shadowColor
                  : Theme.of(context).secondaryHeaderColor,
              fontFamily: 'Klavika',
              fontWeight: FontWeight.normal,
            ),
          ),
          Text(
            'Rate: $_rate per cubic unit',
            style: TextStyle(
              fontSize: 20.0,
              color:
                  currentTheme == CSS.hallowTheme
                  ? Theme.of(context).secondaryHeaderColor
                  : currentTheme == CSS.darkTheme
                  ? Theme.of(context).secondaryHeaderColor
                  : currentTheme == CSS.mintTheme
                  ? Theme.of(context).shadowColor
                  : currentTheme == CSS.lsiTheme
                  ? Theme.of(context).shadowColor
                  : currentTheme == CSS.pinkTheme
                  ? Theme.of(context).shadowColor
                  : Theme.of(context).secondaryHeaderColor,
              fontFamily: 'Klavika',
              fontWeight: FontWeight.normal,
            ),
          ),
          Text(
            'Estimated Price: \$${(_volume * _rate * _quantity).toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 20.0,
              color:
                  currentTheme == CSS.hallowTheme
                  ? Theme.of(context).secondaryHeaderColor
                  : currentTheme == CSS.darkTheme
                  ? Theme.of(context).secondaryHeaderColor
                  : currentTheme == CSS.mintTheme
                  ? Theme.of(context).shadowColor
                  : currentTheme == CSS.lsiTheme
                  ? Theme.of(context).shadowColor
                  : currentTheme == CSS.pinkTheme
                  ? Theme.of(context).shadowColor
                  : Theme.of(context).secondaryHeaderColor,
              fontFamily: 'Klavika',
              fontWeight: FontWeight.normal,
            ),
          ),
          Text(
            'Estimated Delivery:',
            style: TextStyle(
              fontSize: 20.0,
              color:
                  currentTheme == CSS.hallowTheme
                  ? Theme.of(context).secondaryHeaderColor
                  : currentTheme == CSS.darkTheme
                  ? Theme.of(context).secondaryHeaderColor
                  : currentTheme == CSS.mintTheme
                  ? Theme.of(context).shadowColor
                  : currentTheme == CSS.lsiTheme
                  ? Theme.of(context).shadowColor
                  : currentTheme == CSS.pinkTheme
                  ? Theme.of(context).shadowColor
                  : Theme.of(context).secondaryHeaderColor,
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
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CreateSubmitPage()),
        );
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

  @override
  Widget build(BuildContext context) {
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

              child: Column(
                children: <Widget> [
                  Text(
                    'Order Submitted!',
                    style: TextStyle(
                      fontSize: 25,
                      color:
                        currentTheme == CSS.hallowTheme
                        ? Theme.of(context).secondaryHeaderColor
                        : currentTheme == CSS.darkTheme
                        ? Theme.of(context).secondaryHeaderColor
                        : currentTheme == CSS.mintTheme
                        ? Theme.of(context).shadowColor
                        : currentTheme == CSS.lsiTheme
                        ? Theme.of(context).shadowColor
                        : currentTheme == CSS.pinkTheme
                        ? Theme.of(context).shadowColor
                        : Theme.of(context).secondaryHeaderColor,
                      fontFamily: 'Klavika',
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Text(
                    'Order #${globalOrderDetails.orderNumber}',
                    style: TextStyle(
                      fontSize: 16,
                      color:
                        currentTheme == CSS.hallowTheme
                        ? Theme.of(context).secondaryHeaderColor
                        : currentTheme == CSS.darkTheme
                        ? Theme.of(context).secondaryHeaderColor
                        : currentTheme == CSS.mintTheme
                        ? Theme.of(context).shadowColor
                        : currentTheme == CSS.lsiTheme
                        ? Theme.of(context).shadowColor
                        : currentTheme == CSS.pinkTheme
                        ? Theme.of(context).shadowColor
                        : Theme.of(context).secondaryHeaderColor,
                      fontFamily: 'Klavika',
                      fontWeight: FontWeight.normal,
                      decoration: TextDecoration.underline,
                    ),
                  ),

                  Text(
                    'Details:',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 16,
                      color:
                        currentTheme == CSS.hallowTheme
                        ? Theme.of(context).secondaryHeaderColor
                        : currentTheme == CSS.darkTheme
                        ? Theme.of(context).secondaryHeaderColor
                        : currentTheme == CSS.mintTheme
                        ? Theme.of(context).shadowColor
                        : currentTheme == CSS.lsiTheme
                        ? Theme.of(context).shadowColor
                        : currentTheme == CSS.pinkTheme
                        ? Theme.of(context).shadowColor
                        : Theme.of(context).secondaryHeaderColor,
                      fontFamily: 'Klavika',
                      fontWeight: FontWeight.normal,
                    ),
                  ),


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

class TrackOrderPage extends StatefulWidget {
  const TrackOrderPage({super.key});

  @override
  TrackOrderPageState createState() => TrackOrderPageState();
}

class TrackOrderPageState extends State<TrackOrderPage> {
  final TextEditingController _orderIdController = TextEditingController();
  final double _volume = 100.0;

  bool _isTracking = false;

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
                          color:
                            currentTheme == CSS.hallowTheme
                            ? Theme.of(context).secondaryHeaderColor
                            : currentTheme == CSS.darkTheme
                            ? Theme.of(context).primaryColorLight
                            : currentTheme == CSS.mintTheme
                            ? Theme.of(context).shadowColor
                            : currentTheme == CSS.lsiTheme
                            ? Theme.of(context).shadowColor
                            : currentTheme == CSS.pinkTheme
                            ? Theme.of(context).unselectedWidgetColor
                            : Theme.of(context).primaryColorDark,
                          fontFamily: 'Klavika',
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      style: TextStyle(color: Theme.of(context).unselectedWidgetColor),
                    ),

                    const SizedBox(height: 16.0),
                    
                    ElevatedButton(
                      onPressed: _trackOrder,
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
                      'Hi, ${globalOrderDetails.userName}',
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
                              color:
                                currentTheme == CSS.hallowTheme
                                ? Theme.of(context).hoverColor
                                : currentTheme == CSS.darkTheme
                                ? Theme.of(context).hintColor
                                : currentTheme == CSS.mintTheme
                                ? Theme.of(context).shadowColor
                                : currentTheme == CSS.lsiTheme
                                ? Theme.of(context).shadowColor
                                : currentTheme == CSS.pinkTheme
                                ? Theme.of(context).shadowColor
                                : Theme.of(context).primaryColorDark, 
                              fontFamily: 'Klavika',
                              fontWeight: FontWeight.normal,
                              fontSize: 16.0,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              globalOrderDetails.orderNumber,
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
                              color:
                                currentTheme == CSS.hallowTheme
                                ? Theme.of(context).hoverColor
                                : currentTheme == CSS.darkTheme
                                ? Theme.of(context).hintColor
                                : currentTheme == CSS.mintTheme
                                ? Theme.of(context).shadowColor
                                : currentTheme == CSS.lsiTheme
                                ? Theme.of(context).shadowColor
                                : currentTheme == CSS.pinkTheme
                                ? Theme.of(context).shadowColor
                                : Theme.of(context).primaryColorDark, 
                              fontFamily: 'Klavika',
                              fontWeight: FontWeight.normal,
                              fontSize: 16.0,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              globalOrderDetails.userName,
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
                              color:
                                currentTheme == CSS.hallowTheme
                                ? Theme.of(context).hoverColor
                                : currentTheme == CSS.darkTheme
                                ? Theme.of(context).hintColor
                                : currentTheme == CSS.mintTheme
                                ? Theme.of(context).shadowColor
                                : currentTheme == CSS.lsiTheme
                                ? Theme.of(context).shadowColor
                                : currentTheme == CSS.pinkTheme
                                ? Theme.of(context).shadowColor
                                : Theme.of(context).primaryColorDark, 
                              fontFamily: 'Klavika',
                              fontWeight: FontWeight.normal,
                              fontSize: 16.0,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              globalOrderDetails.process,
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
                              color:
                                currentTheme == CSS.hallowTheme
                                ? Theme.of(context).hoverColor
                                : currentTheme == CSS.darkTheme
                                ? Theme.of(context).hintColor
                                : currentTheme == CSS.mintTheme
                                ? Theme.of(context).shadowColor
                                : currentTheme == CSS.lsiTheme
                                ? Theme.of(context).shadowColor
                                : currentTheme == CSS.pinkTheme
                                ? Theme.of(context).shadowColor
                                : Theme.of(context).primaryColorDark,
                              fontFamily: 'Klavika',
                              fontWeight: FontWeight.normal,
                              fontSize: 16.0,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              globalOrderDetails.unit,
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
                              color:
                                currentTheme == CSS.hallowTheme
                                ? Theme.of(context).hoverColor
                                : currentTheme == CSS.darkTheme
                                ? Theme.of(context).hintColor
                                : currentTheme == CSS.mintTheme
                                ? Theme.of(context).shadowColor
                                : currentTheme == CSS.lsiTheme
                                ? Theme.of(context).shadowColor
                                : currentTheme == CSS.pinkTheme
                                ? Theme.of(context).shadowColor
                                : Theme.of(context).primaryColorDark,
                              fontFamily: 'Klavika',
                              fontWeight: FontWeight.normal,
                              fontSize: 16.0,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              globalOrderDetails.type,
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
                              color:
                                currentTheme == CSS.hallowTheme
                                ? Theme.of(context).hoverColor
                                : currentTheme == CSS.darkTheme
                                ? Theme.of(context).hintColor
                                : currentTheme == CSS.mintTheme
                                ? Theme.of(context).shadowColor
                                : currentTheme == CSS.lsiTheme
                                ? Theme.of(context).shadowColor
                                : currentTheme == CSS.pinkTheme
                                ? Theme.of(context).shadowColor
                                : Theme.of(context).primaryColorDark, 
                              fontFamily: 'Klavika',
                              fontWeight: FontWeight.normal,
                              fontSize: 16.0,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              globalOrderDetails.quantity.toString(),
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
                              color:
                                currentTheme == CSS.hallowTheme
                                ? Theme.of(context).hoverColor
                                : currentTheme == CSS.darkTheme
                                ? Theme.of(context).hintColor
                                : currentTheme == CSS.mintTheme
                                ? Theme.of(context).shadowColor
                                : currentTheme == CSS.lsiTheme
                                ? Theme.of(context).shadowColor
                                : currentTheme == CSS.pinkTheme
                                ? Theme.of(context).shadowColor
                                : Theme.of(context).primaryColorDark,
                              fontFamily: 'Klavika',
                              fontWeight: FontWeight.normal,
                              fontSize: 16.0,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              '${globalOrderDetails.rate} per cubic unit',
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
                              color:
                                currentTheme == CSS.hallowTheme
                                ? Theme.of(context).hoverColor
                                : currentTheme == CSS.darkTheme
                                ? Theme.of(context).hintColor
                                : currentTheme == CSS.mintTheme
                                ? Theme.of(context).shadowColor
                                : currentTheme == CSS.lsiTheme
                                ? Theme.of(context).shadowColor
                                : currentTheme == CSS.pinkTheme
                                ? Theme.of(context).shadowColor
                                : Theme.of(context).primaryColorDark,
                              fontFamily: 'Klavika',
                              fontWeight: FontWeight.normal,
                              fontSize: 16.0,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              '\$${(_volume * (globalOrderDetails.rate) * (globalOrderDetails.quantity)).toStringAsFixed(2)}',
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
  final String orderNumber = globalOrderDetails.orderNumber;

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


  void _trackOrder() {
    setState(() {
      //_orderStatus = 'Results for Order #${_orderIdController.text}:';
      _isTracking = true;
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
            color: isCompleted 
              ? (Theme.of(context).primaryColorLight)  // Default for completed
              : (currentTheme ==  CSS.mintTheme
                  ? Theme.of(context).splashColor
                  : currentTheme == CSS.lsiTheme
                  ? Theme.of(context).unselectedWidgetColor
                  : currentTheme == CSS.pinkTheme
                  ? Theme.of(context).canvasColor
                  : Theme.of(context).primaryColorLight), // Default for not completed
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

class OrderDetails {
  String orderNumber = '';
  String userName = '';
  double rate = 0.0;
  String type = '';
  int quantity = 0;
  String process = '';
  String unit = '';
}

OrderDetails globalOrderDetails = OrderDetails();

