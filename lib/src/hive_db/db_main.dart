import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import 'model/dynamic_data_model.dart';

part 'response_wrapper.dart';

/// Run the following command to generate code:
/// flutter packages pub run build_runner build --delete-conflicting-outputs
class DbMain {
  // Singleton instance
  static final DbMain instance = DbMain._internal();
  static bool _isDbInit = false;

  // Box names
  final TablesName tablesName = TablesName();

  /// All current Created Table name
  static List<String>? _tableNameList;

  // Factory constructor to return the singleton instance
  factory DbMain() => instance;

  // Private constructor for singleton
  DbMain._internal();

  /// Initialize Hive database
  Future<bool> dbInit() async {
    if (_isDbInit) return true;
    try {
      final directory = await getApplicationDocumentsDirectory();
      Hive.init(directory.path);
      _registerAdapters();
      _isDbInit = true;
      _tableNameList ??= [];
      await _fetchAndOpenBoxTable();
    } catch (e) {
      debugPrint("Error initializing Hive: $e");
    }
    return _isDbInit;
  }

  Future<ResponseWrapper?> _fetchAndOpenBoxTable() async {
    if (_isDbInit) {
      try {
        _tableNameList ??= [];

        if (_tableNameList!.isEmpty) {
          ResponseWrapper result = await hiveGetItemList(tablesName._dbTables);
          if (result.isSuccess &&
              result.data != null &&
              result.data!.isNotEmpty &&
              result.data!["result"].isNotEmpty) {
            for (Map<String, String> tableNameMap in result.data!["result"]) {
              String? tableName = tableNameMap['table_name'];
              if (tableName != null && tableName.isNotEmpty) {
                try {
                  _registerAdapters();
                  await openDatabaseBoxes(tableName: tableName);
                  if (!_tableNameList!.contains(tableName)) {
                    _tableNameList!.add(tableName);
                  }
                } catch (e) {
                  debugPrint("$e");
                }
              }
            }
          } else {
            return result;
          }
        } else {
          for (String tableName in _tableNameList!) {
            if (tableName.isNotEmpty) {
              try {
                _registerAdapters();
                await openDatabaseBoxes(tableName: tableName);
              } catch (e) {
                debugPrint("$e");
              }
            }
          }
        }
      } catch (e) {
        debugPrint("Error initializing Hive: $e");
      }
      return ResponseWrapper(
        isSuccess: true,
        message: "Opened successfully",
        data: {},
      );
    }
    return ResponseWrapper(
      isSuccess: false,
      message: "Please inti DB by calling dbInit()",
      data: null,
    );
  }

  /// Register Hive adapters if not registered
  void _registerAdapters() {
    if (!Hive.isAdapterRegistered(0)) {
      try {
        Hive.registerAdapter(HiveDynamicDataModelAdapter());
      } catch (e) {
        debugPrint("Error registering adapter: $e");
      }
    }
  }

  /// Call this function to create multi table by single call
  Future<ResponseWrapper?> createNewTable(List<String> tableNameList) async {
    if (_isDbInit) {
      try {
        _tableNameList ??= [];
        if (tableNameList.isNotEmpty) {
          for (String tableName in tableNameList) {
            if (tableName.isNotEmpty) {
              if (!_tableNameList!.contains(tableName)) {
                ResponseWrapper result = await hiveAddItem(
                    tablesName._dbTables, {"table_name": tableName},
                    isAddedLocally: true);
                if (result.isSuccess) {
                  _registerAdapters();
                  await openDatabaseBoxes(tableName: tableName);
                  _tableNameList!.add(tableName);
                } else {
                  return result;
                }
              }
            }
          }
        }
      } catch (e) {
        debugPrint("Error initializing Hive: $e");
      }
      return ResponseWrapper(
        isSuccess: true,
        message: "${tableNameList.toString()} created successfully",
        data: {},
      );
    }
    return ResponseWrapper(
      isSuccess: false,
      message: "Please inti DB by calling dbInit()",
      data: null,
    );
  }

