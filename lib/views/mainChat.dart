import 'dart:async';
import 'dart:io';

import 'package:chat_app_firebase/common/constants.dart';
import 'package:chat_app_firebase/models/ChatChannelModel.dart';
import 'package:chat_app_firebase/repository/chatChannelRep.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../common/color_constants.dart';
import 'package:connectivity/connectivity.dart';
import 'chat.dart';
import 'searchPage.dart';
import 'sign_in.dart';

class mainChat extends StatefulWidget {
  @override
  _mainChatState createState() => _mainChatState();
}

class _mainChatState extends State<mainChat> with WidgetsBindingObserver {
  // Stream mainchat;
  AppLifecycleState _lastLifecycleState;
  Stream mainchat;
  List<ChatChannelModel> chatChannelList;
  Map _source = {ConnectivityResult.none: false};
  MyConnectivity _connectivity = MyConnectivity.instance;

  Widget mainchatList() {
    return StreamBuilder(
      stream: mainchat,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.documents.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return mainchatTile(
                      userName: snapshot.data.documents[index]
                                  .data()['userEmail'][0] ==
                              Constants.myEmail
                          ? snapshot.data.documents[index]
                              .data()['userList'][1]
                              .toString()
                          : snapshot.data.documents[index]
                              .data()['userList'][0]
                              .toString(),
                      userEmail: snapshot.data.documents[index]
                                  .data()['userEmail'][0] ==
                              Constants.myEmail
                          ? snapshot.data.documents[index]
                              .data()['userEmail'][1]
                              .toString()
                          : snapshot.data.documents[index]
                              .data()['userEmail'][0]
                              .toString(),
                      chatChannelId:
                          snapshot.data.documents[index].data()['channelID'],
                      onlineUserEmailList: snapshot.data.documents[index]
                          .data()['onlineUserEmailList'],
                      unreadMessage: snapshot.data.documents[index]
                              .data()['unreadMessageNumberList']
                          [Constants.myEmail]);
                })
            : Container();
      },
    );
  }

  @override
  void initState() {
    getUserInfogetChats();
    ChatChannelRepository().updateOnlineStatus(true);
    _connectivity.initialise();
    _connectivity.myStream.listen((source) {
      setState(() => _source = source);
    });
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    ChatChannelRepository().updateOnlineStatus(false);
    _connectivity.disposeStream();
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      _lastLifecycleState = state;
    });

    switch (state) {
      case AppLifecycleState.inactive:
        ChatChannelRepository().updateOnlineStatus(false);
        break;

      case AppLifecycleState.paused:
        ChatChannelRepository().updateOnlineStatus(false);
        break;
      case AppLifecycleState.detached:
        break;
      case AppLifecycleState.resumed:
        ChatChannelRepository().updateOnlineStatus(true);
        break;
    }
  }

  _onLogout() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.clear();
    Constants.loggedInUserID = null;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => SignInScreen(),
      ),
      (route) => false,
    );
  }

  getUserInfogetChats() async {
    ChatChannelRepository()
        .getchatChannelByuserEmail(Constants.myEmail)
        .then((snapshotdata) {
      setState(() {
        // chats = val;
        mainchat = snapshotdata;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // onWillPop: () => ChatChannelRepository().updateOnlineStatus(false),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: ColorConstants.kPrimaryColor,
          title: Row(
            children: [
              Image.asset(
                "assets/images/logoSmall.png",
                height: 40,
              ),
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text("Chat with US"),
              )
            ],
          ),
          elevation: 0.0,
          centerTitle: false,
          actions: [
            GestureDetector(
              onTap: () {
                // AuthService().signOut();
                // Navigator.pushReplacement(context,
                //     MaterialPageRoute(builder: (context) => Authenticate()));
                _onLogout();
              },
              child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Icon(Icons.exit_to_app)),
            )
          ],
        ),
        body: Container(
          child: mainchatList(),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: ColorConstants.kPrimaryColor,
          child: Icon(Icons.search),
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => Search()));
          },
        ),
      ),
    );
  }
}

