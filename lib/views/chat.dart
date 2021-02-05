import 'package:chat_app_firebase/common/color_constants.dart';
import 'package:chat_app_firebase/common/constants.dart';
import 'package:chat_app_firebase/repository/chatChannelRep.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Chat extends StatefulWidget {
  final String chatChannelId;
  final String partnerName;
  final String partnerEmail;
  

  Chat({this.chatChannelId, this.partnerEmail, this.partnerName});

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  Stream<QuerySnapshot> chats;
  Stream userdetail;
  TextEditingController messageEditingController = new TextEditingController();
  final ScrollController _scrollController = ScrollController();

  Widget chatMessages() {
    return Expanded(
      child: StreamBuilder(
        stream: chats,
        builder: (context, snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  scrollDirection: Axis.vertical,
                  controller: _scrollController,
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (context, index) {
                    return MessageTile(
                      message: snapshot.data.documents[index].data()["message"],
                      sendByMe: Constants.myName ==
                          snapshot.data.documents[index].data()["sendBy"],
                      messageId: snapshot.data.documents[index].id,
                      chatchannelId: widget.chatChannelId,
                      date: DateTime.fromMillisecondsSinceEpoch(snapshot.data.documents[index].data()["time"]),
                    );
                  })
              : Container();
        },
      ),
    );
  }

  addMessage() async {
    if (messageEditingController.text.isNotEmpty) {
      Map<String, dynamic> chatMessageMap = {
        "sendBy": Constants.myName,
        "sendByEmail": Constants.myEmail,
        "message": messageEditingController.text,
        'time': DateTime.now().millisecondsSinceEpoch,
      };

      await ChatChannelRepository().addMessage(
          widget.chatChannelId, chatMessageMap, widget.partnerEmail);

      setState(() {
        messageEditingController.text = "";
        _scrollController.animateTo(_scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 100), curve: Curves.easeInOut);
      });
    }
  }

  @override
  void initState() {
    ChatChannelRepository().getChats(widget.chatChannelId).then((val) {
      setState(() {
        chats = val;
      });
    });

    ChatChannelRepository().getuser(widget.chatChannelId).then((val) {
      setState(() {
        userdetail = val;
      });
    });

    ChatChannelRepository()
        .updateOnlineReadingStatus(widget.chatChannelId, true);
    ChatChannelRepository()
        .updateunreadMessageNumber(widget.chatChannelId, widget.partnerEmail);

    super.initState();
  }

  scrollerDown(BuildContext context) {
    setState(() {
      messageEditingController.text = "";
      _scrollController.animateTo(_scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 100), curve: Curves.easeInOut);
    });
  }

  @override
  void dispose() {
    ChatChannelRepository()
        .updateOnlineReadingStatus(widget.chatChannelId, false);
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: ColorConstants.kPrimaryColor,
          title: Container(
            child: StreamBuilder(
                stream: userdetail,
                builder: (context, snapshot) {
                  return snapshot.hasData
                      ? Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width / 2.5,
                                child: Row(
                                  children: [
                                    //         Image.asset(
                                    //   "assets/images/logoSmall.png",
                                    //   height: 40,
                                    // ),
                                    Expanded(
                                      child: Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: Text(widget.partnerName,
                                              style: GoogleFonts.poppins(
                                                fontSize: 17,
                                                fontWeight: FontWeight.w600,
                                                color:
                                                    ColorConstants.kWhiteColor,
                                              ))),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  snapshot.data
                                          .data()['onlineUserEmailList']
                                          .contains(widget.partnerEmail)
                                      ? Container(
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(23),
                                                  topRight: Radius.circular(23),
                                                  bottomRight:
                                                      Radius.circular(23)),
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
                                                color:
                                                    ColorConstants.kBlackColor,
                                              ),
                                            ),
                                          ),
                                        )
                                      : Container(
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(23),
                                                  topRight: Radius.circular(23),
                                                  bottomRight:
                                                      Radius.circular(23)),
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.red,
                                                  Colors.red
                                                ],
                                              )),
                                          child: Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: Text(
                                              "Offline",
                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color:
                                                    ColorConstants.kBlackColor,
                                              ),
                                            ),
                                          ),
                                        ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  snapshot.data.data()['readingUserEmailList']
                                              [widget.partnerEmail] &&
                                          snapshot.data
                                              .data()['onlineUserEmailList']
                                              .contains(widget.partnerEmail)
                                      ? Container(
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(23),
                                                  topRight: Radius.circular(23),
                                                  bottomRight:
                                                      Radius.circular(23)),
                                              gradient: LinearGradient(
                                                colors: [
                                                  ColorConstants.kGreenColor,
                                                  ColorConstants.kGreenColor
                                                ],
                                              )),
                                          child: Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: Text(
                                              'Reading',
                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color:
                                                    ColorConstants.kBlackColor,
                                              ),
                                            ),
                                          ),
                                        )
                                      : Container()
                                ],
                              ),
                            ],
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Text(widget.partnerName),
                        );
                }),
          )),
      // appBar: appBarMain(context),
      body: Container(
        child: Column(
          children: [
            chatMessages(),
            Container(
              alignment: Alignment.bottomCenter,
              width: MediaQuery.of(context).size.width,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: ColorConstants.kGreyColor,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  children: [
                    Expanded(
                        child: TextField(
                      minLines: 1,
                      maxLines: 4,
                      controller: messageEditingController,
                      // style: simpleTextStyle(),
                      decoration: InputDecoration(
                          hintText: "Send Message ...",
                          hintStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          border: InputBorder.none),
                    )),
                    SizedBox(
                      width: 16,
                    ),
                    GestureDetector(
                      onTap: () {
                        addMessage();
                      },
                      child: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  colors: [
                                    ColorConstants.kWhiteColor,
                                    ColorConstants.kWhiteColor
                                  ],
                                  begin: FractionalOffset.topLeft,
                                  end: FractionalOffset.bottomRight),
                              borderRadius: BorderRadius.circular(40)),
                          padding: EdgeInsets.all(12),
                          child: Image.asset(
                            "assets/images/send.png",
                            height: 25,
                            width: 25,
                          )),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageTile extends StatelessWidget {
  final String message;
  final String messageId;
  final String chatchannelId;
  final bool sendByMe;
  final DateTime date;

  MessageTile(
      {@required this.message,
      @required this.sendByMe,
      this.messageId,
      this.chatchannelId,
      this.date});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: () {
        ChatChannelRepository().deleteMessage(chatchannelId, messageId);
      },
      child: Container(
        padding: EdgeInsets.only(
            top: 8,
            bottom: 8,
            left: sendByMe ? 0 : 24,
            right: sendByMe ? 24 : 0),
        alignment: sendByMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin:
              sendByMe ? EdgeInsets.only(left: 30) : EdgeInsets.only(right: 30),
          padding: EdgeInsets.only(top: 17, bottom: 17, left: 20, right: 20),
          decoration: BoxDecoration(
              borderRadius: sendByMe
                  ? BorderRadius.only(
                      topLeft: Radius.circular(23),
                      topRight: Radius.circular(23),
                      bottomLeft: Radius.circular(23))
                  : BorderRadius.only(
                      topLeft: Radius.circular(23),
                      topRight: Radius.circular(23),
                      bottomRight: Radius.circular(23)),
              gradient: LinearGradient(
                colors: sendByMe
                    ? [ColorConstants.kPrimaryColor, const Color(0xff2A75BC)]
                    : [
                        ColorConstants.kGreyColor,
                        ColorConstants.kGreyColor,
                      ],
              )),
          child: Text(message,
              textAlign: TextAlign.start,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'OverpassRegular',
                  fontWeight: FontWeight.w300)),
        ),
      ),
    );
  }
}
