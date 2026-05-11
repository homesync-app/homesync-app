#!/usr/bin/env node
import { existsSync, readFileSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { createClient } from '@supabase/supabase-js';

const __dirname = dirname(fileURLToPath(import.meta.url));
const rootDir = resolve(__dirname, '..');

function loadEnvFile(filePath) {
  if (!existsSync(filePath)) return;
  const content = readFileSync(filePath, 'utf8');
  for (const line of content.split(/\r?\n/)) {
    const trimmed = line.trim();
    if (!trimmed || trimmed.startsWith('#')) continue;
    const match = trimmed.match(/^([^=]+)=(.*)$/);
    if (!match) continue;
    const key = match[1].trim();
    let value = match[2].trim();
    if (
      (value.startsWith('"') && value.endsWith('"')) ||
      (value.startsWith("'") && value.endsWith("'"))
    ) {
      value = value.slice(1, -1);
    }
    if (!process.env[key]) process.env[key] = value;
  }
}

loadEnvFile(resolve(rootDir, '.env'));
loadEnvFile(resolve(rootDir, '.env.local'));

const args = process.argv.slice(2);
const options = {
  days: 7,
  limit: 10,
  fetchLimit: 800,
  levels: ['critical', 'error', 'warning'],
  json: false,
  sync: false,
};

for (let i = 0; i < args.length; i += 1) {
  const arg = args[i];
  const next = args[i + 1];
  if (arg === '--days' && next) {
    options.days = Number(next);
    i += 1;
  } else if (arg === '--limit' && next) {
    options.limit = Number(next);
    i += 1;
  } else if (arg === '--fetch-limit' && next) {
    options.fetchLimit = Number(next);
    i += 1;
  } else if (arg === '--levels' && next) {
    options.levels = next.split(',').map((level) => level.trim()).filter(Boolean);
    i += 1;
  } else if (arg === '--json') {
    options.json = true;
  } else if (arg === '--sync') {
    options.sync = true;
  } else if (arg === '--help' || arg === '-h') {
    printHelp();
    process.exit(0);
  }
}

function printHelp() {
  console.log(`Usage: npm run triage:errors -- [options]

Options:
  --days <n>          Lookback window in days. Default: 7
  --limit <n>         Number of grouped issues to print. Default: 10
  --fetch-limit <n>   Raw log rows to inspect before grouping. Default: 800
  --levels <csv>      Levels to include. Default: critical,error,warning
  --json              Print machine-readable JSON
  --sync              Upsert grouped issues into public.error_issues

Auth:
  Uses VITE_SUPABASE_URL + VITE_SUPABASE_ANON_KEY from .env.local.
  If RLS requires a user session, set HOMESYNC_ADMIN_EMAIL and HOMESYNC_ADMIN_PASSWORD.
  For server-only ops, SUPABASE_SERVICE_ROLE_KEY also works. Never commit that key.
`);
}

const supabaseUrl = process.env.SUPABASE_URL || process.env.VITE_SUPABASE_URL;
const supabaseKey =
  process.env.SUPABASE_SERVICE_ROLE_KEY ||
  process.env.SUPABASE_ANON_KEY ||
  process.env.VITE_SUPABASE_ANON_KEY;

if (!supabaseUrl || !supabaseKey) {
  console.error('Missing Supabase env vars. Configure VITE_SUPABASE_URL and VITE_SUPABASE_ANON_KEY.');
  process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseKey, {
  auth: {
    persistSession: false,
    autoRefreshToken: false,
  },
});

let authMode = process.env.SUPABASE_SERVICE_ROLE_KEY ? 'service_role' : 'anonymous';
if (!process.env.SUPABASE_SERVICE_ROLE_KEY) {
  const email = process.env.HOMESYNC_ADMIN_EMAIL || process.env.ADMIN_EMAIL;
  const password = process.env.HOMESYNC_ADMIN_PASSWORD || process.env.ADMIN_PASSWORD;
  if (email && password) {
    const { error } = await supabase.auth.signInWithPassword({ email, password });
    if (error) {
      console.error(`Admin login failed: ${error.message}`);
      process.exit(1);
    }
    authMode = 'admin_session';
  }
}

const since = new Date(Date.now() - options.days * 24 * 60 * 60 * 1000).toISOString();
const { data, error } = await supabase
  .from('application_logs')
  .select('id,created_at,level,message,stack_trace,context,device_info,user_id')
  .in('level', options.levels)
  .gte('created_at', since)
  .order('created_at', { ascending: false })
  .limit(options.fetchLimit);

if (error) {
  console.error(`Could not read application_logs: ${error.message}`);
  console.error('Tip: set HOMESYNC_ADMIN_EMAIL/HOMESYNC_ADMIN_PASSWORD or SUPABASE_SERVICE_ROLE_KEY.');
  process.exit(1);
}

const groups = groupLogs(data || [])
  .sort((a, b) => severityRank(a.level) - severityRank(b.level) || b.count - a.count || b.lastSeen.localeCompare(a.lastSeen))
  .slice(0, options.limit);

if (options.sync && groups.length > 0) {
  await syncIssues(groups);
}

if (options.json) {
  console.log(JSON.stringify({ since, authMode, synced: options.sync, rawCount: data?.length || 0, groups }, null, 2));
} else {
  printMarkdown({ since, authMode, synced: options.sync, rawCount: data?.length || 0, groups });
}

function groupLogs(logs) {
  const grouped = new Map();
  for (const log of logs) {
    const message = String(log.message || 'No message');
    const key = `${log.level || 'unknown'}:${fingerprint(message, log.stack_trace)}`;
    const appFrame = firstAppFrame(log.stack_trace);
    if (!grouped.has(key)) {
      grouped.set(key, {
        level: log.level || 'unknown',
        message,
        fingerprint: key,
        count: 0,
        affectedUsers: new Set(),
        firstSeen: log.created_at,
        lastSeen: log.created_at,
        appFrame,
        screens: new Set(),
        environments: new Set(),
        firstSeenBuild: readContextString(log.context, 'build_number'),
        lastSeenBuild: readContextString(log.context, 'build_number'),
        sample: sanitizeLog(log),
      });
    }
    const group = grouped.get(key);
    group.count += 1;
    if (log.user_id) group.affectedUsers.add(log.user_id);
    const screen = readContextString(log.context, 'current_screen');
    const environment = readContextString(log.context, 'environment');
    if (screen) group.screens.add(screen);
    if (environment) group.environments.add(environment);
    if (log.created_at < group.firstSeen) group.firstSeen = log.created_at;
    if (log.created_at > group.lastSeen) {
      group.lastSeen = log.created_at;
      group.sample = sanitizeLog(log);
      group.appFrame = appFrame || group.appFrame;
      group.lastSeenBuild = readContextString(log.context, 'build_number');
    }
  }

  return [...grouped.values()].map((group) => ({
    ...group,
    affectedUsers: group.affectedUsers.size,
    screens: [...group.screens],
    environments: [...group.environments],
  }));
}

function fingerprint(message, stackTrace) {
  const normalizedMessage = message.replace(/\s+/g, ' ').slice(0, 180);
  const appFrame = firstAppFrame(stackTrace);
  return appFrame ? `${normalizedMessage}|${appFrame}` : normalizedMessage;
}

function firstAppFrame(stackTrace) {
  if (!stackTrace) return null;
  const match = String(stackTrace).match(/package:homesync_client\/[^\s)]+/);
  return match?.[0] || null;
}

