import 'package:flutter/material.dart';

import '../views/mainChat.dart';
import '../views/sign_in.dart';
import '../views/sign_up.dart';


const String SignUpScreenRoute = 'signUpScreenView';
const String SignInScreenRoute = 'signInScreenView';
const String chatRoute = 'chatPage';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Getting arguments passed in while calling Navigator.pushNamed
    final args = settings.arguments as Map<String,dynamic>;
    Widget page;
    switch (settings.name) {
      case SignUpScreenRoute:
        page = SignUpScreen();
        break;
      case SignInScreenRoute:
        page = SignInScreen();
        break;
      case chatRoute:
        page = mainChat();
        break;
      default:
        // If there is no such named route in the switch statement, e.g. /third
        page = mainChat();
        break;
    }
    return MaterialPageRoute(builder: (context) => page,);
  }
}
