# How to merge these

Seven documentation files. No code, no generated files, nothing that
`make verify` touches. Base commit: **`bcc1859`** (the prototype rename).

---

## Option A — apply the patch (recommended)

Cleanest history, and it will refuse rather than clobber if you have edited
any of these files since `bcc1859`.

```bash
cd /path/to/TinBela

# dry run first — prints nothing and exits 0 if it will apply
git apply --check docs-nav-fixes.patch

git apply docs-nav-fixes.patch
git add -A
git commit -m "docs: resolve prototype/spec navigation conflicts

- prototype vs ADR-0009: sign-in is Google, not phone OTP
- manager nav locked to 4 tabs; member PWA to 2
- SCREENS.md verified against prototype.html, 8 rows added
- root AGENTS.md now routes to the prototype"
```

If `--check` fails, you have local edits in one of the seven. Use Option B.

---

## Option B — copy the files over

Overwrites all seven with the patched versions.

```bash
cd /path/to/TinBela
cp -r /path/to/tinbela-docs-patch/AGENTS.md .
cp -r /path/to/tinbela-docs-patch/apps  .
cp -r /path/to/tinbela-docs-patch/docs  .

git diff            # read this before committing
```

The `apps/` and `docs/` copies only contain the four changed files, so they
merge into your existing directories without touching anything else.

---

## Option C — review each one first

```bash
cd /path/to/TinBela
for f in AGENTS.md apps/manager/AGENTS.md apps/web/AGENTS.md \
         docs/design/README.md docs/design/SCREENS.md \
         docs/product/UI_SPEC.md docs/product/EPICS.md; do
  echo "═══ $f"
  diff -u "$f" "/path/to/tinbela-docs-patch/$f"
done | less
```

---

## What is in each file

| File | Δ | Change |
|---|---|---|
| `AGENTS.md` | +4 | Routing rows for `prototype.html` and `SCREENS.md`; a stop-condition for prototype/ADR conflicts |
| `apps/manager/AGENTS.md` | +21 −1 | ADR carve-out table, 4-tab nav lock, no-dead-rows-in-আরও rule, no-ads-in-v1.0 rule |
| `apps/web/AGENTS.md` | +9 | Build 2 PWA tabs, not the prototype's 3 |
| `docs/design/README.md` | +40 −1 | How to read the canvas (it runs 3 → 2 → 1), scenario picker guidance, divergence list |
| `docs/design/SCREENS.md` | +70 −55 | Rewritten. Banner removed, 26 v1.0 rows (was 18), conflicts marked ⚠, reasoning appendix |
| `docs/product/UI_SPEC.md` | +21 | New §2.1 — where this spec deliberately overrides the prototype |
| `docs/product/EPICS.md` | +3 −3 | 09.1, 09.2 (was "Sign-in per prototype"), 14.1 |

---

## After merging

Two things worth doing while this is fresh:

1. **`docs/design/SCREENS.md` row 24** — pending-member phone matching — is
   marked ★ and assigned task `13.3`, but no such task exists in
   `EPICS.md` yet. Add it, or renumber. It has real edge cases (two members
   sharing one phone; a member who opens the link before being added).

2. **When you export `prototype-v2.html` after launch**, redraw the sign-in
   screen as Google and the nav bar as 4 tabs. Until then the committed
   prototype disagrees with the shipped app in two visible places, and every
   new agent will rediscover the same conflict.
