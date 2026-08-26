# Error Taxonomy

Domain errors are typed values. `transport/` maps them to Connect codes and
localised messages. A user never sees a stack trace or a database error.

| Domain error | Connect code | bn message | en message |
|---|---|---|---|
| `ErrNotFound` | `not_found` | পাওয়া যায়নি | Not found |
| `ErrNotMember` | `permission_denied` | আপনি এই মেসের সদস্য নন | You are not a member of this mess |
| `ErrNotManager` | `permission_denied` | শুধু ম্যানেজার এটি করতে পারেন | Only the manager can do this |
| `ErrCutoffPassed` | `failed_precondition` | কাটঅফের সময় শেষ, ম্যানেজারকে বলুন | Cutoff has passed — ask the manager |
| `ErrPeriodClosed` | `failed_precondition` | এই মাস বন্ধ হয়ে গেছে | This month is already closed |
| `ErrPeriodOverlap` | `invalid_argument` | সময়কাল আগের মাসের সাথে মিলে যাচ্ছে | Period overlaps an existing one |
| `ErrNoMeals` | `failed_precondition` | কোনো মিল নেই, মাস শেষ করা যাবে না | No meals recorded — cannot close |
| `ErrInvalidToken` | `unauthenticated` | লিংকটি আর কাজ করছে না | This link is no longer valid |
| `ErrAlreadyVoided` | `failed_precondition` | এটি আগেই বাতিল হয়েছে | Already voided |
| `ErrAlreadyLeft` | `failed_precondition` | এই সদস্য আগেই মেস ছেড়েছেন | This member has already left |
| `ErrCannotLeaveManager` | `failed_precondition` | ম্যানেজারকে এভাবে সরানো যায় না | The manager cannot be removed this way |
| `ErrTenantMismatch` | `permission_denied` | *(generic)* | Not found |

## Rules

- **`ErrTenantMismatch` returns a generic "not found"** to the client. Never
  confirm that another tenant's resource exists.
- `failed_precondition` means "the request was well-formed but the world is
  not in the right state". `invalid_argument` means the request itself was
  wrong. Use them precisely — clients branch on this.
- Every error carries a `request_id` the user can quote to support.
- Never surface a pgx or driver error. Wrap at the repository boundary.