  /// Open necessary Hive boxes
  Future<void> openDatabaseBoxes({String? tableName}) async {
    try {
      /// Don't remove it because it is created for internal
      await tablesName._getHiveBoxForTable(tablesName._dbTables);
    } catch (e) {
      debugPrint("Error opening database box: $e");
    }
    try {
      /// Don't remove it because it is created for internal
      if (tableName != null && tableName.isNotEmpty) {
        await tablesName._getHiveBoxForTable(tableName);
      }
    } catch (e) {
      debugPrint("Error opening database box: $e");
    }
    //
    //
    // try {
    //   await tablesName._getHiveBoxForTable(tablesName.propertyListBox);
    // } catch (e) {
    //   debugPrint("Error opening database box: $e");
    // }
    //
    // try {
    //   await tablesName._getHiveBoxForTable(tablesName.usersBox);
    // } catch (e) {
    //   debugPrint("Error opening database box: $e");
    // }
    // try {
    //   await tablesName._getHiveBoxForTable(tablesName.contactBox);
    // } catch (e) {
    //   debugPrint("Error opening database box: $e");
    // }
    // try {
    //   await tablesName._getHiveBoxForTable(tablesName.leadBox);
    // } catch (e) {
    //   debugPrint("Error opening database box: $e");
    // }
    // try {
    //   await tablesName._getHiveBoxForTable(tablesName.assignBox);
    // } catch (e) {
    //   debugPrint("Error opening database box: $e");
    // }
    // try {
    //   await tablesName._getHiveBoxForTable(tablesName.followUpBox);
    // } catch (e) {
    //   debugPrint("Error opening database box: $e");
    // }
    // try {
    //   await tablesName._getHiveBoxForTable(tablesName.photosBox);
    // } catch (e) {
    //   debugPrint("Error opening database box: $e");
    // }
  }

  /// Clear all entries from the database
  Future<ResponseWrapper> dbClear() async {
    if (!_isDbInit) {
      return ResponseWrapper(
        isSuccess: false,
        message: "Please Enter init db first by calling dbInit()",
        data: null,
      );
    }

    _tableNameList ??= [];
    for (String tableName in _tableNameList!) {
      try {
        Box? box = await tablesName._getHiveBoxForTable(tableName);
        await box?.clear();
      } catch (e) {
        debugPrint("Error clearing database: $e");
      }
    }
    try {
      /// Don't remove it because it is created for internal
      Box? box = await tablesName._getHiveBoxForTable(tablesName._dbTables);
      await box?.clear();
      return ResponseWrapper(
        isSuccess: true,
        message: "Clear successfully",
        data: null,
      );
    } catch (e) {
      debugPrint("Error clearing database: $e");
    }
    // try {
    //   Box? box = await tablesName._getHiveBoxForTable(tablesName.propertyListBox);
    //   await box?.clear();
    // } catch (e) {
    //   debugPrint("Error clearing database: $e");
    // }
    // try {
    //   Box? box = await tablesName._getHiveBoxForTable(tablesName.usersBox);
    //   await box?.clear();
    // } catch (e) {
    //   debugPrint("Error clearing database: $e");
    // }
    // try {
    //   Box? box = await tablesName._getHiveBoxForTable(tablesName.contactBox);
    //   await box?.clear();
    // } catch (e) {
    //   debugPrint("Error clearing database: $e");
    // }
    // try {
    //   Box? box = await tablesName._getHiveBoxForTable(tablesName.leadBox);
    //   await box?.clear();
    // } catch (e) {
    //   debugPrint("Error clearing database: $e");
    // }
    // try {
    //   Box? box = await tablesName._getHiveBoxForTable(tablesName.assignBox);
    //   await box?.clear();
    // } catch (e) {
    //   debugPrint("Error clearing database: $e");
    // }
    // try {
    //   Box? box = await tablesName._getHiveBoxForTable(tablesName.photosBox);
    //   await box?.clear();
    // } catch (e) {
    //   debugPrint("Error clearing database: $e");
    // }
    // try {
    //   Box? box = await tablesName._getHiveBoxForTable(tablesName.followUpBox);
    //   await box?.clear();
    // } catch (e) {
    //   debugPrint("Error clearing database: $e");
    // }
    return ResponseWrapper(
      isSuccess: true,
      message: "Clear successfully",
      data: null,
    );
  }

