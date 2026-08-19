# ADR-0009 — Google Sign-In for managers, magic-link tokens for members

**Status:** Accepted
**Date:** 2026-08-19

**Context.** The prototype specified phone OTP. OTP requires an SMS gateway, carries a per-message
cost, has real deliverability failure modes in Bangladesh, and tempts an `READ_SMS` permission
that triggers a Play permissions review.

**Decision.** Managers authenticate with Google Sign-In via Firebase, with phone number collected
as a profile field for member matching. Members never authenticate at all — a long random,
revocable, single-member-scoped token in the URL *is* the credential.

**Consequences.** One tap to sign in, zero SMS cost, no gateway dependency, no sensitive permission.
Members get the zero-friction path that makes the growth loop work. Cost: managers without a Google
account cannot sign in — a negligible population on Android in Bangladesh.

**Revisit when.** Field feedback shows managers expecting phone login, or iOS becomes a target. OTP
becomes an additional method, not a replacement.