function sanitizeLog(log) {
  return {
    id: log.id,
    created_at: log.created_at,
    level: log.level,
    message: log.message,
    stack_trace_head: String(log.stack_trace || '').split('\n').slice(0, 24).join('\n'),
    context: sanitizeValue(log.context),
    device_info: sanitizeValue(log.device_info),
  };
}

function readContextString(context, key) {
  const value = context && typeof context === 'object' ? context[key] : null;
  if (typeof value !== 'string') return null;
  const trimmed = value.trim();
  return trimmed || null;
}

function sanitizeValue(value) {
  if (Array.isArray(value)) return value.map(sanitizeValue);
  if (!value || typeof value !== 'object') return value;
  return Object.fromEntries(
    Object.entries(value)
      .filter(([key]) => !/email|token|jwt|secret|password|authorization/i.test(key))
      .map(([key, nested]) => [key, sanitizeValue(nested)])
  );
}

function severityRank(level) {
  if (level === 'critical') return 0;
  if (level === 'error') return 1;
  if (level === 'warning') return 2;
  return 3;
}

async function syncIssues(groups) {
  const rows = groups.map((group) => ({
    fingerprint: group.fingerprint,
    title: group.message.split('\n')[0].slice(0, 220),
    level: group.level,
    first_seen: group.firstSeen,
    last_seen: group.lastSeen,
    occurrences: group.count,
    affected_users: group.affectedUsers,
    sample_log_id: group.sample.id,
    sample_message: group.sample.message,
    sample_stack_trace_head: group.sample.stack_trace_head || null,
    app_frame: group.appFrame,
    screens: group.screens,
    environments: group.environments,
    first_seen_build: group.firstSeenBuild,
    last_seen_build: group.lastSeenBuild,
  }));

  const { error } = await supabase
    .from('error_issues')
    .upsert(rows, {
      onConflict: 'fingerprint',
      ignoreDuplicates: false,
    });

  if (error) {
    console.error(`Could not sync error_issues: ${error.message}`);
    process.exit(1);
  }
}

function printMarkdown(report) {
  const actuallySynced = report.synced && report.groups.length > 0;
  console.log(`# HomeSync Error Triage

Window: since ${report.since}
Auth mode: ${report.authMode}
Synced issues: ${actuallySynced ? 'yes' : 'no'}
Rows inspected: ${report.rawCount}

`);
  if (report.groups.length === 0) {
    console.log('No matching errors found.');
    if (report.authMode === 'anonymous') {
      console.log('');
      console.log('Note: this ran without an admin session. If production has logs, set HOMESYNC_ADMIN_EMAIL/HOMESYNC_ADMIN_PASSWORD or use the Supabase MCP playbook.');
    }
    return;
  }

  report.groups.forEach((group, index) => {
    console.log(`## ${index + 1}. ${group.level.toUpperCase()} x${group.count}`);
    console.log(`Affected users: ${group.affectedUsers}`);
    console.log(`First seen: ${group.firstSeen}`);
    console.log(`Last seen: ${group.lastSeen}`);
    if (group.appFrame) console.log(`Likely app frame: ${group.appFrame}`);
    console.log(`Message: ${group.message}`);
    console.log('');
    if (group.sample.stack_trace_head) {
      console.log('```text');
      console.log(group.sample.stack_trace_head);
      console.log('```');
    }
    console.log('');
  });
}
