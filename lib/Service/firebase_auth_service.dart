import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class FirebaseAuthService {
  FirebaseAuthService._();

  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Get current logged-in Firebase Social user
  static User? get currentUser => _auth.currentUser;

  /// Stream of Auth State changes
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ── 1. GOOGLE SIGN-IN ──────────────────────────────────────────────────────
  static Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        debugPrint('[FirebaseAuth] Google Sign-In cancelled by user');
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      debugPrint('[FirebaseAuth] Google Sign-In success: ${userCredential.user?.email}');
      return userCredential;
    } catch (e) {
      debugPrint('[FirebaseAuth] Google Sign-In error: $e');
      rethrow;
    }
  }

  // ── 2. FACEBOOK SIGN-IN ────────────────────────────────────────────────────
  static Future<UserCredential?> signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();

      if (result.status == LoginStatus.success && result.accessToken != null) {
        final OAuthCredential credential = FacebookAuthProvider.credential(
          result.accessToken!.tokenString,
        );

        final UserCredential userCredential = await _auth.signInWithCredential(credential);
        debugPrint('[FirebaseAuth] Facebook Sign-In success: ${userCredential.user?.email}');
        return userCredential;
      } else {
        debugPrint('[FirebaseAuth] Facebook Sign-In status: ${result.status}, msg: ${result.message}');
        return null;
      }
    } catch (e) {
      debugPrint('[FirebaseAuth] Facebook Sign-In error: $e');
      rethrow;
    }
  }

  // ── 3. APPLE SIGN-IN ───────────────────────────────────────────────────────
  static Future<UserCredential?> signInWithApple() async {
    try {
      final AuthorizationCredentialAppleID appleCredential =
          await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final OAuthCredential credential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      debugPrint('[FirebaseAuth] Apple Sign-In success: ${userCredential.user?.email}');
      return userCredential;
    } catch (e) {
      debugPrint('[FirebaseAuth] Apple Sign-In error: $e');
      rethrow;
    }
  }

  // ── 4. SIGN OUT ────────────────────────────────────────────────────────────
  static Future<void> signOut() async {
    try {
      await _auth.signOut();
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }
      await FacebookAuth.instance.logOut();
      debugPrint('[FirebaseAuth] Social Sign Out successful');
    } catch (e) {
      debugPrint('[FirebaseAuth] Sign Out error: $e');
    }
  }
}
