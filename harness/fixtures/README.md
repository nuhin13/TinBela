# Fixtures

`make seed` loads a realistic demo mess:

- 8 members with mixed patterns
- 30 days of exceptions at a realistic rate (~10% of member-days)
- bazar entries roughly every other day
- deposits from 6 of 8 members
- one closed period and one open period

Used for local development, the admin portal, and the in-app demo mess
(Epic 09, task 09.7).

Keep the data plausible. A demo mess with round numbers hides rounding bugs —
which are exactly the bugs that matter here.