  /// Delete all data from a specific table

  Future<ResponseWrapper> dbDeleteSelectedTable(
      {String columnName = ""}) async {
    if (columnName.trim().isEmpty) {
      return ResponseWrapper(
        isSuccess: false,
        message: "Please Enter Correct table name",
        data: null,
      );
    }

    if (!_isDbInit) await dbInit();
    try {
      var box = await tablesName._getHiveBoxForTable(columnName);
      if (box != null) {
        await box.clear();
      }
    } catch (e) {
      debugPrint("Error deleting data from table: $e");
    }
    return ResponseWrapper(
      isSuccess: true,
      message: "Deleted successfully",
      data: null,
    );
  }

  /// Close the Hive box
  // Future<void> _closeBdBox({String? boxName, bool? all = false}) async {
  //   if (boxName==null || boxName.trim().isEmpty && all==false) return;
  //
  //   if (!_isDbInit) await dbInit();
  //   try {
  //     if (boxName.trim().isNotEmpty){
  //     var box = await tablesName._getHiveBoxForTable(boxName);
  //     if(box!=null){
  //     if (box.isOpen) {
  //     await box.close();
  //     }
  //     }
  //   }
  //     // else if(all==true){
  //     //
  //     // }
  //   } catch (e) {
  //     debugPrint("Error closing database box: $e");
  //   }
  // }

  /// Function to delete an item in the specified table
  Future<ResponseWrapper> deleteSelectedItem<E>(
    String tableName,
    List<dynamic> itemIds,
  ) async {
    if (!_isDbInit) await dbInit();

    try {
      var box = await tablesName._getHiveBoxForTable(tableName);
      if (box == null) {
        return ResponseWrapper(
          isSuccess: false,
          message: "Failed to open Hive box for ",
          data: null,
        );
      }

      if (itemIds.isEmpty) {
        return ResponseWrapper(
          isSuccess: false,
          message: "No item IDs provided for deletion",
          data: null,
        );
      }

      // Delete the selected items from the box
      await box.deleteAll(itemIds);

      return ResponseWrapper(
        isSuccess: true,
        message: "Items deleted successfully from ",
        data: {"message": "Deleted successfully"},
      );
    } catch (e) {
      debugPrint("Error deleting items from : $e");
      return ResponseWrapper(
        isSuccess: false,
        message: "Error deleting items from : $e",
        data: null,
      );
    }
  }

  /// Function to update an item in the specified table
  Future<ResponseWrapper> updateItem<E>(
    String tableName,
    dynamic itemId,
    Map<String, dynamic> newData, {
    E Function(Map<String, dynamic>)? returnType,
  }) async {
    if (!_isDbInit) await dbInit();

    try {
      // Open Hive box
      var box = await tablesName._getHiveBoxForTable(tableName);
      if (box == null) {
        return ResponseWrapper(
          isSuccess: false,
          message: "Failed to open Hive box for ",
          data: null,
        );
      }

      // Check if the item exists
      if (!box.containsKey(itemId)) {
        return ResponseWrapper(
          isSuccess: false,
          message: "Key $itemId does not exist in ",
          data: null,
        );
      }

      // Retrieve the existing data
      var existingData = box.get(itemId);
      if (existingData == null) {
        return ResponseWrapper(
          isSuccess: false,
          message: "No data found for key $itemId in ",
          data: null,
        );
      }

      // Update the `id` field in the new data
      try {
        var id = existingData is Map<String, dynamic>
            ? existingData["id"]
            : existingData.id;
        newData["id"] = id;
      } catch (e) {
        debugPrint("Error updating ID field: $e");
      }

      // Convert the new data into the Hive model
      var modelData = tablesName
          ._convertRequestModelToHiveModel(tableName, newData, rowId: itemId);
      if (modelData == null) {
        return ResponseWrapper(
          isSuccess: false,
          message: "Failed to convert new data to Hive model for ",
          data: null,
        );
      }

      // Update the item in the Hive box
      await box.put(itemId, modelData);

      // Retrieve the updated data
      var updatedData = box.get(itemId);
      Map<String, dynamic> responseData = updatedData is Map<String, dynamic>
          ? updatedData
          : updatedData.dynamicData;

      // Return the updated data in the specified return type
      if (returnType != null) {
        return ResponseWrapper(
          isSuccess: true,
          message: "Item updated successfully in ",
          data: responseData,
        );
      }

      return ResponseWrapper(
        isSuccess: true,
        message: "Item updated successfully in ",
        data: responseData,
      );
    } catch (e) {
      debugPrint("Error updating item in : $e");
      return ResponseWrapper(
        isSuccess: false,
        message: "Error updating item in : $e",
        data: null,
      );
    }
  }

