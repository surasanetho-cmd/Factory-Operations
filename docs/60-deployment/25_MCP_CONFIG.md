# 25 — MCP Config

**Product:** Smart-Factory Manufacturing Platform  
**Purpose:** Document expected Model Context Protocol servers for AI agents working on this repo

---

## 1. Intent

MCP servers give agents safe, structured access to platforms used by Smart-Factory. Prefer MCP over ad-hoc scraping when available.

---

## 2. Expected Servers

| Server | Use |
|--------|-----|
| **Supabase** | Schema inspection, SQL advisors, migrations guidance, RLS review |
| **Vercel** | Deployments, logs, project env documentation, docs search |
| **cursor-cloud** | Cloud agent run diagnostics (when running as cloud agent) |

Additional servers may be added via Decision Log.

---

## 3. Configuration Notes

1. Project-level `.mcp.json` (when introduced) should point to official server URLs.
2. Supabase MCP requires OAuth / project auth by the developer — agents must not invent tokens.
3. Never expose service role keys through MCP tool arguments in chat logs.
4. Verify Supabase feature behavior against current docs (platform changes frequently).

---

## 4. Agent Usage Rules

- Discover tool schemas before calling (`GetMcpTools` / equivalent).
- Use Supabase MCP for database questions once linked; keep dictionary docs authoritative for intended design.
- Use Vercel MCP for deployment troubleshooting after app exists.
- Documentation phase: MCP is optional; docs remain primary.

---

## 5. Local Future File (not created in docs-only phase)

Target:

```json
{
  "mcpServers": {
    "supabase": { "url": "https://mcp.supabase.com/mcp" },
    "vercel": { "url": "https://mcp.vercel.com" }
  }
}
```

Exact shape follows current Cursor MCP documentation when scaffolding begins.

---

## Related Documents

- [03_TECH_STACK.md](../20-architecture/03_TECH_STACK.md)
- [23_CURSOR_RULES.md](../00-governance/23_CURSOR_RULES.md)
- [21_DEPLOYMENT_STANDARD.md](21_DEPLOYMENT_STANDARD.md)
