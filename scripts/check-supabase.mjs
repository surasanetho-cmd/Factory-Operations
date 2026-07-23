/**
 * Quick Supabase connectivity check.
 * Usage: node scripts/check-supabase.mjs
 */
import { readFileSync } from "node:fs";
import { resolve } from "node:path";

function loadEnvLocal() {
  const path = resolve(process.cwd(), ".env.local");
  const text = readFileSync(path, "utf8");
  const env = {};
  for (const line of text.split("\n")) {
    const trimmed = line.trim();
    if (!trimmed || trimmed.startsWith("#")) continue;
    const eq = trimmed.indexOf("=");
    if (eq === -1) continue;
    env[trimmed.slice(0, eq)] = trimmed.slice(eq + 1);
  }
  return env;
}

const env = loadEnvLocal();
const url = env.NEXT_PUBLIC_SUPABASE_URL;
const anonKey = env.NEXT_PUBLIC_SUPABASE_ANON_KEY;

if (!url || !anonKey) {
  console.error("Missing NEXT_PUBLIC_SUPABASE_URL or NEXT_PUBLIC_SUPABASE_ANON_KEY in .env.local");
  process.exit(1);
}

console.log("Project URL:", url);

const health = await fetch(`${url}/auth/v1/health`, {
  headers: { apikey: anonKey },
});
console.log("Auth health:", health.status, health.ok ? "OK" : "FAIL");

const rest = await fetch(`${url}/rest/v1/`, {
  headers: {
    apikey: anonKey,
    Authorization: `Bearer ${anonKey}`,
  },
});
console.log("REST API:", rest.status, rest.ok || rest.status === 404 ? "OK" : "FAIL");

const menus = await fetch(`${url}/rest/v1/auth_menu?select=id,label&limit=1`, {
  headers: {
    apikey: anonKey,
    Authorization: `Bearer ${anonKey}`,
    "Accept-Profile": "master",
  },
});
const menuBody = await menus.text();
console.log("Sample query (auth_menu):", menus.status, menuBody.slice(0, 120));

if (!health.ok) {
  process.exit(1);
}

console.log("\nSupabase connection looks good.");
