// Epic 03's gate, TypeScript half.
//
// The response body below was captured verbatim from the running binary:
//
//   curl -s -X POST localhost:8080/tinbela.core.v1.CoreService/GetMe \
//     -H 'Content-Type: application/json' \
//     -H 'Authorization: Bearer dev:dev-8801711000001' -d '{}'
//
// A test that composes its own JSON proves only that the client agrees with
// the test author. These bytes carry the server's real choices -- proto3
// JSON lowerCamelCase, enums as names rather than ordinals, omitted default
// fields -- and each is a way a client can silently disagree with the server
// while every test still passes.
//
// The live call against a running binary is `pnpm test:live`, wired into
// `make contract-live`. This file needs no stack and runs in `make verify`.

import assert from "node:assert/strict";
import { createServer, type Server } from "node:http";
import { after, before, describe, test } from "node:test";

import { createClient } from "@connectrpc/connect";
import { createConnectTransport } from "@connectrpc/connect-node";

import { CoreService } from "../gen/tinbela/core/v1/core_pb.ts";
import { TenantKind } from "../gen/tinbela/core/v1/core_pb.ts";

/** Captured from the running binary. Do not reformat. */
const GET_ME_BODY =
  '{"user":{"id":"6d521664-8b2b-5429-b4bd-464e0b73d5a9", "name":"রফিকুল ইসলাম", ' +
  '"phoneE164":"+8801711000001", "locale":"bn", "useBanglaNumerals":true}, ' +
  '"messes":[{"id":"b5ced3ea-f30f-588e-8cc0-9e79acddd2a9", ' +
  '"name":"নীলক্ষেত ব্যাচেলর মেস", "kind":"TENANT_KIND_MESS"}]}';

/** Also captured: the shape every failure arrives in (docs/eng/errors.md). */
const PERMISSION_DENIED_BODY =
  '{"code":"permission_denied","message":"শুধু ম্যানেজার এটি করতে পারেন"}';

describe("generated TypeScript client", () => {
  let server: Server;
  let baseUrl: string;
  let next: { status: number; body: string } = { status: 200, body: "{}" };
  let lastRequest: { path: string; body: string; headers: Record<string, unknown> };

  before(async () => {
    server = createServer((req, res) => {
      let body = "";
      req.on("data", (chunk) => (body += chunk));
      req.on("end", () => {
        lastRequest = { path: req.url ?? "", body, headers: req.headers };
        res.writeHead(next.status, { "Content-Type": "application/json" });
        res.end(next.body);
      });
    });
    await new Promise<void>((resolve) => server.listen(0, "127.0.0.1", resolve));
    const address = server.address();
    if (address === null || typeof address === "string") {
      throw new Error("server did not bind to a port");
    }
    baseUrl = `http://127.0.0.1:${address.port}`;
  });

  after(async () => {
    await new Promise<void>((resolve, reject) =>
      server.close((err) => (err ? reject(err) : resolve())),
    );
  });

  const client = () =>
    createClient(
      CoreService,
      createConnectTransport({
        baseUrl,
        httpVersion: "1.1",
        // JSON, not binary: this is the codec the Go server speaks over HTTP
        // and the one the Flutter app hand-rolls against (ADR-0003).
        useBinaryFormat: false,
      }),
    );

  test("round-trips GetMe from the real wire format", async () => {
    next = { status: 200, body: GET_ME_BODY };

    const res = await client().getMe({});

    assert.equal(res.user?.id, "6d521664-8b2b-5429-b4bd-464e0b73d5a9");
    assert.equal(res.user?.name, "রফিকুল ইসলাম");
    assert.equal(res.user?.phoneE164, "+8801711000001");
    assert.equal(res.user?.locale, "bn");
    assert.equal(res.user?.useBanglaNumerals, true);

    assert.equal(res.messes.length, 1);
    assert.equal(res.messes[0]?.name, "নীলক্ষেত ব্যাচেলর মেস");
    // The enum arrives as a name. A client expecting an ordinal would land
    // on the zero value with no error at all.
    assert.equal(res.messes[0]?.kind, TenantKind.MESS);

    assert.equal(lastRequest.path, "/tinbela.core.v1.CoreService/GetMe");
  });

  test("an empty body is all-defaults, not a failure", async () => {
    // Proto3 JSON omits defaults, so an all-default response is literally
    // `{}` -- the emptiest and most common day must not read as malformed.
    next = { status: 200, body: "{}" };

    const res = await client().getMe({});

    assert.equal(res.messes.length, 0);
    assert.equal(res.user, undefined);
  });

  test("surfaces the server's localised message on a refusal", async () => {
    next = { status: 403, body: PERMISSION_DENIED_BODY };

    await assert.rejects(
      () => client().getMe({}),
      (err: Error) => {
        // Rendered as sent: bn is the source of truth and it lives on the
        // server. A client that writes its own copy grows a second
        // vocabulary that drifts from the first.
        assert.match(err.message, /শুধু ম্যানেজার এটি করতে পারেন/);
        return true;
      },
    );
  });
});
