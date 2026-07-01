import { describe, expect, it } from "vitest";
import entry from "./index.js";
import { getToolPluginMetadata } from "openclaw/plugin-sdk/tool-plugin";

describe("homelab-automation", () => {
  it("declares tool metadata", () => {
    expect(getToolPluginMetadata(entry)?.tools.map((tool) => tool.name)).toEqual([
      "flight_add",
      "word_add",
      "translate_add",
      "lookup_add",
      "torrent_add",
      "journal_add",
    ]);
  });
});