  /// Function to add an item to the specified table
  Future<ResponseWrapper> hiveAddItem<E>(
    String tableName,
    Map<String, dynamic> data, {
    E Function(Map<String, dynamic>)? returnType,
    bool? isAddedLocally = false,
    int? rowId,
    String? keyToAvoidDuplicateEntry,
  }) async {
    if (!DbMain._isDbInit) await dbInit();

    try {
      // Open Hive box
      var box = await tablesName._getHiveBoxForTable(tableName);
      if (box == null) {
        return ResponseWrapper(
          isSuccess: false,
          message: "Failed to open Hive box for ",
        );
      }

      // Convert data to Hive model
      var modelData = tablesName
          ._convertRequestModelToHiveModel(tableName, data, rowId: rowId);
      if (modelData == null) {
        return ResponseWrapper(
          isSuccess: false,
          message: "Failed to convert data ",
        );
      }

      // Check for duplicate entry
      bool alreadyExist = false;
      if (keyToAvoidDuplicateEntry != null &&
          keyToAvoidDuplicateEntry.isNotEmpty) {
        alreadyExist = _isDuplicateEntry(box, data, keyToAvoidDuplicateEntry);
      }

      if (alreadyExist) {
        return ResponseWrapper(
          isSuccess: false,
          message: "Duplicate entry found for key $keyToAvoidDuplicateEntry ",
        );
      }

      // Add item to the Hive box
      var itemId = await box.add(modelData);

      // Update local ID if required
      if (isAddedLocally != null && isAddedLocally == true) {
        try {
          if (modelData is Map<String, dynamic>) {
            if (modelData.containsKey("id")) {
              modelData['id'] = itemId; // Assumes `modelData` is a Map
            } else {
              modelData['id'] = itemId; // Assumes `modelData` is a Map
            }
          } else {
            modelData.id = itemId; // Assumes `modelData` is a Map
            modelData.dynamicData["id"] =
                itemId; // Assumes `modelData` is a Map
          }

          await box.put(itemId, modelData);
        } catch (e) {
          await box.delete(itemId);
          return ResponseWrapper(
            isSuccess: false,
            message: "Error updating local ID: $e",
          );
        }
      }

      // Retrieve saved data
      var savedData = box.get(itemId);

      // Transform response data if required
      if (returnType != null) {
        if (savedData is Map<String, dynamic>) {
          return ResponseWrapper(
            isSuccess: true,
            data: savedData,
            message: "Item added successfully ",
          );
        } else if (savedData != null && savedData.toJson is Function) {
          return ResponseWrapper(
            isSuccess: true,
            data: savedData.toJson(),
            message: "Item added successfully ",
          );
        }
      }

      if (savedData is Map<String, dynamic>) {
        return ResponseWrapper(
          isSuccess: true,
          data: savedData,
          message: "Item added successfully ",
        );
      } else {
        return ResponseWrapper(
          isSuccess: true,
          data: savedData?.toJson() ?? savedData,
          message: "Item added successfully ",
        );
      }
    } catch (e) {
      return ResponseWrapper(
        isSuccess: false,
        message: "Error adding item to : $e",
      );
    }
  }

