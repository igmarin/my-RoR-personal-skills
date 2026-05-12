import { describe, expect, it } from "vitest";
import {
  buildRawUrl,
  categoryFromPath,
  extractSkillDescription,
  listSkills,
  loadSkill,
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

describe("categoryFromPath", () => {
  it("returns build for the root build skill", () => {
    expect(categoryFromPath("build/SKILL.md")).toBe("build");
  });

  it("returns the nested skill category", () => {
    expect(categoryFromPath("skills/code-quality/code-review/SKILL.md")).toBe("code-quality");
  });
});

describe("extractSkillDescription", () => {
  it("extracts folded frontmatter descriptions", () => {
    expect(
      extractSkillDescription(`---\nname: code-review\ndescription: >\n  Reviews Rails code for bugs,\n  regressions, and missing tests.\nmetadata:\n  version: 1.0.0\n---\n# Code Review\n`),
    ).toBe("Reviews Rails code for bugs, regressions, and missing tests.");
  });
});

describe("skill loading", () => {
  const skillBody = `---\nname: code-review\ndescription: >\n  Reviews Rails code for bugs and missing tests.\n---\n# Code Review\n`;

  function fetcher(url: string) {
    if (url.endsWith("/tile.json")) {
      return Promise.resolve(new Response(JSON.stringify(manifest)));
    }

    if (url.endsWith("/skills/code-quality/code-review/SKILL.md")) {
      return Promise.resolve(new Response(skillBody));
    }

    if (url.endsWith("/build/SKILL.md")) {
      return Promise.resolve(new Response("---\nname: build\ndescription: Build the tile.\n---\n# Build\n"));
    }

    return Promise.resolve(new Response("not found", { status: 404 }));
  }

  it("lists structured skill metadata", async () => {
    await expect(listSkills(fetcher as typeof fetch, "https://example.test")).resolves.toEqual([
      {
        name: "build",
        path: "build/SKILL.md",
        category: "build",
        description: "Build the tile.",
      },
      {
        name: "code-review",
        path: "skills/code-quality/code-review/SKILL.md",
        category: "code-quality",
        description: "Reviews Rails code for bugs and missing tests.",
      },
    ]);
  });

  it("skips unavailable skills while preserving successful skill order", async () => {
    function partialFetcher(url: string) {
      if (url.endsWith("/tile.json")) {
        return Promise.resolve(new Response(JSON.stringify(manifest)));
      }

      if (url.endsWith("/build/SKILL.md")) {
        return Promise.resolve(new Response("---\nname: build\ndescription: Build the tile.\n---\n# Build\n"));
      }

      return Promise.resolve(new Response("not found", { status: 404 }));
    }

    await expect(listSkills(partialFetcher as typeof fetch, "https://example.test")).resolves.toEqual([
      {
        name: "build",
        path: "build/SKILL.md",
        category: "build",
        description: "Build the tile.",
      },
    ]);
  });

  it("loads structured skill content", async () => {
    await expect(loadSkill("code-review", fetcher as typeof fetch, "https://example.test")).resolves.toMatchObject({
      name: "code-review",
      path: "skills/code-quality/code-review/SKILL.md",
      category: "code-quality",
      description: "Reviews Rails code for bugs and missing tests.",
      content: skillBody,
    });
  });
});