class mainchatTile extends StatelessWidget {
  final String userName;
  final String userEmail;
  final String chatChannelId;
  final List<dynamic> onlineUserEmailList;
  final int unreadMessage;

  mainchatTile(
      {this.userName,
      @required this.chatChannelId,
      this.userEmail,
      this.onlineUserEmailList,
      this.unreadMessage});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Chat(
                      chatChannelId: chatChannelId,
                      partnerName: userName,
                      partnerEmail: userEmail,
                    )));
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: ColorConstants.kWhiteColor,
          shape: BoxShape.rectangle,
          //       boxShadow: [BoxShadow(
          // color: ColorConstants.kBlackColor,
          // blurRadius: 25.0, // soften the shadow
          // spreadRadius: 1.0, //extend the shadow
          // offset: Offset(
          //   15.0, // Move to right 10  horizontally
          //   15.0, // Move to bottom 10 Vertically
          // ),
          //       )]
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                      color: ColorConstants.kGreyColor,
                      borderRadius: BorderRadius.circular(30)),
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Text(userName.substring(0, 1),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: ColorConstants.kPrimaryColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w300)),
                  ),
                ),
                SizedBox(
                  width: 12,
                ),
                Text(userName,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        color: ColorConstants.kPrimaryColor,
                        fontSize: 16,
                        fontFamily: 'OverpassRegular',
                        fontWeight: FontWeight.w300)),
                Divider(color: Colors.black)
              ],
            ),
            Row(
              children: [
                onlineUserEmailList.contains(userEmail)
                    ? Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(23),
                                topRight: Radius.circular(23),
                                bottomRight: Radius.circular(23)),
                            gradient: LinearGradient(
                              colors: [
                                ColorConstants.kGreenColor,
                                ColorConstants.kGreenColor
                              ],
                            )),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                            "Online",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: ColorConstants.kBlackColor,
                            ),
                          ),
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(23),
                                topRight: Radius.circular(23),
                                bottomRight: Radius.circular(23)),
                            gradient: LinearGradient(
                              colors: [Colors.red, Colors.red],
                            )),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                            "Offline",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: ColorConstants.kBlackColor,
                            ),
                          ),
                        ),
                      ),
                SizedBox(
                  width: 5,
                ),
                unreadMessage != 0
                    ? Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(23),
                                topRight: Radius.circular(23),
                                bottomRight: Radius.circular(23)),
                            gradient: LinearGradient(
                              colors: [
                                ColorConstants.kGreenColor,
                                ColorConstants.kGreenColor
                              ],
                            )),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(
                            unreadMessage.toString(),
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: ColorConstants.kBlackColor,
                            ),
                          ),
                        ),
                      )
                    : Container()
              ],
            )
          ],
        ),
      ),
    );
  }
}

class MyConnectivity {
  MyConnectivity._internal();

  static final MyConnectivity _instance = MyConnectivity._internal();

  static MyConnectivity get instance => _instance;

  Connectivity connectivity = Connectivity();

  StreamController controller = StreamController.broadcast();

  Stream get myStream => controller.stream;

  void initialise() async {
    ConnectivityResult result = await connectivity.checkConnectivity();
    _checkStatus(result);
    connectivity.onConnectivityChanged.listen((result) {
      _checkStatus(result);
    });
  }

  void _checkStatus(ConnectivityResult result) async {
    bool isOnline = false;
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        isOnline = true;
      } else {
        ChatChannelRepository().updateOnlineStatus(false);
        isOnline = false;
      }
    } on SocketException catch (_) {
      ChatChannelRepository().updateOnlineStatus(false);
      isOnline = false;
    }
    controller.sink.add({result: isOnline});
  }

  void disposeStream() => controller.close();
}
