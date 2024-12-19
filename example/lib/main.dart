import 'package:flutter/material.dart';
import 'package:hive_simple/hive_simple.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Add your function code here!
  await DbMain.instance.dbInit();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  /// This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voice Assistant',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyAppPage(title: 'Voice Assistant'),
    );
  }
}
///Example project main Screen
class MyAppPage extends StatefulWidget {
  const MyAppPage({super.key, required this.title});

  final String title;

  @override
  State<MyAppPage> createState() => _MyAppPageState();
}
class _MyAppPageState extends State<MyAppPage> {
  String textStringValue = "";
  List<dynamic> searchedData = [];
  bool isSearching = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(
            color: Colors.black, //change your color here
          ),
          title:
              Text(widget.title, style: const TextStyle(color: Colors.black)),
          centerTitle: true,
          elevation: 2.5,
          actions: [
            InkWell(
                onTap: () {
                },
                child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    child: const Icon(
                      Icons.list_alt,
                    )))
          ],
        ),
        body: Center(
          /// Center is a layout widget. It takes a single child and positions it
          /// in the middle of the parent.
          child: Container(),
        ));
  }
}
