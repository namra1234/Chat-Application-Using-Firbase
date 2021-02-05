import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../common/color_constants.dart';
import '../common/constants.dart';
import '../common/route_generator.dart';
import 'sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double height,width;

  @override
  void initState() {
    super.initState();
    loginCheck();    
  }

  void loginCheck() async {
    
    WidgetsFlutterBinding.ensureInitialized();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var loginStatus = prefs.getBool('isLoggedin');
    
    // var loginStatus= false;
    Constants.loggedInUserID = FirebaseAuth.instance.currentUser?.uid;
if(loginStatus==null)loginStatus=false;
    if(loginStatus)
    {
      Constants.myName=prefs.getString('myName');
      Constants.myEmail=prefs.getString('myEmail');
      Constants.loggedInUserID=prefs.getString('loggedInUserID');
    }
    var _duartion = new Duration(
      seconds: Constants.SPLASH_SCREEN_TIME,
    );
    Timer(_duartion, () async{
      
    
      Navigator.of(context).pushNamedAndRemoveUntil(
        loginStatus == true ? chatRoute : SignInScreenRoute,
        (route) => false,
      );

    });
  }

  @override
  Widget build(BuildContext context) {

    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: ColorConstants.kPrimaryColor,
      body: Column(
        children: [
          Container(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal:width/10,vertical: height/5
              ),
              child: Image.asset(
                'assets/images/logo.png'
              ),
            ),
          ),
          Container(
            child: Text("Unique",
            style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: ColorConstants.kWhiteColor,
              ),
              ),
          ),Container(
            child: Text("Developer",
            style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: ColorConstants.kWhiteColor,
              ),
              ),
          ),
        ],
      ),
    );
  }
}
