#!/usr/bin/env node

import { writeFile } from "node:fs/promises";

const policy = "human-voice";
const version = "1.0.0";
const output = "AI_POLICY.md";

const source = `https://raw.githubusercontent.com/43081j/ai-policy/main/policies/versions/${policy}/${version}.md`;

const response = await fetch(source);

if (!response.ok) {
  throw new Error(`Failed to fetch policy: HTTP ${response.status}`);
}

const markdown = await response.text();

const frontmatter = /^---\r?\n[\s\S]*?\r?\n---(?:\r?\n|$)/;

if (!frontmatter.test(markdown)) {
  throw new Error("Expected YAML frontmatter was not found");
}

const content = markdown.replace(frontmatter, "").trim();

const attribution = `<!--
Synced from: ${source}
Policy: ${policy} v${version}
Website: https://ai-policy.dev/
-->

`;

await writeFile(output, attribution + content + "\n", "utf8");

console.log(`Updated ${output} (${policy} v${version})`);
