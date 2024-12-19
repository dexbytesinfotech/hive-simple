part of "db_main.dart";

class ResponseWrapper {
  final Map<String,dynamic>? data;
  final String? message;
  final bool isSuccess;

  ResponseWrapper({this.data, this.message, required this.isSuccess});

  @override
  String toString() {
    return 'ResponseWrapper{isSuccess: $isSuccess, message: $message, data: $data}';
  }

  Map<String, dynamic> toJson() {
    // final Map<String, dynamic> data = <String, dynamic>{};
    // data['id'] = id;
    // data['data'] = data;
    // data['last_name'] = lastName;
    // data['email'] = email;
    // data['password'] = password;
    return {"isSuccess": isSuccess, "message": message, "data": data};
  }
}