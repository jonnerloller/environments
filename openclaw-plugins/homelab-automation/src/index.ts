import { execFile } from "node:child_process";
import { promisify } from "node:util";
import { Type } from "typebox";
import { defineToolPlugin } from "openclaw/plugin-sdk/tool-plugin";

const run = promisify(execFile);

/**
 * Default location of the canonical automation scripts. Machine-specific, but
 * overridable via plugin config (`scriptsDir`) to honor path discipline.
 */
const DEFAULT_SCRIPTS_DIR =
  "/home/phitrine/repo/environments/scripts/automation";

const configSchema = Type.Object({
  scriptsDir: Type.Optional(
    Type.String({
      description:
        "Directory holding the automation scripts (add_flight.sh, etc.).",
    }),
  ),
});

/**
 * Every tool receives the same shape. `command` is the raw CLI argument string:
 * - when dispatched from a slash command (command-dispatch: tool,
 *   command-arg-mode: raw) OpenClaw passes { command, commandName, skillName };
 * - when the model calls the tool (inferred English), it fills `command` with
 *   the CLI args formatted per the tool description.
 * commandName/skillName are accepted so raw-dispatch payloads validate; routing
 * is fixed per-tool, so they are not used for dispatch.
 */
const commandParams = Type.Object({
  command: Type.String({
    description: "Raw CLI arguments to pass to the script, space-separated.",
  }),
  commandName: Type.Optional(Type.String()),
  skillName: Type.Optional(Type.String()),
});

/**
 * Tokenize a raw argument string into argv, honoring single and double quotes
 * so multi-word fields survive. Nothing is passed through a shell — argv is
 * handed to execFile directly — so there is no shell-injection surface.
 */
function tokenize(input: string): string[] {
  const tokens: string[] = [];
  let cur = "";
  let quote: '"' | "'" | null = null;
  let has = false;
  for (let i = 0; i < input.length; i++) {
    const ch = input[i];
    if (quote) {
      if (ch === quote) quote = null;
      else cur += ch;
      continue;
    }
    if (ch === '"' || ch === "'") {
      quote = ch;
      has = true;
      continue;
    }
    if (ch === " " || ch === "\t" || ch === "\n") {
      if (has) {
        tokens.push(cur);
        cur = "";
        has = false;
      }
      continue;
    }
    cur += ch;
    has = true;
  }
  if (has) tokens.push(cur);
  return tokens;
}

async function runScript(
  scriptsDir: string,
  script: string,
  command: string,
  prefixArgs: string[] = [],
): Promise<string> {
  const argv = [...prefixArgs, ...tokenize(command ?? "")];
  const path = `${scriptsDir}/${script}`;
  try {
    const { stdout, stderr } = await run(path, argv, {
      timeout: 30_000,
      maxBuffer: 1024 * 1024,
    });
    const out = `${stdout ?? ""}${stderr ?? ""}`.trim();
    return out.length > 0 ? out : `ok: ${script} completed`;
  } catch (err: unknown) {
    const e = err as { stdout?: string; stderr?: string; message?: string };
    const detail = `${e.stderr ?? ""}${e.stdout ?? ""}`.trim() || e.message || String(err);
    return `error running ${script}: ${detail}`;
  }
}

type ToolSpec = {
  name: string;
  script: string;
  description: string;
  /** Fixed leading argv prepended before the parsed command (e.g. a kind). */
  prefixArgs?: string[];
};

/**
 * One tool per automation. The description mirrors the script's own --help so
 * the model can format inferred English into the correct CLI (Path B), while
 * slash commands dispatch here deterministically (Path A).
 */
const SPECS: ToolSpec[] = [
  {
    name: "flight_add",
    script: "add_flight.sh",
    description:
      "Add a flight to the AirTrail flight tracker. CLI: [--dry-run] [YYYY-MM-DD] FLIGHT FROM TO [AIRLINE]. Date defaults to today (UTC) if omitted. Example command: '2026-03-26 AS1415 SEA BUR' or 'AS1415 SEA BUR'.",
  },
  {
    name: "word_add",
    script: "add_word.sh",
    description:
      "Archive a Japanese word in the Word Lookup Archive (dedupes by word). CLI: <word> [reading] [meaning] [nuance] [example_jp] [example_en]. Quote multi-word fields. Example: '出汁 だし \"soup stock\"'.",
  },
  {
    name: "translate_add",
    script: "add_japanese_lookup.sh",
    prefixArgs: ["translate"],
    description:
      "Archive a Japanese translation lookup in the study archive (kind is fixed to 'translate'). CLI (after the fixed kind): <query> [reading] [meaning] [concept_tags] [details]. Quote multi-word fields.",
  },
  {
    name: "lookup_add",
    script: "add_japanese_lookup.sh",
    description:
      "Archive any Japanese study lookup. CLI: <word|translate|grammar|phrase> <query> [reading] [meaning] [concept_tags] [details]. Use for grammar/phrase lookups; for plain translations prefer translate_add.",
  },
  {
    name: "torrent_add",
    script: "add_torrent.sh",
    description:
      "Add a torrent to Transmission. CLI: [--dry-run] <magnet-or-torrent-url>. Pass the magnet/URL as a single argument.",
  },
  {
    name: "journal_add",
    script: "journal.py",
    description:
      "Append a line to today's Obsidian daily journal (Pacific date). CLI: [--section SECTION] <text...>. All trailing words become the journal line.",
  },
];

export default defineToolPlugin({
  id: "homelab-automation",
  name: "Homelab Automation",
  description:
    "Deterministic homelab command routing: slash commands and inferred requests dispatch to well-documented automation scripts (flights, Japanese words/lookups, torrents, journal).",
  configSchema,
  tools: (tool) =>
    SPECS.map((spec) =>
      tool({
        name: spec.name,
        label: spec.name,
        description: spec.description,
        parameters: commandParams,
        async execute({ command }, config) {
          const scriptsDir = config.scriptsDir ?? DEFAULT_SCRIPTS_DIR;
          return runScript(scriptsDir, spec.script, command, spec.prefixArgs);
        },
      }),
    ),
});
