import 'dart:convert';

class UserModel {
  final String userName;
  final String userEmail;
  final String userID;
  final String id;

  UserModel({
    this.userName,
    this.userEmail,
    this.userID,
    this.id
  });

  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
      'userEmail': userEmail,
      'userID': userID,
      'id' : id
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;
    return UserModel(
      userName: map['userName'],
      userEmail: map['userEmail'],
      userID: map['userID'],
      id: map['id']
    );
  }

  factory UserModel.fromJson(String source) => UserModel.fromMap(
        json.decode(source),
      );
}
