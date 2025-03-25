import 'package:hive/hive.dart';
part 'dynamic_data_model.g.dart';

@HiveType(typeId: 0)
class HiveDynamicDataModel {
  @HiveField(0)
  int? id;
  @HiveField(1)
  Map<String,dynamic>? dynamicData;
  HiveDynamicDataModel(
      {this.id,
        this.dynamicData});

  HiveDynamicDataModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    dynamicData = json['dynamic_data'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['dynamic_data'] = dynamicData;
    return data;
  }
}