  /// Function to get all  items from specified table
  Future<ResponseWrapper> hiveGetItemList<E>(String tableName,
      {E Function(Map<String, dynamic>)? fromJson,
      bool? isResentOnTop = true}) async {
    if (!DbMain._isDbInit) await dbInit();

    try {
      // Open Hive box
      var box = await tablesName._getHiveBoxForTable(tableName);
      if (box == null) {
        return ResponseWrapper(
          isSuccess: false,
          message: "Failed to open Hive box ",
          data: null,
        );
      }

      // Retrieve all data from the box
      var rawData = box.values;
      if (rawData.isNotEmpty && isResentOnTop == true) {
        rawData = rawData.toList().reversed;
      }
      // Map the raw data to the desired type using `fromJson`
      var dataList = rawData.map((value) {
        if (fromJson != null) {
          if (value is Map<dynamic, dynamic>) {
            return fromJson(
                value.map((key, value) => MapEntry(key.toString(), value)));
          } else if (value is Map<String, dynamic>) {
            return fromJson(
                value.map((key, value) => MapEntry(key.toString(), value)));
          } else if (value.toJson is Function) {
            return value.dynamicData;
          }
        } else {
          if (value is Map<dynamic, dynamic>) {
            return value.map((key, value) => MapEntry(key.toString(), value));
          } else if (value is Map<String, dynamic>) {
            return value;
          } else if (value.toJson is Function) {
            return value.dynamicData;
          }
        }
        return value;
      }).toList();

      return ResponseWrapper(
        isSuccess: true,
        message: "Data retrieved successfully from ",
        data: {"result": dataList},
      );
    } catch (e) {
      debugPrint("Error retrieving data from : $e");
      return ResponseWrapper(
        isSuccess: false,
        message: "Error retrieving data from : $e",
        data: null,
      );
    }
  }

  /// Function to search from selected table
  Future<ResponseWrapper> hiveSearchData<E>(String tableName,
      {List<String>? searchQueries = const [],
      E Function(Map<String, dynamic>)? fromJson,
      Map<String, dynamic>? searchForEqualsValue,
      bool? isResentOnTop = true}) async {
    // Validate input conditions
    if ((searchQueries == null || searchQueries.isEmpty) &&
        (searchForEqualsValue == null || searchForEqualsValue.isEmpty)) {
      return ResponseWrapper(
        isSuccess: false,
        message: "No search criteria provided",
        data: null,
      );
    }

    if (!DbMain._isDbInit) await dbInit();

    try {
      // Open Hive box
      var box = await tablesName._getHiveBoxForTable(tableName);
      if (box == null) {
        return ResponseWrapper(
          isSuccess: false,
          message: "Failed to open Hive box ",
          data: null,
        );
      }

      // Filter and process the data
      List<dynamic>? dataList = box.values.where((value) {
        dynamic jsonData;

        // Handle non-Map values
        if (value is Map<String, dynamic>) {
          jsonData = value;
        } else if (value.toJson is Function) {
          jsonData = value.dynamicData;
        }

        if (jsonData != null && jsonData["id"] != null) {
          // Check for equality matches
          if (searchForEqualsValue != null && searchForEqualsValue.isNotEmpty) {
            return searchForEqualsValue.entries.every((entry) {
              return jsonData[entry.key] == entry.value;
            });
          }

          // Check for queries containing specific values
          if (searchQueries != null && searchQueries.isNotEmpty) {
            return jsonData.values.any((field) {
              if (field != null) {
                return searchQueries.any((query) {
                  return field
                      .toString()
                      .toLowerCase()
                      .contains(query.toLowerCase());
                });
              }
              return false;
            });
          }
        } else {
          debugPrint("Null or invalid database value encountered.");
        }

        return false;
      }).map((value) {
        // Convert value to the desired format
        if (value is Map<String, dynamic>) {
          return fromJson != null ? fromJson(value) : value;
        } else if (value.toJson is Function) {
          return fromJson != null
              ? fromJson(value.dynamicData)
              : value.dynamicData;
        }
        return value;
      }).toList();

      if (dataList.isNotEmpty && isResentOnTop == true) {
        dataList = dataList.reversed.toList();
      }

      return ResponseWrapper(
        isSuccess: true,
        message: "Data retrieved successfully from ",
        data: {"result": dataList},
      );
    } catch (e) {
      return ResponseWrapper(
        isSuccess: false,
        message: "Error retrieving data from : $e",
        data: null,
      );
    }
  }

