import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ionicons/ionicons.dart';
import 'package:medicare/pages/verificationotp.dart';
import 'package:medicare/utils/name.dart';
import 'package:medicare/utils/colors.dart';
import 'package:medicare/utils/dimensions.dart';
import 'package:medicare/utils/url.dart';
import 'package:quickalert/quickalert.dart';
import 'package:toastification/toastification.dart';
import 'package:http/http.dart' as http;

class Forgotpassword extends StatefulWidget {
  const Forgotpassword({super.key});

  @override
  State<Forgotpassword> createState() => _ForgotpasswordState();
}

class _ForgotpasswordState extends State<Forgotpassword> {
  TextEditingController emailController = TextEditingController();
  TextEditingController otpController = TextEditingController();
  final formkey = GlobalKey<FormState>();

  Future sendOtp(String email) async {
    Map data = {
      'email': email,
    };

    QuickAlert.show(
      context: context,
      type: QuickAlertType.loading,
      title: 'Sending otp',
      text: 'Please wait...',
    );
    try {
      var response = await http.post(
        Uri.parse("${mainurl}forgot_password_otp.php"),
        body: data,
      );
      var jsondata = jsonDecode(response.body);
      if (jsondata['status'] == 'true') {
        print(jsondata);
        toastification.show(
          context: context, // optional if you use ToastificationWrapper
          title: const Text('OTP has been sent to your'),
          description: const Text('registered Email ID'),
          autoCloseDuration: const Duration(seconds: 4),
          style: ToastificationStyle.flatColored,
          applyBlurEffect: true,
          icon: const Icon(
            Ionicons.checkmark_circle,
            color: Colors.green,
          ),
          type: ToastificationType.success,
          pauseOnHover: true,
        );
        if (!mounted) return;
        Navigator.pop(context);
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => Verificationotp(
                      email: email.toString(),
                      jsondata: jsondata,
                    )));
      } else {
        if (!mounted) return;
        Navigator.pop(context);
        Fluttertoast.showToast(
          msg: 'Incorrect email',
          textColor: Colors.black,
          toastLength: Toast.LENGTH_SHORT,
          backgroundColor: Colors.white,
        );
      }
    } catch (e) {
      print("Error: $e");
      Navigator.pop(context);
      Fluttertoast.showToast(
        msg: 'An error occurred, please try again',
        textColor: Colors.black,
        toastLength: Toast.LENGTH_SHORT,
        backgroundColor: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () {
              Navigator.pop(context); // Navigate back
            },
          ),
          backgroundColor: pColor,
          elevation: 0,
          title: appName,
          centerTitle: false,
        ),
        backgroundColor: wColor,
        resizeToAvoidBottomInset: true,
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: Dimensions.width30, vertical: Dimensions.height120),
            child: Form(
              key: formkey,
              child: Column(
                children: [
                  SizedBox(
                    height: Dimensions.height200,
                    width: Dimensions.width180,
                    child: Image.asset(
                      'assets/images/forgot-password.png',
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                  Text(
                    'Forgot password?',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: Dimensions.font20,
                    ),
                  ),
                  SizedBox(
                    height: Dimensions.height10,
                  ),
                  Padding(
                    padding: EdgeInsets.all(Dimensions.height8),
                    child: TextFormField(
                      controller: emailController,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter your registered email";
                        } else if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                          return 'Please enter a valid email id';
                        } else {
                          return null;
                        }
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.email_outlined),
                        filled: false,
                        hintText: 'Email ID', // Changed labelText to hintText
                        hintStyle: const TextStyle(
                          color: Colors.black38,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Colors.black,
                            width: 1.5,
                          ),
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.black,
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.deepPurpleAccent,
                            width: 1.5,
                          ),
                        ),
                        errorBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.red,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: Dimensions.height15),
                    child: ElevatedButton(
                      onPressed: () {
                        if (formkey.currentState!.validate()) {
                          sendOtp(emailController.text);
                        } else {}
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: pColor.withOpacity(0.7),
                        minimumSize:
                            Size(Dimensions.width290, Dimensions.height50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 3,
                      ),
                      child: Text(
                        'Send OTP',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: Dimensions.font20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
