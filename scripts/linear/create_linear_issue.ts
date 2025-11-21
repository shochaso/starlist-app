import "dotenv/config";
import { LinearClient } from "@linear/sdk";

type CliParseResult = {
  positional: string[];
  flags: Record<string, string | undefined>;
};

const PRIORITY_MIN = 0;
const PRIORITY_MAX = 4;
const UUID_REGEX = /^[0-9a-f-]{36}$/i;

/**
 * Very small CLI parser that understands `--key value` and `--key=value`.
 */
function parseArgs(argv: string[]): CliParseResult {
  const positional: string[] = [];
  const flags: Record<string, string | undefined> = {};

  for (let i = 0; i < argv.length; i += 1) {
    const token = argv[i];
    if (!token.startsWith("--")) {
      positional.push(token);
      continue;
    }

    const [rawKey, inlineValue] = token.slice(2).split("=", 2);
    if (!rawKey) {
      continue;
    }

    const key = rawKey.trim();
    if (inlineValue !== undefined) {
      flags[key] = inlineValue;
    } else if (i + 1 < argv.length && !argv[i + 1].startsWith("--")) {
      flags[key] = argv[i + 1];
      i += 1;
    } else {
      flags[key] = "true";
    }
  }

  return { positional, flags };
}

function parsePriority(value?: string): number | undefined {
  if (!value) {
    return undefined;
  }

  const parsed = Number(value);
  if (!Number.isFinite(parsed)) {
    throw new Error(`Invalid priority value "${value}". Use an integer between ${PRIORITY_MIN} and ${PRIORITY_MAX}.`);
  }

  if (parsed < PRIORITY_MIN || parsed > PRIORITY_MAX) {
    throw new Error(`Priority must be between ${PRIORITY_MIN} and ${PRIORITY_MAX}. Received: ${parsed}`);
  }

  return parsed;
}

async function resolveTeamId(client: LinearClient, rawTeam?: string): Promise<{ id: string; label: string }> {
  if (!rawTeam) {
    throw new Error("Team identifier is required. Pass --team=<TEAM_KEY_OR_ID> or set LINEAR_TEAM_ID/LINEAR_TEAM_KEY.");
  }

  const trimmed = rawTeam.trim();
  if (!trimmed) {
    throw new Error("Team identifier cannot be blank.");
  }

  const looksLikeId = trimmed.startsWith("team_") || UUID_REGEX.test(trimmed);
  if (looksLikeId) {
    return { id: trimmed, label: trimmed };
  }

  const connection = await client.teams({
    first: 1,
    filter: { key: { eq: trimmed } },
  });

  const team = connection.nodes[0];
  if (!team) {
    throw new Error(`Team with key "${trimmed}" was not found in Linear.`);
  }

  return { id: team.id, label: `${team.key ?? trimmed} (${team.name ?? "unknown"})` };
}

async function main() {
  const apiKey = process.env.LINEAR_API_KEY;
  if (!apiKey) {
    throw new Error("Missing LINEAR_API_KEY. Add it to your environment or .env file.");
  }

  const { positional, flags } = parseArgs(process.argv.slice(2));
  const title = (flags.title ?? positional[0] ?? process.env.LINEAR_ISSUE_TITLE)?.trim();

  if (!title) {
    throw new Error("Issue title is required. Pass it as the first argument or via --title / LINEAR_ISSUE_TITLE.");
  }

  const description =
    flags.description ??
    positional[1] ??
    process.env.LINEAR_ISSUE_DESCRIPTION ??
    "Cursor から Linear API 経由で作成したテスト issue です。";

  const priority = parsePriority(flags.priority ?? process.env.LINEAR_ISSUE_PRIORITY);
  const teamInput = flags.team ?? process.env.LINEAR_TEAM_ID ?? process.env.LINEAR_TEAM_KEY ?? process.env.LINEAR_TEAM;

  const client = new LinearClient({ apiKey });
  const team = await resolveTeamId(client, teamInput);

  const payload = await client.createIssue({
    teamId: team.id,
    title,
    description,
    ...(priority !== undefined ? { priority } : {}),
  });

  if (!payload.success) {
    throw new Error("Linear API responded with success=false.");
  }

  const issueId = payload.issueId ?? (await payload.issue)?.id;
  if (!issueId) {
    throw new Error("Issue was created but the API did not return an ID.");
  }

  const issue = await client.issue(issueId);

  const identifier = issue.identifier ?? issueId;
  const issueUrl = issue.url ?? "(no url)";
  const logPayload = {
    id: issue.id,
    identifier,
    title: issue.title,
    priority: issue.priority,
    url: issue.url,
    team: team.label,
  };

  console.log("Linear OK", identifier, issueUrl);
  console.log(JSON.stringify(logPayload, null, 2));
}

main().catch((error) => {
  console.error("❌ Failed to create Linear issue.");
  if (error instanceof Error) {
    console.error(error.message);
  } else {
    console.error(error);
  }
  process.exitCode = 1;
});
