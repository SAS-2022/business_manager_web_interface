import 'dart:convert';
import 'dart:math';

import 'package:business_manager_web_ui/src/models/user_model.dart';
import 'package:business_manager_web_ui/src/services/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:business_manager_web_ui/src/services/error_logging_service.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
      scopes: ['email', 'profile'], signInOption: SignInOption.standard);
  DatabaseService db = DatabaseService();
  // Current user stream
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Current user
  User? get currentUser => _firebaseAuth.currentUser;

  // Email & Password Sign Up
  Future<UserCredential> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      var result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      //Create the user details
      await _checkAndCreateFirestoreUserIfNeeded(
          userCred: result,
          firstName: firstName,
          lastName: lastName,
          email: email);
      await sendEmailVerification();
      return result;
    } on FirebaseAuthException catch (e, stackTrace) {
      ErrorLoggingService.instance.recordError(
        e,
        stackTrace,
        reason: 'FirebaseAuthException signing in using Email and Password',
        information: ['signUpWithEmailAndPassword method'],
        printDetails: true,
      );
      throw Exception(_handleAuthException(e));
    } catch (e, stackTrace) {
      ErrorLoggingService.instance.recordError(
        e,
        stackTrace,
        reason: 'CatchError signing in using Email and Password',
        information: ['signUpWithEmailAndPassword method'],
        printDetails: true,
      );
      throw Exception('An unexpected error occurred. Please try again.');
    }
  }

  // Email & Password Sign In
  Future<({String? error, UserCredential? userCredential})>
      signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      var result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return (error: null, userCredential: result);
    } on FirebaseAuthException catch (e, stackTrace) {
      ErrorLoggingService.instance.recordError(
        e,
        stackTrace,
        reason: 'FirebaseAuthException signing in using Email and Password',
        information: ['signInWithEmailAndPassword method'],
        printDetails: true,
      );
      throw Exception(_handleAuthException(e));
    } catch (e, stackTrace) {
      ErrorLoggingService.instance.recordError(
        e,
        stackTrace,
        reason: 'CatchError signing in using Email and Password',
        information: ['signInWithEmailAndPassword method'],
        printDetails: true,
      );
      throw Exception('An unexpected error occurred. Please try again.');
    }
  }

  Future<void> createFirebaseUserIfNew({
    required UserCredential userCred,
    String? firstName,
    String? lastName,
    String? email,
    bool? exists,
  }) async {
    try {
      final User? user = userCred.user;
      if (user == null) return;

      // Check if this is a new user (first time signing in)
      final bool isNewUser = userCred.additionalUserInfo?.isNewUser ?? false;
      if (isNewUser || exists == false) {
        // Use email from user object if not provided from OAuth
        final String userEmail = email ?? user.email ?? '';

        // If names not provided, try to extract from displayName
        String? finalFirstName = firstName;
        String? finalLastName = lastName;

        if (finalFirstName == null && user.displayName != null) {
          final nameParts = user.displayName!.split(' ');
          finalFirstName = nameParts.first;
          finalLastName =
              nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
        }

        UserDetails newUser = UserDetails(
          uid: user.uid,
          firstName: finalFirstName,
          lastName: finalLastName,
          emailAddress: userEmail,
          cardType: ['news', 'products', 'training'],
          createdAt: DateTime.now(), // Add creation timestamp
        );

        await db.createNewUser(uid: user.uid, user: newUser);
      }
    } catch (e) {
      // Don't throw here - we don't want auth to fail if DB creation has issues
    }
  }

  /// Checks if user exists in Firestore and creates if missing
  Future<void> _checkAndCreateFirestoreUserIfNeeded({
    required UserCredential userCred,
    required String email,
    String? firstName,
    String? lastName,
  }) async {
    try {
      final uid = userCred.user?.uid;
      if (uid == null) return;
      // Check if user document exists in Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('user_collection')
          .doc(userCred.user?.uid)
          .get();

      if (!userDoc.exists) {
        // Build the user details directly here — no nested call needed
        final User user = userCred.user!;

        String? finalFirstName = firstName;
        String? finalLastName = lastName;

        // Fallback to displayName if names weren't passed (e.g. Apple Sign-In)
        if ((finalFirstName == null || finalFirstName.isEmpty) &&
            user.displayName != null) {
          final parts = user.displayName!.trim().split(' ');
          finalFirstName = parts.first;
          finalLastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';
        }

        final newUser = UserDetails(
          uid: uid,
          firstName: finalFirstName,
          lastName: finalLastName,
          emailAddress: email.isNotEmpty ? email : user.email,
          cardType: ['news', 'products', 'training'],
          createdAt: DateTime.now(),
        );

        // ✅ Await directly — no nested method, no silent catch
        await db.createNewUser(uid: uid, user: newUser);
      }
    } catch (e, stackTrace) {
      // Log error but don't throw - we still have a valid auth user
      await ErrorLoggingService.instance.recordError(
        e,
        stackTrace,
        reason: 'Failed to check/create Firestore user',
        information: [
          '_checkAndCreateFirestoreUserIfNeeded',
          'UID: ${userCred.user?.uid}'
        ],
        printDetails: true,
      );
    }
  }

  Future<UserCredential> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // Handle user cancellation
      if (googleUser == null) {
        throw SignInCancelledException();
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Check if we have required tokens
      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        throw Exception('Google authentication failed - missing tokens');
      }

      // Create a new credential
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      var result = await _firebaseAuth.signInWithCredential(credential);

      // Extract user info from Google account
      final String? firstName = googleUser.displayName?.split(' ').first;
      final String? lastName = googleUser.displayName != null &&
              googleUser.displayName!.split(' ').length > 1
          ? googleUser.displayName?.split(' ').sublist(1).join(' ')
          : '';
      final String email = googleUser.email;

      //create firebase user
      await _checkAndCreateFirestoreUserIfNeeded(
        userCred: result,
        email: email,
        firstName: firstName,
        lastName: lastName,
      );

      return result;
    } on SignInCancelledException {
      // Re-throw the cancellation exception without logging it
      _googleSignIn.signOut(); // Ensure we sign out from Google if cancelled
      rethrow;
    } on FirebaseAuthException catch (e, stackTrace) {
      // Handle specific Firebase auth errors
      _googleSignIn.signOut();
      ErrorLoggingService.instance.recordError(
        e,
        stackTrace,
        reason: 'FirebaseAuthException signing in using GoogleSignin',
        information: ['signInWithGoogle method'],
        printDetails: true,
      );
      throw Exception(_handleAuthException(e));
    } on PlatformException catch (e, stackTrace) {
      _googleSignIn.signOut();
      ErrorLoggingService.instance.recordError(
        e,
        stackTrace,
        reason: 'PlatformException signing in using GoogleSignin',
        information: ['signInWithGoogle method'],
        printDetails: true,
      );
      // Handle specific platform error codes
      if (e.code == 'sign_in_failed') {
        _googleSignIn.signOut();
        ErrorLoggingService.instance.recordError(
          e,
          stackTrace,
          reason: 'sign_in_failed using GoogleSignin',
          information: ['signInWithGoogle method'],
          printDetails: true,
        );
        throw Exception(
            'Google Sign-In failed. Please check configuration.| Details: ${e.details} | StackTrace: ${e.stacktrace} | Message:${e.message}');
      } else if (e.code == 'sign_in_canceled') {
        throw Exception('Sign in was cancelled');
      } else {
        _googleSignIn.signOut();
        ErrorLoggingService.instance.recordError(
          e,
          stackTrace,
          reason: 'unknown reason GoogleSignin',
          information: ['signInWithGoogle method'],
          printDetails: true,
        );
        throw Exception(
            'Google Sign-In failed: ${e.message} - ${e.stacktrace} - Message: ${e.message} - Details: ${e.details}');
      }
    } catch (e, stackTrace) {
      _googleSignIn.signOut();
      // Handle unexpected errors
      ErrorLoggingService.instance.recordError(
        e,
        stackTrace,
        reason: 'CatchError signing in using GoogleSignin',
        information: ['signInWithGoogle method'],
        printDetails: true,
      );
      throw Exception('An unexpected error occurred. Please try again.\n$e');
    }
  }

  // Apple Sign In
  Future<UserCredential> signInWithApple() async {
    try {
      // Check if Apple Sign-In is available on this device
      if (!await SignInWithApple.isAvailable()) {
        throw Exception('Apple Sign-In is not available on this device');
      }
      // Trigger the authentication flow
      final rawNonce = _generateNonce();
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: _sha256ofString(rawNonce), // Use hashed nonce
      );

      // Validate that we received required tokens
      if (appleCredential.identityToken == null) {
        throw Exception('Apple Sign-In failed - missing identity token');
      }

      // Create an OAuth credential from the Apple credential
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
        rawNonce: rawNonce,
      );

      // Sign in to Firebase with the Apple credential
      final UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(oauthCredential);

      final appleUser = appleCredential;
      // Extract user info from Google account
      final String? firstName = appleUser.givenName?.split(' ').first;
      final String? lastName = appleUser.familyName;
      final String email = appleUser.email ?? '';

      //create firebase user
      await _checkAndCreateFirestoreUserIfNeeded(
          userCred: userCredential,
          firstName: firstName,
          lastName: lastName,
          email: email);

      return userCredential;
    } on SignInWithAppleAuthorizationException catch (e, stackTrace) {
      ErrorLoggingService.instance.recordError(
        e,
        stackTrace,
        reason:
            'SignInWithAppleAuthorizationException signing in using AppleSignin',
        information: ['signInWithApple method'],
        printDetails: true,
      );
      // Handle Apple-specific authorization errors
      switch (e.code) {
        case AuthorizationErrorCode.canceled:
          throw Exception('Apple Sign-In was cancelled');
        case AuthorizationErrorCode.failed:
          throw Exception('Apple Sign-In failed: ${e.message}');
        case AuthorizationErrorCode.invalidResponse:
          throw Exception('Invalid response from Apple Sign-In');
        case AuthorizationErrorCode.notHandled:
          throw Exception('Apple Sign-In not handled: ${e.code}');
        case AuthorizationErrorCode.unknown:
          throw Exception('Unknown Apple Sign-In error');
        default:
          throw Exception('Apple Sign-In error: ${e.message}');
      }
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthException(e));
    } on PlatformException catch (e, stackTrace) {
      ErrorLoggingService.instance.recordError(
        e,
        stackTrace,
        reason: 'PlatformException signing in using AppleSignin',
        information: ['signInWithApple method'],
        printDetails: true,
      );
      // Handle platform-specific errors
      throw Exception('Apple Sign-In failed: ${e.message}');
    } catch (e, stackTrace) {
      ErrorLoggingService.instance.recordError(
        e,
        stackTrace,
        reason: 'CatchError signing in using AppleSignin',
        information: ['signInWithApple method'],
        printDetails: true,
      );
      throw Exception('An unexpected error occurred. Please try again.');
    }
  }

  // Generate a secure nonce for Apple Sign-In
  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      // Revoke Apple token if user signed in with Apple
      final currentUser = _firebaseAuth.currentUser;
      final isAppleUser =
          currentUser?.providerData.any((p) => p.providerId == 'apple.com') ??
              false;
      if (isAppleUser) {
        // Revoke Apple token — required by App Store guidelines
        final appleToken = await _firebaseAuth.currentUser?.getIdToken();
        if (appleToken != null) {
          await _firebaseAuth.revokeTokenWithAuthorizationCode(appleToken);
        }
      }
    } catch (e, stackTrace) {
      ErrorLoggingService.instance.recordError(
        e,
        stackTrace,
        reason: 'Failed to revoke Apple token during sign out',
        information: ['signOut method'],
        printDetails: true,
        fatal: false,
      );
    }
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }

  // Send Email Verification
  Future<String> sendEmailVerification() async {
    try {
      var result = await currentUser?.sendEmailVerification().then((value) =>
          'Email verification sent, check junk or spam email if you cannot find in Inbox.');

      return result ??
          'Email verification sent, check junk or spam email if you cannot find in Inbox.';
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthException(e));
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Check if email is verified
  bool get isEmailVerified => currentUser?.emailVerified ?? false;

  // Password Reset
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e, stackTrace) {
      ErrorLoggingService.instance.recordError(
        e,
        stackTrace,
        reason: 'FirebaseAuthException error',
        information: ['sendPasswordResetEmail method'],
        printDetails: true,
      );
      throw Exception(_handleAuthException(e));
    } catch (e, stackTrace) {
      ErrorLoggingService.instance.recordError(
        e,
        stackTrace,
        reason: 'CatchError',
        information: ['sendPasswordResetEmail method'],
        printDetails: true,
      );
      throw Exception('An unexpected error occurred. Please try again.');
    }
  }

  Future<void> tryRestoreGoogleSession() async {
    try {
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) return;

      // Only attempt for Google users
      final isGoogleUser =
          currentUser.providerData.any((p) => p.providerId == 'google.com');
      if (!isGoogleUser) return;

      final googleUser = await _googleSignIn.signInSilently();
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;
      if (googleAuth.accessToken == null || googleAuth.idToken == null) return;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _firebaseAuth.currentUser!.reauthenticateWithCredential(credential);
    } catch (e, stackTrace) {
      // Silent — failure here just means user sees login screen
      ErrorLoggingService.instance.recordError(
        e,
        stackTrace,
        reason: 'Failed to silently restore Google session',
        information: ['tryRestoreGoogleSession method'],
        printDetails: true,
        fatal: false,
      );
    }
  }

  // Handle auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'account-exists-with-different-credential':
        return 'An account already exists with the same email but different sign-in method.';
      case 'invalid-verification-code':
        return 'Invalid verification code.';
      case 'invalid-verification-id':
        return 'Invalid verification ID.';
      case 'quota-exceeded':
        return 'Quota exceeded. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      case 'invalid-email':
        return 'Invalid email address format';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'user-not-found':
        return 'No account found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'Email already in use';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled';
      case 'weak-password':
        return 'Password is too weak';
      case 'too-many-requests':
        return 'Too many requests. Try again later';
      case 'invalid-credential':
        return 'Invalid Credentials';
      case 'invalid-id-token':
        return 'Invalid ID token received from Apple.';
      case 'missing-id-token':
        return 'Missing ID token from Apple Sign-In.';
      case 'unauthorized-domain':
        return 'This domain is not authorized for OAuth operations.';
      default:
        return 'Authentication failed: ${e.message}';
    }
  }
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}

class SignInCancelledException implements Exception {
  final String message;
  SignInCancelledException([this.message = 'Sign in cancelled by user']);

  @override
  String toString() => message;
}