  ///
  Future<ResponseWrapper> hiveSearchDataByQuery<E>(
      String tableName, String query,
      {List<String>? searchQueries = const [],
      E Function(Map<String, dynamic>)? fromJson,
      Map<String, dynamic>? searchForEqualsValue,
      bool? isResentOnTop = true}) async {
    // Validate input conditions
    if ((searchQueries == null || searchQueries.isEmpty) &&
        (searchForEqualsValue == null || searchForEqualsValue.isEmpty)) {
      return ResponseWrapper(
        isSuccess: false,
        message: "No search criteria provided",
        data: null,
      );
    }

    if (!DbMain._isDbInit) await dbInit();

    try {
      // Open Hive box
      var box = await tablesName._getHiveBoxForTable(tableName);
      if (box == null) {
        return ResponseWrapper(
          isSuccess: false,
          message: "Failed to open Hive box ",
          data: null,
        );
      }

      // Filter and process the data
      List<dynamic>? dataList = box.values.where((value) {
        dynamic jsonData;

        // Handle non-Map values
        if (value is Map<String, dynamic>) {
          jsonData = value;
        } else if (value.toJson is Function) {
          jsonData = value.dynamicData;
        }

        if (jsonData != null && jsonData["id"] != null) {
          // Check for equality matches
          if (searchForEqualsValue != null && searchForEqualsValue.isNotEmpty) {
            return searchForEqualsValue.entries.every((entry) {
              return jsonData[entry.key] == entry.value;
            });
          }

          // Check for queries containing specific values
          if (searchQueries != null && searchQueries.isNotEmpty) {
            return jsonData.values.any((field) {
              if (field != null) {
                return searchQueries.any((query) {
                  return field
                      .toString()
                      .toLowerCase()
                      .contains(query.toLowerCase());
                });
              }
              return false;
            });
          }
        } else {
          debugPrint("Null or invalid database value encountered.");
        }

        return false;
      }).map((value) {
        // Convert value to the desired format
        if (value is Map<String, dynamic>) {
          return fromJson != null ? fromJson(value) : value;
        } else if (value.toJson is Function) {
          return fromJson != null
              ? fromJson(value.dynamicData)
              : value.dynamicData;
        }
        return value;
      }).toList();

      if (dataList.isNotEmpty && isResentOnTop == true) {
        dataList = dataList.reversed.toList();
      }

      return ResponseWrapper(
        isSuccess: true,
        message: "Data retrieved successfully from ",
        data: {"result": dataList},
      );
    } catch (e) {
      return ResponseWrapper(
        isSuccess: false,
        message: "Error retrieving data from : $e",
        data: null,
      );
    }
  }

// Helper function for duplicate entry check
  bool _isDuplicateEntry(
    var box,
    Map<String, dynamic> data,
    String keyToAvoidDuplicateEntry,
  ) {
    try {
      var enteredValue = data[keyToAvoidDuplicateEntry]?.toString() ?? "";
      if (enteredValue.isEmpty) return false;
      bool isExist = box.values.any((rowData) {
        Map<String, dynamic>? jsonData;
        if (rowData is Map<String, dynamic>) {
          jsonData = rowData["dynamic_data"];
        } else if (rowData.toJson is Function) {
          jsonData = rowData.toJson();
        }
        return jsonData?[keyToAvoidDuplicateEntry]?.toString() == enteredValue;
      });
      return isExist;
    } catch (e) {
      debugPrint("Error during duplicate check: $e");
      return true; // Assume duplicate to avoid unsafe additions
    }
  }
}

