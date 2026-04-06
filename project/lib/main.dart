import 'package:flutter/material.dart';

// imported files
import 'admin_eng/services/order_service.dart';
import 'admin_eng/admin.dart';
import 'track_order/track_order.dart';
import 'create_order/create_order.dart';
import 'css/css.dart';

ThemeData currentTheme = CSS.lightTheme;

int orderLength = 0;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // loads in JSON file info
  try {
    await OrderService().init();
  } catch (e) {
    debugPrint("Error initializing OrderService: $e");
  }

  orderLength = OrderService().orders.length;

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

  Widget _buildInfoCard(String imagePath, String text) {
    return HoverImageTile(
      assetPath: imagePath,
      desc: text,
    );
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
                  SizedBox( // left side of the screen
                    height: screenHeight - kToolbarHeight,
                    width: screenWidth / 3,
                    child: Container(
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
                      child: ListView(
                        shrinkWrap: true, 
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        children: [
                          Center(
                            child: _buildInfoCard('assets/images/emb_printer_3d_lg.png', '3D Printing'),
                          ),
                          const SizedBox(height: 15),
                          Center(
                            child: _buildInfoCard('assets/images/emb_mill_lg.png', 'Milling'),
                          ),
                          const SizedBox(height: 15),
                          Center(
                            child: _buildInfoCard('assets/images/emb_thermoform_lg.png', 'Thermoforming'),
                          ),
                        ],
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
                              MaterialPageRoute(builder: (context) => const AdminPage()), // Navigate to AdminPage
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
