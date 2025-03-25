// Copy model from json type and convert for hive model
//Note model name Will be add but add "Hive" before hive model name
// Then run flutter packages pub run build_runner build --delete-conflicting-outputs
// Adn register adapter in _registerAdapters main function

// import 'package:broker_buddy/application/hive_db/db_main.dart';
// await DbMain.instance.hiveAddItem("property_list_box", PropertyModel(id: 3,propertyTitle: "Demo Property 3").toJson());
// await DbMain.instance.updateItem("property_list_box",3,PropertyModel(propertyTitle: "Demo Property 4").toJson());
// var value = await DbMain.instance.hiveGetItemList("property_list_box",PropertyModel.fromJson);
// print("");