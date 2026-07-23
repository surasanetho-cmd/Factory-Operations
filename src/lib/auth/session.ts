import { createClient } from "@/lib/supabase/server";
import type { SessionContext } from "@/lib/auth/types";

export async function getSessionContext(): Promise<SessionContext | null> {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return null;

  const { data, error } = await supabase.rpc("rpc_auth_session_context");
  if (error) {
    console.error("rpc_auth_session_context", error.message);
    return {
      authenticated: true,
      profile: null,
      roles: [],
      permissions: [],
      menus: [],
      message: error.message,
    };
  }
  return data as SessionContext;
}

export async function requirePermission(code: string) {
  const ctx = await getSessionContext();
  if (!ctx?.permissions?.includes(code) && !ctx?.roles?.includes("admin")) {
    return null;
  }
  return ctx;
}
