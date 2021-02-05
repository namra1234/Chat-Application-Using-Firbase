import 'dart:io';

import 'package:image_picker_gallery_camera/image_picker_gallery_camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path/path.dart' as Path;
import 'package:shared_preferences/shared_preferences.dart';
import '../common/constants.dart';
import '../models/userModel.dart';
import '../repository/userRep.dart';
import '../widgets/square_flat_button_widget.dart';
import '../common/color_constants.dart';
import '../widgets/square_textform_field_widget.dart';
import 'sign_in.dart';


class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController nameController,
      emailController,
      mobileController,
      passwordController;
  double height, width, statusBarHeight, appBarHeight;
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  GlobalKey<FormState> _formkey = new GlobalKey<FormState>();
  File _image;
  String _uploadedFileURL;
  bool uploadingImage = false;

  final picker = ImagePicker();
  
    @override
    void initState() {
      super.initState();
      nameController = TextEditingController();
      emailController = TextEditingController();
      mobileController = TextEditingController();
      passwordController = TextEditingController();
    }
  
    @override
    void dispose() {
      nameController.dispose();
      emailController.dispose();
      mobileController.dispose();
      passwordController.dispose();
      super.dispose();
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
        ),
      );
      return Scaffold(
        key: _scaffoldKey,
        backgroundColor: ColorConstants.kWhiteColor,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: ColorConstants.kWhiteColor,
          brightness: Brightness.light,
          elevation: 0,
          title: Text(
            "Sign Up",
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: ColorConstants.kPrimaryColor,
            ),
          ),
        ),
        resizeToAvoidBottomInset: false,
        body: Container(
          decoration: BoxDecoration(
            color: ColorConstants.kPrimaryColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: Form(
            key: _formkey,
            child: Padding(
              padding:  EdgeInsets.only(
                left: height/20,
                right: height/20,
                top: height/20,
              ),
              child: ListView(
                children: [
                  Center(
          child: Image.asset(
            'assets/images/applogo.png',height: height/5,
          ),
        ),
                  SqaureTextFormFieldWidget(
                    controllerName: nameController,
                    lblTxt: "First Name",
                    inputType: TextInputType.text,
                    autoValidate: true,
                    validator: (value) {
                      if (value.isEmpty) {
                        return "";
                      }
                      return null;
                    },
                    onSubmited: (String val) {},
                  ),
                  SizedBox(
                    height: height/50,
                  ),
                  SqaureTextFormFieldWidget(
                    controllerName: emailController,
                    lblTxt: "Email",
                    inputType: TextInputType.emailAddress,
                    autoValidate: true,
                    validator: (value) {
                      if (value.isEmpty) {
                        return "";
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: height/50,
                  ),
                  SqaureTextFormFieldWidget(
                    controllerName: passwordController,
                    lblTxt: "Password",
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
                    height: height/50,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 10,
                      right: 10,
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Upload Image",
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                color: ColorConstants.kWhiteColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            uploadingImage
                                ? CircleAvatar(
                                    radius: 15,
                                    child: CircularProgressIndicator(),
                                  )
                                : GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        FocusScope.of(context)
                                            .requestFocus(new FocusNode());
                                      });
                                      getImage(ImgSource.Both);
                                    },
                                    child: _image != null
                                        ? Container(
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: ColorConstants
                                                      .kMediumRedColor,
                                                )),
                                            child: CircleAvatar(
                                              radius: 15,
                                              backgroundImage: FileImage(_image),
                                            ),
                                          )
                                        : Container(
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: ColorConstants
                                                      .kMediumRedColor,
                                                )),
                                            child: CircleAvatar(
                                              radius: 15,
                                              backgroundColor:
                                                  ColorConstants.kMediumRedColor,
                                              backgroundImage: AssetImage(
                                                "assets/images/profile1.png",
                                              ),
                                            ),
                                          ),
                                  )
                          ],
                        ),
                        Divider(
                          color: ColorConstants.kWhiteColor,
                          thickness: 1,
                        ),
                      ],
                    ),
                  ),
                  /* SqaureTextFormFieldWidget(
                    lblTxt: "Mobile",
                    maxLength: 10,
                    controllerName: mobileController,
                    inputType: TextInputType.phone,
                  ),
                  SizedBox(
                    height: 10,
                  ), */
                  SizedBox(
                    height: height/30,
                  ),
                  SquareFlatButtonWidget(
                    btnTxt: "Sign Up",
                    btnColor: ColorConstants.kMediumRedColor,
                    btnOnTap: () {
                      FocusScope.of(context).requestFocus(FocusNode());
                      if (_formkey.currentState.validate()) {
                        _fireabaseAuth();
                      }
                      // _onSignUp();
                    },
                  ),
                  SizedBox(
                    height: height/15,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        "Already have a account ?",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: ColorConstants.kWhiteColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => SignInScreen(),
                            ),
                          );
                        },
                        child: Text(
                          "Sign In",
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
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
  
    void _showSnackBar(String message) {
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
    }
  
    Future getImage(ImgSource source) async {
      File image = await ImagePickerGC.pickImage(
        context: context,
        source: source,
        cameraIcon: Icon(
          Icons.add,
          color: Colors.red,
        ),
      );
      await uploadPic(image);
      setState(() {
        _image = image;
      });
    }
  
    //not use uploadpic method.
    Future uploadPic(File image) async {
      setState(() {
        uploadingImage = true;
      });
      StorageReference storageReference =
          FirebaseStorage.instance.ref().child(Path.basename(image.path));
      StorageUploadTask uploadTask = storageReference.putFile(image);
      await uploadTask.onComplete.then((taskSnapshot) async {
        _uploadedFileURL = await taskSnapshot.ref.getDownloadURL();
        _showSnackBar("Successfully uploaded profile picture");
      }).catchError((e) {
        _showSnackBar("Failed to upload profile picture");
      });
      setState(() {
        uploadingImage = false;
      });
    }
  
    void _fireabaseAuth() async {
      FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      )
          .then((value) async {
        Constants.loggedInUserID = FirebaseAuth.instance.currentUser.uid;
        User user = value.user;
        await user.updateProfile(
          displayName: nameController.text,
          photoURL: _uploadedFileURL,
        );
        
        SharedPreferences preferences = await SharedPreferences.getInstance();
        preferences.setBool('isLoggedin', true);
        Constants.loggedInUserID = FirebaseAuth.instance.currentUser.uid;
  Constants.myName=FirebaseAuth.instance.currentUser.displayName;
    Constants.myEmail=FirebaseAuth.instance.currentUser.email;
    preferences.setString('myName', Constants.myName);
      preferences.setString('myEmail', Constants.myEmail);
      preferences.setString('loggedInUserID', Constants.loggedInUserID);
        // var isAdmin=await UserRepository().getUserById(Constants.loggedInUserID);
        // preferences.setBool('isAdmin', isAdmin.isAdmin);
  
  
      await UserRepository().createUser(
        UserModel(
          userName: nameController.text,
          userEmail: emailController.text,
          userID: Constants.loggedInUserID,
          
        ),
      );
      
      _showSnackBar("Category Created Successfully");
      
      //   Navigator.of(context).pushAndRemoveUntil(
      //   MaterialPageRoute(
      //     builder: (context) => CreateJoinOrg(),
      //   ),
      //   (route) => false,
      // );
      }).catchError((e) {
        _showSnackBar(e.message);
      });
    }
  }
  
  ImagePicker() {
}
