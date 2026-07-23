/**
 * Shared env helpers for Supabase client / auth.
 * Public keys must use NEXT_PUBLIC_* for browser bundles (build-time).
 * Server code may also read SUPABASE_URL / SUPABASE_ANON_KEY at runtime on Vercel.
 */

type SupabaseEnv = {
  url: string;
  anonKey: string;
};

function readSupabaseEnv(serverFallback = false): SupabaseEnv | null {
  const url =
    process.env.NEXT_PUBLIC_SUPABASE_URL?.trim() ||
    (serverFallback ? process.env.SUPABASE_URL?.trim() : undefined);
  const anonKey =
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY?.trim() ||
    (serverFallback ? process.env.SUPABASE_ANON_KEY?.trim() : undefined);

  if (!url || !anonKey) {
    return null;
  }

  return { url, anonKey };
}

export function getSupabaseEnv(options?: { server?: boolean }) {
  const env = readSupabaseEnv(options?.server ?? false);

  if (!env) {
    throw new Error(
      "Missing Supabase env. Set NEXT_PUBLIC_SUPABASE_URL and NEXT_PUBLIC_SUPABASE_ANON_KEY on Vercel (Production + Preview), then redeploy.",
    );
  }

  return env;
}

export function getSupabaseEnvStatus(options?: { server?: boolean }) {
  const env = readSupabaseEnv(options?.server ?? true);
  if (!env) {
    return { configured: false as const };
  }

  return {
    configured: true as const,
    url: env.url,
    projectRef: env.url.match(/https:\/\/([^.]+)\.supabase\.co/)?.[1] ?? null,
  };
}
