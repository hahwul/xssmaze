// Regenerates solutions/baseline.txt: which GET mazes one textbook payload
// already beats, proven by a real alert() in headless Chrome rather than read
// off the served HTML.
//
//   ./bin/xssmaze -p 3000 &
//   node scripts/baseline.mjs http://127.0.0.1:3000 solutions/baseline.txt
//
// A maze is *measured* when it is an exploitable GET maze delivered by query,
// path or fragment, the channels a URL can carry. Each measured maze is loaded
// once per injection point, with no clicks, hovers or focus, and with every
// other param left at its catalog sample value (so a `token=valid` gate stays
// open):
//   - each query param in turn (or a bare `?<payload>` when it names none)
//   - the `:path` segment, or an appended segment for path-delivered mazes
//   - the fragment, for fragment-delivered mazes
// It is `true` when any of those loads opens a JS dialog. Mazes that are not
// measured (POST/QUERY, header/cookie/referer/postMessage/...) are left out,
// so /map/json reports them as `baseline: null`.
//
// The output file is written only after a complete, self-checked sweep.
// Needs Node >= 22 (global WebSocket) and Google Chrome; set CHROME to override.
import { spawn } from "node:child_process";
import { mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

const BASELINE_PAYLOAD = "<svg onload=alert(1)>";
const URL_CHANNELS = ["query", "path", "fragment"];
const base = (process.argv[2] || "http://127.0.0.1:3000").replace(/\/$/, "");
const outFile = process.argv[3];
if (!outFile) {
  console.error("usage: node scripts/baseline.mjs <lab-url> <output-file>");
  process.exit(2);
}
const chromePath = process.env.CHROME ||
  (process.platform === "darwin"
    ? "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
    : "google-chrome");
const PORT = 9300 + Math.floor(Math.random() * 500);
const WORKERS = 8;
const SETTLE_MS = 2000;
const CALL_TIMEOUT_MS = 5000;

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));
// Percent-encode only what a URL cannot carry raw, as a browser address bar
// does: URLSearchParams' `+` for space, or encodeURIComponent's `%3D`, both
// survive decodeURI() and leave mazes that use it a mangled tag.
const enc = (s) => s.replace(/[\s"#%&+<>?`]/g, (c) => "%" + c.charCodeAt(0).toString(16).toUpperCase().padStart(2, "0"));
const profile = mkdtempSync(join(tmpdir(), "xssmaze-baseline-"));
const chrome = spawn(chromePath, [
  "--headless=new", "--disable-gpu", "--no-first-run",
  `--remote-debugging-port=${PORT}`, `--user-data-dir=${profile}`, "about:blank",
], { stdio: "ignore" });
// Wait for Chrome to exit before removing its profile: it keeps writing to it
// while shutting down, and an early rm fails with ENOTEMPTY.
const exited = new Promise((r) => chrome.once("exit", r));
chrome.once("error", () => {});

let ws;
const pending = new Map();
const listeners = new Map();
let seq = 0;
// Every call is bounded: a page stuck on a dialog or a hung navigation must
// not stall the whole sweep.
const send = (method, params = {}, sessionId) => new Promise((resolve, reject) => {
  const id = ++seq;
  const timer = setTimeout(() => { pending.delete(id); reject(new Error(`${method} timed out`)); }, CALL_TIMEOUT_MS);
  pending.set(id, (m) => { clearTimeout(timer); m.error ? reject(new Error(m.error.message)) : resolve(m.result); });
  ws.send(JSON.stringify({ id, method, params, sessionId }));
});

async function opensDialog(url) {
  const { targetId } = await send("Target.createTarget", { url: "about:blank" });
  let fired = false;
  try {
    const { sessionId } = await send("Target.attachToTarget", { targetId, flatten: true });
    listeners.set(sessionId, (m) => {
      if (m.method !== "Page.javascriptDialogOpening") return;
      fired = true;
      send("Page.handleJavaScriptDialog", { accept: true }, sessionId).catch(() => {});
    });
    await send("Page.enable", {}, sessionId);
    await send("Page.navigate", { url }, sessionId);
    await sleep(SETTLE_MS);
    listeners.delete(sessionId);
  } finally {
    await send("Target.closeTarget", { targetId }).catch(() => {});
  }
  return fired;
}

// One URL per injection point, other params kept at their sample values.
function probeUrls(maze) {
  const [beforeHash] = maze.url.split("#"); // a sample fragment can be a live exploit
  const [path, query = ""] = beforeHash.split("?");
  const sample = query ? query.split("&").map((kv) => kv.split("=")) : [];
  const plain = maze.params.filter((p) => !/^[:#]/.test(p));
  const delivery = maze.vuln.delivery;
  const qs = (pairs) => (pairs.length ? "?" + pairs.map(([k, v = ""]) => `${k}=${v}`).join("&") : "");
  const urls = [];
  if (delivery.includes("query")) {
    if (plain.length === 0) urls.push(path + "?" + enc(BASELINE_PAYLOAD));
    for (const p of plain) {
      const pairs = sample.filter(([k]) => decodeURIComponent(k) !== p);
      urls.push(path + qs([...pairs, [enc(p), enc(BASELINE_PAYLOAD)]]));
    }
  }
  if (maze.params.some((p) => p.startsWith(":"))) {
    urls.push(path.replace(/[^/]*$/, enc(BASELINE_PAYLOAD)) + qs(sample));
  } else if (delivery.includes("path")) {
    urls.push(path.replace(/\/?$/, "/") + enc(BASELINE_PAYLOAD) + qs(sample));
  }
  if (delivery.includes("fragment")) urls.push(path + qs(sample) + "#" + enc(BASELINE_PAYLOAD));
  return urls.map((u) => base + u);
}

async function fires(maze) {
  for (const url of probeUrls(maze)) if (await opensDialog(url)) return true;
  return false;
}

async function main() {
  let version;
  for (let i = 0; i < 100 && !version; i++) {
    try { version = await (await fetch(`http://127.0.0.1:${PORT}/json/version`)).json(); }
    catch { await sleep(100); }
  }
  if (!version) throw new Error(`Chrome did not start (${chromePath})`);
  ws = new WebSocket(version.webSocketDebuggerUrl);
  await new Promise((resolve, reject) => {
    ws.addEventListener("open", resolve);
    ws.addEventListener("error", () => reject(new Error("CDP WebSocket failed")));
  });
  ws.addEventListener("message", (e) => {
    const m = JSON.parse(e.data);
    if (m.id && pending.has(m.id)) { pending.get(m.id)(m); pending.delete(m.id); }
    else if (m.sessionId && listeners.has(m.sessionId)) listeners.get(m.sessionId)(m);
  });

  const map = await (await fetch(`${base}/map/json`)).json();
  const { version: labVersion } = await (await fetch(`${base}/version`)).json();
  const mazes = map.endpoints.filter((m) => m.method === "GET" && m.vuln.exploitable &&
    m.vuln.delivery.some((d) => URL_CHANNELS.includes(d)));
  const byName = Object.fromEntries(mazes.map((m) => [m.name, m]));

  // Harness self-check: a "did not fire" only means something once the same
  // harness has been seen to fire on a raw reflection and not on a filtered one.
  if (!(await fires(byName["basic-level1"])) || (await fires(byName["basic-level5"]))) {
    throw new Error("harness self-check failed: basic-level1 must fire, basic-level5 must not");
  }

  const result = {};
  const attempt = async (maze) => {
    try { result[maze.name] = await fires(maze); } catch { /* retried below */ }
  };
  let next = 0;
  await Promise.all(Array.from({ length: WORKERS }, async () => {
    while (next < mazes.length) await attempt(mazes[next++]);
  }));
  // A probe can time out while tabs contend for Chrome; retry those alone.
  for (const maze of mazes) if (!(maze.name in result)) await attempt(maze);
  const failed = mazes.filter((m) => !(m.name in result)).map((m) => m.name);
  if (failed.length) throw new Error(`could not probe ${failed.length} mazes: ${failed.join(", ")}`);

  const names = Object.keys(result).sort();
  const hits = names.filter((n) => result[n]).length;
  writeFileSync(outFile, [
    `# Generated by scripts/baseline.mjs against XSSMaze ${labVersion}. Do not edit by hand.`,
    `# <maze> true|false: does ${BASELINE_PAYLOAD} run alert() in headless Chrome with no`,
    "# interaction? Mazes not listed were not measured (baseline: null).",
    `# ${hits} of ${names.length} measured mazes are baseline.`,
    ...names.map((n) => `${n} ${result[n]}`),
    "",
  ].join("\n"));
  console.error(`${hits}/${names.length} measured mazes fired; wrote ${outFile}`);
}

let failure = null;
try { await main(); } catch (e) { failure = e; }
finally {
  ws?.close();
  chrome.kill();
  await exited;
  rmSync(profile, { recursive: true, force: true, maxRetries: 5 });
}
if (failure) { console.error(String(failure.message || failure)); process.exit(1); }
process.exit(0);
