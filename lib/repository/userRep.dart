import 'package:chat_app_firebase/common/constants.dart';
import 'package:flutter/cupertino.dart';
import '../models/userModel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserRepository {
  final CollectionReference collection =
      FirebaseFirestore.instance.collection('User');

  Future<DocumentReference> createUser(UserModel Usermodel) async {
    final docSnapshot = await collection
        .where("userID", isEqualTo: Usermodel.userID)
        .get()
        .then((var snapshot) async {
      if (snapshot.documents.length == 0) {
        final newDocRef = collection.doc();
        Map UserMap = Usermodel.toJson();
        UserMap['id'] = newDocRef.id;
        await newDocRef.set(UserMap);
        SharedPreferences preferences = await SharedPreferences.getInstance();
        preferences.setString('id', newDocRef.id);
        return newDocRef;
      } else {
        SharedPreferences preferences = await SharedPreferences.getInstance();
        preferences.setString('id', snapshot.documents.first.data()['id']);
        return null;
      }
    });
  }

  Future<List<UserModel>> getallUser() async {
    List<UserModel> userList = List();
    final docSnapshot = await collection.get().then((var snapshot) {
      snapshot.documents.forEach((element) {
        UserModel userModel = UserModel.fromMap(
          element.data(),
        );
        userList.add(userModel);
      });

      print(userList);
    });

    return userList;
  }

  Future<UserModel> getUserById(String id) async {
    UserModel userModel;

    final docSnapshot = await collection
        .where("userID", isEqualTo: id)
        .get()
        .then((var snapshot) {
      print(snapshot);
      snapshot.documents.forEach((element) {
        userModel = UserModel.fromMap(
          element.data(),
        );
      });
      return snapshot;
    });
    return userModel;
  }

  Future<List<UserModel>> searchByName(String searchField) async {
    UserModel userModel;
    List<UserModel> userList = List();
    final docSnapshot = await collection
        // .where('userName', isEqualTo: searchField)
        .getDocuments()
        .then((var snapshot) {
      print(snapshot);
      snapshot.documents.forEach((element) {
        userModel = UserModel.fromMap(
          element.data(),
        );
        String name = userModel.userName.toLowerCase();
        String searchname = searchField.toLowerCase();
        var email = Constants.myEmail;
        if (name.contains(searchname) &&
            userModel.userEmail.toLowerCase() != email.toLowerCase())
          userList.add(userModel);
      });
      return snapshot;
    });
    return userList;
  }
}
