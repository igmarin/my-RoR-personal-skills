export type SkillSpec = {
  path: string;
};

export type TileManifest = {
  skills: Record<string, SkillSpec>;
};

export const DEFAULT_RAW_BASE = "https://raw.githubusercontent.com/igmarin/rails-agent-skills/main";

type Fetcher = typeof fetch;

export function normalizeSkillName(input: string): string {
  const parts = input
    .trim()
    .replace(/\/+$/, "")
    .split("/")
    .filter(Boolean);

  if (parts.at(-1) === "SKILL.md") {
    return parts.at(-2) ?? "";
  }

  return parts.at(-1) ?? "";
}

export function resolveSkillPath(manifest: TileManifest, skillName: string): string | null {
  const normalized = normalizeSkillName(skillName);
  return manifest.skills[normalized]?.path ?? null;
}

export function buildRawUrl(rawBase: string, path: string): string {
  return `${rawBase.replace(/\/+$/, "")}/${path.replace(/^\/+/, "")}`;
}

export async function loadManifest(fetcher: Fetcher = fetch, rawBase = DEFAULT_RAW_BASE): Promise<TileManifest> {
  const response = await fetcher(buildRawUrl(rawBase, "tile.json"));
  if (!response.ok) {
    throw new Error(`Unable to load tile.json: ${response.status}`);
  }

  return (await response.json()) as TileManifest;
}

export async function listSkillNames(fetcher: Fetcher = fetch, rawBase = DEFAULT_RAW_BASE): Promise<string[]> {
  const manifest = await loadManifest(fetcher, rawBase);
  return Object.keys(manifest.skills).sort();
}

export async function loadSkillContent(
  skillName: string,
  fetcher: Fetcher = fetch,
  rawBase = DEFAULT_RAW_BASE,
): Promise<string | null> {
  const manifest = await loadManifest(fetcher, rawBase);
  const path = resolveSkillPath(manifest, skillName);
  if (!path) return null;

  const response = await fetcher(buildRawUrl(rawBase, path));
  if (!response.ok) {
    throw new Error(`Unable to load ${path}: ${response.status}`);
  }

  return response.text();
}
