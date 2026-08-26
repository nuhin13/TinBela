// Epic 08 task 08.9 -- the manager's auth session lifecycle.
//
// This is the token plumbing, not the sign-in screen (that is task 09.2). It
// exists to satisfy one hard requirement: the app must SURVIVE TOKEN EXPIRY
// MID-SESSION. Firebase ID tokens expire after an hour, and a manager marking
// the day's meals at minute 61 must not be bounced to sign-in.
//
// Two mechanisms, both here:
//   1. Proactive -- token() refreshes a token that is within a skew window of
//      expiry before it is ever put on the wire.
//   2. Reactive  -- refresh() force-mints a new token, and ConnectClient calls
//      it on a 401 and retries once, covering a token the server rejects that
//      our own clock still thought valid (revocation, clock skew).
//
// The concrete token source is an [AuthBackend]. The refresh POLICY lives here
// so it is written and tested once and shared: task 09.2 drops in a
// FirebaseAuthBackend and inherits all of it unchanged.

import 'package:flutter/foundation.dart';

/// A bearer token and the instant it stops being valid.
///
/// [expiresAt] is UTC. Firebase reports this on the decoded ID token; the dev
/// backend synthesises it so the same refresh path runs before Firebase does.
@immutable
class AuthToken {
  const AuthToken(this.jwt, this.expiresAt);

  final String jwt;
  final DateTime expiresAt;
}

/// Whether anyone is signed in. [unknown] is the state before the first token
/// has been asked for -- the app has not yet learned who, if anyone, is here.
enum AuthStatus { unknown, signedIn, signedOut }

/// The token source. One implementation in v1.0 dev (`dev:<uid>`); task 09.2
/// adds the Firebase one; prod runs [UnauthenticatedBackend] until it does.
abstract interface class AuthBackend {
  /// A currently-valid token, or null when no one is signed in.
  ///
  /// [forceRefresh] must bypass any backend-side cache -- it maps directly to
  /// Firebase's `getIdToken(true)`, which is the whole point of the reactive
  /// path: when the server has rejected the cached token, asking for the same
  /// cached token again would loop.
  Future<AuthToken?> issueToken({bool forceRefresh = false});

  /// Ends the session at the source (Firebase sign-out, Google disconnect).
  Future<void> signOut();
}

/// Owns the token cache and the refresh policy across every backend.
///
/// [token] is the [TokenProvider] ConnectClient asks on each call; [refresh]
/// is the [UnauthenticatedRecovery] it calls on a 401. Neither is wired to any
/// widget -- routing on sign-out is task 09.2's job -- but [status] is exposed
/// so that wiring has something to listen to.
class AuthSession {
  AuthSession(
    this._backend, {
    // Refresh this far before the real expiry. Longer than any single request
    // could take, so a token handed to the transport cannot die in flight.
    Duration refreshSkew = const Duration(minutes: 5),
    // Injected so the expiry policy is testable without waiting an hour.
    DateTime Function()? clock,
  })  : _refreshSkew = refreshSkew,
        _clock = clock ?? (() => DateTime.now().toUtc());

  final AuthBackend _backend;
  final Duration _refreshSkew;
  final DateTime Function() _clock;

  final ValueNotifier<AuthStatus> _status =
      ValueNotifier<AuthStatus>(AuthStatus.unknown);

  /// Observable sign-in state, for the router that task 09.2 will add.
  ValueListenable<AuthStatus> get status => _status;

  AuthToken? _cached;

  /// The bearer token for the next call, refreshing first if it is spent or
  /// nearly so. Null when signed out -- ConnectClient then omits the header
  /// and the server answers `unauthenticated`, which the app reads as
  /// onboarding.
  Future<String?> token() async {
    final cached = _cached;
    if (cached != null && !_isStale(cached)) return cached.jwt;
    // A cached-but-stale token means force a real refresh; a cold start
    // (nothing cached) just asks for whatever the backend already holds.
    return _mint(forceRefresh: cached != null);
  }

  /// Forces a new token regardless of the cache, returning whether one was
  /// obtained. ConnectClient calls this on a 401 and retries once when true.
  Future<bool> refresh() async => (await _mint(forceRefresh: true)) != null;

  /// Ends the session and drops the cached token. Idempotent.
  Future<void> signOut() async {
    await _backend.signOut();
    _cached = null;
    _status.value = AuthStatus.signedOut;
  }

  Future<String?> _mint({required bool forceRefresh}) async {
    final token = await _backend.issueToken(forceRefresh: forceRefresh);
    _cached = token;
    _status.value = token == null ? AuthStatus.signedOut : AuthStatus.signedIn;
    return token?.jwt;
  }

  bool _isStale(AuthToken token) =>
      !_clock().isBefore(token.expiresAt.subtract(_refreshSkew));

  void dispose() => _status.dispose();
}

/// Dev backend: the seeded `dev:<uid>` token the local stack's dev verifier
/// accepts (services/api NewDevVerifier). The verifier ignores expiry, so the
/// synthetic TTL here exists only to drive the refresh path -- in dev the app
/// refreshes on the same schedule it will in prod, so "survives token expiry"
/// is exercised long before Firebase exists.
class DevAuthBackend implements AuthBackend {
  DevAuthBackend(
    this._uid, {
    Duration ttl = const Duration(hours: 1),
    DateTime Function()? clock,
  })  : _ttl = ttl,
        _clock = clock ?? (() => DateTime.now().toUtc());

  final String _uid;
  final Duration _ttl;
  final DateTime Function() _clock;
  bool _signedOut = false;

  @override
  Future<AuthToken?> issueToken({bool forceRefresh = false}) async {
    if (_signedOut) return null;
    return AuthToken('dev:$_uid', _clock().add(_ttl));
  }

  @override
  Future<void> signOut() async => _signedOut = true;
}

/// Prod backend until task 09.2 wires Firebase: nobody is signed in, so every
/// call goes out tokenless and the server answers `unauthenticated`. This is
/// the same behaviour the app shipped with before this task -- a release build
/// simply has no sign-in yet.
class UnauthenticatedBackend implements AuthBackend {
  const UnauthenticatedBackend();

  @override
  Future<AuthToken?> issueToken({bool forceRefresh = false}) async => null;

  @override
  Future<void> signOut() async {}
}
