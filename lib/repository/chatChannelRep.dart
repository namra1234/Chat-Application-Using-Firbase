import 'package:chat_app_firebase/common/constants.dart';
import 'package:flutter/cupertino.dart';
import '../models/ChatChannelModel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatChannelRepository {
  final CollectionReference collection =
      FirebaseFirestore.instance.collection('chatChannel');

  Future<DocumentReference> createchatChannel(
      ChatChannelModel chatChannelModel) async {
    final newDocRef = collection.doc();
    Map categoryMap = chatChannelModel.toJson();
    categoryMap['channelID'] = newDocRef.id;
    await newDocRef.set(categoryMap);
    return newDocRef;
  }

  Future<void> updatechannel(String orgid, String orgname) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var id = prefs.getString('id');
    var ChatChannelModel;

    final docSnapshot = await collection
        .where("id", isEqualTo: id)
        .get()
        .then((var snapshot) async {
      snapshot.documents.forEach((element) {
        ChatChannelModel = ChatChannelModel.fromMap(
          element.data(),
        );
      });
    });

    await collection
        .doc(id)
        .update(ChatChannelModel(
                id: id,
                chatChannelName: ChatChannelModel.chatChannelName,
                channelID: ChatChannelModel.channelID)
            .toJson())
        .catchError(
          (error) {},
        );
  }

  Future<List<ChatChannelModel>> getallchatChannel() async {
    List<ChatChannelModel> chatChannelList = List();
    final docSnapshot = await collection.get().then((var snapshot) {
      snapshot.documents.forEach((element) {
        ChatChannelModel chatChannel = ChatChannelModel.fromMap(
          element.data(),
        );
        chatChannelList.add(chatChannel);
      });

      print(chatChannelList);
    });

    return chatChannelList;
  }

  Future<ChatChannelModel> getchatChannelById(String id) async {
    ChatChannelModel chatChannel;
    final docSnapshot = await collection
        .where("channelID", isEqualTo: id)
        .get()
        .then((var snapshot) {
      print(snapshot);
      snapshot.documents.forEach((element) {
        chatChannel = ChatChannelModel.fromMap(
          element.data(),
        );
      });
      return snapshot;
    });
    return chatChannel;
  }

  Future<ChatChannelModel> getchatChannelByuserList(
      List<String> userEmailList) async {
    ChatChannelModel chatChannel;
    final docSnapshot = await collection
        .where("userEmail", arrayContains: userEmailList.first)
        .get()
        .then((var snapshot) {
      print(snapshot);
      snapshot.documents.forEach((element) {
        if (element.data()["userEmail"].contains(userEmailList.last)) {
          chatChannel = ChatChannelModel.fromMap(
            element.data(),
          );
        }
      });
      return snapshot;
    });
    return chatChannel;
  }

  getchatChannelByuserEmail(String userEmail) async {
    return collection.where("userEmail", arrayContains: userEmail).snapshots();
  }

  getChats(String chatChannelId) async {
    return collection
        .document(chatChannelId)
        .collection("chats")
        .orderBy('time')
        .snapshots();
  }

  getuser(String chatChannelId) async {
    return collection.document(chatChannelId).snapshots();
  }

  Future<void> deleteMessage(String chatChannelId, String id) async {
    await collection
        .document(chatChannelId)
        .collection("chats")
        .doc(id)
        .delete();
  }

  Future<void> addMessage(
      String chatChannelId, chatMessageData, partnerEmail) async {
    await collection
        .document(chatChannelId)
        .collection("chats")
        .add(chatMessageData)
        .catchError((e) {
      print(e.toString());
    });
    final docSnapshot = collection
        .where("channelID", isEqualTo: chatChannelId)
        .get()
        .then((var snapshot) {
      print(snapshot);
      snapshot.documents.forEach((element) {
        element.data()['readingUserEmailList'].forEach((key, val) {
          if (key == partnerEmail) {
            if (!val ||
                !element.data()['onlineUserEmailList'].contains(partnerEmail)) {
              var currentUnreadMsg =
                  element.data()['unreadMessageNumberList'][key];
              var newValue = currentUnreadMsg + 1;
              collection.doc(element.id).update({
                'unreadMessageNumberList': {
                  Constants.myEmail: 0,
                  partnerEmail: newValue,
                }
              }).catchError(
                (error) {},
              );
            }
          }
        });
      });
      return snapshot;
    });
  }

  Future<void> updateunreadMessageNumber(
      String chatChannelId, partnerEmail) async {
    final docSnapshot = await collection
        .where("channelID", isEqualTo: chatChannelId)
        .get()
        .then((var snapshot) {
      print(snapshot);
      snapshot.documents.forEach((element) {
        if ((element.data()['unreadMessageNumberList'] == null)) {
          collection.doc(element.id).update({
            'unreadMessageNumberList': {
              element.data()['userEmail'].first: 0,
              element.data()['userEmail'].last: 0,
            }
          }).catchError(
            (error) {},
          );
        } else {
          element.data()['readingUserEmailList'].forEach((key, val) {
            if (key == partnerEmail) {
              collection.doc(element.id).update({
                'unreadMessageNumberList': {
                  Constants.myEmail: 0,
                  partnerEmail: element.data()['unreadMessageNumberList']
                      [partnerEmail],
                }
              }).catchError(
                (error) {},
              );
            }
          });
        }
      });
      return snapshot;
    });
  }

  Future<void> updateOnlineStatus(bool online) {
    List onlineEmail = [Constants.myEmail];
    List oflineEmail = [];
    // List onlineEmail=["namra.patel.549@gmail.com"];
    collection
        .where("userEmail", arrayContains: Constants.myEmail)
        .get()
        .then((var snapshot) {
      print(snapshot);
      snapshot.documents.forEach((element) {
        if ((element.data()['onlineUserEmailList'] == null ||
                element.data()['onlineUserEmailList']?.length == 0) &&
            online) {
          collection
              .doc(element.id)
              .update({'onlineUserEmailList': onlineEmail}).catchError(
            (error) {},
          );
        } else {
          element.data()['onlineUserEmailList'].forEach((element) {
            if (element != Constants.myEmail && online) {
              onlineEmail.add(element);
            }
            if (element != Constants.myEmail && !online) {
              oflineEmail.add(element);
            }
          });
          if (online) {
            collection
                .doc(element.id)
                .update({'onlineUserEmailList': onlineEmail}).catchError(
              (error) {},
            );
          } else {
            collection
                .doc(element.id)
                .update({'onlineUserEmailList': oflineEmail}).catchError(
              (error) {},
            );
          }
        }
      });
      return snapshot;
    });
  }

  Future<void> updateOnlineReadingStatus(String channelID, bool reading) {
    String partnerEmail;
    String partnerReadingVal;
    List<String> readingEmail = [];
    // List onlineEmail=["namra.patel.549@gmail.com"];
    collection
        .where("channelID", isEqualTo: channelID)
        .get()
        .then((var snapshot) {
      print(snapshot);
      snapshot.documents.forEach((element) {
        if ((element.data()['readingUserEmailList'] == null) && reading) {
          collection.doc(element.id).update({
            'readingUserEmailList': {
              element.data()['userEmail'].first:
                  element.data()['userEmail'].first == Constants.myEmail
                      ? true
                      : false,
              element.data()['userEmail'].last:
                  element.data()['userEmail'].first == Constants.myEmail
                      ? true
                      : false,
            }
          }).catchError(
            (error) {},
          );
        } else {
          List<bool> readingVal = [];
          element.data()['readingUserEmailList'].forEach((key, val) {
            if (key == Constants.myEmail && reading) {
              readingVal.add(true);
              readingEmail.add(key);
              // onlineEmail.add(element);
            } else if (key == Constants.myEmail && !reading) {
              readingVal.add(false);
              readingEmail.add(key);
              // readingEmail.add(element);
            } else if (key != Constants.myEmail) {
              readingVal.add(val);
              readingEmail.add(key);
            }
          });

          collection.doc(element.id).update({
            'readingUserEmailList': {
              readingEmail[0]: readingVal[0],
              readingEmail[1]: readingVal[1]
            }
          }).catchError(
            (error) {},
          );
        }
      });
      return snapshot;
    });
  }
}
