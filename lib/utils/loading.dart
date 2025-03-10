import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:medicare/utils/dimensions.dart';

class LoadingDialog extends StatelessWidget {
  const LoadingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      insetPadding: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Center(
        child: Container(
          color: Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // CupertinoActivityIndicator(
              //   radius: 20,
              //   color: CupertinoColors.black,
              // )
              // CircularProgressIndicator(
              //   color: Colors.purple[300],
              // ),
              Lottie.asset(
                'assets/animation/loading.json',
                width: Dimensions.screenWidth,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
