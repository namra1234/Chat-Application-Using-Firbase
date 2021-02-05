import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../common/color_constants.dart';

/* 
Title:SquareFlatButtonWidget
Purpose:SquareFlatButtonWidget
Created Date: 29 Sep, 2020
Updated Updated Date:29 Sep, 2020
Author: Flutter Agency
*/

class SquareFlatButtonWidget extends StatelessWidget {
  final Color btnColor;
  final String btnTxt;
  final Function btnOnTap;
  final double btnHeight;
  final Color textColor;
  final double btnTxtfontSize;
  final double btnWidth;
  final bool loading;

  SquareFlatButtonWidget({
    Key key,
    this.btnColor,
    @required this.btnTxt,
    @required this.btnOnTap,
    this.btnHeight = 45,
    this.btnWidth,
    this.textColor = ColorConstants.kWhiteColor,
    this.btnTxtfontSize = 16.0,
    this.loading = false
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: btnHeight,
      width: btnWidth,
      decoration: BoxDecoration(
        color: btnColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: FlatButton(
        onPressed: loading ? null : btnOnTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 0,
            horizontal: 12,
          ),
          child: Center(
            child: loading ? CircularProgressIndicator() : Text(
              btnTxt,
              style: GoogleFonts.poppins(
                fontSize: btnTxtfontSize,
                color: ColorConstants.kWhiteColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
