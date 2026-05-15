export type SkillSpec = {
  path: string;
};

export type TileManifest = {
  skills: Record<string, SkillSpec>;
};

export type WorkflowManifest = {
  workflows: Record<string, SkillSpec>;
};

export type SkillMetadata = {
  name: string;
  path: string;
  category: string;
  description: string;
};

export type SkillContent = SkillMetadata & {
  content: string;
};

export type WorkflowMetadata = {
  name: string;
  path: string;
  description: string;
  keywords: string;
};

export type WorkflowContent = WorkflowMetadata & {
  content: string;
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

export function categoryFromPath(path: string): string {
  const parts = path.split("/");
  if (parts[0] === "skills" && parts[1]) return parts[1];
  if (parts[0] === "workflows") return "workflow";

  return "unknown";
}

export function extractSkillDescription(markdown: string): string {
  const match = markdown.match(/^---\n([\s\S]*?)\n---/);
  if (!match) return "";

  const lines = match[1].split("\n");
  const descriptionIndex = lines.findIndex((line) => line.startsWith("description:"));
  if (descriptionIndex === -1) return "";

  const firstLine = lines[descriptionIndex].replace(/^description:\s*/, "").trim();
  if (firstLine && firstLine !== ">") return firstLine;

  const descriptionLines: string[] = [];
  for (const line of lines.slice(descriptionIndex + 1)) {
    if (/^\w[\w-]*:/.test(line)) break;
    descriptionLines.push(line);
  }

  return descriptionLines
    .map((line) => line.trim())
    .filter(Boolean)
    .join(" ")
    .replace(/\s+/g, " ")
    .trim();
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

export async function listSkills(fetcher: Fetcher = fetch, rawBase = DEFAULT_RAW_BASE): Promise<SkillMetadata[]> {
  const manifest = await loadManifest(fetcher, rawBase);

  const skills = await Promise.all(
    Object.entries(manifest.skills)
      .sort(([left], [right]) => left.localeCompare(right))
      .map(async ([name, spec]) => {
        try {
          const response = await fetcher(buildRawUrl(rawBase, spec.path));
          if (!response.ok) {
            throw new Error(`Unable to load ${spec.path}: ${response.status}`);
          }

          return {
            name,
            path: spec.path,
            category: categoryFromPath(spec.path),
            description: extractSkillDescription(await response.text()),
          };
        } catch (error) {
          console.warn(`Skipping unavailable skill '${name}':`, error);
          return null;
        }
      }),
  );

  return skills.filter((skill): skill is SkillMetadata => skill !== null);
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

export async function loadSkill(
  skillName: string,
  fetcher: Fetcher = fetch,
  rawBase = DEFAULT_RAW_BASE,
): Promise<SkillContent | null> {
  const manifest = await loadManifest(fetcher, rawBase);
  const normalized = normalizeSkillName(skillName);
  const path = resolveSkillPath(manifest, normalized);
  if (!path) return null;

  const response = await fetcher(buildRawUrl(rawBase, path));
  if (!response.ok) {
    throw new Error(`Unable to load ${path}: ${response.status}`);
  }

  const content = await response.text();
  return {
    name: normalized,
    path,
    category: categoryFromPath(path),
    description: extractSkillDescription(content),
    content,
  };
}

function extractKeywords(markdown: string): string {
  const match = markdown.match(/^---\n([\s\S]*?)\n---/);
  if (!match) return "";

  const lines = match[1].split("\n");
  const keywordsIndex = lines.findIndex((line) => line.trimStart().startsWith("keywords:"));
  if (keywordsIndex === -1) return "";

  return lines[keywordsIndex].replace(/^\s*keywords:\s*/, "").trim();
}

export async function loadWorkflowManifest(
  fetcher: Fetcher = fetch,
  rawBase = DEFAULT_RAW_BASE,
): Promise<WorkflowManifest> {
  const response = await fetcher(buildRawUrl(rawBase, "workflows.json"));
  if (!response.ok) {
    throw new Error(`Unable to load workflows.json: ${response.status}`);
  }

  return (await response.json()) as WorkflowManifest;
}

export async function listWorkflows(
  fetcher: Fetcher = fetch,
  rawBase = DEFAULT_RAW_BASE,
): Promise<WorkflowMetadata[]> {
  const manifest = await loadWorkflowManifest(fetcher, rawBase);

  const workflows = await Promise.all(
    Object.entries(manifest.workflows)
      .sort(([left], [right]) => left.localeCompare(right))
      .map(async ([name, spec]) => {
        try {
          const response = await fetcher(buildRawUrl(rawBase, spec.path));
          if (!response.ok) {
            throw new Error(`Unable to load ${spec.path}: ${response.status}`);
          }

          const text = await response.text();
          return {
            name,
            path: spec.path,
            description: extractSkillDescription(text),
            keywords: extractKeywords(text),
          };
        } catch (error) {
          console.warn(`Skipping unavailable workflow '${name}':`, error);
          return null;
        }
      }),
  );

  return workflows.filter((w): w is WorkflowMetadata => w !== null);
}

export async function loadWorkflow(
  workflowName: string,
  fetcher: Fetcher = fetch,
  rawBase = DEFAULT_RAW_BASE,
): Promise<WorkflowContent | null> {
  const manifest = await loadWorkflowManifest(fetcher, rawBase);
  const normalized = normalizeSkillName(workflowName);
  const spec = manifest.workflows[normalized];
  if (!spec) return null;

  const response = await fetcher(buildRawUrl(rawBase, spec.path));
  if (!response.ok) {
    throw new Error(`Unable to load ${spec.path}: ${response.status}`);
  }

  const content = await response.text();
  return {
    name: normalized,
    path: spec.path,
    description: extractSkillDescription(content),
    keywords: extractKeywords(content),
    content,
  };
}
