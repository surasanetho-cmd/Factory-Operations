import { NextResponse } from "next/server";
import { getSupabaseEnvStatus } from "@/lib/supabase/env";

export async function GET() {
  const status = getSupabaseEnvStatus({ server: true });

  if (!status.configured) {
    return NextResponse.json(
      {
        ok: false,
        configured: false,
        message:
          "Missing NEXT_PUBLIC_SUPABASE_URL or NEXT_PUBLIC_SUPABASE_ANON_KEY. Add them on Vercel and redeploy.",
      },
      { status: 503 },
    );
  }

  try {
    const env = await import("@/lib/supabase/env").then((m) => m.getSupabaseEnv({ server: true }));
    const health = await fetch(`${env.url}/auth/v1/health`, {
      headers: { apikey: env.anonKey },
      cache: "no-store",
    });

    return NextResponse.json({
      ok: health.ok,
      configured: true,
      projectRef: status.projectRef,
      authHealth: health.status,
      hint: health.ok
        ? "Supabase reachable from Vercel."
        : "Env is set but Supabase auth health check failed.",
    });
  } catch {
    return NextResponse.json(
      {
        ok: false,
        configured: true,
        projectRef: status.projectRef,
        message:
          "Cannot reach Supabase from Vercel. Check project URL, paused project, or network.",
      },
      { status: 503 },
    );
  }
}
