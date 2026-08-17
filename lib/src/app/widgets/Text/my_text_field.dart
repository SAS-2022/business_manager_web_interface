import 'package:business_manager_web_ui/l10n/app_localizations.dart';
import 'package:business_manager_web_ui/src/app/theme/responsive_utils.dart';
import 'package:business_manager_web_ui/src/app/utils/components/number_format.dart';
import 'package:business_manager_web_ui/src/app/utils/validators.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class MyTextField extends StatefulWidget {
  const MyTextField(
      {super.key,
      required this.controller,
      this.hintText,
      this.obsecure,
      this.emailValidation,
      this.stringEmpty,
      this.passValidation,
      this.isPassword,
      this.isString,
      this.fontSize,
      this.prefix,
      this.prefixIcon,
      this.suffix,
      this.lines,
      this.enabled,
      this.center,
      this.maxLenght,
      this.height,
      this.focus,
      this.capitalize,
      this.itemOriginalPrice,
      this.items,
      this.bgColor,
      this.focusNode,
      this.isNumberKeyboard,
      this.signed,
      this.onChanged,
      this.enabledBorders});
  final TextEditingController controller;
  final String? hintText;
  final bool? obsecure;
  final bool? emailValidation;
  final bool? stringEmpty;
  final bool? passValidation;
  final bool? isPassword;
  final bool? isString;
  final double? fontSize;
  final String? prefix;
  final Icon? prefixIcon;
  final String? suffix;
  final int? lines;
  final bool? enabled;
  final bool? center;
  final int? maxLenght;
  final double? height;
  final bool? focus;
  final TextCapitalization? capitalize;
  final double? itemOriginalPrice;
  final List<String>? items;
  final Color? bgColor;
  final FocusNode? focusNode;
  final bool? isNumberKeyboard;
  final bool? signed;
  final Function? onChanged;
  final bool? enabledBorders;

  @override
  State<MyTextField> createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  final specialChar = RegExp(r'[!@#%^&*(),.?":{}|<>]');
  final digitRex = RegExp(r'\d');
  AppLocalizations? appLoc;
  RegExp numberPattern = RegExp(r'^[0-9]{0,8}(?:[.][0-9]{0,4})?$');
  RegExp numberPatternWithNeg = RegExp(r'^-?[0-9]{0,8}(?:[.][0-9]{0,4})?$');
  //RegExp(r'^\d*\.?\d{0,4}$');
  double? newValue = 0.0;
  bool? isObsecure = false, notValid = false;
  ResponsiveUtils? responsive;

  @override
  void initState() {
    if (widget.obsecure != null) {
      isObsecure = widget.obsecure;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    appLoc = AppLocalizations.of(context);
    responsive = ResponsiveUtils(context);

    return SizedBox(
      height: widget.height ?? responsive!.screenHeight * 0.1,
      child: TextFormField(
        key: widget.key,
        focusNode: widget.focusNode,
        controller: widget.controller,
        scrollPadding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        enabled: widget.enabled ?? true,
        maxLength: widget.maxLenght,
        autofocus: widget.focus ?? false,
        textAlign: widget.center != null && widget.center!
            ? TextAlign.center
            : TextAlign.start,
        obscureText: isObsecure ?? false,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        textCapitalization: widget.capitalize == null
            ? TextCapitalization.none
            : widget.capitalize!,
        maxLines: widget.lines ?? 1,
        keyboardType:
            widget.isNumberKeyboard != null && widget.isNumberKeyboard!
                ? TextInputType.numberWithOptions(
                    signed: widget.signed ?? false, decimal: true)
                : null,
        inputFormatters: widget.isString != null && !widget.isString!
            ? [
                FilteringTextInputFormatter.allow(
                    widget.signed != null && widget.signed!
                        ? numberPatternWithNeg
                        : numberPattern)
              ]
            : null,
        decoration: InputDecoration(
          // label: widget.hintText != null
          //     ? Text(
          //         widget.hintText!,
          //         style: TextStyle(
          //           fontSize: widget.fontSize ?? 12,
          //         ),
          //       )
          //     : null,
          errorStyle: TextStyle(
              fontSize: responsive!.scaleFont(widget.fontSize ?? 12) * 0.6),
          fillColor: widget.bgColor ?? Colors.white,
          isDense: true,
          isCollapsed: false,
          contentPadding: responsive!.responsivePaddingM,
          suffix: widget.suffix != null
              ? Text(
                  widget.suffix!,
                )
              : null,
          prefix: Text('${widget.prefix ?? ''} '),
          prefixIcon: widget.prefixIcon != null
              ? Icon(
                  widget.prefixIcon!.icon,
                  size: responsive!.scaleWidth(18),
                  color: Theme.of(context).colorScheme.primary,
                )
              : null,
          enabledBorder:
              widget.enabledBorders != null && widget.enabledBorders == false
                  ? InputBorder.none
                  : OutlineInputBorder(
                      gapPadding: 1,
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 0.5,
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
          border:
              widget.enabledBorders != null && widget.enabledBorders == false
                  ? InputBorder.none
                  : OutlineInputBorder(
                      gapPadding: 1,
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.secondary,
                        width: 0.5,
                      ),
                    ),
          errorBorder: widget.enabledBorders != null &&
                  widget.enabledBorders == false
              ? InputBorder.none
              : OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Theme.of(context).colorScheme.error),
                  borderRadius: BorderRadius.circular(10),
                ),
          focusedBorder:
              widget.enabledBorders != null && widget.enabledBorders == false
                  ? InputBorder.none
                  : OutlineInputBorder(
                      gapPadding: 1,
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.secondaryFixed,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
          hintText: widget.hintText,
          //for obsecuring password and showing it
          suffixIcon: widget.isPassword != null && widget.isPassword!
              ? IconButton(
                  onPressed: () async {
                    setState(() {
                      isObsecure = !isObsecure!;
                    });
                  },
                  icon: Icon(
                      !isObsecure! ? Icons.visibility : Icons.visibility_off),
                  color: Theme.of(context).iconTheme.color,
                )
              : null,
        ),
        validator: (value) {
          if (value != null) {
            notValid = true;
          } else {
            notValid = false;
          }
          if (widget.stringEmpty != null && widget.stringEmpty!) {
            if (value!.isEmpty) {
              return '${widget.hintText} ${appLoc!.notEmpty}';
            }
          }
          if (widget.emailValidation != null && widget.emailValidation!) {
            //will validated email
            if (value != null &&
                value.isNotEmpty &&
                !EmailValidator.validate(value)) {
              return appLoc!.emailValidation;
            }
          }
          if (widget.passValidation != null && widget.passValidation!) {
            var pass = PasswordValidator.validate(value!, appLoc!);
            if (!pass.isValid) {
              return pass.errorMessage.toString();
            } else {
              return null;
            }
          }

          return null;
        },
        onChanged: (value) {
          if (widget.onChanged != null) {
            NumberWithCommas nc = NumberWithCommas();
            nc.formatNumber(widget.controller);
          }
        },
        style: TextStyle(
          fontSize: widget.fontSize ?? 12,
        ),
      ),
    );
  }
}
