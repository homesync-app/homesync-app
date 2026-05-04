# Supabase HomeSync Plugin

Local Codex plugin for the HomeSync Supabase project.

## Environment

This plugin does not store the Supabase personal access token in plugin files. It expects:

- `SUPABASE_PROJECT_REF=tfavamqszdkoeabpyxms`
- `SUPABASE_ACCESS_TOKEN=<your Supabase personal access token>`

The MCP URL is scoped to `tfavamqszdkoeabpyxms` and uses `read_only=true` by default.
Remove `&read_only=true` from `.mcp.json` only when you intentionally want write-capable MCP tools.

## Source

Supabase MCP docs: https://supabase.com/docs/guides/getting-started/mcp
