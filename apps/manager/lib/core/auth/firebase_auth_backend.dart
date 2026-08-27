// Epic 09 task 09.2 -- the real manager sign-in, behind the AuthBackend seam.
//
// Google Sign-In via Firebase (ADR-0009): one tap, no SMS gateway, no OTP, no
// READ_SMS permission. Phone number is a profile field collected later, never
// a credential here.
//
// This is the ONE file that touches the google_sign_in / firebase_auth plugin
// APIs, deliberately: those APIs shift between major versions, so the blast
// radius of a version bump is this file, not the app. Everything else depends
// only on AuthBackend / AuthSession.
//
// It is compiled in every build but constructed only for the prod flavor
// (see main.dart) -- dev signs in through DevAuthBackend and never initialises
// Firebase, so a dev build needs no google-services.json.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'auth_session.dart';

class FirebaseAuthBackend implements AuthBackend {
  FirebaseAuthBackend({FirebaseAuth? auth, GoogleSignIn? google})
      : _auth = auth ?? FirebaseAuth.instance,
        _google = google ?? GoogleSignIn();

  final FirebaseAuth _auth;
  final GoogleSignIn _google;

  @override
  Future<AuthToken?> signIn() async {
    // Null means the user dismissed the Google account picker -- a back-out,
    // not a failure. The screen stays put and shows nothing.
    final account = await _google.signIn();
    if (account == null) return null;

    final auth = await account.authentication;
    final credential = GoogleAuthProvider.credential(
      idToken: auth.idToken,
      accessToken: auth.accessToken,
    );
    await _auth.signInWithCredential(credential);

    // currentUser is now set; read the freshly minted ID token uniformly.
    return _tokenFor(forceRefresh: true);
  }

  @override
  Future<AuthToken?> issueToken({bool forceRefresh = false}) =>
      _tokenFor(forceRefresh: forceRefresh);

  @override
  Future<void> signOut() async {
    // Sign out of both: leaving the Google session behind would silently
    // re-authenticate the same account on the next tap, so "sign out" would
    // not actually let a manager switch accounts.
    await _google.signOut();
    await _auth.signOut();
  }

  Future<AuthToken?> _tokenFor({required bool forceRefresh}) async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final result = await user.getIdTokenResult(forceRefresh);
    final jwt = result.token;
    if (jwt == null) return null;

    // Firebase reports the real expiry; AuthSession refreshes ahead of it.
    // Fall back to the standard one-hour lifetime if it is ever absent.
    final expiresAt = result.expirationTime?.toUtc() ??
        DateTime.now().toUtc().add(const Duration(hours: 1));
    return AuthToken(jwt, expiresAt);
  }
}
