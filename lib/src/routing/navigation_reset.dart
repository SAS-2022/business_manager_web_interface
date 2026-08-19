import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NavigationHelper {
  static void resetToHome(BuildContext context, String uid) {
    // Reset the entire navigation stack and push home
    context.goNamed('homeId', pathParameters: {'uid': uid});
  }

  static void resetToHomeWithReplacement(BuildContext context, String uid) {
    // Alternative approach that replaces the current stack
    while (context.canPop()) {
      context.pop();
    }
    context.pushReplacementNamed('homeId', pathParameters: {'uid': uid});
  }

  //reset to login
  static void resetToLoginWithReplacement(BuildContext context,
      {String? message, String? verified}) {
    // Alternative approach that replaces the current stack
    while (context.canPop()) {
      context.pop();
    }
    context.pushReplacementNamed('loginMessage', pathParameters: {
      'message': message ?? '',
      'verified': verified ?? '',
    });
  }
}
