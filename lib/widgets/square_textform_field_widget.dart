import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../common/color_constants.dart';

class SqaureTextFormFieldWidget extends StatelessWidget {
  final TextEditingController controllerName;
  final List<TextInputFormatter> inputFormatterList;
  final FocusNode myFocusNode;
  final TextInputType inputType;
  final TextInputAction inputAction;
  final EdgeInsetsGeometry myMargin;
  final Function(String) onChanged;
  final Function(String) onSubmited;
  final VoidCallback textFocus;
  final String Function(String) validator;
  final bool autoValidate;
  final bool isAlignLeft;
  final String hintTxt;
  final bool myAutoFocus;
  final int maxLength;
  final TextCapitalization textCapitalization;
  final String lblTxt;
  final bool isObscureTxt;
  final bool isEnable;
  final double conHeight;

  SqaureTextFormFieldWidget({
    Key key,
    @required this.controllerName,
    this.inputFormatterList,
    this.onChanged,
    this.myFocusNode,
    this.isAlignLeft = true,
    this.myMargin = const EdgeInsets.all(0),
    this.inputType = TextInputType.text,
    this.inputAction = TextInputAction.done,
    this.textFocus,
    this.onSubmited,
    this.validator,
    this.hintTxt,
    this.myAutoFocus = false,
    this.autoValidate = false,
    this.maxLength,
    this.textCapitalization = TextCapitalization.sentences,
    this.lblTxt,
    this.isObscureTxt = false,
    this.isEnable = true,
    this.conHeight = 50,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: conHeight,
      child: Padding(
        padding: const EdgeInsets.only(
          left: 10,
          right: 10,
        ),
        child: TextFormField(
          cursorColor: ColorConstants.kMediumRedColor,
          enabled: isEnable,
          maxLength: maxLength,
          obscureText: isObscureTxt,
          autofocus: myAutoFocus,
          textAlign: TextAlign.start,
          autovalidateMode: autoValidate ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
          validator: this.validator,
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: ColorConstants.kWhiteColor,
          ),
          controller: controllerName,
          focusNode: myFocusNode,
          keyboardType: inputType,
          textInputAction: inputAction,
          onEditingComplete: textFocus,
          decoration: InputDecoration(
            labelText: lblTxt,
            labelStyle: GoogleFonts.poppins(
              fontSize: 18,
              color: ColorConstants.kWhiteColor,
              fontWeight: FontWeight.w500,
            ),
            contentPadding: EdgeInsets.all(0.0),
            isDense: true,
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: ColorConstants.kWhiteColor,
              ),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: ColorConstants.kWhiteColor,
              ),
            ),
            errorBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: ColorConstants.kErrorColor,
              ),
            ),
            disabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: ColorConstants.kWhiteColor,
              ),
            ),
            hintStyle: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: ColorConstants.kWhiteColor,
            ),
            errorStyle: GoogleFonts.poppins(
              color: ColorConstants.kErrorColor,
              fontWeight: FontWeight.w700,
              fontSize: 0
            ),
            hintText: hintTxt,
            focusColor: ColorConstants.kWhiteColor,
            counterText: '',
          ),
          onChanged: (str) {
            onChanged(str);
          },
          onSaved: (str) {
            onSubmited(str);
          },
          inputFormatters: inputFormatterList,
          textCapitalization: textCapitalization,
        ),
      ),
    );
  }
}
