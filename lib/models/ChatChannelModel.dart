import 'dart:convert';

class ChatChannelModel {
 
  final String channelID;
  final List<dynamic> userList;
  final List<dynamic> userEmailList;
  final List<dynamic> onlineUserEmailList;

  ChatChannelModel({
    this.channelID,
    this.userList,
    this.userEmailList,
    this.onlineUserEmailList
  });

  Map<String, dynamic> toJson() {
    return {
      'channelID' : channelID,
      'userList': userList,
      'userEmail': userEmailList,
      'onlineUserEmailList' : onlineUserEmailList
    };
  }

  factory ChatChannelModel.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;
    return ChatChannelModel(
      userList: map['userList'] ,
      channelID: map['channelID'],
      userEmailList: map['userEmail'],
      onlineUserEmailList: map['onlineUserEmailList'] 
    );
  }

  factory ChatChannelModel.fromJson(String source) => ChatChannelModel.fromMap(
        json.decode(source),
      );
}
