// A visible marker for content this scaffold deliberately did not write.
//
// It renders on screen rather than hiding in a comment so that nobody ships
// a Play-required legal page still holding an agent's guess at its wording.
// Delete the component's usage as each task lands; when the last one goes,
// delete the file.
//
// It is intentionally not localised: it is developer scaffolding, never
// product copy, and it must not survive into a release build unnoticed.
export function PlaceholderNotice({
  task,
  owner,
  what,
}: {
  task: string;
  owner: 'founder' | 'web';
  what: string;
}) {
  return (
    <aside
      lang="en"
      className="rounded-card border border-divider bg-tint p-lg text-sm text-ink"
    >
      <p className="font-semibold">
        Not written yet — task {task}
        {owner === 'founder' ? ' ★ (founder-owned)' : ''}
      </p>
      <p className="mt-sm text-inkMuted">{what}</p>
    </aside>
  );
}
