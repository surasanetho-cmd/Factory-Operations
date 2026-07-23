/**
 * Create or update a Supabase Auth user and assign a platform role.
 *
 * Usage:
 *   node scripts/provision-auth-user.mjs user@example.com "TempPassword123!" admin
 *
 * Requires in .env.local:
 *   NEXT_PUBLIC_SUPABASE_URL
 *   SUPABASE_SERVICE_ROLE_KEY
 */
import { readFileSync } from "node:fs";
import { resolve } from "node:path";

function loadEnvLocal() {
  const path = resolve(process.cwd(), ".env.local");
  const env = {};
  for (const line of readFileSync(path, "utf8").split("\n")) {
    const trimmed = line.trim();
    if (!trimmed || trimmed.startsWith("#")) continue;
    const eq = trimmed.indexOf("=");
    if (eq === -1) continue;
    env[trimmed.slice(0, eq)] = trimmed.slice(eq + 1);
  }
  return env;
}

const [emailArg, passwordArg, roleCodeArg = "admin"] = process.argv.slice(2);
const email = emailArg?.trim().toLowerCase();
const password = passwordArg;
const roleCode = roleCodeArg.trim().toLowerCase();

if (!email || !password) {
  console.error(
    'Usage: node scripts/provision-auth-user.mjs <email> "<password>" [roleCode]',
  );
  process.exit(1);
}

const env = loadEnvLocal();
const baseUrl = env.NEXT_PUBLIC_SUPABASE_URL?.trim();
const serviceKey = env.SUPABASE_SERVICE_ROLE_KEY?.trim();

if (!baseUrl || !serviceKey) {
  console.error("Missing NEXT_PUBLIC_SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY in .env.local");
  process.exit(1);
}

const adminHeaders = {
  Authorization: `Bearer ${serviceKey}`,
  apikey: serviceKey,
  "Content-Type": "application/json",
};

const masterHeaders = {
  ...adminHeaders,
  Accept: "application/json",
  "Accept-Profile": "master",
  "Content-Profile": "master",
};

async function findUserByEmail(targetEmail) {
  const res = await fetch(
    `${baseUrl}/auth/v1/admin/users?email=${encodeURIComponent(targetEmail)}`,
    { headers: adminHeaders },
  );
  if (!res.ok) {
    throw new Error(`List users failed (${res.status}): ${await res.text()}`);
  }
  const data = await res.json();
  const users = data.users ?? data;
  return Array.isArray(users) ? users.find((u) => u.email?.toLowerCase() === targetEmail) : null;
}

async function createUser(targetEmail, targetPassword) {
  const res = await fetch(`${baseUrl}/auth/v1/admin/users`, {
    method: "POST",
    headers: adminHeaders,
    body: JSON.stringify({
      email: targetEmail,
      password: targetPassword,
      email_confirm: true,
      user_metadata: {
        display_name: targetEmail.split("@")[0],
      },
    }),
  });
  if (!res.ok) {
    throw new Error(`Create user failed (${res.status}): ${await res.text()}`);
  }
  return res.json();
}

async function updatePassword(userId, targetPassword) {
  const res = await fetch(`${baseUrl}/auth/v1/admin/users/${userId}`, {
    method: "PUT",
    headers: adminHeaders,
    body: JSON.stringify({ password: targetPassword, email_confirm: true }),
  });
  if (!res.ok) {
    throw new Error(`Update password failed (${res.status}): ${await res.text()}`);
  }
  return res.json();
}

async function getProfileId(targetEmail, attempts = 5) {
  for (let i = 0; i < attempts; i += 1) {
    const res = await fetch(
      `${baseUrl}/rest/v1/user_profile?select=id,email&email=eq.${encodeURIComponent(targetEmail)}&deleted_at=is.null`,
      { headers: masterHeaders },
    );
    if (!res.ok) {
      throw new Error(`Fetch profile failed (${res.status}): ${await res.text()}`);
    }
    const profiles = await res.json();
    if (profiles.length) return profiles[0].id;
    await new Promise((r) => setTimeout(r, 1000));
  }
  throw new Error(
    "user_profile not found. Auth user exists but profile trigger may be missing — check Supabase migrations.",
  );
}

async function assignRole(targetEmail, targetRoleCode) {
  const profileId = await getProfileId(targetEmail);

  const roleRes = await fetch(
    `${baseUrl}/rest/v1/role?select=id&code=eq.${encodeURIComponent(targetRoleCode)}&deleted_at=is.null`,
    { headers: masterHeaders },
  );
  const roles = await roleRes.json();
  if (!roles.length) throw new Error(`Role not found: ${targetRoleCode}`);

  const existingRes = await fetch(
    `${baseUrl}/rest/v1/user_role?select=id&user_id=eq.${profileId}&role_id=eq.${roles[0].id}&deleted_at=is.null`,
    { headers: masterHeaders },
  );
  const existing = await existingRes.json();
  if (existing.length) {
    console.log("Role already assigned.");
    return;
  }

  const assignRes = await fetch(`${baseUrl}/rest/v1/user_role`, {
    method: "POST",
    headers: {
      ...masterHeaders,
      Prefer: "return=representation",
    },
    body: JSON.stringify({
      user_id: profileId,
      role_id: roles[0].id,
      is_active: true,
    }),
  });

  if (!assignRes.ok) {
    throw new Error(`Assign role failed (${assignRes.status}): ${await assignRes.text()}`);
  }

  console.log("Assigned role", targetRoleCode, "to", targetEmail);
}

console.log("Supabase:", baseUrl);
console.log("Email:", email);
console.log("Role:", roleCode);

let user = await findUserByEmail(email);
if (user) {
  console.log("User exists:", user.id);
  await updatePassword(user.id, password);
  console.log("Password updated.");
} else {
  user = await createUser(email, password);
  console.log("User created:", user.id ?? user.user?.id);
}

await assignRole(email, roleCode);

console.log("\nDone. Sign in at /login with this email and password.");