class TablesName {
  final String propertyListBox = "property_list_box";
  final String usersBox = "users_box";

  final String contactBox = "contact_box";
  final String leadBox = "lead_box";

  final String followUpBox = "follow_up_box";
  final String assignBox = "assign_box";
  final String photosBox = "photos_box";

  final String dynamicDataBox = "dynamic_data_box";

  /// It is use for internal use only
  final String _dbTables = "db_tables_db";

  Future<Box?> _getHiveBoxForTable(String tableName) async {
    if (await Hive.boxExists(tableName)) {
      try {
        return Hive.box<HiveDynamicDataModel>(tableName);
      } catch (e) {
        debugPrint("$e");
        try {
          return await Hive.openBox<HiveDynamicDataModel>(tableName);
        } catch (e) {
          debugPrint("$e");
        }
      }
    } else {
      try {
        return await Hive.openBox<HiveDynamicDataModel>(tableName);
      } catch (e) {
        debugPrint("$e");
      }
    }

    return null;
  }

  /// Converting Normal model to Hive model
  dynamic _convertRequestModelToHiveModel(
      String tableName, Map<String, dynamic> data,
      {int? rowId}) {
    try {
      HiveDynamicDataModel mHiveProjectModel =
          HiveDynamicDataModel(id: rowId, dynamicData: data);
      return mHiveProjectModel;
    } catch (e) {
      debugPrint("$e");
    }

    // switch (tableName) {
    //   case 'property_list_box':
    //     // HiveDynamicDataModel mHiveProjectModel = HiveDynamicDataModel.fromJson(data);
    //     HiveDynamicDataModel mHiveProjectModel = HiveDynamicDataModel(id:rowId,dynamicData: data);
    //     return mHiveProjectModel;
    //   case 'users_box':
    //     // HiveDynamicDataModel mHivePropertyModel = HiveDynamicDataModel.fromJson(data);
    //     HiveDynamicDataModel mHiveProjectModel = HiveDynamicDataModel(id:rowId,dynamicData: data);
    //     return mHiveProjectModel;
    //
    //     case 'contact_box':
    //       // HiveDynamicDataModel mHivePropertyModel = HiveDynamicDataModel.fromJson(data);
    //       HiveDynamicDataModel mHiveProjectModel = HiveDynamicDataModel(id:rowId,dynamicData: data);
    //       return mHiveProjectModel;
    //
    //     case 'lead_box':
    //     //  HiveDynamicDataModel mHivePropertyModel = HiveDynamicDataModel.fromJson(data);
    //       HiveDynamicDataModel mHiveProjectModel = HiveDynamicDataModel(id:rowId,dynamicData: data);
    //       return mHiveProjectModel;
    //
    //     case 'follow_up_box':
    //     //  HiveDynamicDataModel mHivePropertyModel = HiveDynamicDataModel.fromJson(data);
    //       HiveDynamicDataModel mHiveProjectModel = HiveDynamicDataModel(id:rowId,dynamicData: data);
    //       return mHiveProjectModel;
    //
    //     case 'photos_box':
    //     //  HiveDynamicDataModel mHivePropertyModel = HiveDynamicDataModel.fromJson(data);
    //       HiveDynamicDataModel mHiveProjectModel = HiveDynamicDataModel(id:rowId,dynamicData: data);
    //       return mHiveProjectModel;
    //
    //     case 'assign_box':
    //     //  HiveDynamicDataModel mHivePropertyModel = HiveDynamicDataModel.fromJson(data);
    //       HiveDynamicDataModel mHiveProjectModel = HiveDynamicDataModel(id:rowId,dynamicData: data);
    //       return mHiveProjectModel;
    //
    //     case 'dynamic_data_box':
    //       HiveDynamicDataModel mHivePropertyModel = HiveDynamicDataModel.fromJson(data);
    //     return mHivePropertyModel;
    //   default:
    //     return null;
    // }

    return null;
  }
}
