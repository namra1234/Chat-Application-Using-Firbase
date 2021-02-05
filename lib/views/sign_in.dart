import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/square_flat_button_widget.dart';
import '../widgets/square_textform_field_widget.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import '../common/color_constants.dart';
import '../common/constants.dart';
import '../common/route_generator.dart';
import '../models/userModel.dart';
import '../repository/userRep.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../common/color_constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'forgot_password_screen.dart';
import 'sign_up.dart';

class SignInScreen extends StatefulWidget {
  SignInScreen({Key key}) : super(key: key);

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  TextEditingController emailController, passwordController;
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  GoogleSignInAccount googleUser;
  GoogleSignInAuthentication googleAuth;
  GoogleAuthCredential credential;
  LoginResult result;
  FacebookAuthCredential facebookAuthCredential;
  double height, width, statusBarHeight, appBarHeight;

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
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _onGoogleSignIn() async {
    // Trigger the authentication flow
    googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    googleAuth = await googleUser.authentication;

    // Create a new credential
    credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Once signed in, return the UserCredential
    await FirebaseAuth.instance
        .signInWithCredential(credential)
        .then((value) async {
      _showSnackBar("Login Successfully with Google");
      final pref = await SharedPreferences.getInstance();
      pref.setString(
        'loggedInUserId',
        FirebaseAuth.instance.currentUser.uid,
      );
      pref.setBool('isLoggedin', true);
      Constants.myName = FirebaseAuth.instance.currentUser.displayName;
      Constants.myEmail = FirebaseAuth.instance.currentUser.email;
      Constants.loggedInUserID = FirebaseAuth.instance.currentUser.uid;
      // var isAdmin=await UserRepository().getUserById(Constants.loggedInUserID);
      // pref.setBool('isAdmin', isAdmin.isAdmin);
      pref.setString('myName', Constants.myName);
      pref.setString('myEmail', Constants.myEmail);
      pref.setString('loggedInUserID', Constants.loggedInUserID);

      await UserRepository().createUser(
        UserModel(
          userName: FirebaseAuth.instance.currentUser.displayName,
          userEmail: FirebaseAuth.instance.currentUser.email,
          userID: Constants.loggedInUserID,
        ),
      );

      SharedPreferences prefs = await SharedPreferences.getInstance();

      Navigator.of(context).pushNamedAndRemoveUntil(
        chatRoute,
        (route) => false,
      );
    }).catchError((e) {
      _showSnackBar(e.message);
    });
  }

  Future<void> _onFacebookLogin() async {
    // Trigger the sign-in flow
    result = await FacebookAuth.instance.login();
    // Create a credential from the access token
    facebookAuthCredential =
        FacebookAuthProvider.credential(result.accessToken.token);
    // Once signed in, return the UserCredential
    await FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);

    _showSnackBar("Login Successfully with Facebook");
    final pref = await SharedPreferences.getInstance();
    pref.setString(
      'loggedInUserId',
      FirebaseAuth.instance.currentUser.uid,
    );
    pref.setBool('isLoggedin', true);
    Constants.myName = FirebaseAuth.instance.currentUser.displayName;
    Constants.myEmail = FirebaseAuth.instance.currentUser.email;
    Constants.loggedInUserID = FirebaseAuth.instance.currentUser.uid;

    pref.setString('myName', Constants.myName);
    pref.setString('myEmail', Constants.myEmail);
    pref.setString('loggedInUserID', Constants.loggedInUserID);
    // var isAdmin=await UserRepository().getUserById(Constants.loggedInUserID);
    //   pref.setBool('isAdmin', isAdmin.isAdmin);
    await UserRepository().createUser(
      UserModel(
        userName: FirebaseAuth.instance.currentUser.displayName,
        userEmail: FirebaseAuth.instance.currentUser.email,
        userID: Constants.loggedInUserID,
      ),
    );
    pref.setString(
      'loggedInUserPhoto',
      FirebaseAuth.instance.currentUser.photoURL,
    );
    SharedPreferences prefs = await SharedPreferences.getInstance();

