# hive-simple

This is a Hive-based Flutter package designed to simplify data storage and management.
We have created a set of custom functions to add, update, and delete data, making it easy to
interact with your Hive database. The package eliminates the need to add a separate adapter for each
table, providing a more flexible and efficient way to manage data across your Flutter project.

You can use this package in any Flutter project, including those built with FlutterFlow. For
FlutterFlow users, you can easily create tables directly from the FlutterFlow constants.

|             | Android | iOS   |
|:------------|:--------|:------|
| **Support** | SDK 21+ | 10.0+ |

## Features

Use this plugin in your Flutter app to:

* Easy to store data by calling await DbMain.instance.hiveAddItem(
  tableName,
  data, {
  E Function(Map<String, dynamic>)? returnType,
  bool? isAddedLocally = false,
  String? keyToAvoidDuplicateEntry,
  })
* Easy to fetch data. calling await DbMain.instance.hiveGetItemList(
  String tableName, {
  E Function(Map<String, dynamic>)? fromJson, bool? isResentOnTop = true
  })

## Getting started

This plugin relies on the flutter core.

## Usage

To use the plugin you just need to add hive_simple: ^1.0.2 into your pubspec.yaml file and run
pub get.

#### Add following into your package's pubspec.yaml (and run an implicit dart pub get):

hive_simple: ^1.0.2

## Example

     import 'package:flutter/material.dart';
    import 'package:hive_simple/hive_simple.dart';
    
    void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    // Add your function code here!
    // Init Hive Db by call below 
    await DbMain.instance.dbInit();
    // Add your hive box you have to add box before using it in init method
    await DbMain.instance.createNewTable(["users","product"]);
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

## Changelog

All notable changes to this project will be documented in [this file](./CHANGELOG.md).

## Issues

To report your issues, submit them directly in
the [Issues](https://github.com/dexbytesinfotech/hive-simple/issues) section.

## License

[this file](./LICENSE).
