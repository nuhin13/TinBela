// "Invalid or revoked token gets a friendly screen, never a stack trace"
// (apps/web/AGENTS.md).
//
// The reader is a mess member who tapped a link in Messenger, not an
// engineer. It says what to do next -- ask the manager -- because that is
// the only action that actually resolves it. There is deliberately no retry
// button: retrying a dead link does nothing, and UX law 8's "no error
// without a retry" means an error the user CAN retry.
export function InvalidLink() {
  return (
    <main className="mx-auto flex min-h-screen w-full max-w-md flex-col items-center justify-center gap-lg px-lg text-center">
      <h1 className="text-2xl font-semibold">লিংকটি কাজ করছে না</h1>
      <p className="text-inkMuted">
        লিংকটি হয়তো পুরোনো, নয়তো বাতিল করা হয়েছে।
        <br />
        আপনার মেস ম্যানেজারকে নতুন লিংক পাঠাতে বলুন।
      </p>
    </main>
  );
}