    Navigator.of(context).pushNamedAndRemoveUntil(
      chatRoute,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    statusBarHeight = MediaQuery.of(context).padding.top;
    appBarHeight = AppBar().preferredSize.height;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: ColorConstants.kWhiteColor,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
    return Scaffold(
      backgroundColor: ColorConstants.kWhiteColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: ColorConstants.kWhiteColor,
        brightness: Brightness.light,
        title: Text(
          "Sign In",
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: ColorConstants.kPrimaryColor,
          ),
        ),
      ),
      key: _scaffoldKey,
      resizeToAvoidBottomPadding: false,
      body: Container(
        decoration: BoxDecoration(
          color: ColorConstants.kPrimaryColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        height: height,
        child: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.only(
              left: height / 20,
              right: height / 20,
              top: height / 20,
            ),
            child: ListView(
              children: [
                Center(
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: height / 5,
                  ),
                ),
                SqaureTextFormFieldWidget(
                  controllerName: emailController,
                  lblTxt: "Email",
                  autoValidate: true,
                  inputType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value.isEmpty) {
                      return "";
                    }
                    return null;
                  },
                  onChanged: (String value) {},
                  onSubmited: (String val) {
                    FocusScope.of(context).nextFocus();
                  },
                ),
                SizedBox(
                  height: height / 50,
                ),
                SqaureTextFormFieldWidget(
                  lblTxt: "Password",
                  controllerName: passwordController,
                  onChanged: (String value) {},
                  isObscureTxt: true,
                  autoValidate: true,
                  validator: (value) {
                    if (value.isEmpty) {
                      return "";
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: height / 30,
                ),
                SquareFlatButtonWidget(
                  btnTxt: "Login",
                  btnColor: ColorConstants.kMediumRedColor,
                  btnOnTap: () {
                    _onSignIn();
                  },
                ),
                SizedBox(height: height / 30),
                Container(
                  width: width * .7,
                  child: GoogleSignInButton(
                    onPressed: () {
                      _onGoogleSignIn();
                    },
                    centered: true,
                  ),
                ),
                SizedBox(
                  height: height / 50,
                ),
                Container(
                  width: width * .7,
                  child: FacebookSignInButton(
                    onPressed: () {
                      _onFacebookLogin();
                    },
                    centered: true,
                  ),
                ),
                SizedBox(height: height / 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ForgotPasswordScreen(),
                          ),
                        );
                      },
                      child: Text(
                        "Forgot Password?",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: ColorConstants.kMediumRedColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: height / 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "New to App ?",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: ColorConstants.kWhiteColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(
                      width: 3,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => SignUpScreen(),
                          ),
                        );
                      },
                      child: Text(
                        "Sign Up Here",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: ColorConstants.kMediumRedColor,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onSignIn() async {
    FocusManager.instance.primaryFocus.unfocus();

    FirebaseAuth.instance
        .signInWithEmailAndPassword(
            email: emailController.text, password: passwordController.text)
        .then((value) async {
      Constants.loggedInUserID = FirebaseAuth.instance.currentUser.uid;

      SharedPreferences preferences = await SharedPreferences.getInstance();
      preferences.setBool('isLoggedin', true);
      preferences.setString(
          'myName', FirebaseAuth.instance.currentUser.displayName);
      preferences.setString('myEmail', FirebaseAuth.instance.currentUser.email);
      preferences.setString('loggedInUserID', Constants.loggedInUserID);
      // var isAdmin=await UserRepository().getUserById(Constants.loggedInUserID);
      // preferences.setBool('isAdmin', isAdmin.isAdmin);

      await UserRepository().createUser(
        UserModel(
          userName: FirebaseAuth.instance.currentUser.displayName,
          userEmail: FirebaseAuth.instance.currentUser.email,
          userID: Constants.loggedInUserID,
        ),
      );
      SharedPreferences prefs = await SharedPreferences.getInstance();
      Constants.myName = FirebaseAuth.instance.currentUser.displayName;
      Constants.myEmail = FirebaseAuth.instance.currentUser.email;
      Navigator.of(context).pushNamedAndRemoveUntil(
        chatRoute,
        (route) => false,
      );
    }).catchError((e) {
      _showSnackBar(e.message);
    });
  }
}
