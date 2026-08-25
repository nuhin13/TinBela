// Epic 03's gate, TypeScript half: "a generated TypeScript client
// round-trips a real call against the running binary."
//
// This is the literal reading -- a real socket, the real Go process, a real
// database. wire_format.test.ts proves the same codec on every `make verify`
// without a stack; this proves the stack.
//
// It is not a *.test.ts on purpose: `pnpm test` must not fail whenever the
// developer has not booted Postgres. A gate that is usually red gets
// ignored, and an ignored gate is worse than no gate.
//
// Run: make contract-live   (which boots the stack, migrates and seeds first)
//
// Env:
//   TINBELA_API_URL  default http://localhost:8080
//   TINBELA_TOKEN    default dev:dev-8801711000001, the seeded manager

import { Code, ConnectError, createClient } from "@connectrpc/connect";
import { createConnectTransport } from "@connectrpc/connect-node";

import { CoreService, TenantKind } from "../gen/tinbela/core/v1/core_pb.ts";

const baseUrl = process.env.TINBELA_API_URL ?? "http://localhost:8080";
const token = process.env.TINBELA_TOKEN ?? "dev:dev-8801711000001";

let failures = 0;

function check(what: string, ok: boolean, detail?: string): void {
  const mark = ok ? "[32m✓[0m" : "[31m✗[0m";
  console.log(`  ${mark} ${what}${ok || detail === undefined ? "" : ` — ${detail}`}`);
  if (!ok) failures++;
}

function transport(bearer?: string) {
  return createConnectTransport({
    baseUrl,
    httpVersion: "1.1",
    useBinaryFormat: false,
    interceptors: bearer
      ? [
          (next) => (req) => {
            req.header.set("Authorization", `Bearer ${bearer}`);
            return next(req);
          },
        ]
      : [],
  });
}

console.log(`── typescript round trip against ${baseUrl} ──`);

try {
  const me = await createClient(CoreService, transport(token)).getMe({});

  check("GetMe returned a user", (me.user?.id ?? "") !== "");
  check(
    "the name survived as Bangla, not mojibake",
    (me.user?.name ?? "") !== "" && me.user?.name !== "?",
    me.user?.name,
  );
  check("the user is in at least one mess", me.messes.length > 0);
  if (me.messes.length > 0) {
    // The enum is the part most likely to break silently: proto3 JSON sends
    // it as a name, and a client expecting an ordinal lands on the zero
    // value without any error.
    check(
      "the mess kind parsed from its JSON name",
      me.messes[0]?.kind !== TenantKind.UNSPECIFIED,
      String(me.messes[0]?.kind),
    );
  }
} catch (err) {
  const e = ConnectError.from(err);
  check("GetMe", false, `${Code[e.code]}: ${e.rawMessage}`);
  if (e.code === Code.Unauthenticated) {
    console.log("    (is the stack seeded? `go run ./harness/fixtures/seed`)");
  }
}

// An unauthenticated call must be refused. Proving only the happy path would
// pass just as well against a server that authenticated nobody.
try {
  await createClient(CoreService, transport()).getMe({});
  check("a call with no token is refused", false, "it succeeded");
} catch (err) {
  const e = ConnectError.from(err);
  check(
    "a call with no token is refused",
    e.code === Code.Unauthenticated,
    Code[e.code],
  );
  check("the refusal is localised by the server", e.rawMessage.length > 0, e.rawMessage);
}

console.log("");
if (failures === 0) {
  console.log("  [32mtypescript client round-trips the running binary[0m");
} else {
  console.log(`  [31m${failures} check(s) failed[0m`);
}
process.exit(failures === 0 ? 0 : 1);
