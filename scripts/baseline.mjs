// Regenerates solutions/baseline.txt: the GET mazes that one textbook payload
// already beats, proven by a real alert() in headless Chrome rather than read
// off the served HTML.
//
//   ./bin/xssmaze -p 3000 &
//   node scripts/baseline.mjs http://127.0.0.1:3000 > solutions/baseline.txt
//
// Every exploitable GET maze is loaded with BASELINE_PAYLOAD in each of its
// params (query, `:path` segment, and the fragment for fragment-delivered
// mazes), with no clicks, hovers or focus. A maze is "baseline" when the
// payload opens a JS dialog. POST/QUERY mazes are not probed and never listed.
// Needs Node >= 22 (global WebSocket) and Google Chrome; set CHROME to override.
import { spawn } from "node:child_process";
import { mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

const BASELINE_PAYLOAD = "<svg onload=alert(1)>";
const base = (process.argv[2] || "http://127.0.0.1:3000").replace(/\/$/, "");
const chromePath = process.env.CHROME ||
  (process.platform === "darwin"
    ? "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
    : "google-chrome");
const PORT = 9300 + Math.floor(Math.random() * 500);
const WORKERS = 8;
const SETTLE_MS = 1500;
const CALL_TIMEOUT_MS = 5000;

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));
const profile = mkdtempSync(join(tmpdir(), "xssmaze-baseline-"));
const chrome = spawn(chromePath, [
  "--headless=new", "--disable-gpu", "--no-first-run",
  `--remote-debugging-port=${PORT}`, `--user-data-dir=${profile}`, "about:blank",
], { stdio: "ignore" });
// Wait for Chrome to exit before removing its profile: it keeps writing to it
// while shutting down, and an early rm fails with ENOTEMPTY.
const exited = new Promise((r) => chrome.once("exit", r));
const cleanup = async () => {
  chrome.kill();
  await exited;
  rmSync(profile, { recursive: true, force: true, maxRetries: 5 });
};

let version;
for (let i = 0; i < 100 && !version; i++) {
  try { version = await (await fetch(`http://127.0.0.1:${PORT}/json/version`)).json(); }
  catch { await sleep(100); }
}
if (!version) { await cleanup(); throw new Error(`Chrome did not start (${chromePath})`); }

const ws = new WebSocket(version.webSocketDebuggerUrl);
await new Promise((r) => ws.addEventListener("open", r));
let seq = 0;
const pending = new Map();
const listeners = new Map();
ws.addEventListener("message", (e) => {
  const m = JSON.parse(e.data);
  if (m.id && pending.has(m.id)) { pending.get(m.id)(m); pending.delete(m.id); }
  else if (m.sessionId && listeners.has(m.sessionId)) listeners.get(m.sessionId)(m);
});
// Every call is bounded: a page stuck on a dialog or a hung navigation must
// not stall the whole sweep (an unbounded first version hung on the 2nd run).
const send = (method, params = {}, sessionId) => new Promise((resolve, reject) => {
  const id = ++seq;
  const timer = setTimeout(() => { pending.delete(id); reject(new Error(`${method} timed out`)); }, CALL_TIMEOUT_MS);
  pending.set(id, (m) => { clearTimeout(timer); m.error ? reject(new Error(m.error.message)) : resolve(m.result); });
  ws.send(JSON.stringify({ id, method, params, sessionId }));
});

async function fires(maze) {
  // Drop the catalog's sample query and fragment: modern-bypass-level4's
  // sample fragment *is* a working exploit and would fire on its own.
  const url = new URL(base + maze.url.split(/[?#]/)[0]);
  for (const p of maze.params) {
    if (p.startsWith(":")) url.pathname = url.pathname.replace(/[^/]*$/, encodeURIComponent(BASELINE_PAYLOAD));
    else url.searchParams.set(p, BASELINE_PAYLOAD);
  }
  if (maze.vuln.delivery.includes("fragment")) url.hash = BASELINE_PAYLOAD;
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
    await send("Page.navigate", { url: url.toString() }, sessionId);
    await sleep(SETTLE_MS);
    listeners.delete(sessionId);
  } finally {
    await send("Target.closeTarget", { targetId }).catch(() => {});
  }
  return fired;
}

const map = await (await fetch(`${base}/map/json`)).json();
const { version: labVersion } = await (await fetch(`${base}/version`)).json();
const mazes = map.endpoints.filter((m) => m.method === "GET" && m.vuln.exploitable);

// Harness self-check: a "did not fire" only means something once the same
// harness has been seen to fire on a raw reflection and not on a filtered one.
const byName = Object.fromEntries(mazes.map((m) => [m.name, m]));
if (!(await fires(byName["basic-level1"])) || (await fires(byName["basic-level5"]))) {
  await cleanup();
  throw new Error("harness self-check failed: basic-level1 must fire, basic-level5 must not");
}

const hits = [];
const failed = [];
let next = 0;
await Promise.all(Array.from({ length: WORKERS }, async () => {
  while (next < mazes.length) {
    const maze = mazes[next++];
    let result = null;
    for (let attempt = 0; attempt < 2 && result === null; attempt++) {
      try { result = await fires(maze); } catch { result = null; }
    }
    if (result === null) failed.push(maze.name);
    else if (result) hits.push(maze.name);
  }
}));
// A probe can time out while 8 tabs contend for Chrome; give those one more
// try each, alone, before calling the sweep incomplete.
for (const name of failed.splice(0)) {
  let result = null;
  try { result = await fires(byName[name]); } catch { result = null; }
  if (result === null) failed.push(name);
  else if (result) hits.push(name);
}
await cleanup();

if (failed.length) {
  console.error(`could not probe ${failed.length} mazes: ${failed.join(", ")}`);
  process.exit(1);
}
hits.sort();
console.log(`# Generated by scripts/baseline.mjs against XSSMaze ${labVersion}`);
console.log(`# GET mazes where ${BASELINE_PAYLOAD} in every param runs alert() in headless`);
console.log("# Chrome with no interaction. Regenerate after adding or changing mazes.");
console.log(`# ${hits.length} of ${mazes.length} exploitable GET mazes.`);
for (const name of hits) console.log(name);
console.error(`${hits.length}/${mazes.length} fired`);
process.exit(0);
