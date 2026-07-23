import { redirect } from "next/navigation";
import { LoginForm } from "@/components/auth/LoginForm";
import { createClient } from "@/lib/supabase/server";
import { getSupabaseEnvStatus } from "@/lib/supabase/env";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";

export default async function LoginPage() {
  const config = getSupabaseEnvStatus({ server: true });

  if (config.configured) {
    const supabase = await createClient();
    const {
      data: { user },
    } = await supabase.auth.getUser();
    if (user) redirect("/dashboard");
  }

  return (
    <div className="grid min-h-screen place-items-center p-6">
      <Card className="w-full max-w-md border-[var(--app-border)] bg-[rgba(26,34,44,0.92)] text-[var(--text)] shadow-2xl">
        <CardHeader>
          <CardTitle className="text-2xl">Factory Operations</CardTitle>
          <CardDescription className="text-[var(--text-muted)]">
            Sign in with Supabase Auth
          </CardDescription>
        </CardHeader>
        <CardContent className="grid gap-4">
          {!config.configured ? (
            <p className="text-sm text-[var(--danger)] m-0">
              Supabase env is missing on this deployment. Set{" "}
              <code>NEXT_PUBLIC_SUPABASE_URL</code> and{" "}
              <code>NEXT_PUBLIC_SUPABASE_ANON_KEY</code> on Vercel (Production + Preview), then{" "}
              <strong>Redeploy</strong>.
            </p>
          ) : (
            <>
              <LoginForm />
              <details className="text-xs text-[var(--text-muted)]">
                <summary className="cursor-pointer">ยัง login ไม่ได้ / ไม่รู้จัก account?</summary>
                <ul className="mt-2 space-y-1 pl-4 list-disc">
                  <li>
                    ระบบยังไม่มี user อัตโนมัติ — ต้องสร้างใน Supabase →{" "}
                    <strong>Authentication → Users → Add user</strong>
                  </li>
                  <li>
                    Demo (ถ้ามี): <code>admin@factory.local</code>
                  </li>
                  <li>
                    หลังสร้าง user แล้ว ให้ assign role admin ใน SQL Editor:{" "}
                    <code>select master.assign_role_by_email(&apos;your@email.com&apos;, &apos;admin&apos;);</code>
                  </li>
                  <li>
                    หรือรัน local:{" "}
                    <code>node scripts/provision-auth-user.mjs your@email.com &quot;password&quot; admin</code>
                  </li>
                </ul>
              </details>
            </>
          )}
        </CardContent>
      </Card>
    </div>
  );
}
