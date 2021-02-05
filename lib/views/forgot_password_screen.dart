import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../common/color_constants.dart';
import '../common/constants.dart';
import '../widgets/square_flat_button_widget.dart';
import '../widgets/square_textform_field_widget.dart';
import 'sign_in.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  TextEditingController emailController;
  double height, width, appBarHeight, statusBarHeight;
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  bool isaddMode = true;
  Color currentColor = ColorConstants.kMediumRedColor;

  bool shimmer = true;

  void _showSnackBar(String message) {
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void changeColor(Color color) {
    setState(() {
      currentColor = color;
    });
  }

  @override
  Widget build(BuildContext context) {
    statusBarHeight = MediaQuery.of(context).padding.top;
    appBarHeight = AppBar().preferredSize.height;
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: ColorConstants.kWhiteColor,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: ColorConstants.kWhiteColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: ColorConstants.kWhiteColor,
        elevation: 0,
        brightness: Brightness.light,
        title: Text(
          "Forgot Password",
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: ColorConstants.kPrimaryColor,
          ),
        ),
      ),
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: height - appBarHeight - statusBarHeight,
                  decoration: BoxDecoration(
                    color: ColorConstants.kPrimaryColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 15,
                          right: 15,
                          top: 20,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SqaureTextFormFieldWidget(
                              controllerName: emailController,
                              lblTxt: "Email",
                              inputType: TextInputType.text,
                            ),
                            SizedBox(
                              height: 40,
                            ),
                            SquareFlatButtonWidget(
                              btnTxt: "Reset Password",
                              btnColor: ColorConstants.kMediumRedColor,
                              btnOnTap: () {
                                sendEmail();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  sendEmail() {
    var email = emailController.text;
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    _firebaseAuth.sendPasswordResetEmail(email: email).catchError((e) {
      _showSnackBar(e.message);
    }).then((value) {
      Timer(Duration(seconds: 1), () {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => SignInScreen(),
          ),
          (route) => false,
        );
      });
    });
  }
}
