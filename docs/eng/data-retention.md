# Data Retention & Account Deletion

Google Play requires both in-app account deletion and a public web deletion
request page. Missing either is a rejection cause (Epic 19).

## What happens on account deletion

A mess is a shared ledger. One member deleting their account must not
destroy other members' statements — those are immutable financial records
that other people rely on.

| Data | On deletion |
|---|---|
| `users` row | soft-deleted: `deleted_at` set, `phone_e164` released, name replaced with "মুছে ফেলা সদস্য" |
| `memberships` | retained, `display_name` anonymised |
| `meal_exceptions` | **retained** — append-only, and other members' meal rates depend on the totals |
| `ledger_entries` | **retained** for the same reason |
| `period_statements` | **retained** — immutable financial records |
| Firebase auth record | deleted |
| Analytics identifiers | deleted |

## Why records are retained

Removing one member's meals would silently change everyone else's meal rate
for a closed month. That would break the immutability promise which is the
core of the product. We anonymise the person, we do not rewrite history.

**This must be stated plainly in the deletion flow and the privacy policy.**
A user has a right to know that their meals stay in the mess's totals even
after their name is gone.

## If a manager deletes their account

The mess is not deleted. Ownership must be handed over first (P2 feature) or
the mess enters an orphaned state where the remaining members can claim
management. Until handover ships (v1.1), block manager deletion with a clear
message rather than orphaning the mess.
