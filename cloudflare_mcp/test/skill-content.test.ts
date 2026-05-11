import { describe, expect, it } from "vitest";
import {
  buildRawUrl,
  normalizeSkillName,
  resolveSkillPath,
  type TileManifest,
} from "../src/skill-content";

const manifest: TileManifest = {
  skills: {
    "code-review": { path: "skills/code-quality/code-review/SKILL.md" },
    build: { path: "build/SKILL.md" },
  },
};

describe("normalizeSkillName", () => {
  it("keeps a plain skill name", () => {
    expect(normalizeSkillName("code-review")).toBe("code-review");
  });

  it("extracts the skill directory from a path", () => {
    expect(normalizeSkillName("skills/code-quality/code-review")).toBe("code-review");
  });

  it("extracts the skill directory from a SKILL.md path", () => {
    expect(normalizeSkillName("skills/code-quality/code-review/SKILL.md")).toBe("code-review");
  });
});

describe("resolveSkillPath", () => {
  it("returns a manifest path for a known skill", () => {
    expect(resolveSkillPath(manifest, "code-review")).toBe("skills/code-quality/code-review/SKILL.md");
  });

  it("supports root build skill paths", () => {
    expect(resolveSkillPath(manifest, "build/SKILL.md")).toBe("build/SKILL.md");
  });

  it("returns null for unknown skills", () => {
    expect(resolveSkillPath(manifest, "missing")).toBeNull();
  });
});

describe("buildRawUrl", () => {
  it("builds a GitHub raw URL for a manifest path", () => {
    expect(buildRawUrl("https://raw.githubusercontent.com/owner/repo/main", "skills/a/SKILL.md")).toBe(
      "https://raw.githubusercontent.com/owner/repo/main/skills/a/SKILL.md",
    );
  });
});
