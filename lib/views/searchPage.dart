
import 'package:chat_app_firebase/common/color_constants.dart';
import 'package:chat_app_firebase/common/constants.dart';
import 'package:chat_app_firebase/models/ChatChannelModel.dart';
import 'package:chat_app_firebase/models/userModel.dart';
import 'package:chat_app_firebase/repository/chatChannelRep.dart';
import 'package:chat_app_firebase/repository/userRep.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'chat.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {

  UserRepository userRep = new UserRepository();
  ChatChannelRepository chatchannel = new ChatChannelRepository();
  ChatChannelModel chatmodel = new ChatChannelModel();
  TextEditingController searchEditingController = new TextEditingController();
  QuerySnapshot searchResultSnapshot;
  List<UserModel> userlist;

  bool isLoading = false;
  bool haveUserSearched = false;

  initiateSearch() async {
    if(searchEditingController.text.isNotEmpty){
      setState(() {
        isLoading = true;
      });
      await userRep.searchByName(searchEditingController.text)
          .then((snapshot){
        userlist = snapshot;        
        setState(() {
          isLoading = false;
          haveUserSearched = true;
        });
      });
    }
  }

  Widget userList(){
    return haveUserSearched ? ListView.builder(
      shrinkWrap: true,
      itemCount: userlist.length,
        itemBuilder: (context, index){
        return userTile(
          userlist[index].userName,
          userlist[index].userEmail
          // searchResultSnapshot.documents[index].data()["userEmail"],
        );
        }) : Container();
  }

  /// 1.create a chatroom, send user to the chatroom, other userdetails
  sendMessage(String userName,String userEmail){
    List<String> users = [Constants.myName,userName];
    List<String> usersEmail = [Constants.myEmail,userEmail];
    

chatchannel.getchatChannelByuserList(usersEmail)
          .then((snapshotdata){

        chatmodel = snapshotdata;        
        if(chatmodel==null)
        {
            chatchannel.createchatChannel(ChatChannelModel(
        userEmailList: usersEmail,
        userList: users, 
        onlineUserEmailList: []              
      ),)
          .then((snapshotdata){

        // chatmodel = snapshotdata;        
        setState(() {
         Navigator.push(context, MaterialPageRoute(
      builder: (context) => Chat(
        chatChannelId: snapshotdata.id,
        partnerName: users.last,
        partnerEmail: usersEmail.last
      )
    ));
        });
      });
        }
        else
        {
          Navigator.push(context, MaterialPageRoute(
      builder: (context) => Chat(
        chatChannelId: chatmodel.channelID,
        partnerName: users.last,
        partnerEmail: usersEmail.last,
      )
    ));
        }
      });

      

    // Map<String, dynamic> chatRoom = {
    //   "users": users,
    //   "chatRoomId" : chatRoomId,
    // };

    // databaseMethods.addChatRoom(chatRoom, chatRoomId);

    // Navigator.push(context, MaterialPageRoute(
    //   builder: (context) => Chat(
    //     chatRoomId: chatRoomId,
    //   )
    // ));

  }

  Widget userTile(String userName,String userEmail){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userName,
                style: TextStyle(
                    color: ColorConstants.kPrimaryColor,
                    fontSize: 16
                ),
              ),
              Text(
                userEmail,
                style: TextStyle(
                    color: ColorConstants.kPrimaryColor,
                    fontSize: 16
                ),
              )
            ],
          ),
          Spacer(),
          GestureDetector(
            onTap: (){
              sendMessage(userName,userEmail);
            },
            child: Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12,vertical: 8),
                decoration: BoxDecoration(
                    color: ColorConstants.kPrimaryColor,
                    borderRadius: BorderRadius.circular(24)
                ),
                child: Text("Say Hi!",
                  style: TextStyle(
                      color: ColorConstants.kWhiteColor,
                      fontSize: 16
                  ),),
              ),
            ),
          )
        ],
      ),
    );
  }


  getChatRoomId(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }

  @override
  void initState() {
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: ColorConstants.kWhiteColor,
        // brightness: Brightness.light,
        title: Text(
          "Search Screen",
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: ColorConstants.kPrimaryColor,
          ),
        ),
      ),
      // appBar: appBarMain(context),
      body: isLoading ? Container(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ) :  Container(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              color: ColorConstants.kPrimaryColor,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchEditingController,
                      // style: simpleTextStyle(),
                      decoration: InputDecoration(
                        hintText: "search username ...",
                        hintStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        border: InputBorder.none
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: (){
                      initiateSearch();
                    },
                    child: Container(
                      height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              ColorConstants.kWhiteColor,
                              const Color(0x0FFFFFFF)
                            ],
                            begin: FractionalOffset.topLeft,
                            end: FractionalOffset.bottomRight
                          ),
                          borderRadius: BorderRadius.circular(40)
                        ),
                        padding: EdgeInsets.all(10),
                        // child: Image.asset("assets/images/search_white.png",
                        //   height: 25, width: 25,)
                        child: Icon(Icons.search)
                          
                          ),
                  )
                ],
              ),
            ),
            userList()
          ],
        ),
      ),
    );
  }
}


