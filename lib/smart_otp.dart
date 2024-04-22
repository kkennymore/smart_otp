library smart_otp;

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

class SmartOTP extends StatefulWidget {
  final int otpLength;
  final bool autoFocus;
  final TextEditingController controller;
  final double width;
  final double height;
  final double borderRadius;
  final Color backgroundColor;
  final Color textColor;
  final Color cursorColor;
  final Color activeStateBackgroundColor;
  final Color activeStateBorderColor;
  final Color activeStateTextColor;
  final TextStyle style;
  final bool isDigit;

  const SmartOTP({
    super.key,
    this.otpLength = 6,
    this.autoFocus = true,
    required this.controller,
    this.width = 40,
    this.height = 50,
    this.borderRadius = 8.0,
    this.backgroundColor = Colors.white,
    this.textColor = Colors.black,
    this.cursorColor = Colors.blue,
    this.activeStateBackgroundColor = Colors.lightBlueAccent,
    this.activeStateBorderColor = Colors.blueAccent,
    this.activeStateTextColor =  Colors.deepOrangeAccent,
    this.style = const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    this.isDigit = true,
  })  : assert(otpLength >= 1 && otpLength <= 6);

  @override
  State<SmartOTP> createState() => _OTPFormState();
}

class _OTPFormState extends State<SmartOTP> {
  late List<String> _otpCodes;
  late List<FocusNode> _focusNodes;
  late List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _otpCodes = List<String>.filled(widget.otpLength, '');
    _focusNodes = List.generate(widget.otpLength, (_) => FocusNode());
    _controllers = List.generate(widget.otpLength, (index) => TextEditingController());

    if (widget.autoFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FocusScope.of(context).requestFocus(_focusNodes[0]);
      });
    }
  }

  @override
  void dispose() {
    for (var node in _focusNodes) {
      node.dispose();
    }
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onOTPChange(String value, int index) {
    if (value.length > 1) {
      // Paste scenario
      value = value.substring(0, min(value.length, widget.otpLength - index)); // Ensure we do not exceed otpLength
      for (int i = 0; i < value.length; i++) {
        _otpCodes[index + i] = value[i];
        _controllers[index + i].text = value[i];
      }
    } else {
      // Single character input or deletion
      _otpCodes[index] = value;
      _controllers[index].text = value;
    }

    widget.controller.text = _otpCodes.join();

    // Move focus appropriately
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    } else if (value.length == 1 && index < widget.otpLength - 1) {
      _focusNodes[index + 1].requestFocus();
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.otpLength, (index) {
        return Container(
          width: widget.width,
          height: widget.height,
          margin: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            color: _otpCodes[index].isEmpty ? widget.backgroundColor : widget.activeStateBackgroundColor,
            border: Border.all(color: _otpCodes[index].isEmpty ? Colors.transparent : widget.activeStateBorderColor),
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
          child:TextField(
            focusNode: _focusNodes[index],
            controller: _controllers[index],
            style: widget.style.copyWith(color: _otpCodes[index].isEmpty ? widget.textColor : widget.activeStateTextColor),
            cursorColor: widget.cursorColor,
            keyboardType: widget.isDigit ? TextInputType.number : TextInputType.text,
            inputFormatters: [
              widget.isDigit ? FilteringTextInputFormatter.digitsOnly : FilteringTextInputFormatter.singleLineFormatter,
              LengthLimitingTextInputFormatter(1),
            ],
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.only(top:  2.0),
              border: InputBorder.none,
              hintText: index == 0 ? '_' : null,
              hintStyle: widget.style,
            ),
            onChanged: (value) => _onOTPChange(value, index),
            
          ),
        );
      }),
    );
  }
}
